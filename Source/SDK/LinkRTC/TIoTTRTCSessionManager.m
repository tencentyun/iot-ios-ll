//
//  TIoTTRTCSessionManager.m
//  TIoTLinkKit.default-TRTC
//
//

#import "TIoTTRTCSessionManager.h"
#import "NSObject+additions.h"
#import "TIoTCoreFoundation.h"
#import "TIoTCoreSocketCover.h"
#import "TIoTCoreRequestAction.h"
#import "YYModel.h"
#import "TRTCCalling.h"

NSString *const TIoTTRTCaudio_call_status = @"_sys_audio_call_status";
NSString *const TIoTTRTCvideo_call_status = @"_sys_video_call_status";

@interface TIoTTRTCSessionManager()<TRTCCallingDelegate>
@end

@implementation TIoTTRTCSessionManager {
    TIOTtrtcPayloadParamModel *_deviceParam;
    TIOTTRTCModel *_trtcModel;
}

+ (instancetype)sharedManager {
    static TIoTTRTCSessionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[TRTCCalling shareInstance] addDelegate:self];
    }
    return self;
}

- (void)callDevice:(NSString *)DeviceId deviceName:(NSString *)DeviceName productId:(NSString *)ProductId success:(SRHandler)success failure:(FRHandler)failure {
    _state = TIoTTRTCSessionType_free;
    
    if (DeviceId == nil || DeviceName == nil || ProductId == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    NSDictionary *param = @{@"DeviceId":DeviceId,@"DeviceName":DeviceName,@"ProductId":ProductId};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppIotRTCInviteDevice params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    
    NSString *iDString = [TIoTCoreUserManage shared].userId;
    if (![NSString isNullOrNilWithObject:iDString]) {
        if ([deviceParam._sys_caller_id isEqual:iDString]) {
            iDString = deviceParam._sys_caller_id;
        }
        
        if ([deviceParam._sys_called_id isEqual:iDString]) {
            iDString = deviceParam._sys_caller_id;
        }
    }
    
    if (iDString == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    _state = TIoTTRTCSessionType_pre;
    _deviceParam = deviceParam;
    
    //开始准备进房间，通话中状态
    NSDictionary *param = @{@"DeviceId":iDString};
//    NSDictionary *tmpDic = @{@"ProductId":self.productId, @"DeviceName":self.deviceName};
    
    TIoTCoreRequestBuilder *b = [[TIoTCoreRequestBuilder alloc] initWtihAction:AppIotRTCCallDevice params:param useToken:YES];
    [TIoTCoreRequestClient sendRequestWithBuild:b.build success:^(id  _Nonnull responseObject) {
//        success(responseObject);
        NSDictionary *tempDic = responseObject[@"TRTCParams"];
        TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
        [self configRoom:model];
        [self enterRoom];
        
    } failure:^(NSString * _Nonnull reason, NSError * _Nonnull error,NSDictionary *dic) {
        failure(reason,error,dic);
    }];
}


//MARK ########TRTCCloud
- (void)configRoom:(TIOTTRTCModel *)model {
    _trtcModel = model;
    
    //初始化trtc
    [[TRTCCalling shareInstance] login:model.SdkAppId.intValue user:model.UserId userSig:model.UserSig roomID:model.StrRoomId];
}

- (void)enterRoom {
    //进房间,如果是主叫直接进房间，如果是被叫等待UI确认后进房间
    _state = TIoTTRTCSessionType_calling;
    CallType _calltype = CallType_Audio;
    if (_deviceParam._sys_video_call_status.intValue == 1) {
        _calltype = CallType_Video;
    }
    [[TRTCCalling shareInstance] groupCall:@[_trtcModel.UserId] type:_calltype groupID:nil];
}

- (void)resetSessionType {
    _state = TIoTTRTCSessionType_free;
}

////获取 caller_id  （被叫时用called_id）
//- (NSString *)getSysCallerIdWithPayloadParamModel:(TIOTtrtcPayloadParamModel *)model {
//
//    NSString *idString = @"";
//    if (_isActiveStatus == YES) { //主叫
//        if (![NSString isNullOrNilWithObject:model._sys_caller_id]) {
//            idString = model._sys_caller_id;
//        }
//    }else { // 被叫
//        if (![NSString isNullOrNilWithObject:model._sys_called_id]) {
//            idString = model._sys_called_id;
//        }
//    }
//    return idString;
//}

#pragma mark -

- (void)onUserEnter:(NSString *)uid {
    //远端流给起来
    if ([self.uidelegate respondsToSelector:@selector(showRemoteUser:)]) {
        [self.uidelegate showRemoteUser:uid];
    }
}
   
/// 离开通话回调 | user leave room callback
-(void)onUserLeave:(NSString *)uid {
    _state = TIoTTRTCSessionType_free;
    if ([self.uidelegate respondsToSelector:@selector(exitRoom:)]) {
        [self.uidelegate exitRoom:uid];
    }
}
@end
