//
//  TIoTShortcutView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

/**
 设备快捷入口View
 */
NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTEnterDevicePanel)(void);
@interface TIoTShortcutView : UIView
@property (nonatomic, copy) TIoTEnterDevicePanel moreFunctionBlock;


/// 设置设备快捷入口视图

- (void)shortcutViewData:(NSDictionary *)config productId:(NSString *)productId deviceDic:(NSMutableDictionary *)deviceDic withDeviceName:aliasName shortcutArray:(NSArray *)shortcutArray;
@end

NS_ASSUME_NONNULL_END
