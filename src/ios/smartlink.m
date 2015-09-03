
#import <Cordova/CDV.h>
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface smartlink : CDVPlugin {
    // Member variables go here.
 
}

- (void)startSmartLink:(CDVInvokedUrlCommand*)command;
//-(void)getSSid;
- (void)getCurrentSSID:(CDVInvokedUrlCommand*)command;
@end

@implementation smartlink{
HFSmartLink * smtlk;
BOOL isconnecting;
     CDVPluginResult *pluginResult;
}

- (void)startSmartLink:(CDVInvokedUrlCommand*)command
{
    // Do any additional setup after loading the view, typically from a nib.
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    isconnecting = false;
    NSString *ssid=command.arguments[0];
    NSString *pwd=command.arguments[1];
   

    
    [smtlk startWithKey:pwd processblock:^(NSInteger process) {
       // self.progress.progress = process/18.0;
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
      NSDictionary  *ret =
        [NSDictionary dictionaryWithObjectsAndKeys:
         dev.mac, @"mac",
        dev.ip, @"ip",
         nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:ret];
//        [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
    } failBlock:^(NSString *failmsg) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:failmsg];
        } endBlock:^(NSDictionary *deviceDic) {
        isconnecting  = false;
    }];


}
//- (void)getSSid
//{
//    BOOL wifiOK= FALSE;
//    NSDictionary *ifs;
//    NSString *ssid;
//      if (!wifiOK)
//    {
//        ifs = [self fetchSSIDInfo];
//        ssid = [ifs objectForKey:@"SSID"];
//        if (ssid!= nil)
//        {
//            wifiOK= TRUE;
//             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ssid];
//            
//        }
//        else
//        {
//             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"请链接网络"];
//        }
//    }
//}
//
//- (id)fetchSSIDInfo {
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    NSLog(@"Supported interfaces: %@", ifs);
//    id info = nil;
//    for (NSString *ifnam in ifs) {
//        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSLog(@"%@ => %@", ifnam, info);
//        if (info && [info count]) { break; }
//    }
//    return info;
//}

- (void)getSSid:(CDVInvokedUrlCommand*)command
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
