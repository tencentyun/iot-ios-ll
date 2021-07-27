//
//  TIoTTRTCSessionManager.h
//  TIoTLinkKit.default-TRTC
//
//

#import <Foundation/Foundation.h>
#import "TIoTCoreParts.h"
#import "TIOTTRTCModel.h"

/**
 TRTC 设备状态保存
 */

NS_ASSUME_NONNULL_BEGIN

//0 表示设备空闲或者不愿意接听
//1 表示设备准备进入通话状态
//3 表示设备正在通话中

typedef enum : NSUInteger {
    TIoTTRTCSessionType_free,
    TIoTTRTCSessionType_pre,
    TIoTTRTCSessionType_calling,
    TIoTTRTCSessionType_end
} TIoTTRTCSessionType;


FOUNDATION_EXPORT NSString *const TIoTTRTCaudio_call_status;
FOUNDATION_EXPORT NSString *const TIoTTRTCvideo_call_status;

typedef enum : NSUInteger {
    TIoTTRTCSessionCallType_audio,
    TIoTTRTCSessionCallType_video
} TIoTTRTCSessionCallType;


@protocol TIoTTRTCSessionUIDelegate <NSObject>
//远端流进房间了，需要展示
- (void)showRemoteUser:(NSString *)remoteUserID;

//远程挂断，退出房间
- (void)exitRoom:(NSString *)remoteUserID;
@end

@interface TIoTTRTCSessionManager : NSObject
@property (nonatomic, readonly) TIoTTRTCSessionType state; //呼叫状态； 1 呼叫中
@property (nonatomic, weak) id<TIoTTRTCSessionUIDelegate> uidelegate;

+ (instancetype)sharedManager ;
- (void)callDevice:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId success:(SRHandler)success failure:(FRHandler)failure ;
- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure;
- (void)configRoom:(TIOTTRTCModel *)model ;
- (void)enterRoom;
- (void)resetSessionType;
@end

NS_ASSUME_NONNULL_END
