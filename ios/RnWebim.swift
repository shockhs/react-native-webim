// RnWebim.swift

import Foundation
import WebimMobileSDK

@objc(RnWebim)
class RnWebim : RCTEventEmitter  {
    
    private var jsPromiseResolver: RCTPromiseResolveBlock? = nil;
    private var jsPromiseRejecter: RCTPromiseRejectBlock? = nil;
    private var utils: Utils? = nil;
    private var session: WebimSession? = nil;
    private var tracker: MessageTracker? = nil;
    private var messageListener: RnWebimMessageListener? = nil;
    
     override init() {
        super.init()
        EventEmitter.sharedInstance.registerEventEmitter(eventEmitter: self)
        utils = Utils();
        messageListener = RnWebimMessageListener(utils: utils!);
     }
    
    @objc open override func supportedEvents() -> [String] {
        return EventEmitter.sharedInstance.allEvents
    }
    
    
    func build(
        accountName: String, location: String, userFields: String?) -> Void {
        do {
            let logger = RnWebimLogger();
            
          
            
            var builder = Webim.newSessionBuilder().set(accountName: accountName).set(location: location).set(webimLogger: logger, verbosityLevel: SessionBuilder.WebimLoggerVerbosityLevel.verbose)
            
            if (userFields != nil){
                builder = builder.set(visitorFieldsJSONString: userFields!);
            }
            
            session = try builder.build();
        } catch let error {
            NSLog(error.localizedDescription)
        }
             
    }
    
    @objc
    func resume(
        _ params: NSDictionary?,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
            
            let accountName = params?.value(forKey: "accountName");
            let location = params?.value(forKey: "location");
            let userFields = params?.value(forKey: "userFields");
            
            if (self.session == nil){
                self.build(accountName: accountName as! String, location: location as! String, userFields: userFields as? String);
            }
            
            if (self.session == nil) {
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error","Unable to build session",nil)
                }
            } else {
                
                    do{
                        try self.session!.resume();
                        try self.session!.getStream().startChat();
                        try self.session!.getStream().setChatRead();
                        self.tracker = try self.session!.getStream().newMessageTracker(messageListener: self.messageListener!);
                        
                        if (self.jsPromiseResolver != nil) {
                            self.jsPromiseResolver!(String(format: "since ok"))
                        }
                           
                        
                    }catch let error{
                        if (self.jsPromiseRejecter != nil) {
                            self.jsPromiseRejecter!("error","Unable to start session: \(error.localizedDescription)", nil)
                        }
                    }
            }
        }
    }
    
    @objc
    func pause(
        _ resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
          
            if (self.session == nil){
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error","Unable to find session", nil)
                }
            } else {
                do{
                    try self.session?.pause()
                    if (self.jsPromiseResolver != nil) {
                        self.jsPromiseResolver!("success")
                    }
                }catch let error{
                    if (self.jsPromiseRejecter != nil) {
                        self.jsPromiseRejecter!("error","Unable to pause session: \(error.localizedDescription)", nil)
                    }
                }
            }
        }
       
    }
    
    @objc
    func destroy(
        _ clearData: Bool,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
          
            if (self.session != nil){
                do {
                    try self.session?.getStream().closeChat()
                    try self.tracker?.destroy()
                    
                    if (clearData){
                        try self.session?.destroyWithClearVisitorData()
                    } else {
                        try self.session?.destroy()
                    }
                    
                    self.session = nil;
                }
                catch let error{
                    if (self.jsPromiseRejecter != nil) {
                        self.jsPromiseRejecter!("error","Unable to close session: \(error.localizedDescription)", nil)
                    }
                }
            }
            
            if (self.jsPromiseResolver != nil) {
                self.jsPromiseResolver!(nil)
            }
        }
       
    }
    
    
    @objc
    func sendMessage(
        _ message: NSString,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
          
            do {
                try self.session?.getStream().send(message: message as String);
                if (self.jsPromiseResolver != nil) {
                    self.jsPromiseResolver!("success")
                }
            }catch let error{
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error","Send message error: \(error.localizedDescription)", nil)
                }
            }
        }
       
    }

    @objc
    func sendFile(
        _ fileUri: NSString,
        fileName: NSString,
        mimeType: NSString,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
            
            do {
                // Validate file existence and size
                var filePath = fileUri as String;
                let fileManager = FileManager.default;
                if !fileManager.fileExists(atPath: filePath) {
                    throw NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found"]);
                }
                
                // Check file size (e.g., 10MB limit)
                let attributes = try fileManager.attributesOfItem(atPath: filePath);
                if let fileSize = attributes[.size] as? Int64, fileSize > 10 * 1024 * 1024 {
                    throw NSError(domain: "FileError", code: -2, userInfo: [NSLocalizedDescriptionKey: "File size exceeded"]);
                }
                
                // Validate MIME type (example: allow images and PDFs)
                let allowedMimeTypes = ["image/jpeg", "image/png", "application/pdf"];
                if !allowedMimeTypes.contains(mimeType as String) {
                    throw NSError(domain: "FileError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Type not allowed"]);
                }
                
                
                if !filePath.hasPrefix("file://") {
                    filePath = "file://" + filePath
                }
                guard let url = URL(string: filePath) else {
                    throw NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid file URL"])
                }
                
                let fileData = try Data(contentsOf: url)
                
                // Assuming the session.getStream() has a sendFile method
                // Adjust the method signature based on the actual WebIM SDK
                try self.session?.getStream().send(file: fileData, filename: fileName as String, mimeType: mimeType as String, completionHandler: nil);
                
                if (self.jsPromiseResolver != nil) {
                    self.jsPromiseResolver!("success");
                }
            } catch let error {
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error", "Send file error: \(error.localizedDescription)", nil);
                }
            }
        }
    }
    
    @objc
    func getLastMessages(
        _ limit: NSNumber,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
          
            do{
                try self.tracker?.getLastMessages(byLimit: Int(limit)) {
                    (messages) in
                        if (self.jsPromiseResolver != nil) {
                            self.jsPromiseResolver!(Utils.messagesToJson(messages: messages))
                        }
                }
            }catch let error{
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error","Unable to get last messages: \(error.localizedDescription)", nil)
                }
            }
        }
       
    }
    
    @objc
    func getNextMessages(
        _ limit: NSNumber,
        withResolver resolve: @escaping RCTPromiseResolveBlock,
        withRejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async {
            self.jsPromiseResolver = resolve;
            self.jsPromiseRejecter = reject;
          
            do{
                try self.tracker?.getNextMessages(byLimit: Int(limit)) {
                    (messages) in
                        if (self.jsPromiseResolver != nil) {
                            self.jsPromiseResolver!(Utils.messagesToJson(messages: messages))
                        }
                }
            }catch let error{
                if (self.jsPromiseRejecter != nil) {
                    self.jsPromiseRejecter!("error","Unable to get next messages: \(error.localizedDescription)", nil)
                }
            }
        }
       
    }
}

