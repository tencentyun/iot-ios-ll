//
//  WCRequestAction.h
//  TenextCloud
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreRequestAction : NSObject


//MARK: 用户管理

FOUNDATION_EXPORT NSString *const AppFindUser;
FOUNDATION_EXPORT NSString *const AppSendVerificationCode;//短信验证码
FOUNDATION_EXPORT NSString *const AppCheckVerificationCode;//校验短信验证码
FOUNDATION_EXPORT NSString *const AppCreateCellphoneUser;//手机号注册
FOUNDATION_EXPORT NSString *const AppResetPasswordByCellphone;//手机号重置密码

FOUNDATION_EXPORT NSString *const AppSendEmailVerificationCode;//邮箱验证码
FOUNDATION_EXPORT NSString *const AppCheckEmailVerificationCode;//检验邮箱验证码
FOUNDATION_EXPORT NSString *const AppCreateEmailUser;//使用邮箱注册
FOUNDATION_EXPORT NSString *const AppResetPasswordByEmail;//邮箱重置密码

FOUNDATION_EXPORT NSString *const AppGetToken;//手机号邮箱登录
FOUNDATION_EXPORT NSString *const AppGetTokenByWeiXin;//微信登录
FOUNDATION_EXPORT NSString *const AppUpdateUserByWeiXin;//获取openid

FOUNDATION_EXPORT NSString *const AppGetGlobalConfig;//获取时区、地区列表
FOUNDATION_EXPORT NSString *const AppGetUser;//查询用户基本信息
FOUNDATION_EXPORT NSString *const AppUpdateUser;//修改用户基本信息
FOUNDATION_EXPORT NSString *const AppGetUserSetting;//查询用户设置信息
FOUNDATION_EXPORT NSString *const AppUpdateUserSetting;//修改用户设置信息
FOUNDATION_EXPORT NSString *const AppLogoutUser;//退出登录

FOUNDATION_EXPORT NSString *const AppUserResetPassword;//登录下修改密码

FOUNDATION_EXPORT NSString *const AppUserFeedBack;//用户意见反馈
FOUNDATION_EXPORT NSString *const AppCosAuth;//上传图片获取信息

FOUNDATION_EXPORT NSString *const AppGetTokenTicket;//得到一次性的TokenTicket
FOUNDATION_EXPORT NSString *const AppUserCancelAccount;//账户注销
FOUNDATION_EXPORT NSString *const AppGetLatestVersion;//获取App最新版本信息

//MARK: 消息

FOUNDATION_EXPORT NSString *const AppGetMessages;//查询消息列表
FOUNDATION_EXPORT NSString *const AppDeleteMessage;//用户删除消息
FOUNDATION_EXPORT NSString *const AppBindXgToken;//绑定推送token
FOUNDATION_EXPORT NSString *const AppUnBindXgToken;//解绑推送token


//MARK: 家庭管理

FOUNDATION_EXPORT NSString *const AppGetFamilyList;//家庭列表
FOUNDATION_EXPORT NSString *const AppCreateFamily;//新建家庭
FOUNDATION_EXPORT NSString *const AppDescribeFamily;//获取家庭详情
FOUNDATION_EXPORT NSString *const AppModifyFamily;//修改家庭
FOUNDATION_EXPORT NSString *const AppDeleteFamily;//删除家庭

FOUNDATION_EXPORT NSString *const AppCreateRoom;//新建房间
FOUNDATION_EXPORT NSString *const AppGetRoomList;//房间列表
FOUNDATION_EXPORT NSString *const AppModifyRoom;//修改房间
FOUNDATION_EXPORT NSString *const AppDeleteRoom;//删除房间

FOUNDATION_EXPORT NSString *const AppInviteMember;//邀请成员
FOUNDATION_EXPORT NSString *const AppDeleteFamilyMember;//管理员移除成员
FOUNDATION_EXPORT NSString *const AppJoinFamily;//成员申请加入
FOUNDATION_EXPORT NSString *const AppExitFamily;//成员主动退出
FOUNDATION_EXPORT NSString *const AppGetFamilyMemberList;//获取成员列表

FOUNDATION_EXPORT NSString *const AppSendShareFamilyInvite;//邀请家庭成员

//MARK: 设备管理

FOUNDATION_EXPORT NSString *const AppGetFamilyDeviceList;//获取设备列表
FOUNDATION_EXPORT NSString *const AppGetDeviceStatuses;//获取设备在线状态
FOUNDATION_EXPORT NSString *const AppSigBindDeviceInFamily;//wifi配网绑定设备
FOUNDATION_EXPORT NSString *const AppSecureAddDeviceInFamily;//扫码绑定设备
FOUNDATION_EXPORT NSString *const AppGetDeviceInFamily;//获取设备详情
FOUNDATION_EXPORT NSString *const AppGetDeviceData;//获取设备的模型数据
FOUNDATION_EXPORT NSString *const AppUpdateDeviceInFamily;//修改设备名称
FOUNDATION_EXPORT NSString *const AppControlDeviceData;//用户控制设备
FOUNDATION_EXPORT NSString *const AppDeleteDeviceInFamily;//用户移除设备

FOUNDATION_EXPORT NSString *const AppGetProductsConfig;//获取产品的界面配置
FOUNDATION_EXPORT NSString *const AppGetProducts;//获取产品属性
FOUNDATION_EXPORT NSString *const AppReportDeviceData;//虚拟设备上报

FOUNDATION_EXPORT NSString *const AppModifyFamilyDeviceRoom;//更换设备所属房间

FOUNDATION_EXPORT NSString *const AppCreateDeviceBindToken;//用户获取当次配网token
FOUNDATION_EXPORT NSString *const AppGetDeviceBindTokenState;// 查询token，生成之后经hub回调后token状态标识为可用状态
FOUNDATION_EXPORT NSString *const AppTokenBindDeviceFamily;//使用token进行设备绑定


FOUNDATION_EXPORT NSString *const AppGetParentCategoryList;//获取产品推荐父类别列表
FOUNDATION_EXPORT NSString *const AppGetRecommList;//获取某个父类别下的推荐产品列表及子类别列表

FOUNDATION_EXPORT NSString *const AppCreateDeviceBindToken;//用户获取当次配网token
FOUNDATION_EXPORT NSString *const AppGetDeviceBindTokenState;// 查询token，生成之后经hub回调后token状态标识为可用状态
FOUNDATION_EXPORT NSString *const AppTokenBindDeviceFamily;//使用token进行设备绑定

FOUNDATION_EXPORT NSString *const AppGetProductInfo;//扫一扫落地页面显示 （设备批量生产扫码也调用）

FOUNDATION_EXPORT NSString *const AppGetGatewayBindDeviceList;//网关设备列表
FOUNDATION_EXPORT NSString *const AppBindSubDeviceInFamily;//绑定子设备

FOUNDATION_EXPORT NSString *const AppGetVirtualBindDeviceList;//APP拉用户绑定设备列表

//MARK: LLSync
FOUNDATION_EXPORT NSString *const AppGetDeviceConfig;//读取用户设备的私有信息 (psk)
FOUNDATION_EXPORT NSString *const AppSetDeviceConfig;//上传服务器保存用户设备的私有信息 (psk)
FOUNDATION_EXPORT NSString *const AppReportDataAsDevice;//蓝牙设备上传数据
FOUNDATION_EXPORT NSString *const AppPublishMsgAsDevice;//蓝牙设备行为回复消息数据
FOUNDATION_EXPORT NSString *const AppCheckFirmwareUpdate;//查看固件版本
FOUNDATION_EXPORT NSString *const AppReportFirmwareVersion;//上报固件版本
FOUNDATION_EXPORT NSString *const AppDescribeFirmwareUpdateStatus;//查询设备固件升级状态
FOUNDATION_EXPORT NSString *const AppGetDeviceOTAInfo; //获取固件升级包URL
FOUNDATION_EXPORT NSString *const AppReportOTAStatus; //上报设备OTA状态进度 （下载、更新升级、烧录）
FOUNDATION_EXPORT NSString *const AppReportDeviceEvent; //设备事件上报

//MARK: 设备定时

FOUNDATION_EXPORT NSString *const AppGetTimerList;//获取定时任务列表
FOUNDATION_EXPORT NSString *const AppCreateTimer;//新建定时任务
FOUNDATION_EXPORT NSString *const AppModifyTimerStatus;//修改定时器状态
FOUNDATION_EXPORT NSString *const AppModifyTimer;//修改定时器
FOUNDATION_EXPORT NSString *const AppDeleteTimer;//修改定时器

//MARK: 设备分享

FOUNDATION_EXPORT NSString *const AppSendShareDeviceInvite;//发送设备分享邀请
FOUNDATION_EXPORT NSString *const AppBindUserShareDevice;//绑定用户分享的设备
FOUNDATION_EXPORT NSString *const AppListUserShareDevices;//查询用户分享的设备列表
FOUNDATION_EXPORT NSString *const AppListShareDeviceUsers;//查询设备的用户列表
FOUNDATION_EXPORT NSString *const AppRemoveShareDeviceUser;//删除设备的用户
FOUNDATION_EXPORT NSString *const AppRemoveUserShareDevice;//删除用户的设备

//MARK: 智能联动
FOUNDATION_EXPORT NSString *const AppCreateScene;//创建手动场景
FOUNDATION_EXPORT NSString *const AppGetSceneList;//获取场景列表
FOUNDATION_EXPORT NSString *const AppGetAutomationList;//获取自动智能场景列表
FOUNDATION_EXPORT NSString *const AppCreateAutomation;//创建自动智能场景
FOUNDATION_EXPORT NSString *const AppDeleteScene;//删除手动场景
FOUNDATION_EXPORT NSString *const AppDeleteAutomation;//删除自动场景
FOUNDATION_EXPORT NSString *const AppRunScene;//手动智能场景执行
FOUNDATION_EXPORT NSString *const AppModifyAutomationStatus;//自动智能更改状态
FOUNDATION_EXPORT NSString *const AppModifyScene;//修改手动智能场景
FOUNDATION_EXPORT NSString *const AppModifyAutomation;//修改自动智能场景
FOUNDATION_EXPORT NSString *const AppDescribeAutomation;//获取自动智能场景详情
FOUNDATION_EXPORT NSString *const AppGetSceneAndAutomationLogs;//智能联动执行日志

//MARK: Video
FOUNDATION_EXPORT NSString *const DescribeDevices;//Video 设备列表
FOUNDATION_EXPORT NSString *const DescribeCloudStorageEvents;//云存事件列表
FOUNDATION_EXPORT NSString *const DescribeCloudStorageThumbnail;//云存缩略图
FOUNDATION_EXPORT NSString *const GenerateSignedVideoURL;//获取视频防盗链播放URL
FOUNDATION_EXPORT NSString *const DescribeProduct;//获取产品详情
FOUNDATION_EXPORT NSString *const DescribeDeviceData;//获取设备属性数据

//MARK: Explore
FOUNDATION_EXPORT NSString *const GetDeviceList;//Explore 设备列表

//MARK:CloudStorage
FOUNDATION_EXPORT NSString *const DescribeCloudStorageDate;//获取具有云存的日期

//MARK:获取云存某一天时间轴
FOUNDATION_EXPORT NSString *const DescribeCloudStorageTime;//获取云存某一天时间轴

//MARK: TRTC
FOUNDATION_EXPORT NSString *const AppIotRTCInviteDevice;//1.手机请求设备通话
FOUNDATION_EXPORT NSString *const AppIotRTCCallDevice;//5. 手机请求加入房间参数

//===============h5
FOUNDATION_EXPORT NSString *const H5HelpCenter;//帮助中心
FOUNDATION_EXPORT NSString *const H5Evaluation;//评测

//腾讯地图
FOUNDATION_EXPORT NSString *const MapSDKLocationParseURL;//腾讯逆地址解析(get)
FOUNDATION_EXPORT NSString *const MapSDKAddressParseURL;//地址解析
FOUNDATION_EXPORT NSString *const MapSDKSearchAddressURL;//地点搜索

//===============用户协议、隐私协议链接
FOUNDATION_EXPORT NSString *const ServiceProtocolURl;//用户协议
FOUNDATION_EXPORT NSString *const PrivacyProtocolURL;//隐私协议
FOUNDATION_EXPORT NSString *const DeviceSharedPrivacyProtocolURL;//设备分享隐私协议
FOUNDATION_EXPORT NSString *const CancelAccountURL;//账号注销协议
@end

NS_ASSUME_NONNULL_END
