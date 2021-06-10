//
//  TIoTUserConfigModel.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTUserConfigModel : NSObject
@property (nonatomic, assign) NSInteger EnableWechatPush;
@property (nonatomic, assign) NSInteger EnableDeviceMessagePush;
@property (nonatomic, assign) NSInteger EnableFamilyMessagePush;
@property (nonatomic, assign) NSInteger EnableNotifyMessagePush;
@property (nonatomic, assign) NSInteger AllowEditions;
@property (nonatomic, assign) NSInteger UsingEdition;
@property (nonatomic, copy) NSString *TemperatureUnit;
@property (nonatomic, copy) NSString *Region;
@end

NS_ASSUME_NONNULL_END
