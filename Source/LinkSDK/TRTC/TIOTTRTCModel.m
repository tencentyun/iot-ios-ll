//
//  TIOTTRTCModel.m
//  TIoTLinkKit.default-TRTC
//
//  Created by eagleychen on 2020/11/19.
//

#import "TIOTTRTCModel.h"

@implementation TIOTTRTCModel

@end

@implementation TIOTtrtcPayloadParamModel

@end

@implementation TIOTtrtcPayloadModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"params":[TIOTtrtcPayloadParamModel class]};
}
@end
