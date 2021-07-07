//
//  QCSocketManager.h
//  QCAccount
//
//

#import <Foundation/Foundation.h>


static NSString * _Nonnull socketDidOpenNotification = @"socketDidOpenNotification";


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WCReadyState) {
    WC_CONNECTING   = 0,
    WC_OPEN         = 1,
    WC_CLOSING      = 2,
    WC_CLOSED       = 3,
};


@class TIoTCoreSocketManager;
@protocol QCSocketManagerDelegate <NSObject>
@optional
- (void)socket:(TIoTCoreSocketManager *)manager didReceiveMessage:(id)message;
- (void)socketDidOpen:(TIoTCoreSocketManager *)manager;
- (void)socket:(TIoTCoreSocketManager *)manager didFailWithError:(NSError *)error;
- (void)socket:(TIoTCoreSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end




@interface TIoTCoreSocketManager : NSObject

@property (nonatomic,weak) id<QCSocketManagerDelegate> delegate;
/** 连接状态 */
@property (nonatomic,assign) WCReadyState socketReadyState;

+ (instancetype)shared;
- (void)socketOpen;//开启连接
- (void)socketClose;//关闭连接
- (void)sendData:(NSDictionary *)obj;//发送数据

- (void)startHeartBeatWith:(id)userInfo;
- (void)stopHeartBeat;

@property (nonatomic, strong) NSString *socketedRequestURL;

@end

NS_ASSUME_NONNULL_END
