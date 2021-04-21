//
//  TIoTBindAccountView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/30.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTBindAccountView.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTBindAccountView ()

@property (nonatomic, strong) UIView        *contentView;

@property (nonatomic, strong) UILabel *passTipLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *phoneOrEmailLabel;
@property (nonatomic, strong) UIButton *passwordButton;
@property (nonatomic, strong) UIButton *passwordConfirmButton;
@end

@implementation TIoTBindAccountView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat kSpace = 15;
    CGFloat kPadding = 16;
    CGFloat kHeight = 48;
    CGFloat kWidthTitle = 80;
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    self.phoneOrEmailLabel = [[UILabel alloc]init];
    [self.phoneOrEmailLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.phoneOrEmailLabel];
    [self.phoneOrEmailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kSpace * kScreenAllHeightScale);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.width.mas_equalTo(kWidthTitle);
    }];
    
    [self.contentView addSubview:self.phoneOrEmailTF];
    [self.phoneOrEmailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kSpace * kScreenAllHeightScale);
        make.leading.equalTo(self.phoneOrEmailLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    [self.contentView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom).offset(3);
        make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = kLineColor;
    [self.contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneOrEmailLabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom);
    }];
    
    UILabel *verificationlabel = [[UILabel alloc]init];
    [verificationlabel setLabelFormateTitle:NSLocalizedString(@"verification_code", @"验证码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:verificationlabel];
    [verificationlabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(line1.mas_bottom).offset(kSpace*kScreenAllHeightScale);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        
    }];
    
    [self.contentView addSubview:self.verificationButton];
    [self.verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.top.equalTo(verificationlabel.mas_top);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    [self.contentView addSubview:self.verificationCodeTF];
    [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(verificationlabel.mas_top);
       make.leading.equalTo(verificationlabel.mas_trailing);
//       make.trailing.equalTo(self.verificationButton.mas_leading);
        make.width.mas_equalTo(140);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = kLineColor;
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(verificationlabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.verificationCodeTF.mas_bottom);
    }];
    
    
    UILabel *passwordLabel = [[UILabel alloc]init];
    [passwordLabel setLabelFormateTitle:NSLocalizedString(@"password", @"密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(line2.mas_bottom).offset(kSpace*kScreenAllHeightScale);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        
    }];
    
    CGFloat kPassWordBtnWidth = 18;
    
    [self.contentView addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(passwordLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPassWordBtnWidth*2);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.top.equalTo(passwordLabel.mas_top);
    }];
    
    self.passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.passwordButton addTarget:self action:@selector(changePasswordTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.passwordButton];
    [self.passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passwordTF);
        make.trailing.equalTo(self.contentView.mas_trailing);
    }];
    
    [self.contentView addSubview:self.passTipLabel];
    [self.passTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTF.mas_bottom).offset(3);
        make.leading.equalTo(self.passwordTF.mas_leading);
    }];
    
    UIView *line3 = [[UIView alloc]init];
    line3.backgroundColor = kLineColor;
    [self.contentView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.passwordTF.mas_bottom);
    }];
    
    
    UILabel *confirmPasswordLabel = [[UILabel alloc]init];
    [confirmPasswordLabel setLabelFormateTitle:NSLocalizedString(@"confirm_password", @"确认密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:confirmPasswordLabel];
    [confirmPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(line3.mas_bottom).offset(kSpace*kScreenAllHeightScale);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        
    }];
    
    [self.contentView addSubview:self.passwordConfirmTF];
    [self.passwordConfirmTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(confirmPasswordLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPassWordBtnWidth*2);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.top.equalTo(confirmPasswordLabel.mas_top);
    }];
    
    self.passwordConfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.passwordConfirmButton addTarget:self action:@selector(changePasswordConfirmTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordConfirmButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.passwordConfirmButton];
    [self.passwordConfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passwordConfirmTF);
        make.trailing.equalTo(self.contentView.mas_trailing);
    }];

    
    UIView *line4 = [[UIView alloc]init];
    line4.backgroundColor = kLineColor;
    [self.contentView addSubview:line4];
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(kSpace*kScreenAllHeightScale);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.passwordConfirmTF.mas_bottom);
    }];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.bottom.equalTo(line4.mas_top);
    }];
    [self.contentView sendSubviewToBack:bottomView];
    
    
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line4.mas_bottom).offset(24);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(40);
    }];
    
    if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"1"]) {
        
        [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(line2.mas_top);
        }];
        
        self.passwordTF.hidden = YES;
        self.passwordConfirmTF.hidden = YES;
        confirmPasswordLabel.hidden = YES;
        passwordLabel.hidden = YES;
        self.passwordButton.hidden = YES;
        self.passwordConfirmButton.hidden = YES;
        [self.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line2.mas_bottom).offset(24);
        }];
    }else {
        
        [bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(line4.mas_top);
        }];
        
        self.passwordTF.hidden = NO;
        self.passwordConfirmTF.hidden = NO;
        confirmPasswordLabel.hidden = NO;
        passwordLabel.hidden = NO;
        self.passwordButton.hidden = NO;
        self.passwordConfirmButton.hidden = NO;
        [self.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line4.mas_bottom).offset(24);
        }];
    }

}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSString *placeHoldString = @"";
    if (self.bindAccoutType == BindAccountPhoneType) {
        placeHoldString = NSLocalizedString(@"please_input_phonenumber", @"请输入手机号");
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneOrEmailLabel.text = NSLocalizedString(@"phone_number", @"手机号码");
    }else if (self.bindAccoutType == BindAccountEmailType) {
        placeHoldString = NSLocalizedString(@"write_email_address", @"请输入邮箱");
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.phoneOrEmailLabel.text = NSLocalizedString(@"email_account", @"邮箱账号");
    }
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:placeHoldString attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
    self.phoneOrEmailTF.attributedPlaceholder = attriStr;
    
}

#pragma mark - setter and getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
    }
    return _contentView;
}

- (UITextField *)phoneOrEmailTF {
    if (!_phoneOrEmailTF) {
        _phoneOrEmailTF = [[UITextField alloc]init];
        _phoneOrEmailTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _phoneOrEmailTF.font = [UIFont wcPfRegularFontOfSize:14];
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_phonenumber", @"请输入手机号") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _phoneOrEmailTF.attributedPlaceholder = ap;
        _phoneOrEmailTF.clearButtonMode = UITextFieldViewModeAlways;
        UIButton *clearButton = [_phoneOrEmailTF valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"text_clear"] forState:UIControlStateNormal];
        [_phoneOrEmailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneOrEmailTF;
  
}

- (UIButton *)verificationButton {
    if (!_verificationButton) {
        _verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verificationButton setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
        [_verificationButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _verificationButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_verificationButton setTitleColor:[UIColor colorWithHexString:kPhoneEmailHexColor] forState:UIControlStateNormal];
        _verificationButton.selected = NO;
        [_verificationButton addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verificationButton;
}

- (UITextField *)verificationCodeTF {
    if (!_verificationCodeTF) {
        _verificationCodeTF = [[UITextField alloc]init];
        _verificationCodeTF.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _verificationCodeTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"input_verification_code", @"请输入验证码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _verificationCodeTF.attributedPlaceholder = apVerification;
        _verificationCodeTF.clearButtonMode = UITextFieldViewModeAlways;
        UIButton *clearButton = [_verificationCodeTF valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"text_clear"] forState:UIControlStateNormal];
        [_verificationCodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationCodeTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.keyboardType = UITextFieldViewModeAlways;
        _passwordTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _passwordTF.secureTextEntry = YES;
        _passwordTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_set_passwd", @"请设置您的密码")  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _passwordTF.attributedPlaceholder = passwordAttStr;
//        _passwordTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordTF;
}

- (UITextField *)passwordConfirmTF {
    if (!_passwordConfirmTF) {
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF.keyboardType = UITextFieldViewModeAlways;
        _passwordConfirmTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _passwordConfirmTF.secureTextEntry = YES;
        _passwordConfirmTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_confirm_passwd", @"请再次确认您的密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _passwordConfirmTF.attributedPlaceholder = passwordAttStr;
//        _passwordConfirmTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordConfirmTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordConfirmTF;;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _tipLabel.text = @"";
        _tipLabel.textColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
        _tipLabel.hidden = YES;
    }
    return _tipLabel;
}

- (UILabel *)passTipLabel {
    if (!_passTipLabel) {
        _passTipLabel = [[UILabel alloc] init];
        _passTipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _passTipLabel.text = @"";
        _passTipLabel.textColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
        _passTipLabel.hidden = YES;
    }
    return _passTipLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedString(@"confirm_to_bind", @"确认绑定")  forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor colorWithHexString:kNoSelectedHexColor]];
        _confirmButton.enabled = NO;
        _confirmButton.layer.cornerRadius = 20;
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_confirmButton addTarget:self action:@selector(confirmClickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)confirmClickButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bindAccountConfirmClickButtonWithAccountType:)]) {
        [self.delegate bindAccountConfirmClickButtonWithAccountType:self.bindAccoutType];
    }
}

-(void)changedTextField:(UITextField *)textField {

    if (self.delegate && [self.delegate respondsToSelector:@selector(bindAccountChangedTextFieldWithAccountType:)]) {
        [self.delegate bindAccountChangedTextFieldWithAccountType:self.bindAccoutType];
    }
    
    //优化提示文案
    if (textField == self.phoneOrEmailTF) {
        
        if (self.phoneOrEmailTF.keyboardType == UIKeyboardTypeNumberPad) { //手机号改密码
            
            if ([NSString judgePhoneNumberLegal:self.phoneOrEmailTF.text withRegionID:[TIoTCoreUserManage shared].userRegionId]) { //手机号合格
                self.tipLabel.hidden = YES;
            }else{ //手机号不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
            }
            
        }else { //邮箱改密码
            
            if ([NSString judgeEmailLegal:self.phoneOrEmailTF.text]) { //邮箱合格
                self.tipLabel.hidden = YES;
            }else{ //邮箱合格不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
            }
        }
        
    }
    
    if (textField == self.passwordTF) {
        if ([NSString judgePassWordLegal:self.passwordTF.text]) {
            self.passTipLabel.hidden = YES;
        }else {
            self.passTipLabel.hidden = NO;
            self.passTipLabel.text = NSLocalizedString(@"password_style", @"密码支持8-16位，必须包含字母和数字");
        }
    }
}

- (void)sendCode:(UIButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(bindAccountSendCodeWithAccountType:)]) {
        [self.delegate bindAccountSendCodeWithAccountType:self.bindAccoutType];
    }
    
}

- (void)changePasswordTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passwordTF.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passwordTF.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}

- (void)changePasswordConfirmTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passwordConfirmTF.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passwordConfirmTF.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
