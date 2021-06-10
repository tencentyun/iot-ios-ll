//
//  UIDevice+Until.h
//  SEEXiaodianpu
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Until)

/**
 获取设备型号
 */
+ (NSString *)deviceModel;

/**
 手机名称
 */
+ (NSString *)name;

/**
 系统名称
 */
+ (NSString *)systemName;

/**
 分辨率
 */
+ (NSString *)resolution;

/**
 cup核数
 */
+ (NSString *)countofCores;

@end

NS_ASSUME_NONNULL_END
