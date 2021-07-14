//
//  TIoTNetConfigViewController.m
//  LinkSDKDemo
//
//

#import "TIoTNetConfigViewController.h"
#import "TIoTCoreUserManage.h"
#import "TIoTVideoConfigNetVC.h"

@interface TIoTNetConfigViewController ()<UITextFieldDelegate>

@end

@implementation TIoTNetConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)jumpVideoConfigNet:(id)sender {
    TIoTVideoConfigNetVC *VideoConfigVC = [[TIoTVideoConfigNetVC alloc]init];
    [self.navigationController pushViewController:VideoConfigVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text--%@",textField.text);
    
    [[TIoTCoreDeviceSet shared] bindDeviceWithDeviceSignature:textField.text inFamilyId:[TIoTCoreUserManage shared].familyId roomId:@"0" success:^(id  _Nonnull responseObject) {
       
        NSLog(@"---");
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        NSLog(@"fail bind---");
    }];
    
    return YES;
}
@end
