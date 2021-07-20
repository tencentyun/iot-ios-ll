//
//  WCScanlViewController.m
//  TenextCloud
//
//

#import "TIoTScanlViewController.h"
#import "SGQRCode.h"
#import "TIoTConfigHardwareViewController.h"
#import "TIoTProductWelComeConfigModel.h"
#import <YYModel.h>
#import "TIoTConfigScanVC.h"
#import "TIoTSecureAddDeviceModel.h"
#import "TIoTGateWayBindDeviceModel.h"
#import "TIoTLLSyncViewController.h"

@interface QRBlueObject : NSObject
@property (nonatomic, strong)NSString *productId;
@property (nonatomic, strong)NSString *deviceName;
@property (nonatomic, strong)NSString *connId;
@property (nonatomic, strong)NSString *deviceTimestamp;
@property (nonatomic, strong)NSString *signMethod;
@property (nonatomic, strong)NSString *signature;
@end

@implementation QRBlueObject
@end

@interface TIoTScanlViewController (){
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSDictionary *configData;
@end

@implementation TIoTScanlViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /// 二维码开启方法
    [obtain startRunningWithBefore:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
    [self removeFlashlightBtn];
    [obtain stopRunning];
}

- (void)dealloc {
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    obtain = [SGQRCodeObtain QRCodeObtain];
    
    [self setupQRCodeScan];
    [self setupNavigationBar];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
    /// 为了 UI 效果
    [self.view addSubview:self.bottomView];
}

//绑定设备
- (void)bindDevice:(NSString *)signature{
    
    [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
    
    NSString *roomId = self.roomId ?: @"";
    NSDictionary *param = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"DeviceSignature":signature,@"RoomId":roomId};
    
    [[TIoTRequestObject shared] post:AppSecureAddDeviceInFamily Param:param success:^(id responseObject) {
        TIoTSecureAddDeviceModel *model =  [TIoTSecureAddDeviceModel yy_modelWithJSON:responseObject];
        if (![NSString isNullOrNilWithObject:model.Data.AppDeviceInfo.DeviceType]) {
            if (model.Data.AppDeviceInfo.DeviceType.intValue == 1) {
                //网关设备,需查询子设备列表再绑定
                [self getGetWayDeviceList:model];
            }else {
                //其他设备
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:NSLocalizedString(@"add_sucess", @"添加成功")];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [HXYNotice addUpdateDeviceListPost];
            }
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//        [MBProgressHUD dismissInView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

///MARK: 网关设备列表
- (void)getGetWayDeviceList:(TIoTSecureAddDeviceModel *)secureModel {
    
    NSDictionary *param = @{@"GatewayProductId":secureModel.Data.AppDeviceInfo.ProductId?:@"",@"GatewayDeviceName":secureModel.Data.AppDeviceInfo.DeviceName?:@"",@"Limit":@(100),@"Limit":@(0)};
    [[TIoTRequestObject shared] post:AppGetGatewayBindDeviceList Param:param success:^(id responseObject) {
        TIoTGateWayBindDeviceModel *model = [TIoTGateWayBindDeviceModel yy_modelWithJSON:responseObject];
        
        dispatch_group_t group = dispatch_group_create();
        
        if (![NSString isNullOrNilWithObject:model.DeviceList]) {
            NSArray *deviceList = [[model.DeviceList reverseObjectEnumerator] allObjects]?:[NSArray new];
            for (TIoTGateWayBindDeviceInfo *deviceInfoModel in deviceList) {
                
                [self bingSubDeviceWithScureModel:secureModel withDeviceInfo:deviceInfoModel withGrpup:group];
            }
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:NSLocalizedString(@"add_sucess", @"添加成功")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [HXYNotice addUpdateDeviceListPost];
        });
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

///MARK: 子设备绑定
- (void)bingSubDeviceWithScureModel:(TIoTSecureAddDeviceModel*)secureModel withDeviceInfo:(TIoTGateWayBindDeviceInfo *)deviceInfoModel withGrpup:(dispatch_group_t)group{
    dispatch_group_enter(group);
    NSDictionary *param = @{@"GatewayProductId":secureModel.Data.AppDeviceInfo.ProductId?:@"",@"GatewayDeviceName":secureModel.Data.AppDeviceInfo.DeviceName?:@"",@"ProductId":deviceInfoModel.ProductId?:@"",@"DeviceName":deviceInfoModel.DeviceName?:@""};
    [[TIoTRequestObject shared] post:AppBindSubDeviceInFamily Param:param success:^(id responseObject) {
        dispatch_group_leave(group);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}



- (void)processQRCodeResult:(NSString *)result {
    if (result) {
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:NSLocalizedString(@"Processing", @"正在处理...")];
        [obtain stopRunning];
        [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD dismissInView:self.view];
            
            
            //设备扫码配网（手表设备）
            if ([result containsString:@"hmac"]) {
                NSArray<NSString *> *qrBlueObjs = [result componentsSeparatedByString:@";"];
                if (qrBlueObjs.count > 5) {
                    
                    QRBlueObject *qr = [QRBlueObject new];
                    qr.productId     = qrBlueObjs.firstObject;
                    qr.deviceName    = qrBlueObjs[1];
                    qr.connId        = qrBlueObjs[2];
                    qr.deviceTimestamp = qrBlueObjs[3];
                    qr.signMethod    = qrBlueObjs[4];
                    
                    NSData *signatureBase64Decode = [NSString decodeBase64String:qrBlueObjs[5]];
                    NSString *signature = [NSString hexStringFromData:signatureBase64Decode];
                    qr.signature     = signature;
                    
                    [self QRCodeBindDevice:qr];
                    return;
                }
            }
            NSString *signature = @"";//result;
            NSString *productId = @"";//productId
            NSDictionary *param = [NSString jsonToObject:result];
            
            if (param) {
                signature = param[@"Signature"];
                [self bindDevice:signature];
            }
            else if ([result hasPrefix:@"http"]) {
                
                NSURL *url = [NSURL URLWithString:result];
                NSString *page = @"";
                NSString *preview = @"";
                if (url.query) {
                    NSArray *params = [url.query componentsSeparatedByString:@"&"];
                    
                    for (NSString *param in params) {
                        if ([param containsString:@"signature"]) {
                            signature = [[param componentsSeparatedByString:@"="] lastObject];
                        }
                        if ([param containsString:@"page"]) {
                            page = [[param componentsSeparatedByString:@"="] lastObject];
                        }
                        if ([param containsString:@"productId"]) {
                            productId =[[param componentsSeparatedByString:@"="] lastObject];
                        }
                        if ([param containsString:@"preview"]) {
                            preview = [[param componentsSeparatedByString:@"="] lastObject];
                        }
                    }
                    
                }
                if (signature.length) {
                    [self bindDevice:signature];
                } else {
                    if ([page isEqualToString:@"softap"]) {
//                        [self.navigationController popViewControllerAnimated:YES];
//                        [HXYNotice postChangeAddDeviceType:1];
                        [self getProductsConfig:productId];
                    } else if ([page isEqualToString:@"smartconfig"]) {
//                        [self.navigationController popViewControllerAnimated:YES];
//                        [HXYNotice postChangeAddDeviceType:0];
                        [self getProductsConfig:productId];
                    } else if ([page isEqualToString:@"adddevice"] && ![NSString isNullOrNilWithObject:productId]){ //设备批量生产的二维码扫描
                        
                        if (![NSString isNullOrNilWithObject:preview]) {
                            // 扫一扫落地页，有配置，则显示，没配置，则显示默认配置信息
                            if ([preview isEqualToString:@"1"]) {
                                [self getProductInfoConfigScan:productId showConfigData:YES];
                            }
                            
                        }else {
                            //批量生产，落地页有配置，则显示，没配置，则直接进默认配网流程
                            [self getProductInfoConfigScan:productId showConfigData:NO];
                        }
                    }else {//未知page
                        [self bindDevice:signature];
                    }
                }
                
            }
            
        });
    }
}

#pragma mark - 蓝牙配网
- (void)QRCodeBindDevice:(QRBlueObject *)qrData{
    
    [[TIoTRequestObject shared] post:AppSigBindDeviceInFamily Param:@{@"ProductId":qrData.productId,
                                                                      @"DeviceName":qrData.deviceName,
                                                                      @"DeviceTimestamp":@([qrData.deviceTimestamp integerValue]),
                                                                      @"ConnId":qrData.connId,
                                                                      @"Signature":qrData.signature,
                                                                      @"SignMethod":qrData.signMethod,
                                                                      @"BindType":@"other_sign",
                                                                      @"FamilyId":[TIoTCoreUserManage shared].familyId,
                                                                      @"RoomId":[TIoTCoreUserManage shared].currentRoomId,
    } success:^(id responseObject) {
        
        [MBProgressHUD showSuccess:NSLocalizedString(@"bind_success", @"绑定成功")];
        [self.navigationController popToRootViewControllerAnimated:YES];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:dic[@"error_message"]];
    }];
}

#pragma mark - 配网请求流程
- (void)getProductsConfig:(NSString *)productId{
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            self.configData = [[NSDictionary alloc]initWithDictionary:config];
            WCLog(@"AppGetProductsConfig config%@", config);
            NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
            if (wifiConfTypeList.count > 0) {
                NSString *configType = wifiConfTypeList.firstObject;
                if ([configType isEqualToString:@"softap"]) {
                    [self jumpConfigVC:NSLocalizedString(@"soft_ap", @"自助配网")];
                    return;
                }else if  ([configType isEqualToString:@"llsync"]) {
                    
                    [self jumpllsyncVC];
                    return;
                }
            }else {
//调试使用，正常需要删掉
//                [self jumpllsyncVC];
//                return;
            }
        }
        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
        WCLog(@"AppGetProductsConfig responseObject%@", responseObject);
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
    }];
}

#pragma mark - 先展示落地页面，完后再选择房间走配网流程
- (void)getProductInfoConfigScan:(NSString *)productId showConfigData:(BOOL)isEnterConfigScan {
    
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            self.configData = [[NSDictionary alloc]initWithDictionary:config];
            if (isEnterConfigScan == YES) {
                
                //进入扫一扫页面
                [self JumpConfigSacnWith:productId];
                
            }else {
                //进入批量扫码
                if ([NSString isNullOrNilWithObject:config[@"Global"][@"IconUrlAdvertise"]] && [NSString isNullOrNilWithObject:config[@"Global"][@"AddDeviceHintMsg"]]) {
                 // 无配置，直接进配网流程
                    [self getProductsConfig:productId];
                    return;
                }
                
                //进入扫一扫页面
                [self JumpConfigSacnWith:productId];
            }
        }
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
        }];
    
}

/**
 进入扫一扫页面
 */
- (void)JumpConfigSacnWith:(NSString *)productId {
    //进入扫一扫落地页
    TIoTConfigScanVC *configScanVC = [[TIoTConfigScanVC alloc]init];
//    configScanVC.productWelConfigModel = [TIoTProductWelComeConfigModel yy_modelWithJSON:self.configData[@"Global"]?:@{}];
    configScanVC.welConfigDic = [NSDictionary dictionaryWithDictionary:self.configData[@"Global"]?:@{}];
    configScanVC.productID = productId?:@"";
    configScanVC.roomId = self.roomId;
    [self.navigationController pushViewController:configScanVC animated:YES];
}

- (void)jumpConfigVC:(NSString *)title{
    TIoTConfigHardwareViewController *vc = [[TIoTConfigHardwareViewController alloc] init];
    vc.configurationData = self.configData;
    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSmartConfig;
    } else {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSoftAP;
    }
    vc.roomId = self.roomId?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpllsyncVC {
    TIoTLLSyncViewController *vc = [[TIoTLLSyncViewController alloc] init];
    vc.configurationData = self.configData;
//    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        
    vc.roomId = self.roomId?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)setupQRCodeScan {
    WeakObj(self)
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        StrongObj(self)
        [selfstrong processQRCodeResult:result];
    }];
    [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
        StrongObj(self)
        if (brightness < - 1) {
            [selfstrong.view addSubview:selfstrong.flashlightBtn];
        } else {
            if (selfstrong.isSelectedFlashlightBtn == NO) {
                [selfstrong removeFlashlightBtn];
            }
        }
    }];
}

- (void)setupNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"scan", @"扫一扫");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"photoalbum", @"相册") style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction {
    
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    WeakObj(self)
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        StrongObj(self)
        [selfstrong.view addSubview:selfstrong.scanView];
    }];
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        StrongObj(self)
        [selfstrong processQRCodeResult:result];
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = NSLocalizedString(@"autoscan_QRcode", @"将二维码/条码放入框内, 即可自动扫描");
    }
    return _promptLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnW = 30;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [obtain openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->obtain closeFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn removeFromSuperview];
    });
}

@end
