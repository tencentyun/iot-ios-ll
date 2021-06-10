//
//  NSDate+TIoTCustomCalendar.h
//  LinkSDKDemo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TIoTCustomCalendar)

/// 获得当前 NSDate 对应day
- (NSInteger)dateDay;

/// 获取当前 NSDate 对应 农历day
- (NSInteger)lundarDateDay;

/// 获得当前 NSDate 对应的月
- (NSInteger)dateMonth;


/// 获得当前 NSDate 对应的年
- (NSInteger)dateYear;

/// 获得当前 NSDate 的上月某一天的 NSDate
- (NSDate *)previousMonthDate;


/// 获得当前 NSDate 的下月某一天的 NSDate
- (NSDate *)nextMonthDate;


/// 获得当前 NSDate 对应的月份总天数
- (NSInteger)totalDaysInMonth;


/// 获得当前 NSDate 对应月份当月第一天的所在星期
- (NSInteger)firstWeekDayInMonth;

/// 获取当天是星期几
- (NSString *)getWeekDayWithDate;
@end

NS_ASSUME_NONNULL_END
