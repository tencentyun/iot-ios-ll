//
//  ChangeWifiVC.m
//  QCFrameworkDemo
//
//

#import "ChangeWifiVC.h"
#import "TIoTCoreAddDevice.h"
#import "GCDAsyncUdpSocket.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>

#import "NSString+Extension.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestObject.h"
#import "TIoTCoreRequestAction.h"
#import "TIoTCoreUserManage.h"

@interface ChangeWifiVC ()<TIoTCoreAddDeviceDelegate,GCDAsyncUdpSocketDelegate>

@property (nonatomic,strong) TIoTCoreSoftAP *sa;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic) NSUInteger sendCount2;
@property (nonatomic, assign) BOOL isTokenbindedStatus;

@property (nonatomic,copy) NSString *sig;//q

@end

@implementation ChangeWifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    NSLog(@"==%@==%@",self.wName,self.wPassword);
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //去重
    if (self.sa) {
        [self.sa stopAddDevice];
    }
}

- (void)dealloc {
    [self releaseAlloc];
}

- (IBAction)toSetting:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}

- (IBAction)next:(UIButton *)sender {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@"配网中"];
    
    _sa = [[TIoTCoreSoftAP alloc] initWithSSID:self.wName PWD:self.wPassword BSSID:self.wBssid Token:self.wToken distributeNet:TIoTConfigHardwareTypeSoftAp];
    _sa.delegate = self;
    _sa.gatewayIpString = [NSString getGateway];
    __weak __typeof(self)weakSelf = self;
    _sa.udpFaildBlock = ^{
        TIoTCoreResult *result = [TIoTCoreResult new];
        result.code = 6000;
        result.errMsg = @"模组有问题";
        [weakSelf onResult:result];
    };
    [_sa startAddDevice];
}

- (IBAction)bind:(id)sender {
    
    NSString *familyId = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstFamilyId"];
    NSAssert(familyId, @"家庭id");
    
    [[TIoTCoreDeviceSet shared] bindDeviceWithSignatureInfo:self.sig inFamilyId:familyId roomId:@"" success:^(id  _Nonnull responseObject) {
        self.status.text = @"绑定设备成功";
        [self releaseAlloc];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        self.status.text = reason;
        [self releaseAlloc];
    }];
}


/// 可选实现
/// @param result 返回的调用结果
- (void)onResult:(TIoTCoreResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
        [self releaseAlloc];
        if (result.code == 0) {
            
            self.sig = result.signatureInfo;
            self.status.text = @"配网成功，请切换至热点或移动网，确保手机网络畅通，然后点击绑定设备";
            [self.btn setHidden:NO];
        }
        else
        {
            self.status.text = result.errMsg;
        }
        
    });
    
}

- (void)connectFaildResult:(NSString *)message {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 6000;
    result.errMsg = message;
    [self onResult:result];
}

- (void)compareSuccessResult {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 0;
    [self onResult:result];
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"连接成功");
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    NSLog(@"设备成功返回数据: %@",dictionary);
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                [self checkTokenStateWithCirculationWithDeviceData:dictionary];
            }else {
                //deviceReplay 为 Cuttent_Error
                NSLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaildResult:@"模组有问题"];
            }
            
        }else {
            NSLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
        }
        
    }
}

- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
//    dispatch_source_cancel(self.timer);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{

            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectFaildResult:@"模组有问题"];
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

//获取设备绑定token状态
- (void)getDevideBindTokenStateWithData:(NSDictionary *)deviceData {
    [[TIoTCoreRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.wToken} success:^(id responseObject) {
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        NSLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {
            self.isTokenbindedStatus = YES;
            [self bindingDevidesWithData:deviceData];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        NSLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        
    }];
}

//判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = @"0";
        [[TIoTCoreRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.wToken,@"FamilyId":[TIoTCoreUserManage shared].familyId,@"RoomId":roomId} success:^(id responseObject) {

            [self compareSuccessResult];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self connectFaildResult:@"绑定设备失败"];
        }];
    }else {
        [self connectFaildResult:@"绑定设备失败"];
    }

}

- (void)releaseAlloc{
    self.timer = nil;
    self.timer2 = nil;
    if (self.sa) {
        [self.sa stopAddDevice];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
