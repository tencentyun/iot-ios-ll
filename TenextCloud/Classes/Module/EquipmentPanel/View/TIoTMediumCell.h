//
//  WCMediumCell.h
//  TenextCloud
//
//  Created by Wp on 2020/1/6.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCMediumCell : UICollectionViewCell
@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic, copy) void (^boolUpdate)(NSDictionary *uploadInfo);

@property (nonatomic) WCThemeStyle themeStyle;
@end

NS_ASSUME_NONNULL_END
