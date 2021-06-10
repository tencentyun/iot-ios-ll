//
//  WCProductCell.m
//  TenextCloud
//
//

#import "TIoTProductCell.h"

@interface TIoTProductCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation TIoTProductCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.image = [UIImage imageNamed:@"new_add_product_placeholder"];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.left.right.equalTo(self.contentView);
        make.top.centerX.equalTo(self.contentView);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont wcPfRegularFontOfSize:12];
    self.titleLab.textColor = [UIColor colorWithHexString:kRegionHexColor];
    self.titleLab.numberOfLines = 0;
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.text = @"客厅灯泡\n(其他）";
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom).offset(6.5);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
    }];
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    if (![NSString isNullOrNilWithObject:[dic objectForKey:@"AliasName"]]) {
        self.titleLab.text = dic[@"AliasName"]?:@"";
    }else {
        self.titleLab.text = dic[@"DeviceName"]?:@"";
    }
    
    if ([dic objectForKey:@"CategoryName"]){
        self.titleLab.text = dic[@"CategoryName"]?:@"";
    }
    if ([dic objectForKey:@"ProductName"]){
        self.titleLab.text = dic[@"ProductName"]?:@"";
    }
    [self.imgView setImageWithURLStr:dic[@"IconUrl"] placeHolder:@"new_add_product_placeholder"];
}

@end
