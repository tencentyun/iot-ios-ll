//
//  TUIUtils.m
//  TXIMSDK_TUIKit_iOS
//
//

#import "TRTCCallingUtils.h"
#import "TIoTCoreWMacros.h"

@implementation TRTCCallingUtils

+ (TRTCCallingUtils *)shareInstance {
    static dispatch_once_t onceToken;
    static TRTCCallingUtils *g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TRTCCallingUtils alloc] init];
    });
    return g_sharedInstance;
}

// 实际项目中建议由后台生成一个唯一 roomID，防止 roomID 重复
+ (UInt32)generateRoomID {
    // android 最大值是 int32，roomID 不能为 0
    UInt32 random = 1 + arc4random() % (INT32_MAX - 1);
    return random;
}

+ (NSString *)loginUser {
    return @"IM_User";
}

+ (void)getCallUserModel:(NSString *)userID finished:(void(^)(CallUserModel *))finished {
    
            CallUserModel *model = [[CallUserModel alloc] init];
            model.name = @"info.nickName";
            model.avatar = @"info.faceURL";
            model.userId = @"info.userID";
            finished(model);
}

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[self dictionary2JsonData:dict] encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        DDLogError(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            DDLogError(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        DDLogError(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        DDLogError(@"Json parse failed");
        return nil;
    }
    return dic;
}


@end
