//
//  WCTextVC.m
//  TenextCloud
//
//

#import "TIoTTextVC.h"
#import <WebKit/WKWebView.h>

@interface TIoTTextVC ()

@end

@implementation TIoTTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"help", @"帮助");
    self.view.backgroundColor = kBgColor;
    
    if ([self.content isEqualToString:@"web"]) {
        WKWebView *web = [[WKWebView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wifi_type" ofType:@"html"];
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
        [self.view addSubview:web];
        [web mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    else
    {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.text = self.content;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(-16);
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
            } else {
                make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight).offset(20);
            }
        }];
    }
}



@end
