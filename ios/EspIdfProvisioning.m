#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#endif

@interface RCT_EXTERN_MODULE(EspIdfProvisioning, RCTEventEmitter)

RCT_EXTERN_METHOD(getBleDevices:(NSString *)prefix
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(connectBleDevice:(NSString *)deviceAddress
                 security:(NSInteger *)security
                 deviceProofOfPossession:(NSString *)deviceProofOfPossession
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(createDevice:(NSString *)deviceName
                  devicePassword:(NSString *)devicePassword
                  deviceProofOfPossession:(NSString *)deviceProofOfPossession
                  successCallback:(RCTResponseSenderBlock *)successCallback)
RCT_EXTERN_METHOD(scanWifiList:
  (RCTPromiseResolveBlock)resolve
  withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(provision:(NSString *)ssid
                passPhrase:(NSString *)passPhrase
                withResolver:(RCTPromiseResolveBlock)resolve
                withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(disconnectBLEDeviceIfConnected)

+ (BOOL) requiresMainQueueSetup {
  return YES;
}

@end
