//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//

#import "TIoTCoreAppEnvironment.h"

NSString *const TIoTLinkKitShortVersionString = @"1.0.3";

@interface TIoTCoreAppEnvironment ()
@end

@implementation TIoTCoreAppEnvironment

+ (instancetype)shareEnvironment{
    
    static TIoTCoreAppEnvironment *_inst ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[self alloc] init];
    });
    return _inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configBuglySDKInfos];
        [self setEnvironment];
    }
    return self;
}

- (void)setEnvironment {

    //公版&开源体验版使用  当在 app-config.json 中配置 TencentIotLinkAppkey TencentIotLinkAppSecret 后，将自动切换为 OEM 版本。
    self.studioBaseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
    self.studioBaseUrlForLogined = @"https://iot.cloud.tencent.com/api/studioapp/tokenapi";
    
    //天气公版和开源版
    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if ([bundleId containsString:@"opensource"]) {
        self.weatherNowHost = @"https://devapi.heweather.net/v7/weather/now?";
        self.weatherIndicesHost = @"https://devapi.qweather.com/v7/indices/1d?";
    }else {
        self.weatherNowHost = @"https://api.heweather.net/v7/weather/now?";
        self.weatherIndicesHost = @"https://api.qweather.com/v7/indices/1d?";
    }
    
    self.weatherCityHost = @"https://geoapi.qweather.com/v2/city/lookup?";
    
    
    
    //OEM App 使用
    self.oemAppApi = @"https://iot.cloud.tencent.com/api/exploreropen/appapi"; // 需要在 TIoTAppEnvironment.m 的 -selectEnvironmentType: 中替换为自建后台服务地址。
    self.oemTokenApi = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";  // 可安全在设备端调用。
    
    //Video
    self.videoHostApi = @"https://iotvideo.tencentcloudapi.com";
    self.cloudSecretId = @"";
    self.cloudSecretKey = @"";
    self.cloudProductId = @"";
    
    self.deviceRegion = @"ap-guangzhou";
    
    //explore
    self.exploreHostApi = @"https://iotexplorer.tencentcloudapi.com";
    
//    self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";        //长连接通信 https://cloud.tencent.com/document/product/1081/40792
    self.wsUrl = @"wss://iot.cloud.tencent.com/iotstudio_v2_weapp_1";
    self.h5Url = @"https://iot.cloud.tencent.com/explorer-h5";
    self.deviceDetailH5URL = @"https://iot.cloud.tencent.com/scf/h5panel";
    self.bluetoothSearchH5URL = @"https://iot.cloud.tencent.com/scf/h5panel/bluetooth-search";
    self.wxShareType = 0;
    self.action = @"YunApi";
    self.appKey = @"";
    self.appSecret = @"";
    self.platform = @"iOS";
}

- (void)configBuglySDKInfos {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * componentId = @"3c26077475";
        NSString * version = TIoTLinkKitShortVersionString;
        if (componentId && version) {
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
            // 读取已有信息并记录
            NSDictionary * dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"BuglySDKInfos"];
            if (dict) {
                [dictionary addEntriesFromDictionary:dict];
            }
            // 添加当前组件的唯⼀一标识和版本
            [dictionary setValue:version forKey:componentId];
            // 写⼊入更更新的信息
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:dictionary] forKey:@"BuglySDKInfos"];
        }
    });
}

@end
