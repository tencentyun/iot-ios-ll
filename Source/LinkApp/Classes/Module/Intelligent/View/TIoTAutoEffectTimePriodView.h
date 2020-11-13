//
//  TIoTAutoEffectTimePriodView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 生效时间段自定义view
 */
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, AutoEffectPeriodRepetaType) {
//    AutoEffectPeriodRepetaTypeOnce,
    AutoEffectPeriodRepetaTypeEveryday,
    AutoEffectPeriodRepetaTypeWorkday,
    AutoEffectPeriodRepetaTypeWeekend,
    AutoEffectPeriodRepetaTypeCustom
};

@interface TIoTAutoEffectTimePriodView : UIView
@property (nonatomic, assign) NSInteger defaultRepeatTimeNum;
@end

NS_ASSUME_NONNULL_END
