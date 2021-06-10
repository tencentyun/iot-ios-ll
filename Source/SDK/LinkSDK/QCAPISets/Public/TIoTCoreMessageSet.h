//
//  QCMessagePart.h
//  QCAccount
//
//

#import <Foundation/Foundation.h>
#import "TIoTCoreParts.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreMessageSet : NSObject

+ (instancetype)shared;

/// 获取消息
/// @param msgId 消息id，首次可不传
/// @param msgTimestamp 消息的时间戳，首次可不传或传 0
/// @param limit 最大返回条数，最大不超过100
/// @param category 主类型，1设备，2家庭，3通知
- (void)getMessagesWithMsgId:(NSString *)msgId msgTimestamp:(SInt64)msgTimestamp limit:(NSUInteger)limit category:(NSUInteger)category success:(SRHandler)success failure:(FRHandler)failure;

/// 删除消息
- (void)deleteMessageByMsgId:(NSString *)msgId success:(SRHandler)success failure:(FRHandler)failure;

/// 绑定移动推送token
- (void)bindXgToken:(NSString *)token success:(SRHandler)success failure:(FRHandler)failure;

/// 解绑移动推送token
- (void)unbindXgToken:(NSString *)token success:(SRHandler)success failure:(FRHandler)failure;

@end

NS_ASSUME_NONNULL_END
