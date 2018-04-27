
#import <Cordova/CDV.h>
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import "smartlinklib_7x.h"
#import <SystemConfiguration/CaptiveNetwork.h>

// V 7.2.00 for ipv6 compatible
#define APP_VERSION         @"V 7.2.01"
HFSmartLink * smtlk;
@interface smartlink : CDVPlugin {
    // Member variables go here.
}
@property (nonatomic, strong) NSTimer *paintingTimer;

- (void)startSmartLink:(CDVInvokedUrlCommand*)command;
//-(void)getSSid;
- (void)getCurrentSSID:(CDVInvokedUrlCommand*)command;
@end

@implementation smartlink{
    
    BOOL isconnecting;
    CDVPluginResult *pluginResult;
    CDVInvokedUrlCommand *publicCommand;
    NSDictionary  *ret;
    
    NSString *errorMessage;
}

- (void)startSmartLink:(CDVInvokedUrlCommand*)command
{
    
    // Do any additional setup after loading the view, typically from a nib.
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    smtlk.waitTimers=30;
    isconnecting = false;
    NSString *ssid=command.arguments[0];
    NSString *pwd=command.arguments[1];
    
    publicCommand=command;
    [smtlk startWithSSID:ssid Key:pwd withV3x:true  processblock: ^(NSInteger pro) {
        
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        ret =
        [NSDictionary dictionaryWithObjectsAndKeys:
         dev.mac, @"Mac",
         dev.ip, @"ModuleIPc",
         //         @"",@"Mid",
         //         @"",@"Info",
         //         @"",@"error",
         nil];
        isconnecting  = false;
    } failBlock:^(NSString *failmsg) {
        
    } endBlock:^(NSDictionary *deviceDic) {
        //  isconnecting  = false;
    }];
    [self startPainting ];
    
}


- (void)getSSid:(CDVInvokedUrlCommand*)command
{
    
    NSDictionary *ifs;
    NSString *ssid;
    UIAlertView *alert;
    ifs = [self fetchSSIDInfo];
    ssid = [ifs objectForKey:@"SSID"];
    if (ssid!= nil)
    {
         CDVPluginResult *pluginResult = nil;
        if(ssid!=nil && [ssid length] > 0){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ssid];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else
    {
        alert= [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请连接Wi-Fi"] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        alert.delegate=self;
        [alert show];
    }
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}



// 定时器执行的方法
- (void)paint:(NSTimer *)paramTimer{
    
    NSLog(@"定时器执行的方法");
    
    
    if(errorMessage!=nil){
        [self stopPainting];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:publicCommand.callbackId];
    }
    if(ret!=nil){
        [self stopPainting];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:ret];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:publicCommand.callbackId];
        
    }
}

- (void) startPainting{
    //    seconds：需要调用的毫秒数
    //    target：调用方法需要发送的对象。即：发给谁
    //    userInfo：发送的参数
    //    repeats：指定定时器是否重复调用目标方
    // 定义一个NSTimer
    // 定义将调用的方法
    SEL selectorToCall = @selector(paint:);
    // 为SEL进行 方法签名
    NSMethodSignature *methodSignature =[[self class] instanceMethodSignatureForSelector:selectorToCall];
    // 初始化NSInvocation
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:selectorToCall];
    self.paintingTimer = [NSTimer timerWithTimeInterval:1.0
                                             invocation:invocation
                                                repeats:YES];
    
    // 当需要调用时,可以把计时器添加到事件处理循环中
    [[NSRunLoop currentRunLoop] addTimer:self.paintingTimer forMode:NSDefaultRunLoopMode];
}
// 停止定时器
- (void) stopPainting{
    if (self.paintingTimer != nil){
        // 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
        [self.paintingTimer invalidate];
    }
}
@end
