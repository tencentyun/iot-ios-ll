//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
//

#import <Foundation/Foundation.h>
#import "TIoTAVCaptionFLV.h"
#include "AppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTCoreXP2PBridgeDelegate <NSObject>

/*
 * 裸流接口使用方式:
 * 通过 startAvRecvService 和 stopAvRecvService 接口，可以启动和停止裸流传输
 * 客户端拉取到的裸流数据对应 data 参数
 */
- (void)getVideoPacket:(uint8_t *)data len:(size_t)len;
@end


@interface TIoTCoreXP2PBridge : NSObject
@property (nonatomic, weak)id<TIoTCoreXP2PBridgeDelegate> delegate;

/*
 * 开关是否将数据帧写入 Document 目录的 video.data 文件 （后缀可导出后改动）
 */
@property (nonatomic, assign)BOOL writeFile;

/*
 * 是否打印 SDK Log，默认打开
 */
@property (nonatomic, assign)BOOL logEnable;

/*
 * 获取版本号
 */
+ (NSString *)getSDKVersion;
+ (instancetype)sharedInstance ;

- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name __attribute__((deprecated("Use -startAppWith & -setXp2pInfo")));
- (XP2PErrCode)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo __attribute__((deprecated("Use -startAppWith & -setXp2pInfo")));

/*
 * 启动 sdk 服务，productid和devicename可以从video控制台创建得倒
 */
- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name;

/*
 * 此接口慎重：需注意 正式版app发布时候不需要传入secretid和secretkey，避免将这两个参数放置在app中，防止账号泄露，此处仅为演示功能
 * 此接口只二者选一：传入xp2pinfo 就不需要填写 secretid和secretkey，xp2pinfo可从自建服务获取；
 * 仅跑通流程的话，可设置 secretid和secretkey 两个参数，xp2pinfo传“”即可
 */
- (XP2PErrCode)setXp2pInfo:(NSString *)dev_name sec_id:(NSString *)sec_id sec_key:(NSString *)sec_key  xp2pinfo:(NSString *)xp2pinfo;

/*
 * 使用播放器播放时，需先等待 SDK 初始化完成，ready事件(xp2preconnect 通知)之后，即可获取到 http-url
 */
- (NSString *)getUrlForHttpFlv:(NSString *)dev_name;

/*
 * 与设备信令交互接口
 * 1.设备端回复 app 的消息没有限制
 * 2.app 发送给设备的信令，要求不带&符号，信令长度不超过3000个字节
 *
 * 事例 cmd 参数（action=inner_define&cmd=get_nvr_list）
 */
- (void)getCommandRequestWithAsync:(NSString *)dev_name cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion;

/*
 * 开始停止裸流传输接口，通过代理 getVideoPacket 返回裸流数据
 */
- (void)startAvRecvService:(NSString *)dev_name cmd:(NSString *)cmd;
- (XP2PErrCode)stopAvRecvService:(NSString *)dev_name;

/*
 * 语音对讲开始结束接口
 */
//对讲音频默认采样率
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number;
//可通过此接口 audio_onfig 参数既可设置对讲音频码率（bitrate）、采样率（sampleRate）、channelCount、sampleSize
<<<<<<< HEAD   (204be9 修复使用DDLog库后，内存及时不释放问题)
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(AWAudioConfig *)audio_onfig;
=======
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate;
//音视频采样
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView;
>>>>>>> CHANGE (516ba1 添加采集音频+视频+合成flv)
- (XP2PErrCode)stopVoiceToServer;

/*
 * 退出 SDK 服务
 */
- (void)stopService:(NSString *)dev_name;

/*
 * 调试接口，录制通过播放器拉取的数据流并行保存到 Document 目录的 video.data 文件
 * 需提前打开 writeFile 开关
 */
+ (void)recordstream:(NSString *)dev_name;
@end

NS_ASSUME_NONNULL_END
