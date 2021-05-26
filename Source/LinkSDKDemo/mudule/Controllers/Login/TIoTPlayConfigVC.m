//
//  TIoTPlayConfigVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayConfigVC.h"

#import "NSObject+additions.h"
#import "UIColor+Color.h"
#import "NSString+Extension.h"
#import "TIoTPlayListVC.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTLoginCustomView.h"
#import "TIoTDemoHomeViewController.h"
#import "TIoTDemoNavController.h"
#import "TIoTDemoTabBarController.h"

@interface TIoTPlayConfigVC ()<UITextFieldDelegate>

@property (nonatomic, strong) TIoTLoginCustomView *loginView;
@property (nonatomic, strong) UIButton *loginBtn;
@end

@implementation TIoTPlayConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopSpace = 30;
    CGFloat kWidthPadding = 16;
    
    self.loginView = [[TIoTLoginCustomView alloc]init];
    [self.view addSubview:self.loginView];
    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopSpace);
        }else {
            make.top.equalTo(self.view);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(56*3 + 3 + 35 + 21);
    }];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [self.loginBtn setButtonFormateWithTitlt:@"登录" titleColorHexString:@"#FFFFFF" font:[UIFont wcPfRegularFontOfSize:17]];
    [self.loginBtn addTarget:self action:@selector(requestDeviceList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
        make.top.equalTo(self.loginView.mas_bottom).offset(40);
        make.height.mas_equalTo(45);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)hideKeyBoard {
    [self.loginView.accessID resignFirstResponder];
    [self.loginView.accessToken resignFirstResponder];
    [self.loginView.productID resignFirstResponder];
}

#pragma mark - event

- (void)requestDeviceList {
    
    if ((![NSString isNullOrNilWithObject:self.loginView.secretIDString] && ![NSString isFullSpaceEmpty:self.loginView.secretIDString]) && (![NSString isNullOrNilWithObject:self.loginView.secretKeyString] && ![NSString isFullSpaceEmpty:self.loginView.secretKeyString]) && (![NSString isNullOrNilWithObject:self.loginView.productIDString] && ![NSString isFullSpaceEmpty:self.loginView.productIDString])) {
        
        NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
        NSMutableArray *accessIDArray = [NSMutableArray arrayWithArray:[defaluts objectForKey:@"AccessIDArrayKey"]];
        if (accessIDArray != nil) {
            [accessIDArray addObject:self.loginView.secretIDString];
            [defaluts setValue:accessIDArray forKey:@"AccessIDArrayKey"];
        }else {
            NSMutableArray *IDArray = [[NSMutableArray alloc]init];
            [IDArray addObject:self.loginView.secretIDString];
            [defaluts setValue:IDArray forKey:@"AccessIDArrayKey"];
        }
        
        TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
        environment.cloudSecretId = self.loginView.secretIDString;
        environment.cloudSecretKey = self.loginView.secretKeyString;
        environment.cloudProductId = self.loginView.productIDString;
        
        //原播放列表
//        TIoTPlayListVC *playListVC = [[TIoTPlayListVC alloc]init];
//        [self.navigationController pushViewController:playListVC animated:YES];
        
        TIoTDemoHomeViewController *homeVC = [[TIoTDemoHomeViewController alloc]init];
        TIoTDemoNavController *nav = [[TIoTDemoNavController alloc]initWithRootViewController:homeVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
        
    }else {
        //原播放列表
//        TIoTPlayListVC *playListVC = [[TIoTPlayListVC alloc]init];
//        [self.navigationController pushViewController:playListVC animated:YES];
        
        TIoTDemoHomeViewController *homeVC = [[TIoTDemoHomeViewController alloc]init];
        TIoTDemoNavController *nav = [[TIoTDemoNavController alloc]initWithRootViewController:homeVC];
//        TIoTDemoTabBarController *tabbarVC = [[TIoTDemoTabBarController alloc]init];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
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
