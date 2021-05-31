//
//  UIBarButtonItem+TIoTDemoCustomUI.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (TIoTDemoCustomUI)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage;
@end

NS_ASSUME_NONNULL_END
