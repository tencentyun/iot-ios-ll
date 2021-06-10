//
//  WCMessageText2Cell.m
//  TenextCloud
//
//

#import "TIoTMessageText2Cell.h"

@interface TIoTMessageText2Cell()
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end
@implementation TIoTMessageText2Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMsgData:(NSDictionary *)msgData
{
    self.titleL.text = msgData[@"MsgTitle"];
    self.contentL.text = msgData[@"MsgContent"];
    self.timeL.text = [NSString convertTimestampToTime:msgData[@"MsgTimestamp"] byDateFormat:@"yyyy-MM-dd HH:mm"];
    [self.picView setImage:[UIImage imageNamed:@"deviceDefault"]];
}

@end
