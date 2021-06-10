//
//  TIoTDeviceSettingVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IntelligentEnterType) {
    IntelligentEnterTypeManual,
    IntelligentEnterTypeAuto,
};

/**
 设备设置页面
 */
@interface TIoTDeviceSettingVC : UIViewController
@property (nonatomic, strong) TIoTDataTemplateModel *templateModel;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;  //创建的时候传
//@property (nonatomic, strong) NSMutableArray <TIoTIntelligentProductConfigModel*>*productModelArray; //保存的时候传递
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, strong) TIoTPropertiesModel *editedModel;
@property (nonatomic, copy) NSString *valueString;
@property (nonatomic, assign) NSInteger editActionIndex;
@property (nonatomic, strong) NSMutableArray *actionOriginArray;
@property (nonatomic, strong) NSMutableArray *valueOriginArray;

@property (nonatomic, assign) IntelligentEnterType enterType; //
@property (nonatomic, assign) BOOL isAutoActionType;    //自动智能任务入口 (包含在自动智能enterType里 yes 任务入口，no 条件入口） 主动创建的也要设置为NO
@property (nonatomic, strong) TIoTAutoIntelligentModel *model; //智能主页传入的model，编辑时候必须用model更新数据再回传
@property (nonatomic, assign) NSInteger actionArrayCount; //现有action数组个数
@property (nonatomic, assign) NSInteger conditionArrayCount; //现有condition数组个数

@property (nonatomic, strong) NSString *titleString; //编辑情况下，显示别名或设备名
@end

NS_ASSUME_NONNULL_END
