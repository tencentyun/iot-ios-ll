//
//  WCAddFamilyVC.m
//  TenextCloud
//
//

#import "TIoTAddFamilyVC.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTAddFamilyCell.h"
#import "TIoTMapVC.h"

@interface TIoTAddFamilyVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) TIoTSingleCustomButton *singleButton;
@end

@implementation TIoTAddFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"add_family", @"添加家庭");
    
    CGFloat kTopPadding = 20;
    CGFloat kConfimBtnTop = 24;
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(96);
        if (@available(iOS 11.0,*)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopPadding);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale + kTopPadding);
        }
    }];
    
    CGFloat kLeftPadding = 16;
    CGFloat kBackViewHeight = 40;
    
    __weak typeof(self)weakSelf = self;
    self.singleButton = [[TIoTSingleCustomButton alloc]init];
    self.singleButton.kLeftRightPadding = kLeftPadding;
    [self.singleButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"confirm", @"确定")];
    [self.singleButton singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
    self.singleButton.singleAction = ^{
        NSMutableDictionary *nameDic = weakSelf.dataArray[0];
        NSMutableDictionary *addressDic = weakSelf.dataArray[1];
        NSDictionary *param = @{@"Name":nameDic[@"value"]?:@"",@"Address":addressDic[@"addressJson"]?:@""};
        [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
            [HXYNotice addUpdateFamilyListPost];
            [weakSelf cancel];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    };
    self.singleButton.kLeftRightPadding = kLeftPadding;
    [self.view addSubview:self.singleButton];
    [self.singleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kBackViewHeight);
        make.top.equalTo(self.tableView.mas_bottom).offset(kConfimBtnTop);
    }];
}

#pragma mark -UITableViewDelegate And UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAddFamilyCell *cell = [TIoTAddFamilyCell cellForTableView:tableView];
    NSMutableDictionary *dic = self.dataArray[indexPath.row];
    cell.titleString = dic[@"title"];
    cell.placeHoldString = dic[@"placeHold"];
    cell.contectString = dic[@"value"];
    if (indexPath.row == 0) {
        cell.familyType = FillFamilyTypeFamilyName;
    }
    __weak typeof(self)weakSelf = self;
    cell.fillMessageBlock = ^(NSString * _Nonnull contentString) {
        NSMutableDictionary *tempDic = weakSelf.dataArray[indexPath.row];
        [tempDic setValue:contentString?:@"" forKey:@"value"];
        [weakSelf.tableView reloadData];
        
        //家庭名称数据源中是否有空值，有：按钮不响应，反之则允许点击
        BOOL buttonIsEnable = NO;
        if (indexPath.row == 0) {
            NSMutableDictionary *tempDic = weakSelf.dataArray[indexPath.row];
            if ([NSString isNullOrNilWithObject:tempDic[@"value"]] || [NSString isFullSpaceEmpty:tempDic[@"value"]]) {
                buttonIsEnable = NO;
            }else {
                buttonIsEnable = YES;
            }
        }
        
        if (buttonIsEnable == YES) {
            [self.singleButton singleCustomBUttonBackGroundColor:kIntelligentMainHexColor isSelected:YES];
        }else {
            [self.singleButton singleCustomBUttonBackGroundColor:kNoSelectedHexColor isSelected:NO];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        // 点击跳转 地图选点页面
        TIoTMapVC *mapVC = [[TIoTMapVC alloc]init];
        mapVC.title = NSLocalizedString(@"choose_location", @"地图选点");
        NSMutableDictionary *addressDictionary = self.dataArray[indexPath.row];
        mapVC.addressString = addressDictionary[@"value"];
        __weak typeof(self)weakSelf = self;
        mapVC.addressBlcok = ^(NSString * _Nonnull address, NSString * _Nonnull addressJson) {
            NSMutableDictionary *addressDic = weakSelf.dataArray[indexPath.row];
            [addressDic setValue:address forKey:@"value"];
            [addressDic setValue:addressJson forKey:@"addressJson"];
            [weakSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:addressDic];
            TIoTAddFamilyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.contentLabel.text = address;
            cell.contentLabel.textColor = [UIColor colorWithHexString:kRegionHexColor];
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_name", @"家庭名称"),@"value":@"",@"placeHold":NSLocalizedString(@"fill_family_name", @"请输入家庭名称")}],
                                                      [NSMutableDictionary dictionaryWithDictionary:@{@"title":NSLocalizedString(@"family_address", @"家庭位置"),@"value":@"",@"placeHold":NSLocalizedString(@"setting_family_address", @"设置位置"),@"addressJson":@""}]]];
    }
    return _dataArray;
}

- (void)cancel
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
