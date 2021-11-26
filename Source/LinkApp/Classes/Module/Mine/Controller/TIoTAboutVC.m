//
//  WCAboutVC.m
//  TenextCloud
//
//

#import "TIoTAboutVC.h"
#import "TIoTWebVC.h"
#import "TIoTOpensourceLicenseViewController.h"
#import <QuickLook/QLPreviewController.h>

#import "TIoTNewVersionTipView.h"

@interface TIoTAboutVC ()

@property (weak, nonatomic) IBOutlet UILabel *versionLab;

@property (nonatomic, assign) BOOL showLastestVerion;

@property (nonatomic, strong) NSDictionary *versionInfo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *versionTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@property (weak, nonatomic) IBOutlet UIView *opensourceView;

@property (weak, nonatomic) IBOutlet UIView *versionView;

@end

@implementation TIoTAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.showLastestVerion = NO;
    self.title = NSLocalizedString(@"about_me", @"关于我们");
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLab.numberOfLines = 2;
    self.versionLab.textAlignment = NSTextAlignmentCenter;
    self.versionLab.text = [NSString stringWithFormat:@"%@",appVersion];
    [self checkNewVersion];
    
    if ([[TIoTCoreUserManage shared].userRegionId isEqual:@"1"]) { //国内
        self.opensourceView.hidden = YES;
        self.bottomLineView.hidden = YES;
        self.versionTopConstraint.constant = 0.5f;
        [self.versionView setNeedsLayout];
    } else {
        self.opensourceView.hidden = NO;
        self.bottomLineView.hidden = NO;
        self.versionTopConstraint.constant = 61.5f;
        [self.versionView setNeedsLayout];
    }
}


- (IBAction)privacyPolicy:(UITapGestureRecognizer *)sender {
    
    if ([[TIoTCoreUserManage shared].userRegionId isEqual:@"1"]) { //国内
        
        if (LanguageIsEnglish) {
            TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
            vc.title = NSLocalizedString(@"register_agree_4", @"隐私政策");
            vc.urlPath = TIoTAPPConfig.userPrivacyPolicyChEnglishString;
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            TIoTWebVC *vc = [TIoTWebVC new];
            vc.title = NSLocalizedString(@"register_agree_4", @"隐私政策");
            vc.urlPath = PrivacyProtocolURL;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } else {
        TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
        vc.title = NSLocalizedString(@"register_agree_4", @"隐私政策");
        if (LanguageIsEnglish) {
            vc.urlPath = TIoTAPPConfig.privacyPolicyEnglishString;
        }else {
            vc.notZZConfigUrl = YES;
            vc.urlPath = TIoTAPPConfig.userPrivacyPolicyUSChineseString;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)protocol:(UITapGestureRecognizer *)sender {
    
    if ([[TIoTCoreUserManage shared].userRegionId isEqual:@"1"]) { //国内
        
        if (LanguageIsEnglish) {
            TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
            vc.title = NSLocalizedString(@"register_agree_2", @"用户协议");
            vc.urlPath = TIoTAPPConfig.userProtocolChEnglishString;
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
            vc.notZZConfigUrl = YES;
            vc.title =  NSLocalizedString(@"register_agree_2", @"用户协议");
            vc.urlPath = ServiceProtocolURl;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        
        TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
        vc.title = NSLocalizedString(@"register_agree_2", @"用户协议");
        
        if (LanguageIsEnglish) {
            vc.urlPath = TIoTAPPConfig.serviceAgreementEnglishString;
        }else {
            vc.urlPath = TIoTAPPConfig.userProtocolUSChineseString;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)opensourceLicense:(UITapGestureRecognizer *)sender {
    
    TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
    vc.title = NSLocalizedString(@"register_agree_5", @"开源软件信息");
    if (LanguageIsEnglish) {
        vc.urlPath = TIoTAPPConfig.opensourceLicenseString;
    }else {
        vc.urlPath = TIoTAPPConfig.opensourceLicenseChineseString;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)checkNewVersion:(UITapGestureRecognizer *)sender {
    
    if (self.showLastestVerion && self.versionInfo) {
        [self showNewVersionViewWithDict:self.versionInfo];
    } else {
        [MBProgressHUD showError:NSLocalizedString(@"no_need_upgrade", @"您的应用为最新版本")  toView:self.view];
    }
}

- (IBAction)thirdSdkInfo:(UITapGestureRecognizer *)sender {
    TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
    vc.title = NSLocalizedString(@"authentation_thirdsdk_title", @"第三方信息");
    if (LanguageIsEnglish) {
        vc.urlPath = TIoTAPPConfig.userThridSDKChEnglishString;
    }else {
        vc.notZZConfigUrl = YES;
        vc.urlPath = TIoTAPPConfig.userThridSDKChChineseString;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)persionInfo:(UITapGestureRecognizer *)sender {
    TIoTOpensourceLicenseViewController *vc = [TIoTOpensourceLicenseViewController new];
    vc.title = NSLocalizedString(@"authentation_persioninfo_title", @"个人信息收集清单");
    if (LanguageIsEnglish) {
        vc.urlPath = TIoTAPPConfig.userPersonInfoUSENString;
    }else {
        vc.notZZConfigUrl = YES;
        vc.urlPath = TIoTAPPConfig.userPersonInfoUSZHString;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showNewVersionViewWithDict:(NSDictionary *)versionInfo {
    TIoTNewVersionTipView *newVersionView = [[TIoTNewVersionTipView alloc] initWithVersionInfo:versionInfo];
    [[UIApplication sharedApplication].keyWindow addSubview:newVersionView];
    [newVersionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
}

- (void)checkNewVersion {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appVersion = [NSString matchVersionNum:appVersion];
    if (appVersion.length) { //满足要求，必须是三位，x.x.x的形式  每位x的范围分别为1-99,0-99,0-99。
        NSDictionary *tmpDic = @{@"ClientVersion": appVersion, @"Channel":@(0), @"AppPlatform": @"ios"};
        [[TIoTRequestObject shared] postWithoutToken:AppGetLatestVersion Param:tmpDic success:^(id responseObject) {
            NSDictionary *versionInfo = responseObject[@"VersionInfo"];
            if (versionInfo) {
                self.versionInfo = versionInfo;
                NSString *theVersion = [versionInfo objectForKey:@"AppVersion"];
                if (theVersion.length && [self isTheVersion:theVersion laterThanLocalVersion:appVersion]) {
                    self.showLastestVerion = YES;
                    self.versionLab.text = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"current_version", @"当期版本"),appVersion];
                }
            }
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
    
}

- (BOOL)isTheVersion:(NSString *)theVersion laterThanLocalVersion:(NSString *)localVersion {
    NSArray *localArr = [localVersion componentsSeparatedByString:@"."];
    NSArray *theArr = [theVersion componentsSeparatedByString:@"."];
    for (int i = 0; i<localArr.count; i++) {
        NSInteger localIndex = [localArr[i] integerValue];
        NSInteger theIndex;
        if (i < theArr.count) {
            theIndex = [theArr[i] integerValue];
        } else {
            theIndex = 0;
        }
        if (theIndex > localIndex) {
            return YES;
        } else if (theIndex < localIndex) {
            return NO;
        }
    }
    return NO;
}


@end
