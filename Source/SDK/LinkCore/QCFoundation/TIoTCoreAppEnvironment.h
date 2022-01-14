//
//  XDPAppEnvironment.h
//  SEEXiaodianpu
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TIoTCoreAppEnvironment : NSObject

+ (instancetype)shareEnvironment;


/**
 video 云
 */
@property (nonatomic, copy) NSString *videoHostApi;

/**
  云用户身份标识
 */
@property (nonatomic, copy) NSString *cloudSecretId;

/**
 云用户身身份沿验证
 */
@property (nonatomic, copy) NSString *cloudSecretKey;

/**
 注册产品ID
 */
@property (nonatomic, copy) NSString *cloudProductId;

/**
 explore 云
 */
@property (nonatomic, copy) NSString *exploreHostApi;

/**
 未登录baseurl
 */
@property (nonatomic , copy) NSString *oemAppApi;

/**
 已登录baseurl
 */
@property (nonatomic , copy) NSString *oemTokenApi;

/**
 未登录baseurl,公版&开源体验版使用
 */
@property (nonatomic , copy) NSString *studioBaseUrl;

/**
 已登录baseurl,公版&开源体验版使用
 */
@property (nonatomic , copy) NSString *studioBaseUrlForLogined;

/**
长连接
*/
@property (nonatomic , copy) NSString *wsUrl;

/**
h5
*/
@property (nonatomic , copy) NSString *h5Url;

/**
 设备详情h5链接
 */
@property (nonatomic, copy) NSString *deviceDetailH5URL;

/**
 打开 H5 蓝牙搜索页面
 */
@property (nonatomic, copy) NSString *bluetoothSearchH5URL;

/**
 微信分享要的type
 */
@property (nonatomic , assign) NSInteger wxShareType;

/**
 action
 */
@property (nonatomic , copy) NSString *action;

/**
 appKey
 */
@property (nonatomic , copy) NSString *appKey;

/**
 appSecret
 */
@property (nonatomic , copy) NSString *appSecret;

/**
 platform
 */
@property (nonatomic , copy) NSString *platform;

/**
 实时天气公版api
 */
@property (nonatomic , copy) NSString *weatherNowHost;
 
/**
 天气城市信息
 */
@property (nonatomic, copy) NSString *weatherCityHost;

/**
 天气生活指数信息
 */
@property (nonatomic, copy) NSString *weatherIndicesHost;

/**
 地域
 */
@property (nonatomic, copy) NSString *deviceRegion;

- (void)setEnvironment;
@end

NS_ASSUME_NONNULL_END
