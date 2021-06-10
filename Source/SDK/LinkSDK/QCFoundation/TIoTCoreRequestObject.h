//
//  WCRequestObj.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>

#define SDKGlobalDebugUin @"1234567890"
/**
 请求失败响应
 */
typedef void (^FailureResponseBlock)(NSString *reason,NSError *error,NSDictionary *dic);

/**
 请求成功响应
 */
typedef void (^SuccessResponseBlock)(id responseObject);

/**
 H5传参添加到cookie
 */
typedef NSMutableURLRequest *(^ConfigModelH5CookieBlock)(NSMutableURLRequest *request);

/**
  url和请求body设置
 */
typedef NSURL *(^UrlAndBodyParamCustomSettingBlock)(NSMutableDictionary *accessParam,NSURL *requestUrl);


@interface TIoTCoreRequestObject : NSObject
+ (TIoTCoreRequestObject *)shared;
- (void)getRequestURLString:(NSString *)requestString noH5Render:(BOOL)normalRequest success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;


- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;

@property (nonatomic, copy) ConfigModelH5CookieBlock configH5CookieBlock;
@property (nonatomic, copy) UrlAndBodyParamCustomSettingBlock urlAndBodyCustomSettingBlock;


- (void)postRequestWithAction:(NSString *)actionStr url:(NSURL *)url  isWithoutToken:(BOOL)withoutToken param:(NSDictionary *)baseAccessParam urlAndBodySetting:(UrlAndBodyParamCustomSettingBlock )urlAndBodyCustomSettingBlock isShowHelpCenter:(ConfigModelH5CookieBlock )configH5CookieBlock success:(SuccessResponseBlock)success
                      failure:(FailureResponseBlock)failure;

//Video 设备列表请求
- (void)videoOrExplorePost:(NSString *)urlStr Param:(NSDictionary *)param withUrlString:(NSString *)urlString success:(SuccessResponseBlock)success
          failure:(FailureResponseBlock)failure;

//MARK: 重要
/**
  *******对于自定义 TIoTCoreAppEnvironment 文件，此属性必须赋值********
 */
@property (nonatomic, copy) NSString *customEnvrionmentAppSecretStirng;
@property (nonatomic, copy) NSString *customEnvrionmenPlatform;

@end

