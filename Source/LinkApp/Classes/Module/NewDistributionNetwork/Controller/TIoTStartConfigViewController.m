//
//  TIoTStartConfigViewController.m
//  LinkApp
//
//

#import "TIoTStartConfigViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTConnectStepTipView.h"
#import "TIoTConfigResultViewController.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>

//----------------------- soft ap-------------------------
#import "TIoTCoreAddDevice.h"
#import "GCDAsyncUdpSocket.h"

@interface TIoTStartConfigViewController () <TIoTCoreAddDeviceDelegate>

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) TIoTConnectStepTipView *connectStepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

//----------------------- soft ap-------------------------
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;

@property (nonatomic,strong) NSDictionary *signInfo;//签名信息
@property (nonatomic, assign) BOOL isTokenbindedStatus;

//----------------------- smart config-------------------------
@property (nonatomic, strong) TIoTCoreSmartConfig   *smartConfig;

@end

@implementation TIoTStartConfigViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //去重
    if (self.smartConfig) {
        [self.smartConfig stopAddDevice];
    }
    if (self.softAP) {
        [self.softAP stopAddDevice];
    }
    onceToken = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    //禁止返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)dealloc {
    [self releaseAlloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    self.title = [_dataDic objectForKey:@"title"];;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.step = _configHardwareStyle == TIoTConfigHardwareStyleSmartConfig ? 3 : 4;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54+8);
    }];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_connect"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepTipView.mas_bottom).offset(103*kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(203);
        make.height.mas_equalTo(100);
    }];
    
    self.connectStepTipView = [[TIoTConnectStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"connectStepTipArr"]];
    [self.view addSubview:self.connectStepTipView];
    [self.connectStepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
//        make.width.mas_equalTo(166);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(114);
    }];
    
    [self performSelector:@selector(clock4Timer:) withObject:@(1) afterDelay:0.5f];
}

- (void)clock4Timer:(NSNumber *)count {
    if (count.intValue > 4) {
        return;
    } else {
        self.connectStepTipView.step = count.intValue;
//        [self performSelector:@selector(clock4Timer:) withObject:@(count.intValue+1) afterDelay:3.0f];
    }
}

- (void)nav_customBack {
    TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
    [av alertWithTitle:NSLocalizedString(@"退出添加设备", @"退出添加设备")  message:NSLocalizedString(@"addDevicing_confirmSignout", @"当前正在添加设备，是否确认退出") cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"confirm", @"确定")];
    av.doneAction = ^(NSString * _Nonnull text) {
        [self releaseAlloc];
        // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
        UIViewController *vc = [self findViewController:@"TIoTNewAddEquipmentViewController"];
        if (vc) {
            // 找到需要返回的控制器的处理方式
            [self.navigationController popToViewController:vc animated:YES];
        }else{
            // 没找到需要返回的控制器的处理方式
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    };
    [av showInView:[UIApplication sharedApplication].keyWindow];
}

- (id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

#pragma mark SoftAp config

- (void)createSoftAPWith:(NSString *)ip {

    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    
    self.softAP = [[TIoTCoreSoftAP alloc] initWithSSID:apSsid PWD:apPwd];
    self.softAP.delegate = self;
    self.softAP.gatewayIpString = ip;
    __weak __typeof(self)weakSelf = self;
    self.softAP.udpFaildBlock = ^{
        [weakSelf connectFaild];
    };
    [self.softAP startAddDevice];
}

- (void)connectWiFiCheckTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    if (@available(iOS 11.0, *)) { //去连接wifi
        if (self.configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            NSLog(@"wifiInfo :%@", self.wifiInfo);
            NSString *Ssid = self.wifiInfo[@"name"];
            NSString *Pwd = self.wifiInfo[@"pwd"];
             NEHotspotConfiguration * configuration = [[NEHotspotConfiguration alloc] initWithSSID:Ssid passphrase:Pwd isWEP:NO];

            [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
                if (nil == error) {
                    NSLog(@">=iOS 11 Connected!!");
                } else {
                    NSLog (@">=iOS 11 connect WiFi Error :%@", error);
                }
            }];
        }
    }
    
        [self checkTokenStateWithCirculationWithDeviceData:data];
}

//token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    dispatch_source_cancel(self.timer);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{

            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectFaild];
                });
                return ;
            }
            if (self.isTokenbindedStatus == NO) {
                [self getDevideBindTokenStateWithData:data];
            }
            
            self.sendCount2 ++;
        });
        dispatch_resume(self.timer2);

    });
}

static dispatch_once_t onceToken;

//获取设备绑定token状态
- (void)getDevideBindTokenStateWithData:(NSDictionary *)deviceData {
    [[TIoTRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.wifiInfo[@"token"]} success:^(id responseObject) {
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        WCLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {

            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.connectStepTipView.step < 3) {
                    self.connectStepTipView.step = 3;
                }
            });
            
            self.isTokenbindedStatus = YES;
            [self releaseAlloc];
            dispatch_once(&onceToken, ^{
                [self bindingDevidesWithData:deviceData];
            });
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        WCLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        
    }];
}

//判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = self.roomId ?: @"0";
        [[TIoTRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.wifiInfo[@"token"],@"FamilyId":[TIoTCoreUserManage shared].familyId,@"RoomId":roomId} success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.connectStepTipView.step < 4) {
                    self.connectStepTipView.step = 4;
                }
            });
            [self releaseAlloc];
            [self connectSucess:deviceData];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self connectFaild];
        }];
    }else {
        [self connectFaild];
    }

}

- (void)releaseAlloc{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    self.timer = nil;
    if (self.timer2) {
        dispatch_source_cancel(self.timer2);
    }
    self.timer2 = nil;
}

#pragma mark SmartConfig

- (void)tapConfirm{

    [self createSmartConfig];
    __weak __typeof(self)weakSelf = self;
    self.smartConfig.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
        [weakSelf createSoftAPWith:ipaAddrData];
    };
    self.smartConfig.connectFaildBlock = ^{
        [weakSelf connectFaild];
    };
    [self.smartConfig startAddDevice];
}

- (void)createSmartConfig {
    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    NSString *apBssid = self.wifiInfo[@"bssid"];

    self.smartConfig = [[TIoTCoreSmartConfig alloc]initWithSSID:apSsid PWD:apPwd BSSID:apBssid];
    self.smartConfig.delegate = self;
}

#pragma mark TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
    //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //定时器延迟时间
    NSTimeInterval delayTime = 2.0f;
       
    //定时器间隔时间
    NSTimeInterval timeInterval = 2.0f;
       
    //设置开始时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
       
    dispatch_source_set_timer(self.timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 5) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               [self connectFaild];
            });
            return ;
        }
        
        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            
            NSString *Ssid = self.wifiInfo[@"name"];
            NSString *Pwd = self.wifiInfo[@"pwd"];
            NSString *Token = self.wifiInfo[@"token"];
            NSString *apBssid = self.wifiInfo[@"bssid"];
            NSDictionary *dic = @{@"cmdType":@(1),@"ssid":Ssid, @"bssid":apBssid, @"password":Pwd,@"token":Token,@"region":[TIoTCoreUserManage shared].userRegion};
            [sock sendData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        } else {
            [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.wifiInfo[@"token"],@"region":[TIoTCoreUserManage shared].userRegion} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        }
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectStepTipView.step < 1) {
            self.connectStepTipView.step = 1;
        }
    });
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    self.signInfo = dictionary;
    WCLog(@"嘟嘟嘟 %@",dictionary);
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectStepTipView.step < 2) {
            self.connectStepTipView.step = 2;
        }
    });
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                [self connectWiFiCheckTokenStateWithCirculationWithDeviceData:dictionary];
            }else {
                //deviceReplay 为 Cuttent_Error
                WCLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaild];
            }
            
        } else {
            WCLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self connectWiFiCheckTokenStateWithCirculationWithDeviceData:dictionary];
        }
        
    }
}

#pragma mark private Method

- (void)connectFaild {
    TIoTConfigResultViewController *vc = [[TIoTConfigResultViewController alloc] initWithConfigHardwareStyle:self.configHardwareStyle success:NO devieceData:self.connectGuideData];
    [self.navigationController pushViewController:vc animated:YES];
}
//配网成功
- (void)connectSucess:(NSDictionary *)devieceData{
    TIoTConfigResultViewController *vc = [[TIoTConfigResultViewController alloc] initWithConfigHardwareStyle:self.configHardwareStyle success:YES devieceData:devieceData];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark setter or getter

- (void)setConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle {
    _configHardwareStyle = configHardwareStyle;
    switch (configHardwareStyle) {
        case TIoTConfigHardwareStyleSoftAP:
        {
            _dataDic = @{@"title": NSLocalizedString(@"softAP_distributionNetwork", @"热点配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"connectStepTipArr": @[NSLocalizedString(@"phone_device_connect", @"手机与设备连接成功"), NSLocalizedString(@"send_DeveceMassge", @"向设备发送信息成功"), NSLocalizedString(@"device_clound_connect", @"设备连接云端成功"), NSLocalizedString(@"init_success", @"初始化成功")]
            };
            [self setupUI];
            [self createSoftAPWith:[NSString getGateway]];
        }
            break;
            
        case TIoTConfigHardwareStyleSmartConfig:
        {
            _dataDic = @{@"title": NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"chooseTargetWiFi", @"选择目标WiFi"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"connectStepTipArr": @[NSLocalizedString(@"phone_device_connect", @"手机与设备连接成功"), NSLocalizedString(@"send_DeveceMassge", @"向设备发送信息成功"), NSLocalizedString(@"device_clound_connect", @"设备连接云端成功"), NSLocalizedString(@"init_success", @"初始化成功")]
            };
            [self setupUI];
            [self tapConfirm];
        }
            break;
            
        case TIoTConfigHardwareStyleLLsync:
        {
            _dataDic = @{@"title": NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"topic": NSLocalizedString(@"import_WiFiPassword", @"请输入WiFi密码"),
                         @"wifiInputTitle": @"WIFI",
                         @"wifiInputPlaceholder": NSLocalizedString(@"clickArrow_choiceWIFI", @"请点击箭头按钮选择WIFI"),
                         @"wifiInputHaveButton": @(YES),
                         @"pwdInputTitle": NSLocalizedString(@"password", @"密码"),
                         @"pwdInputPlaceholder":NSLocalizedString(@"smart_config_second_hint", @"请输入密码"),
                         @"pwdInputHaveButton": @(NO),
                         @"make": NSLocalizedString(@"operationMethod", @"操作方式:"),
                         @"stepDiscribe": @"1.点击WiFi名称右侧的下拉按钮，前往手机WiFi设置界面选择设备热点后，返回APP。\n2.填写设备密码，若设备热点无密码则无需填写。\n3.点击下一步，开始配网。"
            };
            [self setupUI];
            [self tapConfirm];
        }
            break;
            
        default:
            break;
    }
}

@end
