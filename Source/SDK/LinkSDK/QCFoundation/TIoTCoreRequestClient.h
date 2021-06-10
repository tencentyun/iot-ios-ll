//
//  QCRequestClient.h
//  QCApiClient
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^FailureResponseHandler)(NSString *reason,NSError *error,NSDictionary *dic);
typedef void (^SuccessResponseHandler)(id responseObject);

@interface TIoTCoreRequestClient : NSObject

+ (void)sendRequestWithBuild:(NSDictionary *)build success:(SuccessResponseHandler)success
failure:(FailureResponseHandler)failure;

+ (void)sendVideoOrExploreRequestWithBuild:(NSDictionary *)build urlString:(NSString *)urlString success:(SuccessResponseHandler)success failure:(FailureResponseHandler)failure;
@end

NS_ASSUME_NONNULL_END
