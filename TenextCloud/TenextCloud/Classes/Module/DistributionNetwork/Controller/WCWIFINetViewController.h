//
//  WCSmartConfigDisNetViewController.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EquipmentType) {
    SmartConfig,
    Softap,
};

NS_ASSUME_NONNULL_BEGIN

@interface WCWIFINetViewController : UIViewController

@property (nonatomic, assign) EquipmentType equipmentType;

@end

NS_ASSUME_NONNULL_END
