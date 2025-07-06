#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RnWebim, RCTEventEmitter)


RCT_EXTERN_METHOD(resume:
                  (NSDictionary *)params
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(pause:
                  (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(destroy:
                  (Bool *)clearData
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(sendMessage:
                  (NSString *)message
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(getLastMessages:
                  (nonnull NSNumber *)limit
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(getNextMessages:
                  (nonnull NSNumber *)limit
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
)


RCT_EXPORT_METHOD(sendFile:(NSString *)fileURL 
                  mimeType:(NSString *)mimeType 
                  fileName:(NSString *)fileName 
                  messageId:(NSString *)messageId 
                  resolver:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject) 
{
    NSURL *url = [NSURL URLWithString:fileURL];
    NSData *fileData = [NSData dataWithContentsOfURL:url];
    
    if (!fileData) {
        reject(@"FILE_ERROR", @"Could not read file", nil);
        return;
    }
    
    [WEBIM sendFileWithData:fileData
                   mimeType:mimeType
                   fileName:fileName
                  messageId:messageId
                 completion:^(NSError * _Nullable error) {
        if (error) {
            reject(@"SEND_ERROR", error.localizedDescription, error);
        } else {
            resolve(@(YES));
        }
    }];
}


RCT_EXTERN_METHOD(supportedEvents)


@end



