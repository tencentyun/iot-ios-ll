//
//  WCChoseValueView.m
//  TenextCloud
//
//

#import "TIoTChoseValueView.h"
#import "TIoTChoseValueTableViewCell.h"

@interface TIoTChoseValueView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, copy) NSString *currentValue;//当前选中
@end

@implementation TIoTChoseValueView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    
    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 300 + [TIoTUIProxy shareUIProxy].tabbarAddHeight)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
//    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.bottom.equalTo(self.mas_bottom).offset(200);
//        make.height.mas_equalTo(300 + [WCUIProxy shareUIProxy].tabbarAddHeight);
//    }];
    
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.text = NSLocalizedString(@"choice", @"选择");
    self.titleLab.textColor = kRGBColor(51, 51, 51);
    self.titleLab.font = [UIFont systemFontOfSize:18];
    [self.whiteView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(20);
    }];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setTitle:NSLocalizedString(@"delete_action", @"删除动作") forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.deleteBtn.hidden = YES;
    [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:self.deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(20);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kLineColor;
    [self.whiteView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteView).offset(0);
        make.right.equalTo(self.whiteView).offset(0);
        make.top.equalTo(self.whiteView).offset(60);
        make.height.mas_equalTo(1);
    }];
    
    [self.whiteView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.top.equalTo(lineView.mas_bottom);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kLineColor;
    [_whiteView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(1);
        
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), kScreenWidth, 60);
    [btn setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [btn setTitleColor:kFontColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-[TIoTUIProxy shareUIProxy].tabbarAddHeight);
        make.height.mas_equalTo(60);
    }];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.whiteView]) {
        return NO;
    }
    return YES;
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteView.frame = CGRectMake(0, kScreenHeight - 300 - [TIoTUIProxy shareUIProxy].tabbarAddHeight, kScreenWidth, 300 + [TIoTUIProxy shareUIProxy].tabbarAddHeight);
    }];
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)selectAt:(NSIndexPath *)indexPath{
    if (indexPath) {
        self.currentValue = self.dataArr[indexPath.row][@"id"];
        [self.tableView reloadData];
    }
}

- (void)done
{
    [self hide];
    if (self.updateData) {
        self.updateData(@{self.dic[@"id"]:@([self.currentValue intValue])});
    }
}

- (void)deleteAction
{
    [self hide];
    if (self.deleteTap) {
        self.deleteTap();
    }
}


#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTChoseValueTableViewCell *cell = [TIoTChoseValueTableViewCell cellWithTableView:tableView];
    BOOL iS = [self.dataArr[indexPath.row][@"id"] integerValue] == [self.currentValue integerValue];
    [cell setTitle:self.dataArr[indexPath.row][@"name"] andSelect:iS];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self hide:indexPath];
    [self selectAt:indexPath];
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = kBgColor;
        _tableView.rowHeight = 60;
        _tableView.separatorColor = kRGBColor(242, 244, 245);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (void)setShowValue:(NSString *)showValue
{
    _showValue = showValue;
    self.currentValue = showValue;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"name"];
    if (!self.currentValue) {
        self.currentValue = dic[@"status"][@"Value"]?:@"";
    }
    
    NSDictionary *tmpDic = dic[@"define"][@"mapping"];
    NSArray *keys = [tmpDic allKeys];
    for (NSString *key in keys) {
        NSDictionary *dataDic = @{@"id":key,@"name":tmpDic[key]};
        [self.dataArr addObject:dataDic];
    }
    [self.tableView reloadData];
}

- (void)setIsAction:(BOOL)isAction
{
    self.deleteBtn.hidden = !isAction;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
