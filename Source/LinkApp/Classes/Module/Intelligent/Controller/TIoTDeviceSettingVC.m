//
//  TIoTDeviceSettingVC.m
//  LinkApp
//
//

#import "TIoTDeviceSettingVC.h"
#import "TIoTDeviceDetailTableViewCell.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAddManualIntelligentVC.h"
#import "TIoTChooseClickValueView.h"
#import "TIoTChooseSliderValueView.h"
#import "TIoTAddAutoIntelligentVC.h"
#import "TIoTAutoIntelligentModel.h"

@interface TIoTDeviceSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelliSettingTipLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;      //task 操作自定义view
@property (nonatomic, strong) TIoTChooseClickValueView *clickValueView;         //enum和bool 点击选择view
@property (nonatomic, strong) TIoTChooseSliderValueView *sliderValueView;       //int和float 滑动选择view
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) TIoTPropertiesModel *baseModel;                  //每次选择后的model

@property (nonatomic, strong) NSMutableArray *modifiedValueArray;
@property (nonatomic, strong) NSMutableArray *modifiedModelArray;
@property (nonatomic, strong) NSMutableArray *productArray;
@property (nonatomic, strong) NSString *modifiedValue;
@property (nonatomic, strong) TIoTPropertiesModel *modifiedModel;

@property (nonatomic, strong) NSMutableArray <TIoTAutoIntelligentModel *>*autoIntelModelArray;          //自动智能进入后重组的model数组
@property (nonatomic, strong) NSMutableArray <TIoTAutoIntelligentModel *>*inteliModelTempArray;         //保存用户在添加完action和condition后，没保存之前的数组
@end

@implementation TIoTDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    self.title = self.titleString?:@"";
    
    [self addEmptyIntelligentSettingTipView];
    
    CGFloat kBottomViewHeight = 90;
    
    [self.view addSubview: self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomViewHeight);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}

- (void)addEmptyIntelligentSettingTipView {
    
    CGFloat kPadding = 60;
    
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat kSpaceHeight = 55; //距离中心偏移量
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            kSpaceHeight = 100;
        }
        make.centerY.mas_equalTo(kScreenHeight/2).offset(-kSpaceHeight);
        make.left.equalTo(self.view).offset(kPadding);
        make.right.equalTo(self.view).offset(-kPadding);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            make.height.mas_equalTo(190);
        }else {
            make.height.mas_equalTo(160);
        }

    }];
    
    [self.view addSubview:self.noIntelliSettingTipLabel];
    [self.noIntelliSettingTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.emptyImageView);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDeviceDetailTableViewCell *cell = [TIoTDeviceDetailTableViewCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
// MARK: - enum和bool都是开关这种样式，int和float都是亮度这种样式
    
    self.baseModel = self.modelArray[indexPath.row];
    
    if ([self.baseModel.define.type isEqualToString:@"enum"] || [self.baseModel.define.type isEqualToString:@"bool"]) {
        //点击
        __weak typeof(self) weakSelf = self;
        self.clickValueView = [[TIoTChooseClickValueView alloc]init];
        self.clickValueView.model = self.baseModel;
        
        self.clickValueView.chooseTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model) {
            
            if ([NSString isNullOrNilWithObject:valueString]) {
                NSString *valueTempStr = weakSelf.dataArr[indexPath.row][@"value"];
                if ([valueTempStr isEqualToString:NSLocalizedString(@"unset", @"未设置")]) {
                    valueString = NSLocalizedString(@"unset", @"未设置");
                }else {
                    valueString = valueTempStr;
                }
            }
            
            NSMutableDictionary *tempDic = weakSelf.dataArr[indexPath.row];
            [tempDic setValue:valueString forKey:@"value"];
            
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.modifiedValue = valueString;
            weakSelf.modifiedModel = model;
            
            [weakSelf.modifiedValueArray addObject:weakSelf.modifiedValue];
            [weakSelf.modifiedModelArray insertObject:weakSelf.modifiedModel atIndex:0];
            [weakSelf.productArray addObject:weakSelf.productModel?:@{}];
            
// MARK: 从自动智能-添加条件-设备状态变化入口进入
            
                NSString *keyString = @"0";
                NSDictionary *mappingDic = model.define.mapping;
                if (mappingDic) {
                    for (int i= 0; i<mappingDic.allKeys.count; i++) {
                        NSString *tempValueString = [mappingDic objectForKey:mappingDic.allKeys[i]];
                        if ([valueString isEqualToString:tempValueString]) {
                            keyString = mappingDic.allKeys[i];
                        }
                    }
                }
            
                
                if (self.isEdited == YES) {
                    
                    if (self.isAutoActionType == NO) {
                        weakSelf.model.Property.conditionContentString = valueString;
                        weakSelf.model.Property.Value = [NSNumber numberWithFloat:keyString.intValue];
                    }else {
                        //修改json Data 的内容
                        weakSelf.model.dataValueString = valueString;
                        NSMutableDictionary *dataTempDic = [NSMutableDictionary dictionaryWithDictionary:[weakSelf.model yy_modelToJSONObject]];
                        NSMutableString *dataString = [NSMutableString stringWithString:weakSelf.model.Data];
                        NSDictionary *dataDic = [NSString jsonToObject:dataString];
                        
                        NSString *valueCurrentStrin = weakSelf.dataArr[indexPath.row][@"value"];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:weakSelf.model.propertyModel.define.mapping];
                        NSString *keyString = @"";
                        for (int i = 0; i<dic.allKeys.count; i++) {
                            if ([dic[dic.allKeys[i]] isEqual:valueCurrentStrin]) {
                                keyString = dic.allKeys[i];
                            }
                        }

                        [dataDic setValue:keyString forKey:dataDic.allKeys[0]];
                        NSString *jsonStrin = [NSString objectToJson:dataDic];
                        [dataTempDic setValue:jsonStrin forKey:@"Data"];
                        weakSelf.model = [TIoTAutoIntelligentModel yy_modelWithJSON:dataTempDic];
                        
                    }
                    if (weakSelf.autoIntelModelArray.count != 0) {
                        [weakSelf.autoIntelModelArray removeAllObjects];
                    }
                    [weakSelf.autoIntelModelArray addObject:weakSelf.model];
                }else {
                    
                    if (self.enterType == IntelligentEnterTypeManual) {
                        //MARK:action 手动的按action
                        
                        //创建 "Data":"{"":""}" 
                        NSString *mappKeyString = @"0";
                        NSString *idKeyString = weakSelf.baseModel.id?:@"";
                        for (int i = 0; i<weakSelf.self.baseModel.define.mapping.allValues.count; i++) {
                            if ([valueString isEqualToString:weakSelf.baseModel.define.mapping.allValues[i]]) {
                                mappKeyString = self.baseModel.define.mapping.allKeys[i];
                            }
                        }

                        NSDictionary *dataDic = @{idKeyString:mappKeyString};
                        NSString *dataString = [NSString objectToJson:dataDic];
                        
                        NSDictionary *deviceDic = @{@"ActionType":@(0),
                                                    @"ProductId":weakSelf.productModel.ProductId,
                                                    @"DeviceName":weakSelf.productModel.DeviceName,
                                                    @"AliasName":weakSelf.productModel.AliasName,
                                                    @"IconUrl":weakSelf.productModel.IconUrl,
                                                    @"Data":dataString?:@"",
                                                    @"propertyModel":model,
                        };
                        
                        
                        TIoTAutoIntelligentModel *deviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:deviceDic];
                        deviceModel.propertName = weakSelf.baseModel.name;
                        deviceModel.dataValueString =valueString;
                        
//                        [weakSelf.autoIntelModelArray addObject:deviceModel];
                        
                        [weakSelf addActionSelectModel:deviceModel selectedModelKeyString:idKeyString];
                        
                    }else if (self.enterType == IntelligentEnterTypeAuto) {
                        //MARK:自动
                        
                        //MARK:action and condition 判断
                        if (self.isAutoActionType == YES) {
                            
                            NSString *mappKeyString = @"0";
                            NSString *idKeyString = weakSelf.baseModel.id?:@"";
                            for (int i = 0; i<weakSelf.self.baseModel.define.mapping.allValues.count; i++) {
                                if ([valueString isEqualToString:weakSelf.baseModel.define.mapping.allValues[i]]) {
                                    mappKeyString = self.baseModel.define.mapping.allKeys[i];
                                }
                            }
                            
                            NSDictionary *dataDic = @{idKeyString:mappKeyString};
                            NSString *dataString = [NSString objectToJson:dataDic];
                            
                            NSDictionary *autoDeviceDic = @{@"ActionType":@(0),
                                                            @"ProductId":weakSelf.productModel.ProductId,
                                                            @"DeviceName":weakSelf.productModel.DeviceName,
                                                            @"AliasName":weakSelf.productModel.AliasName,
                                                            @"IconUrl":weakSelf.productModel.IconUrl,
                                                            @"Data":dataString?:@"",
                                                            @"type":@(2),
                                                            @"propertyModel":model,
                            };
                            TIoTAutoIntelligentModel *autoDeviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:autoDeviceDic];
                            autoDeviceModel.propertName = weakSelf.baseModel.name;
                            autoDeviceModel.dataValueString =valueString;
//                            [weakSelf.autoIntelModelArray addObject:autoDeviceModel];
                            
                            [weakSelf addActionSelectModel:autoDeviceModel selectedModelKeyString:idKeyString];
                            
                        }else {
                            NSString *timeTamp = [NSString getNowTimeString];
                            NSDictionary *autoDeviceSelectDic = @{@"ProductId":weakSelf.productModel.ProductId,
                                                                  @"DeviceName":weakSelf.productModel.DeviceName,
                                                                  @"AliasName":weakSelf.productModel.AliasName,
                                                                  @"IconUrl":weakSelf.productModel.IconUrl,
                                                                  @"PropertyId":weakSelf.baseModel.id,
                                                                  @"Op":@"eq",
                                                                  @"Value":[NSNumber numberWithFloat:keyString.intValue],
                                                                  @"conditionTitle":weakSelf.baseModel.name,
                                                                  @"conditionContentString":valueString};
                            
                            NSDictionary *autoDeviceDic = @{@"CondId":timeTamp,
                                                            @"CondType":@(0), //0是设备
                                                            @"Property":autoDeviceSelectDic,
                                                            @"type":@(0),
                                                            @"propertyModel":model};
                            TIoTAutoIntelligentModel *autoDeviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:autoDeviceDic];
//                            [weakSelf.autoIntelModelArray addObject:autoDeviceModel];
                            [weakSelf addConditionSelectModel:autoDeviceModel selectedModelKeyString:weakSelf.baseModel.id];
                            
                        }

                    }
                }
                
        };
        
        [[UIApplication sharedApplication].delegate.window addSubview:self.clickValueView];
        [self.clickValueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                }else {
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
        
    }else if ([self.baseModel.define.type isEqualToString:@"int"] || [self.baseModel.define.type isEqualToString:@"float"]) {
        //滑动
        
        __weak typeof(self) weakSelf = self;
        self.sliderValueView = [[TIoTChooseSliderValueView alloc]init];
        self.sliderValueView.model = self.baseModel;
        self.sliderValueView.conditionModel = self.model;
        self.sliderValueView.isAutoIntellignet = self.enterType;
        self.sliderValueView.isActionType = self.isAutoActionType;
        
        self.sliderValueView.sliderTaskValueBlock = ^(NSString * _Nonnull valueString, TIoTPropertiesModel * _Nonnull model, NSString * _Nonnull numberStr, NSString * _Nonnull compareValue) {
            if ([NSString isNullOrNilWithObject:valueString]) {
                NSString *valueTempStr = weakSelf.dataArr[indexPath.row][@"value"];
                if ([valueTempStr isEqualToString:NSLocalizedString(@"unset", @"未设置")]) {
                    valueString = NSLocalizedString(@"unset", @"未设置");
                }else {
                    valueString = valueTempStr;
                }
            }
            
            NSMutableDictionary *tempDic = weakSelf.dataArr[indexPath.row];
            [tempDic setValue:valueString forKey:@"value"];
            
            NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[selectedPath] withRowAnimation:UITableViewRowAnimationNone];
            
            weakSelf.modifiedValue = valueString;
            weakSelf.modifiedModel = model;
            [weakSelf.modifiedValueArray addObject:weakSelf.modifiedValue];
            [weakSelf.modifiedModelArray insertObject:weakSelf.modifiedModel atIndex:0];
            [weakSelf.productArray addObject:weakSelf.productModel?:@{}];
            
            // MARK: 从自动智能-添加条件-设备状态变化入口进入
                
                if (self.isEdited == YES) {
                    
                    if (self.isAutoActionType == NO) {
                        
                        weakSelf.model.Property.conditionContentString = valueString;
                        weakSelf.model.Property.Op = compareValue;
                        if ([weakSelf.baseModel.define.type isEqualToString:@"int"]) {
                            weakSelf.model.Property.Value = [NSNumber numberWithFloat:numberStr.intValue];
                        }else if ([weakSelf.baseModel.define.type isEqualToString:@"float"]) {
                            weakSelf.model.Property.Value = [NSNumber numberWithFloat:numberStr.floatValue];
                        }
                        
                    }else {
                        //修改json Data 的内容
                        weakSelf.model.dataValueString = valueString;
                        NSMutableDictionary *dataTempDic = [NSMutableDictionary dictionaryWithDictionary:[weakSelf.model yy_modelToJSONObject]];
                        NSMutableString *dataString = [NSMutableString stringWithString:weakSelf.model.Data];
                        NSDictionary *dataDic = [NSString jsonToObject:dataString];
                        
                        NSNumber *sliderValue = dataDic.allValues[0];
                        if ([weakSelf.baseModel.define.type isEqualToString:@"int"]) {
                            NSString *value = [valueString stringByReplacingOccurrencesOfString:weakSelf.baseModel.define.unit withString:@""];
                            sliderValue = [NSNumber numberWithFloat:value.intValue];
                        }else if ([weakSelf.baseModel.define.type isEqualToString:@"float"]) {
                            sliderValue = [NSNumber numberWithFloat:numberStr.floatValue];
                        }

                        [dataDic setValue:sliderValue forKey:dataDic.allKeys[0]];
                        NSString *jsonStrin = [NSString objectToJson:dataDic];
                        [dataTempDic setValue:jsonStrin forKey:@"Data"];
                        weakSelf.model = [TIoTAutoIntelligentModel yy_modelWithJSON:dataTempDic];
                        
                    }
                    if (weakSelf.autoIntelModelArray.count != 0) {
                        [weakSelf.autoIntelModelArray removeAllObjects];
                    }
                    [weakSelf.autoIntelModelArray addObject:weakSelf.model];
                    
                }else {
                    
                    if (self.enterType == IntelligentEnterTypeManual) {
                        //MARK:手动的按action
                        NSString *idKeyString = weakSelf.baseModel.id?:@"";
                        NSDictionary *dataDic = [NSDictionary dictionary];
                        if ([weakSelf.baseModel.define.type isEqualToString:@"int"]) {
                            NSString *value = [valueString stringByReplacingOccurrencesOfString:weakSelf.baseModel.define.unit withString:@""];
                            dataDic = @{idKeyString:@(value.intValue)};
                        }else if ([weakSelf.baseModel.define.type isEqualToString:@"float"]) {
                            dataDic = @{idKeyString:@(numberStr.floatValue)};
                        }
                        NSString *dataJsonString = [NSString objectToJson:dataDic];
                        
                        NSDictionary *deviceDic = @{@"ActionType":@(0),
                                                    @"ProductId":weakSelf.productModel.ProductId,
                                                    @"DeviceName":weakSelf.productModel.DeviceName,
                                                    @"AliasName":weakSelf.productModel.AliasName,
                                                    @"IconUrl":weakSelf.productModel.IconUrl,
                                                    @"Data":dataJsonString?:@"",
                                                    @"propertyModel":model,};
                        
                        TIoTAutoIntelligentModel *deviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:deviceDic];
                        deviceModel.propertName = weakSelf.baseModel.name;
                        deviceModel.dataValueString =valueString;
//                        [weakSelf.autoIntelModelArray addObject:deviceModel];
                        
                        [weakSelf addActionSelectModel:deviceModel selectedModelKeyString:idKeyString];
                        
                    }else if (self.enterType == IntelligentEnterTypeAuto) {
                        //MARK:自动
                        
                        if (self.isAutoActionType == YES) {
                            
                            NSString *idKeyString = weakSelf.baseModel.id?:@"";
                            NSDictionary *dataDic = [NSDictionary dictionary];
                            if ([weakSelf.baseModel.define.type isEqualToString:@"int"]) {
                                NSString *value = [valueString stringByReplacingOccurrencesOfString:weakSelf.baseModel.define.unit withString:@""];
                                dataDic = @{idKeyString:@(value.intValue)};
                            }else if ([weakSelf.baseModel.define.type isEqualToString:@"float"]) {
                                dataDic = @{idKeyString:@(numberStr.floatValue)};
                            }
                            NSString *dataJsonString = [NSString objectToJson:dataDic];
                            
                            NSDictionary *autoDeviceDic = @{@"ActionType":@(0),
                                                            @"ProductId":weakSelf.productModel.ProductId,
                                                            @"DeviceName":weakSelf.productModel.DeviceName,
                                                            @"AliasName":weakSelf.productModel.AliasName,
                                                            @"IconUrl":weakSelf.productModel.IconUrl,
                                                            @"Data":dataJsonString?:@"",
                                                            @"type":@(2),
                                                            @"propertyModel":model,
                            };
                            TIoTAutoIntelligentModel *autoDeviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:autoDeviceDic];
                            autoDeviceModel.propertName = weakSelf.baseModel.name;
                            autoDeviceModel.dataValueString =valueString;
//                            [weakSelf.autoIntelModelArray addObject:autoDeviceModel];
                            
                            [weakSelf addActionSelectModel:autoDeviceModel selectedModelKeyString:idKeyString];
                            
                        }else{
                            NSString *timeTamp = [NSString getNowTimeString];
                            NSDictionary *autoDeviceSelectDic = @{@"ProductId":weakSelf.productModel.ProductId,
                                                                  @"DeviceName":weakSelf.productModel.DeviceName,
                                                                  @"AliasName":weakSelf.productModel.AliasName,
                                                                  @"IconUrl":weakSelf.productModel.IconUrl,
                                                                  @"PropertyId":weakSelf.baseModel.id,
                                                                  @"Op":compareValue,
                                                                  @"Value":[NSNumber numberWithFloat:numberStr.floatValue],
                                                                  @"conditionTitle":weakSelf.baseModel.name,
                                                                  @"conditionContentString":valueString};
                            
                            NSDictionary *autoDeviceDic = @{@"CondId":timeTamp,
                                                            @"CondType":@(0),
                                                            @"Property":autoDeviceSelectDic,
                                                            @"type":@(0),
                                                            @"propertyModel":model};
                            TIoTAutoIntelligentModel *autoDeviceModel = [TIoTAutoIntelligentModel yy_modelWithJSON:autoDeviceDic];
                            
//                            [weakSelf.autoIntelModelArray addObject:autoDeviceModel];
                            [weakSelf addConditionSelectModel:autoDeviceModel selectedModelKeyString:weakSelf.baseModel.id];
                        }
                    }

                }
        };

        [[UIApplication sharedApplication].delegate.window addSubview:self.sliderValueView];
        [self.sliderValueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo([UIApplication sharedApplication].delegate.window);
            if ([TIoTUIProxy shareUIProxy].iPhoneX) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
                }else {
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
    }
    
}

#pragma mark - event
- (id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

//MARK:获取到选择action项的结果
- (void)addActionSelectModel:(TIoTAutoIntelligentModel *)deviceModel selectedModelKeyString:(NSString *)idKeyString{
    if (self.inteliModelTempArray.count == 0) {
        [self.inteliModelTempArray addObject:deviceModel];
    }else {
        NSArray *tempIntelliModelArray = [self.inteliModelTempArray copy];
        
        NSMutableArray *tempDataKeyArray = [NSMutableArray array];
        
        //先筛选，替换重复选择的相同项
        for (int k = 0; k<tempIntelliModelArray.count; k++) {
            TIoTAutoIntelligentModel *model = tempIntelliModelArray[k];
            NSString *dataString =  model.Data;
            NSDictionary *dataDic = [NSString jsonToObject:dataString];
            [tempDataKeyArray addObjectsFromArray:dataDic.allKeys];
            
            if ([dataDic.allKeys containsObject:idKeyString?:@""]) {
                [self.inteliModelTempArray replaceObjectAtIndex:k withObject:deviceModel];
                
            }
        }
        
        //若数组中没有 再添加
        if (![tempDataKeyArray containsObject:idKeyString]) {
            [self.inteliModelTempArray addObject:deviceModel];
        }
    }
}

//MARK:获取到选择condition项的结果
- (void)addConditionSelectModel:(TIoTAutoIntelligentModel *)deviceModel selectedModelKeyString:(NSString *)idKeyString {
    if (self.inteliModelTempArray.count == 0) {
        [self.inteliModelTempArray addObject:deviceModel];
    }else {
        NSArray *tempIntelliModelArray = [self.inteliModelTempArray copy];
        NSMutableArray *tempDataKeyArray = [NSMutableArray array];
        
        //先筛选，替换重复选择的相同项
        for (int k = 0; k<tempIntelliModelArray.count; k++) {
            TIoTAutoIntelligentModel *model = tempIntelliModelArray[k];
            NSString *idKey = model.Property.PropertyId;
            [tempDataKeyArray addObject:idKey];
            
            if ([idKey isEqualToString:idKeyString]) {
                [self.inteliModelTempArray replaceObjectAtIndex:k withObject:deviceModel];
            }
        }
        
        //若数组中没有 再添加
        if (![tempDataKeyArray containsObject:idKeyString]) {
            [self.inteliModelTempArray addObject:deviceModel];
        }
        
    }
}

#pragma mark - lazy loading
- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _emptyImageView;
}


- (UILabel *)noIntelliSettingTipLabel {
    if (!_noIntelliSettingTipLabel) {
        _noIntelliSettingTipLabel = [[UILabel alloc]init];
        _noIntelliSettingTipLabel.text = NSLocalizedString(@"no_intelligent_device", @"该设备暂无功能可作为智能任务，试试其他设备吧");
        _noIntelliSettingTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelliSettingTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelliSettingTipLabel.textAlignment = NSTextAlignmentCenter;
        _noIntelliSettingTipLabel.numberOfLines = 0;
    }
    return _noIntelliSettingTipLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 48;
    }
    return _tableView;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            if (weakSelf.clickValueView) {
                [weakSelf.clickValueView removeFromSuperview];
            }
            if (weakSelf.sliderValueView) {
                [weakSelf.sliderValueView removeFromSuperview];
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        _bottomView.secondBlock = ^{
            if (weakSelf.clickValueView) {
                [weakSelf.clickValueView removeFromSuperview];
            }
            if (weakSelf.sliderValueView) {
                [weakSelf.sliderValueView removeFromSuperview];
            }
#warning 保存然后刷新添加智能tableView
            if ([NSString isNullOrNilWithObject:weakSelf.modifiedValue] || [NSString isNullOrNilWithObject:weakSelf.modifiedModel]) {
                
                TIoTAddManualIntelligentVC *vc = [weakSelf findViewController:NSStringFromClass([TIoTAddManualIntelligentVC class])];
                if (vc) {
                    // 找到需要返回的控制器的处理方式
                    [weakSelf.navigationController popToViewController:vc animated:YES];
                }else{
                    
                    //MARK:从自动智能入口进入，为空则返回
                    TIoTAddAutoIntelligentVC * addAutoVC = [weakSelf findViewController:NSStringFromClass([TIoTAddAutoIntelligentVC class])];
                    if (addAutoVC) {
                        [weakSelf.navigationController popToViewController:addAutoVC animated:YES];
                    }else {
                        // 没找到需要返回的控制器的处理方式
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
                
            }else {
                
                TIoTAddManualIntelligentVC *vc = [weakSelf findViewController:NSStringFromClass([TIoTAddManualIntelligentVC class])];
                if (vc) {
                    // 找到需要返回的控制器的处理方式
                    
                    vc.isEdited = weakSelf.isEdited;
                    vc.actionType = IntelligentActioinTypeManual;
                    vc.valueStringIndexPath = weakSelf.editActionIndex;
                    if (weakSelf.isEdited == YES) {
                        vc.isEdited = weakSelf.isEdited;
                    }else {
                        for (int i = 0; i<weakSelf.modifiedModelArray.count; i++) {
                            [weakSelf.actionOriginArray addObject:weakSelf.modifiedModelArray[i]];
                        }
                        for (int j = 0; j<weakSelf.modifiedValueArray.count; j++) {
                            [weakSelf.valueOriginArray addObject:weakSelf.modifiedValueArray[j]];
                        }
                    }
                    vc.taskArray = weakSelf.actionOriginArray;
                    vc.valueArray = weakSelf.valueOriginArray;
                    vc.productModel = weakSelf.productModel;
                    vc.valueString = weakSelf.modifiedValue;

//                    vc.autoDeviceStatusArray = weakSelf.autoIntelModelArray;
//                    [vc refreshIntelligentManualModifyModel:weakSelf.autoIntelModelArray originIndex:weakSelf.editActionIndex isEdit:weakSelf.isEdited];
//
                    
                    if (weakSelf.actionArrayCount + weakSelf.inteliModelTempArray.count <=20) { //判断不超过限制时，再添加用户创建的设备condition 和 action
                        
                        [weakSelf.autoIntelModelArray addObjectsFromArray:weakSelf.inteliModelTempArray];
                        vc.autoDeviceStatusArray = weakSelf.autoIntelModelArray;
                        [vc refreshIntelligentManualModifyModel:weakSelf.autoIntelModelArray originIndex:weakSelf.editActionIndex isEdit:weakSelf.isEdited];
                        
                        [weakSelf.navigationController popToViewController:vc animated:YES];
                    }else {
                        if (weakSelf.isAutoActionType == NO) {
                            [MBProgressHUD showMessage:NSLocalizedString(@"maximum_twenty_action", @"最多添加20个条件") icon:@""];
                        }else if (weakSelf.isAutoActionType == YES) {
                            [MBProgressHUD showMessage:NSLocalizedString(@"maximum_twenty_action", @"最多添加20个任务") icon:@""];
                        }
                    }
                    
                }else{
                    
                    //MARK:从自动智能入口进入，将选择好的condition数据返回
                    TIoTAddAutoIntelligentVC * addAutoVC = [weakSelf findViewController:NSStringFromClass([TIoTAddAutoIntelligentVC class])];
                    if (addAutoVC) {
                        
                        addAutoVC.productModel = weakSelf.productModel;
                        
                        NSInteger number = 0;
                        
                        if (self.isAutoActionType == YES) {
                            number = self.actionArrayCount;
                        }else {
                            number = self.conditionArrayCount;
                        }
                        
                        if (number + weakSelf.inteliModelTempArray.count <=20) { //判断不超过限制时，再添加用户创建的设备condition 和 action
                            
                            [weakSelf.autoIntelModelArray addObjectsFromArray:weakSelf.inteliModelTempArray];
                            addAutoVC.autoDeviceStatusArray = weakSelf.autoIntelModelArray;
                            //autoIntelModelArray 每次编辑只有一项，所以数组中始终有且仅有一个TIoTPropertiesModel
                            [addAutoVC refreshAutoIntelligentList:weakSelf.isAutoActionType modifyModel:weakSelf.autoIntelModelArray[0] originIndex:weakSelf.editActionIndex isEdit:weakSelf.isEdited];
                            [weakSelf.navigationController popToViewController:addAutoVC animated:YES];
                            
                        }else {
                            if (weakSelf.isAutoActionType == NO) {
                                [MBProgressHUD showMessage:NSLocalizedString(@"maximum_twenty_action", @"最多添加20个条件") icon:@""];
                            }else if (weakSelf.isAutoActionType == YES) {
                                [MBProgressHUD showMessage:NSLocalizedString(@"maximum_twenty_action", @"最多添加20个任务") icon:@""];
                            }
                        }
                        
//                        //autoIntelModelArray 每次编辑只有一项，所以数组中始终有且仅有一个TIoTPropertiesModel
//                        [addAutoVC refreshAutoIntelligentList:weakSelf.isAutoActionType modifyModel:weakSelf.autoIntelModelArray[0] originIndex:weakSelf.editActionIndex isEdit:weakSelf.isEdited];
//                        [weakSelf.navigationController popToViewController:addAutoVC animated:YES];
                    }else {
                        // 没找到需要返回的控制器的处理方式
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                    
                }
            }
            
        };
        
    }
    return _bottomView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        
        //MARK: enum 、bool 列表选择值 ; int float 滑动选择值
        NSArray *propertiesArray = nil;
        if (self.isEdited == YES) {
            if (self.editedModel) {
                propertiesArray = @[self.editedModel];
            }else {
                propertiesArray = @[];
            }
        }else {
            propertiesArray = [NSArray arrayWithArray:self.templateModel.properties];
        }
        
        self.modelArray = [propertiesArray mutableCopy];
//        for (TIoTPropertiesModel *baseModel in propertiesArray) {
//            if ([baseModel.mode isEqualToString:@"r"] || [baseModel.define.type isEqualToString:@"string"] || [baseModel.required isEqualToString:@"1"] ||([NSString isNullOrNilWithObject:baseModel.mode] || [NSString isNullOrNilWithObject:baseModel.required] || [NSString isNullOrNilWithObject:baseModel.define.type])) {
//                [self.modelArray removeObject:baseModel];
//            }
//        }
        
        for (TIoTPropertiesModel *baseModel in self.modelArray) {
            
            NSString *valueSteing = NSLocalizedString(@"unset", @"未设置");
            if (self.isEdited == YES) {
                valueSteing = self.valueString?:@"";
            }
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":baseModel.name?:@"",@"value":valueSteing,@"needArrow":@"1"}];
            [_dataArr addObject:tempDic];
        }
        
        if (_dataArr.count == 0) {
            self.tableView.hidden = YES;
            self.bottomView.hidden = YES;
        }else {
            self.tableView.hidden = NO;
            self.bottomView.hidden = NO;
        }
        
        
    }
    
    return _dataArr;
}

- (NSMutableArray *)modifiedValueArray {
    if (!_modifiedValueArray) {
        _modifiedValueArray = [NSMutableArray array];
    }
    return _modifiedValueArray;
}

- (NSMutableArray *)modifiedModelArray {
    if (!_modifiedModelArray) {
        _modifiedModelArray = [NSMutableArray array];
    }
    return _modifiedModelArray;
}

- (NSMutableArray *)productArray {
    if (!_productArray) {
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}

- (NSMutableArray *)autoIntelModelArray {
    if (!_autoIntelModelArray) {
        _autoIntelModelArray = [NSMutableArray array];
    }
    return _autoIntelModelArray;
}

- (NSMutableArray *)inteliModelTempArray {
    if (!_inteliModelTempArray) {
        _inteliModelTempArray = [NSMutableArray array];
    }
    return _inteliModelTempArray;
}
@end
