//
//  TIoTLLSyncDeviceCell.h
//  LinkApp
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface TIoTLLSyncDeviceCell : UICollectionViewCell
@property (nonatomic, copy) NSString *itemString;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
