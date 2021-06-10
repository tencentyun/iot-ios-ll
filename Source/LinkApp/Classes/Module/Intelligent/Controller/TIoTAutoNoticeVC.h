//
//  TIoTAutoNoticeVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

@class TIoTAutoIntelligentModel;
typedef void(^AutoAddNoticeBlock)(NSMutableArray <TIoTAutoIntelligentModel*>* _Nullable noticeArray);
typedef void(^AutoDeleteNoticeBlcok)(NSMutableArray <TIoTAutoIntelligentModel*>* _Nullable noticeArray);
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoNoticeVC : UIViewController
@property (nonatomic, copy) AutoAddNoticeBlock addNoticeBlock;

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, copy) AutoDeleteNoticeBlcok deleteNoticeBlcok;
@property (nonatomic, strong) TIoTAutoIntelligentModel *editModel;

@property (nonatomic, assign) NSInteger count; //action 个数
@end

NS_ASSUME_NONNULL_END
