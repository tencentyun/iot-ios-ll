//
//  WCTimerCell.m
//  TenextCloud
//
//

#import "TIoTCoreTimerCell.h"

@interface TIoTCoreTimerCell()

@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *addIcon;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *detailL;

@end
@implementation TIoTCoreTimerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActionInfo:(NSDictionary *)actionInfo
{
    _actionInfo = actionInfo;
    self.nameL.text = actionInfo[@"name"];
    self.detailL.text = actionInfo[@"content"];
    if ([actionInfo[@"isAdd"] boolValue]) {
        self.addIcon.hidden = NO;
        self.detailView.hidden = YES;
    }
    else
    {
        self.addIcon.hidden = YES;
        self.detailView.hidden = NO;
    }
}

@end
