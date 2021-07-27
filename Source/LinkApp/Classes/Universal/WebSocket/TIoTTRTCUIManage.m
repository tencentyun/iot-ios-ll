//
//  TIoTWebSocketManage+TRTC.m
//  LinkApp
//
//

#import "TIoTTRTCUIManage.h"
#import "TIoTCoreUtil.h"
#import "TIoTTRTCSessionManager.h"

@interface TIoTTRTCUIManage ()<TRTCCallingViewDelegate> {
    TRTCCallingAuidoViewController *_callAudioVC;
    TRTCCallingVideoViewController *_callVideoVC;
    
//    socket payload
    TIOTtrtcPayloadParamModel *_deviceParam;
    
    BOOL _isActiveCall;
    TIoTTRTCSessionCallType preCallingType;
    NSString *deviceIDTempStr;
    TIOTtrtcPayloadParamModel *tempModel;
    
    NSTimer *noAnswerTimer; //主叫
    NSTimer *behungupTimer; //被叫
    
    dispatch_source_t disconnectNetTimer;//断网
    NSUInteger sendCount;
}
@end

@implementation TIoTTRTCUIManage

+ (instancetype)sharedManager {
    static TIoTTRTCUIManage *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)dealloc {
    [self cancelTimer];
}

//该方法为5步骤，有三个方面会汇总到次，信鸽、websocket、轮训
- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    if (deviceParam._sys_userid == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    if (_deviceParam._sys_userid) {
        if ([_deviceParam.deviceName isEqualToString:deviceParam.deviceName]) {
            _deviceParam = deviceParam;
        }
    }else {
        _deviceParam = deviceParam;
    }
    
//    _deviceParam = deviceParam;
    
    
    if ([NSString isNullOrNilWithObject:_deviceID]) {
        //单设备被呼叫
        _isActiveCall = NO;//表示被呼叫
        _isActiveStatus = _isActiveCall;
    }else {
        if (![NSString isNullOrNilWithObject:_deviceID] && ![_deviceID isEqualToString:deviceParam.deviceName]) {
            _isActiveCall = NO;//表示被呼叫
            _isActiveStatus = _isActiveCall;
        }else {
            _isActiveCall = YES;
            _isActiveStatus = _isActiveCall;
        }
            
    }
    
    //1.先启动UI，再根据UI选择决定是否走calldevice逻辑
    [self isActiveCalling:deviceParam.deviceName];
}

- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    
    _isActiveCall = NO;
    _isActiveStatus = _isActiveCall;
    
    if (_deviceParam._sys_userid) {
        if ([deviceParam._sys_userid isEqualToString:_deviceParam._sys_userid]) {
            if(deviceParam._sys_audio_call_status.intValue == 1 || deviceParam._sys_video_call_status.intValue == 1)
            [self leaveRoomWith:deviceParam];
        }
        
        if ([[NSString stringWithFormat:@"%@%@",deviceParam._sys_userid,deviceParam.deviceName] isEqualToString:[NSString stringWithFormat:@"%@%@",_deviceParam._sys_userid,_deviceParam.deviceName]]) {
            [self leaveRoomWith:deviceParam];
        }
        
        if (deviceParam._sys_audio_call_status.intValue == 2 || deviceParam._sys_video_call_status.intValue == 2) {
            [self leaveRoomWith:deviceParam];
        }
        
        //case 1
        if ([_deviceParam._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
            [self leaveRoomWith:deviceParam];
        }
        
        if ([_deviceParam._sys_userid isEqualToString:_deviceParam.deviceName]) {
            [self leaveRoomWith:deviceParam];
        }
        
    }else {
        [self leaveRoomWith:deviceParam];
    }
    
}

- (void)leaveRoomWith:(TIOTtrtcPayloadParamModel *)deviceParam {
    
    _deviceParam = nil;
    
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        
        if (_isActiveCall == YES) {
            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                [_callAudioVC hungUp];
            }
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                //单设备主叫 接通后 设备挂断
                if (deviceParam._sys_audio_call_status.intValue == 0) {
                    [self->_callAudioVC beHungUp];
                    
                }
            }

        }else {
            if (deviceParam._sys_audio_call_status.intValue == 2) {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling)  {
                    [_callAudioVC otherAnswered];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self->tempModel = deviceParam;
                        [self->_callAudioVC hangupTapped];
                        self->_isActiveCall = NO;
                        self->_isActiveStatus = self->_isActiveCall;
                    });
                    return;
                }
                
            }else {
                
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callAudioVC hungUp];
                }else {
                    [_callAudioVC beHungUp];
                }
                
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
                
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callAudioVC == topVC) {
                    [self exitRoom:deviceParam._sys_userid];
                }
            }
        });
    }else if (_callVideoVC == topVC) {
        
        if (_isActiveCall == YES) {
            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                [_callVideoVC hungUp];
            }
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                //单设备主叫 接通后 设备挂断
                if (deviceParam._sys_video_call_status.intValue == 0) {
                    [_callVideoVC beHungUp];
                }
            }
            
        }else {
            if (deviceParam._sys_video_call_status.intValue == 2) {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callVideoVC otherAnswered];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self->tempModel = deviceParam;
                        [self->_callVideoVC hangupTapped];
                        self->_isActiveCall = NO;
                        self->_isActiveStatus = self->_isActiveCall;
                    });
                    return;
                }
                
            }else {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callVideoVC hungUp];
                }else {
                    [_callVideoVC beHungUp];
                }
                
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
                
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callVideoVC ==topVC) {
                    [self exitRoom:deviceParam._sys_userid];
                }
            }
        });
    }
    
}

#pragma mark- TRTCCallingViewDelegate ui决定是否进入房间
- (void)didAcceptJoinRoom {
    //2.根据UI决定是否进入房间
    
    //开始准备进房间，通话中状态
    NSDictionary *param = @{@"DeviceId":_deviceParam.deviceName};

    [[TIoTRequestObject shared] post:AppIotRTCCallDevice Param:param success:^(id responseObject) {

        NSDictionary *tempDic = responseObject[@"TRTCParams"];
        TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
        [[TIoTTRTCSessionManager sharedManager] configRoom:model];
        [[TIoTTRTCSessionManager sharedManager] enterRoom];

        //取消计时器
        [self cancelTimer];
        
        // RTC App端和设备端通话中 断网监听
        [HXYNotice addCallingDisconnectNetLister:self reaction:@selector(startHungupActionTimer)];
        
         //一方已进入房间，另一方未成功进入或者异常退出，已等待15秒,已进入房间15秒内对方没有进入房间(TRTC有个回调onUserEnter，对方进入房间会触发这个回调)，则设备端和应用端提示对方已挂断，并退出
        self->_isEnterError = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self->_isEnterError == YES) {
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callAudioVC == topVC) {
                    [self->_callAudioVC beHungUp];
                }else {
                    [self->_callVideoVC beHungUp];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self exitRoom:self->_deviceParam._sys_userid];
                });
            }
        });

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        UIViewController *topVC = [TIoTCoreUtil topViewController];
        if (self->_callAudioVC == topVC) {
            [self->_callAudioVC hungUp];
        }else {
            [self->_callVideoVC hungUp];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self exitRoom:self->_deviceParam._sys_userid];
        });
    }];
}

- (void)didRefuseedRoom {
    
    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free) {
        if (preCallingType == TIoTTRTCSessionCallType_audio) {
            if (tempModel._sys_audio_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:deviceIDTempStr];
            }
        }else if (preCallingType == TIoTTRTCSessionCallType_video) {
            if (tempModel._sys_video_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:deviceIDTempStr];
            }

        }

        [self cancelTimer];
    }

    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
        if (preCallingType == TIoTTRTCSessionCallType_audio) {
            [self exitRoom:@""];
        }else if (preCallingType == TIoTTRTCSessionCallType_video) {

            [self exitRoom:@""];
        }
    }
    
}

#pragma mark - 拒绝其他设备呼叫
- (void)refuseOtherCallWithDeviceReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID {
    
    NSMutableDictionary *trtcReport = [reportDic mutableCopy];
    NSString *userId = [TIoTCoreUserManage shared].userId;
    if (userId) {
        [trtcReport setValue:userId forKey:@"_sys_userid"];
    }
    NSString *username = [TIoTCoreUserManage shared].nickName;
    if (username) {
        [trtcReport setValue:username forKey:@"username"];
    }
    
    NSDictionary *tmpDic = @{
        @"ProductId":[deviceID?:@"" componentsSeparatedByString:@"/"].firstObject?:@"",
        @"DeviceName":[deviceID?:@"" componentsSeparatedByString:@"/"].lastObject?:@"",
        @"Data":[NSString objectToJson:trtcReport]?:@""};
    
    [[TIoTRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
        NSLog(@"--!!!--%@",responseObject);
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//---------------------TRTC设备轮训状态与注册物模型----------------------------

- (void)repeatDeviceData:(NSArray *)devices{
    //1.是trtc设备,注册socket通知
    NSArray *devIds = [devices valueForKey:@"DeviceId"];
    [HXYNotice postHeartBeat:devIds];
    [HXYNotice addActivePushPost:devIds];
//    if (socketNotifitionBlock) {
//        socketNotifitionBlock(devIds);
//    }
    
    NSArray *productIDs = [devices valueForKey:@"ProductId"];
    NSSet *productIDSet = [NSSet setWithArray:productIDs];//去chong
    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":productIDSet.allObjects} success:^(id responseObject) {
        
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            for (NSDictionary *productDic in tmpArr) {
//                NSString *DataTemplate = productDic[@"DataTemplate"];
    //            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
//                TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
    //            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
                NSArray *serverArray = productDic[@"Services"]?:@[];
                if ([serverArray containsObject:@"TRTC"]) {
                    //是trtc设备,注册socket和检测trtc设备的状态
                    [self getTRTCDeviceData:productDic[@"ProductId"]?:@"" devices:devices];
                }
            }
            
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];

}


- (void)getTRTCDeviceData:(NSString *)productID devices:(NSArray *)devices {
    
    NSArray<TIoTDevicedListDataModel *> *devicelist = [NSArray yy_modelArrayWithClass:TIoTDevicedListDataModel.class json:devices];
    for (TIoTDevicedListDataModel * device in devicelist) {

        if ([device.ProductId isEqualToString:productID]) {
            //通过产品ID筛选出设备Device，开始拉取Device的TRTC状态
            
            //1.是trtc设备,注册socket通知,提前了注册时机了，要不然接口太多失败了就不知道啥原因
//            [HXYNotice postHeartBeat:@[device.DeviceId]];
//            [HXYNotice addActivePushPost:@[device.DeviceId]];
            
            if (device.Online.intValue != 1) {
                continue;
            }
            //2.是trtc设备,查看trtc状态是否为呼叫中1
            [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"DeviceId":device.DeviceId} success:^(id responseObject) {
                NSString *tmpStr = (NSString *)responseObject[@"Data"];
                TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
                
                
                if ([product._sys_video_call_status.Value isEqualToString:@"1"] || [product._sys_audio_call_status.Value isEqualToString:@"1"]) {
                    
                    TIOTtrtcPayloadParamModel *payloadParam = [TIOTtrtcPayloadParamModel new];
                    if (product._sys_userid.Value.length > 0) {
                        payloadParam._sys_userid = product._sys_userid ? product._sys_userid.Value:device.DeviceId;
                        
                        if (![payloadParam._sys_userid containsString:[TIoTCoreUserManage shared].userId]) {
                            //没给你打，目前正在跟别人打呢
                            return;
                        }
                    }else {
                        payloadParam._sys_userid = device.DeviceId;
                    }
                    payloadParam._sys_video_call_status = product._sys_video_call_status.Value;
                    payloadParam._sys_audio_call_status = product._sys_audio_call_status.Value;
                    payloadParam.deviceName = device.DeviceName;
                    
                    [self preEnterRoom:payloadParam failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        NSLog(@"error--%@",error);
                    }];
                }
                
                
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                
            }];
            
        }
    }
    
}
//---------------------TRTC设备轮训状态与注册物模型----------------------------




//MARK: 监听到的设备上报信息处理
- (void)receiveDeviceData:(NSDictionary *)deviceInfo {
    //检测是否TRTC设备，是否在呼叫中
    NSDictionary *payloadDic = [NSString base64Decode:deviceInfo[@"Payload"]];
    QCLog(@"\n----设备上报 payload:---%@\n",payloadDic);
    QCLog(@"\n----用户ID:---%@\n",[TIoTCoreUserManage shared].userId);
    TIOTtrtcPayloadModel *model = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
    model.params.deviceName = deviceInfo[@"DeviceId"];
    if (model.params._sys_userid.length < 1) {
        model.params._sys_userid = deviceInfo[@"DeviceId"];
    }

    
    if ([payloadDic.allKeys containsObject:@"params"]) {
        NSDictionary *paramsDic = payloadDic[@"params"];
        if (paramsDic[@"_sys_audio_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_audio_call_status;
        }else if (paramsDic[@"_sys_video_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_video_call_status;
        }
    }
    
    if ([model.method isEqualToString:@"report"]) {
        
        NSString *extrainfo = model.params._sys_extra_info;
        if (extrainfo) {
            //被拒绝就退出房间
            TIOTtrtcRejectModel *rejectModel = [TIOTtrtcRejectModel yy_modelWithJSON:extrainfo];
            if ([rejectModel.rejectUserId isEqualToString:[TIoTCoreUserManage shared].userId]) {
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            return;
        }

        
        if (!model.params._sys_audio_call_status && !model.params._sys_video_call_status) {
            //防止没上报status时候，走到了status=0的情况，新增if需要加在次前面，后面的status避免新增加判断
            return;
        }
        
        
        if (model.params._sys_audio_call_status.intValue == 1 || model.params._sys_video_call_status.intValue == 1) {
            
            
            if ([TIoTTRTCUIManage sharedManager].isActiveStatus == YES && (![NSString isNullOrNilWithObject:[TIoTTRTCUIManage sharedManager].deviceID] && [[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName])) {
                //用户1和用户2（不同账号）同时呼叫设备,deviceA 接听，则会上报对应callstatus属性为1 和 先接收到的比方说是用户1的userid，对应的用户1会调用App::IotRTC::CallDevice加入房间，另一个用户2收到的上报消息查看userid不是自己，则提示对方正忙…，并退出
                if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                    //TRTC设备需要通话，开始通话,防止不是trtc设备的通知
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        
                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        [MBProgressHUD showError:reason];
                    }];
                }
            }else {
                
                if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
                    for (NSString *userIdString in userIdArray) {
                        model.params._sys_userid = userIdString?:@"";
                        if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                            [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }
                }
                
            }
        }else if (model.params._sys_audio_call_status.intValue == 2 || model.params._sys_video_call_status.intValue == 2) {
            
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            
        }else if (model.params._sys_audio_call_status.intValue == 0 || model.params._sys_video_call_status.intValue == 0) {
            
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                if ([TIoTTRTCUIManage sharedManager].isEnterError == NO) {
                    if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                        
                        if ([[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName]) {
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }else if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {   //返回socket params 里没有userid时候（设备端主动呼叫，未接听，设备主动挂断）
                           //防止case 3 中另一个设备 呼叫正在调起通话页面的APP
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        
                    }
                    
                }

            }
            
            
        }
        
    }
    
    //异常
    if ([deviceInfo[@"SubType"] isEqualToString:@"Offline"]) {
        
        NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
        for (NSString *userIdString in userIdArray) {

            model.params._sys_userid = userIdString?:@"";
            if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }

        }
    }
}

- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString {
    _isActiveCall = YES; //表示主动呼叫
    _isActiveStatus = _isActiveCall;
 
    preCallingType = audioORvideo;
    deviceIDTempStr = deviceIdString?:@"";
    
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        return;
    }

    if (audioORvideo == TIoTTRTCSessionCallType_audio) { //audio
        _deviceID = deviceIDTempStr;
        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:nil];
        _callAudioVC.actionDelegate = self;
        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{}];
        
    }else if (audioORvideo == TIoTTRTCSessionCallType_video) { //video
        _deviceID = deviceIDTempStr;
        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:nil];
        _callVideoVC.actionDelegate = self;
        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{}];
    }
    
    //若对方60秒未接听，则显示对方无人接听…，并主动挂断退出
    
    noAnswerTimer = [NSTimer scheduledTimerWithTimeInterval:59.0 target:self selector:@selector(hungupAction:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:noAnswerTimer forMode: NSRunLoopCommonModes];
}

- (void)hungupAction:(NSTimer *)sender {
    if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling)  {
        [self hungupActionUIStatusJudgement];
    }
}

- (void)hungupActionUIStatusJudgement {
    if (self->_deviceParam._sys_audio_call_status.intValue == 0 || self->_deviceParam._sys_video_call_status.intValue == 0) {
        if (preCallingType == TIoTTRTCSessionCallType_audio) {
            [self->_callAudioVC noAnswered];

        }else if (preCallingType == TIoTTRTCSessionCallType_video) {
            [self->_callVideoVC noAnswered];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self exitRoom:@""];
        });
    }
}

- (BOOL)isActiveCalling:(NSString *)deviceID {
    deviceIDTempStr = deviceID;
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动,直接进房间

        if (_isActiveCall) { //如果是被动呼叫的话，不能自动进入房间
            [self didAcceptJoinRoom];
        }else {
            //当前是被叫空闲或是正在通话，这时需要判断：设备A、B同时呼叫同一个用户1，用户1已经被一台比方说是设备A呼叫，后接到其他设备B的呼叫请求，用户1则调用AppControldeviceData 发送callstatus为0拒绝其他设备B的请求。
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free || [TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                if (_deviceParam._sys_audio_call_status.intValue == 1) {
                    [self refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:deviceID];
                }else if (_deviceParam._sys_video_call_status.intValue == 1) {
                    [self refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:deviceID];
                }

            }
        }
        return  YES;
    }
    
    _isActiveCall = NO;//表示被呼叫
    _isActiveStatus = _isActiveCall;
    //被呼叫了，点击接听后才进房间吧
    if (_deviceParam._sys_audio_call_status.intValue == 1) { //audio
        
        _deviceID = _deviceParam.deviceName;
        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
        _callAudioVC.deviceName = _deviceParam.deviceName;
        _callAudioVC.actionDelegate = self;
        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:nil];

        
    }else if (_deviceParam._sys_video_call_status.intValue == 1) { //video
        
        _deviceID = _deviceParam.deviceName;
        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
        _callVideoVC.deviceName = _deviceParam.deviceName;
        _callVideoVC.actionDelegate = self;
        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{
//            [[TIoTTRTCSessionManager sharedManager] enterRoom];
        }];
        
    }
    
    //若60秒被叫不接听，则主动挂断退出  应该在接收到socket status=0时 触发
    behungupTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(beHungupAction:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:behungupTimer forMode: NSRunLoopCommonModes];
    
    return NO;
}

- (void)beHungupAction:(NSTimer *)sender {
    if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
        if (self->_deviceParam._sys_audio_call_status.intValue == 0 || self->_deviceParam._sys_video_call_status.intValue == 0) {
            [self exitRoom:@""];
        }
         
    }
}

#pragma mark - 断网Timer

- (void)startHungupActionTimer {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self->disconnectNetTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self->disconnectNetTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self->disconnectNetTimer, ^{

            if (self->sendCount >= 60) {
                dispatch_source_cancel(self->disconnectNetTimer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //挂断
                    [self callingHungupAction];
                });
                return ;
            }
            
            self->sendCount ++;
        });
        dispatch_resume(self->disconnectNetTimer);

    });
}

- (void)callingHungupAction {
    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling)  {
        [self hungupActionUIStatusJudgement];
    }
}

#pragma mark -TIoTTRTCSessionUIDelegate
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理

- (void)showRemoteUser:(NSString *)remoteUserID {
    _isEnterError = NO;
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        [_callAudioVC OCEnterUserWithUserID:remoteUserID];
    }else {
        [_callVideoVC OCEnterUserWithUserID:remoteUserID];
    }
}

- (void)exitRoom:(NSString *)remoteUserID {
    [TIoTCoreUserManage shared].sys_call_status = @"-1";

    _isEnterError = NO;
    _isActiveCall = NO;
    _isActiveStatus = _isActiveCall;
    preCallingType = TIoTTRTCSessionCallType_audio;
    deviceIDTempStr = @"";
    tempModel = nil;
    [[TIoTTRTCSessionManager sharedManager] resetSessionType];
    [_callAudioVC remoteDismiss];
    [_callVideoVC remoteDismiss];

    _callAudioVC = nil;
    _callVideoVC = nil;
    
    [self cancelTimer];
    
    if (remoteUserID.length > 0) {
        [MBProgressHUD showError:@"对方已挂断"];
    }
}

- (void)cancelTimer {
    if (noAnswerTimer) {
        [noAnswerTimer invalidate];
        noAnswerTimer = nil;
    }
    
    if (behungupTimer) {
        [behungupTimer invalidate];
        behungupTimer = nil;
    }
    
    if (disconnectNetTimer) {
        dispatch_source_cancel(disconnectNetTimer);
    }
    disconnectNetTimer = nil;
    
    sendCount = 0;
}
@end
