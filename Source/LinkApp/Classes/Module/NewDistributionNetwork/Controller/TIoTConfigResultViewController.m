//
//  TIoTConfigResultViewController.m
//  LinkApp
//
//

#import "TIoTConfigResultViewController.h"
#import "TIoTStartConfigViewController.h"

#import "TIoTWebVC.h"
#import "TIoTAppEnvironment.h"
#import "TIoTConfigHardwareViewController.h"

@interface TIoTConfigResultViewController ()

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// 配网成功or失败
@property (nonatomic, assign) BOOL success;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSDictionary *devieceData;
@property (nonatomic, strong) NSDictionary *configData;
@end

@implementation TIoTConfigResultViewController

- (void)viewWillAppear:(BOOL)animated {
    //禁止返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (instancetype)initWithConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle success:(BOOL)success devieceData:(NSDictionary *)devieceData {
    if (self = [super init]) {
        _configHardwareStyle = configHardwareStyle;
        _success = success;
        _devieceData = devieceData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    NSString *title = _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? NSLocalizedString(@"softAP_distributionNetwork", @"热点配网") : NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网");
    self.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *imageName = _success ? @"new_distri_success" : @"new_distri_failure";
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30*kScreenAllHeightScale + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.height.mas_equalTo(53.3);
    }];
    
    NSString *topic = _success ? NSLocalizedString(@"distributionNetworkSuccess_addDeviceSuccess", @"配网完成,设备添加成功") : NSLocalizedString(@"distributionNetwork_failure", @"配网失败");
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = topic;
    topicLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(15.4);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(280);
        make.height.mas_equalTo(24);
    }];
    
    NSString *describe = _success ? [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"device_name", @"设备名称"), [_devieceData objectForKey:@"deviceName"]] : NSLocalizedString(@"", @"请检查以下信息");
    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    describeLabel.text = describe;
    describeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(8);
        make.left.right.equalTo(topicLabel);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? NSLocalizedString(@"softAp_connected_failure", @"1. 确认设备处于热点模式（指示灯慢闪）\n2. 确认是否成功连接到设备热点\n3. 核对家庭WiFi密码是否正确\n4. 确认路由设备是否为2.4G WiFi频段") :  NSLocalizedString(@"config_connected_failure", @"1. 确认设备处于一键配网模式（指示灯快闪）\n2. 核对家庭WiFi密码是否正确\n3. 确认路由设备是否为2.4G WiFi频段");
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(136, 136, 136),NSParagraphStyleAttributeName:paragraph}];
    stepLabel.attributedText = attributedStr;
    stepLabel.numberOfLines = 0;
    [self.view addSubview:stepLabel];
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(20);
        make.left.right.equalTo(topicLabel);
//        make.height.mas_equalTo(100);
    }];
    stepLabel.hidden = _success;
    
    if (!_success) {
        UIButton *moreResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreResultBtn setTitle:NSLocalizedString(@"see_more_fail_cause",  @"查看更多失败原因") forState:UIControlStateNormal];
        [moreResultBtn addTarget:self action:@selector(moreErrorResult:) forControlEvents:UIControlEventTouchUpInside];
        moreResultBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [moreResultBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        [self.view addSubview:moreResultBtn];
        [moreResultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topicLabel);
            make.top.equalTo(stepLabel.mas_bottom).offset(5);
        }];
    }
    
    NSString *changeTitle = _success ? NSLocalizedString(@"continue_addDevice", @"继续添加其他设备") : [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"changeTo", @"切换到"), _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网") : NSLocalizedString(@"softAP_distributionNetwork", @"热点配网")];
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setTitle:changeTitle forState:UIControlStateNormal];
    [changeButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    changeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [changeButton addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_success) {
            make.top.equalTo(describeLabel.mas_bottom).offset(291*kScreenAllHeightScale);
        }else {
            make.top.equalTo(describeLabel.mas_bottom).offset(320*kScreenAllHeightScale);
        }
        
        make.centerX.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(72);
    }];
    
    NSString *nextTitle = _success ? NSLocalizedString(@"finish", @"完成") :NSLocalizedString(@"scanning_retry", @"重试");
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    nextBtn.layer.cornerRadius = 2;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(changeButton.mas_bottom).offset(1);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
}

- (void)nav_customBack {
//    [self nextClick:nil];
    [self goBackClick:YES];
}

- (id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

#pragma mark eventResponse

- (void)changeClick:(UIButton *)sender {
    // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
//    UIViewController *vc = [self findViewController:@"TIoTNewAddEquipmentViewController"];
//    if (vc) {
//        // 找到需要返回的控制器的处理方式
//        [self.navigationController popToViewController:vc animated:YES];
//    }else{
//        // 没找到需要返回的控制器的处理方式
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
    if (!_success) {
//        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
////            [HXYNotice postChangeAddDeviceType:0];
////            [self.navigationController popViewControllerAnimated:YES];
//            [self getProductsConfig:self.devieceData[@"profile"][@"ProductId"]?:@""withType:0];
//        } else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
////            [HXYNotice postChangeAddDeviceType:1];
////            [self.navigationController popViewControllerAnimated:YES];
//            [self getProductsConfig:self.devieceData[@"profile"][@"ProductId"]?:@""withType:1];
//        }
        
        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            [self changeConfig:NSLocalizedString(@"smart_config", @"智能配网")];
            
        }else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
            [self changeConfig:NSLocalizedString(@"soft_ap", @"自助配网")];
        }
        
    }
}

- (void)moreErrorResult:(UIButton *)sender {
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
            [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {

                DDLogInfo(@"AppGetTokenTicket responseObject%@", responseObject);
                NSString *ticket = responseObject[@"TokenTicket"]?:@"";
                TIoTWebVC *vc = [TIoTWebVC new];
                vc.title = NSLocalizedString(@"help_center", @"帮助中心");
                NSString *url = nil;
                NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

                url = [NSString stringWithFormat:@"%@/%@/?appID=%@&ticket=%@#/pages/Functional/HelpCenter/QnAList/QnAList?genCateID=config7", [TIoTCoreAppEnvironment shareEnvironment].h5Url, H5HelpCenter, bundleId, ticket];
                vc.urlPath = url;
                vc.needJudgeJump = YES;
                [self.navigationController pushViewController:vc animated:YES];
                [MBProgressHUD dismissInView:self.view];

            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                [MBProgressHUD dismissInView:self.view];
            }];
}

- (void)goBackClick:(BOOL)isBack {
    if (isBack) {
        // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
        UIViewController *vc = [self findViewController:@"TIoTNewAddEquipmentViewController"];
        if (vc) {
            // 找到需要返回的控制器的处理方式
            [self.navigationController popToViewController:vc animated:YES];
        }else{
            // 没找到需要返回的控制器的处理方式
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)nextClick:(UIButton *)sender {
    
    if (!_success) {
        // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
//        UIViewController *vc = [self findViewController:@"TIoTNewAddEquipmentViewController"];
//        if (vc) {
//            // 找到需要返回的控制器的处理方式
//            [self.navigationController popToViewController:vc animated:YES];
//        }else{
//            // 没找到需要返回的控制器的处理方式
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
////            [HXYNotice postChangeAddDeviceType:1];
////            [self.navigationController popViewControllerAnimated:YES];
//            [self getProductsConfig:self.devieceData[@"profile"][@"ProductId"]?:@""];
//        } else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
////            [HXYNotice postChangeAddDeviceType:0];
////            [self.navigationController popViewControllerAnimated:YES];
//            [self getProductsConfig:self.devieceData[@"profile"][@"ProductId"]?:@""];
//        }
        
        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            
            [self changeConfig:NSLocalizedString(@"soft_ap", @"自助配网")];
        }else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
            
            [self changeConfig:NSLocalizedString(@"smart_config", @"智能配网")];
        }
        
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - 配网请求流程
- (void)getProductsConfig:(NSString *)productId{
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            self.configData = [[NSDictionary alloc]initWithDictionary:config];
            DDLogInfo(@"AppGetProductsConfig config%@", config);
            NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
            if (wifiConfTypeList.count > 0) {
                NSString *configType = wifiConfTypeList.firstObject;
                if ([configType isEqualToString:@"softap"]) {
                    [self jumpConfigVC:NSLocalizedString(@"soft_ap", @"自助配网")];
                    return;
                }
            }
        }
        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
        DDLogDebug(@"AppGetProductsConfig responseObject%@", responseObject);
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
                [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
    }];
}

- (void)jumpConfigVC:(NSString *)title{
    TIoTConfigHardwareViewController *vc = [[TIoTConfigHardwareViewController alloc] init];
    vc.configurationData = self.configData;
    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSmartConfig;
    } else {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSoftAP;
    }
//    vc.roomId = self.roomId?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeConfig:(NSString *)title{
    TIoTConfigHardwareViewController *vc = [[TIoTConfigHardwareViewController alloc] init];
    vc.configurationData = self.devieceData;
    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSmartConfig;
    } else {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSoftAP;
    }
//    vc.roomId = self.roomId?:@"";
    vc.isDistributeNetFailure = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
