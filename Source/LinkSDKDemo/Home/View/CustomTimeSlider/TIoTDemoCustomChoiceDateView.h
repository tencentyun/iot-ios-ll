//
//  TIoTDemoCustomChoiceDateView.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTDemoChooseDateBlock)(UIButton *button);

@interface TIoTDemoCustomChoiceDateView : UIView

@property (nonatomic, copy) TIoTDemoChooseDateBlock chooseDateBlock;
@end

NS_ASSUME_NONNULL_END
