//
//  QCApiConfiguration.m
//  QCApiClient
//
//

#import "TIoTCoreServices.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreSocketManager.h"

@implementation TIoTCoreServices

+ (instancetype)shared{
    static TIoTCoreServices *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}



- (void)setAppKey:(NSString *)appkey{
    
    [TIoTCoreAppEnvironment shareEnvironment].appKey = appkey;
    _appKey = appkey;
    
    [[TIoTCoreSocketManager shared] socketOpen];
}

- (void)setLogEnable:(BOOL)logEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:logEnable forKey:@"pLogEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
