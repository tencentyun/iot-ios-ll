#import "AWEncoderManager.h"
#import "AWHWAACEncoder.h"
#import "AWSWFaacEncoder.h"
#import "TIoTCoreXP2PHeader.h"
@interface AWEncoderManager()
//编码器
@property (nonatomic, strong) AWAudioEncoder *audioEncoder;
@end

@implementation AWEncoderManager

-(void) openWithAudioConfig:(AWAudioConfig *) audioConfig {
    switch (self.audioEncoderType) {
        case AWAudioEncoderTypeHWAACLC:
            self.audioEncoder = [[AWHWAACEncoder alloc] init];
            break;
        case AWAudioEncoderTypeSWFAAC:
            self.audioEncoder = [[AWSWFaacEncoder alloc] init];
            break;
        default:
            DDLogInfo(@"[E] AWEncoderManager.open please assin for audioEncoderType");
            return;
    }
    
    self.audioEncoder.audioConfig = audioConfig;
    self.audioEncoder.manager = self;
    [self.audioEncoder open];
}

-(void)close{
    [self.audioEncoder close];
    self.audioEncoder = nil;
    
    self.timestamp = 0;
    
    self.audioEncoder = nil;
}

@end
