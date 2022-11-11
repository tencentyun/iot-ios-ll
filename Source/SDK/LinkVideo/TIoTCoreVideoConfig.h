//
//  TIoTCoreVideoConfig.h
//  TIoTLinkVideo
//
//  Created by eagleychen on 2022/9/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN


@interface TIoTCoreVideoConfig : NSObject
/**
 *  本地预览UI
 */
@property (nonatomic,strong) UIView *localView;

/**
 *  视频采集前后摄像头位置
 */
@property (nonatomic,assign) AVCaptureDevicePosition videoPosition;

/**
 *  需要重启采集器和编码器设置为yes
 */
@property (nonatomic,assign) BOOL refreshSession;

@end

NS_ASSUME_NONNULL_END
