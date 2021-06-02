//
//  TIoTCustomCalendar.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTSelectedDateBlock)(NSString *dateString);

@interface TIoTCustomCalendar : UIView
- (instancetype)initCalendarFrame:(CGRect)frame;

@property (nonatomic, copy) TIoTSelectedDateBlock selectedDateBlock;

/**
  日期数组 item:@"2021-1-1"
 */
@property (nonatomic, strong) NSArray <NSString *>*dateArray;
@end

NS_ASSUME_NONNULL_END
