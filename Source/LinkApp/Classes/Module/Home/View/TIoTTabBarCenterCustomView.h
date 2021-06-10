//
//  TIoTTabBarCenterCustomView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTabBarCenterCustomView : UIView
@property (nonatomic, strong, readonly) UIButton *addDevice;
@property (nonatomic, strong, readonly) UIButton *scanDevice;
@property (nonatomic, strong, readonly) UIButton *addIntelligentDevice;
@property (nonatomic, strong, readonly) UIView *blackMaskView;

- (void)hideView;

@end

NS_ASSUME_NONNULL_END
