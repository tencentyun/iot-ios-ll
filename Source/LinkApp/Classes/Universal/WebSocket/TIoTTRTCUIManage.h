//
//  TIoTWebSocketManage+TRTC.h
//  LinkApp
//
//  Created by eagleychen on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const TIoTTRTCaudio_call_status;
FOUNDATION_EXPORT NSString *const TIoTTRTCvideo_call_status;

typedef enum : NSUInteger {
    TIoTTRTCSessionCallType_audio,
    TIoTTRTCSessionCallType_video
} TIoTTRTCSessionCallType;

@interface TIoTTRTCUIManage: NSObject <TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

//面板中主动呼叫设备 0 audio； 1video
- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

//轮训设备状态，查看trtc设备是否要呼叫我
- (void)repeatDeviceData:(NSArray *)devices;
@end

NS_ASSUME_NONNULL_END
