//
//  WCFamilyInfoVC.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTFamilyInfoVC : UIViewController

@property (nonatomic,copy) NSDictionary *familyInfo;
@property (nonatomic)  NSInteger familyCount;//家庭数量，最后一个家庭不可删除

@end

NS_ASSUME_NONNULL_END
