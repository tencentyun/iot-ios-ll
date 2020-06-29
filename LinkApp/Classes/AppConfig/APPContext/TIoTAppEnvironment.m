//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTAppEnvironment.h"
#import "ESP_NetUtil.h"
#import "XGPushManage.h"
#import "TIoTAppConfig.h"

@interface TIoTAppEnvironment ()

@end

@implementation TIoTAppEnvironment

+ (instancetype)shareEnvironment{
    
    static TIoTAppEnvironment *_environment ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _environment = [TIoTAppEnvironment new];
    });
    return _environment;
}

- (void)selectEnvironmentType:(WCAppEnvironmentType)type{
    self.type = type;
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    
    switch (type) {
        case WCAppEnvironmentTypeRelease:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.signatureBaseUrlBeforeLogined = @"https://iot.cloud.tencent.com/api/exploreropen/appapi";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.h5Url = @"https://iot.cloud.tencent.com/explorer-h5";
            self.wxShareType = 0;
            self.action = @"YunApi";
            self.appKey = model.TencentIotLinkAppkey;
            self.appSecret = model.TencentIotLinkAppSecret;
            self.platform = @"iOS";
        }
            break;
        case WCAppEnvironmentTypeDebug:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.signatureBaseUrlBeforeLogined = @"https://iot.cloud.tencent.com/api/exploreropen/appapi";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.h5Url = @"https://iot.cloud.tencent.com/explorer-h5";
            self.wxShareType = 1;
            self.action = @"YunApi";
            self.appKey = model.TencentIotLinkAppkey;
            self.appSecret = model.TencentIotLinkAppSecret;
            self.platform = @"iOS";
        }
            break;
        default:
            break;
    }
    
}

- (void)loginOut {
//    [[XGPushManage sharedXGPushManage] stopPushService];
    [HXYNotice addLoginOutPost];
    [[TIoTUserManage shared] clear];
    
}

@end
