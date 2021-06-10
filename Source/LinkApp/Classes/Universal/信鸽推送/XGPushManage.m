//
//  XGPushManage.m
//  TenextCloud
//
//

#import "XGPushManage.h"
#import <UserNotifications/UserNotifications.h>
#import "XGPush.h"
#import "XGPushPrivate.h"  /// 如果是海外集群需要导入此头文件
#import "MGJRouter.h"
#import "TIoTFeedBackViewController.h"
#import "TIoTAppConfig.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCUIManage.h"

@interface XGPushManage ()<XGPushDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic, copy) NSString *deviceToken;

@end

@implementation XGPushManage

+ (id)sharedXGPushManage{
    static XGPushManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (void)startPushService{
    
#ifdef DEBUG
    [XGPush.defaultManager setEnableDebug:YES];
#endif
    [XGPush.defaultManager stopXGNotification];
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    NSString *regionID = [TIoTCoreUserManage shared].userRegionId;
    if ([regionID isEqualToString:@"1"]) {
        [XGPush.defaultManager startXGWithAccessID:model.XgAccessId.intValue accessKey:model.XgAccessKey delegate:self];
    }else {
        
        [XGPush.defaultManager configureClusterDomainName:@"tpns.hk.tencent.com"];
        [XGPush.defaultManager startXGWithAccessID:model.XgUSAAccessId.intValue accessKey:model.XgUSAAccessKey delegate:self];
    }
    
    if (XGPush.defaultManager.xgApplicationBadgeNumber > 0) {
        [XGPush.defaultManager setXgApplicationBadgeNumber:0];
    }
    
}

- (void)stopPushService{
    [XGPush.defaultManager stopXGNotification];
    
    [[TIoTRequestObject shared] post:@"AppUnBindXgToken" Param:@{@"Token":self.deviceToken?:@"",@"Platform":@"ios",@"Agent":@"ios"} success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)reportXGNotificationInfo:(nonnull NSDictionary *)info{
}

- (void)bindPushToken
{
    if (self.deviceToken && [TIoTCoreUserManage shared].accessToken) {
        
        [[TIoTRequestObject shared] post:@"AppBindXgToken" Param:@{@"Token":self.deviceToken,@"Platform":@"ios",@"Agent":@"ios"} success:^(id responseObject) {
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
}

#pragma mark - XGPushDelegate

- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken error:(nullable NSError *)error{
    //绑定信鸽
    self.deviceToken = xgToken;
    WCLog(@"信鸽推送deviceToken：%@------xgToken：%@",deviceToken, xgToken);
    [self bindPushToken];
}

// iOS 10 新增 API 无论APP当前在前台还是后台点击通知都会走该 API
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    WCLog(@"-普通推送-responseNOtification_requestContent_info==%@--\n custom-%@", response.notification.request.content.userInfo, response.notification.request.content.userInfo[@"custom"]);
    
    [MGJRouter openURL:@"TIoT://TPNSPushManage/feedback" withUserInfo:@{@"customMessageContent":[NSString jsonToObject:response.notification.request.content.userInfo[@"custom"]]} completion:nil];
    
    completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

 /// 统一收到通知消息的回调（静默消息也调用此方法）
//- (void)xgPushDidReceiveRemoteNotification:(id)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler {
//
//    if (@available(iOS 10.0, *)) {
//        if ([notification isKindOfClass:[UNNotification class]]) {
//            [[XGPush defaultManager] reportXGNotificationInfo:((UNNotification *)notification).request.content.userInfo];
//            completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
//        }
//    } else {
//        [[XGPush defaultManager] reportXGNotificationInfo:(NSDictionary *)notification];
//        completionHandler(UIBackgroundFetchResultNewData);
//    }
//}

/// 统一收到通知消息的回调
/// @param notification 消息对象
/// @param completionHandler 完成回调
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息msgtype为2则代表静默消息
/// notification消息对象说明：有2种类型NSDictionary和UNNotification具体解析参考示例代码
- (void)xgPushDidReceiveRemoteNotification:(nonnull id)notification withCompletionHandler:(nullable void (^)(NSUInteger))completionHandler {
    //    NSLog(@"recieve message:%@", notification);
    if ([notification isKindOfClass:[NSDictionary class]]) {
        NSLog(@"notification ==%@",notification);
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([notification isKindOfClass:[UNNotification class]]) {
                NSLog(@"xg info :%@", ((UNNotification *)notification).request.content.userInfo);
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
        
        //信鸽过来，查看设备是否要呼叫 检测是否TRTC设备，是否在呼叫中
         
        /*NSDictionary *userInfo = ((UNNotification *)notification).request.content.userInfo;
        NSString *custom_content = userInfo[@"custom"];
        
        TIOTtrtcPayloadParamModel *params = [TIOTtrtcPayloadParamModel yy_modelWithJSON:custom_content];
        if (params.audio_call_status.intValue == 1 || params.video_call_status.intValue == 1) {//TRTC设备需要通话，开始通话,防止不是trtc设备的通知
            
            [[TIoTTRTCUIManage sharedManager] preEnterRoom:params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                
                [MBProgressHUD showError:reason];
            }];
        }*/
            
    }
}

@end
