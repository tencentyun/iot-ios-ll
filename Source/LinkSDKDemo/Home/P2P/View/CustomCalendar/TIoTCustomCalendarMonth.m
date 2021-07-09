//
//  TIoTCustomCalendarMonth.m
//  LinkApp
//
//

#import "TIoTCustomCalendarMonth.h"
#import "NSDate+TIoTCustomCalendar.h"

@implementation TIoTCustomCalendarMonth

- (instancetype)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        self.monthDate = date;
        self.currentMonthTotalDays = [self.monthDate totalDaysInMonth];
        self.firstWeekday = [self.monthDate firstWeekDayInMonth];
        self.year = [self.monthDate dateYear];
        self.month = [self.monthDate dateMonth];
        self.day = [self.monthDate dateDay];
        self.lundarDay = [self.monthDate lundarDateDay];
    }
    return self;
}

@end
