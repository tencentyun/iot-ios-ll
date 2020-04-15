//
//  WCMessageInviteCell.h
//  TenextCloud
//
//  Created by Wp on 2020/3/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WCMessageInviteCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *msgData;

@property (nonatomic,strong) void (^rejectEvent) (void);

@end

