
#import <Cordova/CDV.h>
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface smartlink : CDVPlugin {
    // Member variables go here.
}

- (void)getCurrentSSID:(CDVInvokedUrlCommand*)command;
@end

@implementation smartlink

- (void)startSmartLink:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult *pluginResult = nil;
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@",[info  allKeys]);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }

    if(ssid!=nil && [ssid length] > 0){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ssid];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
