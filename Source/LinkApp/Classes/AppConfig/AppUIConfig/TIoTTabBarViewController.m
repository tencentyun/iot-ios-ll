//
//  XDPTabBarViewController.m
//  SEEXiaodianpu
//
//  Created by houxingyu on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTTabBarViewController.h"
#import "TIoTHomeViewController.h"
#import "TIoTMineViewController.h"
#import "TIoTNavigationController.h"
#import "UIImage+Ex.h"
#import "TIoTWebVC.h"
#import "TIoTCoreAppEnvironment.h"
#import <WebKit/WebKit.h>
#import "TIoTIntelligentHomeVC.h"

@interface TIoTTabBarViewController ()<UITabBarControllerDelegate>

@property(nonatomic, strong)TIoTWebVC *webVC;
@end

@implementation TIoTTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    self.tabBar.tintColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
//    [UINavigationBar appearance].shadowImage = [UIImage imageWithColor:kXDPNavigationLineColor];
    // 1.初始化子控制器
    
    //首页
    TIoTHomeViewController *homeVC = [[TIoTHomeViewController alloc] init];
    [self addChildVc:homeVC title:NSLocalizedString(@"main_tab_1", @"首页") image:@"equipmentDefaultTabbar" selectedImage:@"equipmentSelectTabbar"];
    
    
    //智能联动
    TIoTIntelligentHomeVC *intelligent = [[TIoTIntelligentHomeVC alloc]init];
    [self addChildVc:intelligent title:NSLocalizedString(@"home_intelligent", @"智能") image:@"intelligentDefaultTabbar" selectedImage:@"intelligentSelectTabbar"];
    
    
    __weak typeof(self) weadkSelf= self;
    //评测
    self.webVC = [TIoTWebVC new];
    self.webVC.requestTicketRefreshURLBlock = ^(TIoTWebVC * _Nonnull webController) {
        
        [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
        
        [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {
            
            WCLog(@"AppGetTokenTicket responseObject%@", responseObject);
            NSString *ticket = responseObject[@"TokenTicket"]?:@"";
            //            TIoTWebVC *webVC = [TIoTWebVC new];
            NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            NSString *url = [NSString stringWithFormat:@"%@/%@/?appID=%@&ticket=%@&UserID=%@&uin=%@", [TIoTCoreAppEnvironment shareEnvironment].h5Url, H5Evaluation, bundleId, ticket,[TIoTCoreUserManage shared].userId,TIoTAPPConfig.GlobalDebugUin];
            webController.urlPath = url;
            [webController loadUrl:url];
            webController.needJudgeJump = YES;
            webController.needRefresh = YES;
            
            [MBProgressHUD dismissInView:weadkSelf.view];
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD dismissInView:weadkSelf.view];
        }];
    };
    [self addChildVc:self.webVC title: NSLocalizedString(@"home_evaluation", @"评测")  image:@"home_evaluation_unsel" selectedImage:@"home_evaluation_sel"];
    
    //个人中心
    TIoTMineViewController *mineVC = [[TIoTMineViewController alloc] init];
    [self addChildVc:mineVC title: NSLocalizedString(@"main_tab_3", @"我的")  image:@"mineDefaultTabbar" selectedImage:@"mineSelectTabbar"];

    self.delegate = self;
    
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    //[[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:HWColor(255, 255, 255, 1.0)]];
    // 设置子控制器的文字
    childVc.title = title;
    
    // 先给外面传进来的小控制器 包装 一个导航控制器
    TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:childVc];
    // 设置子控制器的图片
    nav.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = kXDPTabbarNomalColor;
    textAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:kXDPTabbarTitleFont];
    
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:kIntelligentMainHexColor];
    selectTextAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:kXDPTabbarTitleFont];;
    [nav.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    // 添加为子控制器
    [self addChildViewController:nav];
}

@end
