//
//  WCRequestObj.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>


typedef void (^FailureResponseBlock)(NSString *reason,NSError *error,NSDictionary *dic);
typedef void (^SuccessResponseBlock)(id responseObject);

@interface TIoTRequestObject : NSObject
+ (TIoTRequestObject *)shared;

- (void)get:(NSString *)urlString isNormalRequest:(BOOL)normal success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;

- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;
@end

