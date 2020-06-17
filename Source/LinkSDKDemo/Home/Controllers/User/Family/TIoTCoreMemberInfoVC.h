//
//  WCMemberInfoVC.h
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreMemberInfoVC : UIViewController

@property (nonatomic) BOOL isOwner;
@property (nonatomic,copy) NSDictionary *memberInfo;
@property (nonatomic,copy) NSString *familyId;


@end

NS_ASSUME_NONNULL_END
