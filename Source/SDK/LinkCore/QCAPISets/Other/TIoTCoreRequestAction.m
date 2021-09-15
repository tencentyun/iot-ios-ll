//
//  WCRequestAction.m
//  TenextCloud
//
//

#import "TIoTCoreRequestAction.h"

@implementation TIoTCoreRequestAction

//===============用户管理

NSString *const AppFindUser = @"AppFindUser";
NSString *const AppSendVerificationCode = @"AppSendVerificationCode";
NSString *const AppCheckVerificationCode = @"AppCheckVerificationCode";
NSString *const AppCreateCellphoneUser = @"AppCreateCellphoneUser";
NSString *const AppResetPasswordByCellphone = @"AppResetPasswordByCellphone";

NSString *const AppSendEmailVerificationCode = @"AppSendEmailVerificationCode";
NSString *const AppCheckEmailVerificationCode = @"AppCheckEmailVerificationCode";
NSString *const AppCreateEmailUser = @"AppCreateEmailUser";
NSString *const AppResetPasswordByEmail = @"AppResetPasswordByEmail";

NSString *const AppGetToken = @"AppGetToken";
NSString *const AppGetTokenByWeiXin = @"AppGetTokenByWeiXin";
NSString *const AppUpdateUserByWeiXin = @"AppUpdateUserByWeiXin";

NSString *const AppGetGlobalConfig = @"AppGetGlobalConfig";
NSString *const AppGetUser = @"AppGetUser";
NSString *const AppUpdateUser = @"AppUpdateUser";
NSString *const AppGetUserSetting = @"AppGetUserSetting";
NSString *const AppUpdateUserSetting = @"AppUpdateUserSetting";
NSString *const AppLogoutUser = @"AppLogoutUser";

NSString *const AppUserResetPassword = @"AppUserResetPassword";

NSString *const AppUserFeedBack = @"AppUserFeedBack";
NSString *const AppCosAuth = @"AppCosAuth";

NSString *const AppGetTokenTicket = @"AppGetTokenTicket";
NSString *const AppUserCancelAccount = @"AppUserCancelAccount";
NSString *const AppGetLatestVersion = @"AppGetLatestVersion";
//===============消息
NSString *const AppGetMessages = @"AppGetMessages";
NSString *const AppDeleteMessage = @"AppDeleteMessage";
NSString *const AppBindXgToken = @"AppBindXgToken";
NSString *const AppUnBindXgToken = @"AppUnBindXgToken";

//===============家庭管理
NSString *const AppGetFamilyList = @"AppGetFamilyList";
NSString *const AppCreateFamily = @"AppCreateFamily";
NSString *const AppDescribeFamily = @"AppDescribeFamily";//获取家庭详情
NSString *const AppModifyFamily = @"AppModifyFamily";//修改家庭
NSString *const AppDeleteFamily = @"AppDeleteFamily";//删除家庭

NSString *const AppCreateRoom = @"AppCreateRoom";
NSString *const AppGetRoomList = @"AppGetRoomList";
NSString *const AppModifyRoom = @"AppModifyRoom";//修改房间
NSString *const AppDeleteRoom = @"AppDeleteRoom";//删除房间

NSString *const AppInviteMember = @"AppInviteMember";//邀请成员
NSString *const AppDeleteFamilyMember = @"AppDeleteFamilyMember";//管理员移除成员
NSString *const AppJoinFamily = @"AppJoinFamily";//成员申请加入
NSString *const AppExitFamily = @"AppExitFamily";//成员主动退出
NSString *const AppGetFamilyMemberList = @"AppGetFamilyMemberList";//获取成员列表

NSString *const AppSendShareFamilyInvite = @"AppSendShareFamilyInvite";//邀请家庭成员

//===============设备管理

NSString *const AppGetFamilyDeviceList = @"AppGetFamilyDeviceList";
NSString *const AppGetDeviceStatuses = @"AppGetDeviceStatuses";
NSString *const AppGetDeviceOnlineStatus = @"AppGetDeviceOnlineStatus";

NSString *const AppSigBindDeviceInFamily = @"AppSigBindDeviceInFamily";
NSString *const AppSecureAddDeviceInFamily = @"AppSecureAddDeviceInFamily";
NSString *const AppGetDeviceInFamily = @"AppGetDeviceInFamily";
NSString *const AppGetDeviceData = @"AppGetDeviceData";
NSString *const AppUpdateDeviceInFamily = @"AppUpdateDeviceInFamily";
NSString *const AppControlDeviceData = @"AppControlDeviceData";
NSString *const AppDeleteDeviceInFamily = @"AppDeleteDeviceInFamily";

NSString *const AppGetProductsConfig = @"AppGetProductsConfig";
NSString *const AppGetProducts = @"AppGetProducts";
NSString *const AppReportDeviceData = @"AppReportDeviceData";

NSString *const AppModifyFamilyDeviceRoom = @"AppModifyFamilyDeviceRoom";

NSString *const AppGetParentCategoryList = @"AppGetParentCategoryList";//获取产品推荐父类别列表
NSString *const AppGetRecommList = @"AppGetRecommList";//获取某个父类别下的推荐产品列表及子类别列表

NSString *const AppCreateDeviceBindToken = @"AppCreateDeviceBindToken";
NSString *const AppGetDeviceBindTokenState = @"AppGetDeviceBindTokenState";
NSString *const AppTokenBindDeviceFamily = @"AppTokenBindDeviceFamily";

NSString *const AppGetProductInfo = @"AppGetProductInfo";

NSString *const AppGetGatewayBindDeviceList = @"AppGetGatewayBindDeviceList";
NSString *const AppBindSubDeviceInFamily = @"AppBindSubDeviceInFamily";

NSString *const AppGetVirtualBindDeviceList = @"AppGetVirtualBindDeviceList";//APP拉用户绑定设备列表

//===============设备定时

NSString *const AppGetTimerList = @"AppGetTimerList";//获取定时任务列表
NSString *const AppCreateTimer = @"AppCreateTimer";//新建定时任务
NSString *const AppModifyTimerStatus = @"AppModifyTimerStatus";//修改定时器状态
NSString *const AppModifyTimer = @"AppModifyTimer";//修改定时器
NSString *const AppDeleteTimer = @"AppDeleteTimer";//修改定时器


//===============设备分享

NSString *const AppSendShareDeviceInvite = @"AppSendShareDeviceInvite";

NSString *const AppBindUserShareDevice = @"AppBindUserShareDevice";//绑定用户分享的设备
NSString *const AppListUserShareDevices = @"AppListUserShareDevices";//查询用户分享的设备列表
NSString *const AppListShareDeviceUsers = @"AppListShareDeviceUsers";//查询设备的用户列表
NSString *const AppRemoveShareDeviceUser = @"AppRemoveShareDeviceUser";//删除设备的用户
NSString *const AppRemoveUserShareDevice = @"AppRemoveUserShareDevice";//删除用户的设备

//===============智能联动
NSString *const AppCreateScene = @"AppCreateScene";//创建手动场景
NSString *const AppGetSceneList = @"AppGetSceneList";//获取场景列表
NSString *const AppGetAutomationList = @"AppGetAutomationList";//获取自动智能场景列表
NSString *const AppCreateAutomation = @"AppCreateAutomation";//创建自动智能场景
NSString *const AppDeleteScene = @"AppDeleteScene";//删除手动场景
NSString *const AppDeleteAutomation = @"AppDeleteAutomation";//删除自动场景
NSString *const AppRunScene = @"AppRunScene";//手动智能场景执行
NSString *const AppModifyAutomationStatus = @"AppModifyAutomationStatus";//自动智能更改状态
NSString *const AppModifyScene = @"AppModifyScene";//修改手动智能场景
NSString *const AppModifyAutomation = @"AppModifyAutomation";//修改自动智能场景
NSString *const AppDescribeAutomation = @"AppDescribeAutomation";//获取自动智能场景详情
NSString *const AppGetSceneAndAutomationLogs = @"AppGetSceneAndAutomationLogs";//智能联动执行日志

//MARK:Video
NSString *const DescribeDevices = @"DescribeDevices";//Video 设备列表
NSString *const DescribeCloudStorageEvents = @"DescribeCloudStorageEvents";//云存事件列表
NSString *const DescribeCloudStorageThumbnail = @"DescribeCloudStorageThumbnail";//云存缩略图
NSString *const GenerateSignedVideoURL = @"GenerateSignedVideoURL";//获取视频防盗链播放URL
NSString *const DescribeProduct = @"DescribeProduct";//获取产品详情

//MARK:Explore
NSString *const GetDeviceList = @"GetDeviceList";//Explore 设备列表 

//MARK:CloudStorage
NSString *const DescribeCloudStorageDate = @"DescribeCloudStorageDate";// 获取具有云存的日期

//MARK:云存某一天时间轴
NSString *const DescribeCloudStorageTime = @"DescribeCloudStorageTime";// 获取云存某一天时间轴

//MARK: TRTC
NSString *const AppIotRTCInviteDevice = @"App::IotRTC::InviteDevice";//1.手机请求设备通话
NSString *const AppIotRTCCallDevice = @"App::IotRTC::CallDevice";//5. 手机请求加入房间参数

//===============h5
NSString *const H5HelpCenter = @"help-center";//帮助中心
NSString *const H5Evaluation = @"evaluation";//评测

//腾讯地图
NSString *const MapSDKLocationParseURL = @"https://apis.map.qq.com/ws/geocoder/v1/?location=";//腾讯逆地址解析(get)
NSString *const MapSDKAddressParseURL = @"https://apis.map.qq.com/ws/geocoder/v1/?address=";// 地址解析
NSString *const MapSDKSearchAddressURL = @"https://apis.map.qq.com/ws/place/v1/suggestion/?";//地点搜索

//===============用户协议、隐私协议链接

NSString *const ServiceProtocolURl = @"https://iot.cloud.tencent.com/explorer-h5/about-policy/#?type=service";//用户协议
NSString *const PrivacyProtocolURL = @"https://iot.cloud.tencent.com/explorer-h5/about-policy/#?type=privacy";//隐私协议
NSString *const DeviceSharedPrivacyProtocolURL = @"";//设备分享隐私协议
NSString *const CancelAccountURL = @"https://iot.cloud.tencent.com/explorer-h5/about-policy/#?type=cancel";//账号注销协议
@end
