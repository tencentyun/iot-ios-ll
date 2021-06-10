//
//  WCAddTimeView.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WCAddTimeDelegate <NSObject>

//保存
- (void)saveData;

@end

@interface TIoTAddTimeView : UIView

@property (nonatomic, weak) id<WCAddTimeDelegate>delegate;

- (void)showView;

@end

NS_ASSUME_NONNULL_END
