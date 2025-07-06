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
                  extension:(NSString *)extension
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
)


RCT_EXTERN_METHOD(supportedEvents)


@end



