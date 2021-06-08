//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"
#import "NSString+Extension.h"
#import "TIoTCustomTimeSlider.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "NSDate+TIoTCustomCalendar.h"

#import "TIoTCoreAppEnvironment.h"
#import <YYModel.h>
#import "TIoTCloudStorageDateModel.h"
#import "TIoTCloudStorageDayTimeListModel.h"

#import "TIoTDemoCustomChoiceDateView.h"
#import "TIoTDemoCalendarCustomView.h"
#import "TIoTDemoPlaybackCustomCell.h"
#import "TIoTExploreDeviceListModel.h"
#import "TIoTDemoCloudEventListModel.h"
#import "TIoTDemoCloudStoreDateListModel.h"
#import "TIoTDemoCloudStoreFullVideoUrl.h"

static CGFloat const kPadding = 16;
static NSString *const kPlaybackCustomCellID = @"kPlaybackCustomCellID";
static NSInteger const kLimit = 999;

@interface TIoTCloudStorageVC ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSString *dayDateString; //选择天日期
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (atomic, retain) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSArray *timeList; //原始时间
@property (nonatomic, strong) NSMutableArray *modelArray; //重组后存放时间数组

@property (nonatomic, assign) CGFloat kTopPadding; //距离日历间距
@property (nonatomic, assign) CGFloat kLeftPadding; //左边距
@property (nonatomic, assign) CGFloat kItemWith; //每一天长度
@property (nonatomic, assign) CGFloat kScrollContentWidth; // 总长度
@property (nonatomic, assign) CGFloat kSliderHeight; //自定义slider高度

@property (nonatomic, strong) TIoTDemoCustomChoiceDateView *choiceDateView; //自定义滚动条
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray; //云存事件列表数组
@property (nonatomic, strong) NSArray *cloudStoreDateList;

@property (nonatomic, copy) NSString *currentDayTime; //当天时间 2020-1-1
@property (nonatomic, strong) TIoTDemoCloudStoreFullVideoUrl *fullVideoURl;
@property (nonatomic, strong) TIoTDemoCloudEventListModel *listModel;
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializaVariable];
    
    [self setupUIViews];
    
    //获取具有云存日期
    [self requestCloudStorageDateList];
    
    //获取某一天云存时间轴
    [self requestCloudStorageDayDate];
    
    //云存事件列表
    [self requestCloudStoreVideoList];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
}

- (void)initializaVariable {
    self.dayDateString = @"";
    self.kTopPadding = 15; //距离日历间距
    self.kLeftPadding = 65; //左边距
    self.kItemWith = 60; //每一小时长度
    self.kScrollContentWidth = self.kItemWith * 24 + self.kLeftPadding*2; // 总长度
    self.kSliderHeight = 30; //自定义slider高度
    self.videoUrl = @"";
    
    NSDate *date = [NSDate date];
    NSInteger year = [date dateYear];
    NSInteger month = [date dateMonth];
    NSInteger day = [date dateDay];
    self.currentDayTime = [NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)year,(long)month,(long)day];
}

- (void)setupUIViews {
    
    [self initializedVideo];
    
    self.title = @"回放";
    
    self.view.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    
    __weak typeof(self) weakSelf = self;
    self.choiceDateView = [[TIoTDemoCustomChoiceDateView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), kScreenWidth, 116)];
    //从日历中选日期
    self.choiceDateView.chooseDateBlock = ^(UIButton * _Nonnull button) {
        
        TIoTDemoCalendarCustomView *calendarView = [[TIoTDemoCalendarCustomView alloc]init];
        //获取云存时间传给日历
        calendarView.calendarDateArray = weakSelf.cloudStoreDateList;
        
        calendarView.choickDayDateBlock = ^(NSString * _Nonnull dayDateString) {
            //更新选择日期时间，并重新请求云存列表刷新UI
            [weakSelf.choiceDateView resetSelectedDate:dayDateString];
            weakSelf.currentDayTime = dayDateString?:weakSelf.currentDayTime;
            //刷新云存事件列表和一天时间抽
            [weakSelf requestCloudStorageDayDate];
            [weakSelf requestCloudStoreVideoList];
            
        };
        [[UIApplication sharedApplication].delegate.window addSubview:calendarView];
        [calendarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
        
    };
    //选择之前事件，获取开始/结束时间戳
    self.choiceDateView.previousDateBlcok = ^(TIoTTimeModel * _Nonnull preTimeModel) {
        
    };
    //选择下一个事件，获取开始/结束时间戳
    self.choiceDateView.nextDateBlcok = ^(TIoTTimeModel * _Nonnull nextTimeModel) {
        
    };
    //滑动停止后，获取当前值所在事件开始/结束时间戳
    self.choiceDateView.timeModelBlock = ^(TIoTTimeModel * _Nonnull selectedTimeModel, CGFloat startTimestamp) {
        NSLog(@"--%f--%f",startTimestamp,selectedTimeModel.startTime);
    };
    [self.view addSubview:self.choiceDateView];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 84;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TIoTDemoPlaybackCustomCell class] forCellReuseIdentifier:kPlaybackCustomCellID];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.choiceDateView.mas_bottom).offset(kPadding);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - network request

//MARK: 获取具有云存日期
- (void)requestCloudStorageDateList {
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"DeviceName"] = self.eventModel.DeviceName?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageDate vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudStoreDateListModel *dateList = [TIoTDemoCloudStoreDateListModel yy_modelWithJSON:responseObject];
        if (dateList.Data.count != 0) {
            self.cloudStoreDateList = [NSArray arrayWithArray:dateList.Data];
        }
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

//MARK:获取某一天云存时间轴
- (void)requestCloudStorageDayDate {
  
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"DeviceName"] = self.eventModel.DeviceName?:@"";
    paramDic[@"Date"] = self.currentDayTime?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageTime vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTCloudStorageDayTimeListModel *data = [TIoTCloudStorageDayTimeListModel yy_modelWithJSON:responseObject[@"Data"]];
        
        //data.VideoURL 需要拼接
        self.timeList = [NSArray arrayWithArray:data.TimeList?:@[]];
        
        [self recombineTimeSegmentWithTimeArray:self.timeList];
        
        self.choiceDateView.videoTimeSegmentArray = self.modelArray;
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

///MARK: 获取视频防盗链播放URL
- (void)getFullVideoURLWithPartURL:(NSString *)videoPartURL withTime:(TIoTDemoCloudEventModel *)timeModel
{
    NSString *currentStamp = [NSString getNowTimeString];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"VideoURL"] = [NSString stringWithFormat:@"%@?starttime_epoch=%ld&endtime_epoch=%ld",videoPartURL,(long)timeModel.StartTime.integerValue,(long)timeModel.EndTime.integerValue]?:@"";
    paramDic[@"ExpireTime"] = [NSNumber numberWithInteger:currentStamp.integerValue + 3600];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:GenerateSignedVideoURL vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudStoreFullVideoUrl *fullVideoURl = [TIoTDemoCloudStoreFullVideoUrl yy_modelWithJSON:responseObject];
        
        //播放
        [self stopPlayMovie];
        self.videoUrl = fullVideoURl.SignedVideoURL?:@"";
        [self configVideo];
        [self.player prepareToPlay];
        [self.player play];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

///MARK: 云存事件列表
- (void)requestCloudStoreVideoList {
    
    NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",self.currentDayTime?:@""];
    NSString *endString = [NSString stringWithFormat:@"%@ 23:59:59",self.currentDayTime?:@""];
    NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    NSString *endTimesstampString = [NSString getTimeStampWithString:endString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"Size"] = [NSNumber numberWithInteger:kLimit];
    paramDic[@"DeviceName"] = self.eventModel.DeviceName?:@"";
    paramDic[@"StartTime"] = [NSNumber numberWithInteger:startTimestampString.integerValue];
    paramDic[@"EndTime"] = [NSNumber numberWithInteger:endTimesstampString.integerValue];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageEvents vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        
        self.listModel = [TIoTDemoCloudEventListModel yy_modelWithJSON:responseObject];
        
        if (self.listModel.Events.count != 0) {
            self.dataArray = [NSMutableArray arrayWithArray:self.listModel.Events?:@[]];
            self.dataArray = (NSMutableArray *)[[self.dataArray reverseObjectEnumerator] allObjects];
            [self getFullVideoURLWithPartURL:self.listModel.VideoURL?:@"" withTime:self.dataArray[0]];
            [self.tableView reloadData];
            
            [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    TIoTDemoCloudEventModel *model = obj;
                    [self requestCloudStoreUrlWithThumbnail:model index:idx];
                });
                
            }];
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

    }];
}

///MARK: 云存事件缩略图
- (void)requestCloudStoreUrlWithThumbnail:(TIoTDemoCloudEventModel *)eventModel index:(NSInteger)index {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"DeviceName"] = self.eventModel.DeviceName?:@"";
    paramDic[@"Thumbnail"] = eventModel.Thumbnail?:@"";
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageThumbnail vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudEventModel *tuumbnailModel = [TIoTDemoCloudEventModel yy_modelWithJSON:responseObject];
        eventModel.ThumbnailURL = tuumbnailModel.ThumbnailURL;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
    
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoPlaybackCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaybackCustomCellID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoCloudEventModel *selectedModel = self.dataArray[indexPath.row];
    [self getFullVideoURLWithPartURL:self.listModel.VideoURL withTime:selectedModel];
}

#pragma mark - responsed method

- (void)initializedVideo {
    
//    CGFloat kTopPadding = [self getTopMaiginWithNavigationBar];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kPadding, self.view.frame.size.width, self.view.frame.size.width * 9 / 16)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
    
    UIImageView *videoPlayImage = [[UIImageView alloc]init];
    videoPlayImage.image = [UIImage imageNamed:@"video_play"];
    [self.imageView addSubview:videoPlayImage];
    [videoPlayImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imageView);
        make.width.height.mas_equalTo(60);
    }];
}

- (NSString *)getStampDateStringWithSecond:(NSInteger )secondTime {
    NSString *secondString = [NSString getDayFormatTimeFromSecond:[NSString stringWithFormat:@"%ld",secondTime]];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.dayDateString,secondString];
    NSString *stampDate = [NSString getTimeStampWithString:dateStr withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""]?:@"";
    NSLog(@"%@",stampDate);
    self.timeLabel.text = secondString;
    return stampDate;
}

- (void)recombineTimeSegmentWithTimeArray:(NSArray *)timeArray {
    
    if (self.modelArray.count != 0) {
        [self.modelArray removeAllObjects];
    }
    
    [timeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TIoTCloudStorageTimeDataModel *model = obj;
        
        if (idx == 0) {
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = model.StartTime.doubleValue;
            timeModel.endTime = model.EndTime.doubleValue;
            
            [self.modelArray addObject:timeModel];
            
        }else {
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = model.StartTime.doubleValue;
            timeModel.endTime = model.EndTime.doubleValue;
            
            NSMutableArray *tempModelArray = [[NSMutableArray alloc]initWithArray:self.modelArray];
            TIoTTimeModel *lastModel = tempModelArray.lastObject;
            if (timeModel.startTime - lastModel.endTime <= 60) {
                
                lastModel.endTime = timeModel.endTime;
                
                [self.modelArray replaceObjectAtIndex:(tempModelArray.count - 1) withObject:lastModel];
            }else {
                [self.modelArray addObject:timeModel];
            }
            
        }
    }];
    
    [self convertTimeArrayItemParam];
}

- (void)convertTimeArrayItemParam{
    if (self.modelArray.count != 0) {
        [self.modelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTTimeModel *itemModel = obj;
            
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = [self captureTimestampWithOutDaySecound:itemModel.startTime];
            timeModel.endTime = [self captureTimestampWithOutDaySecound:itemModel.endTime];
            
            [self.modelArray replaceObjectAtIndex:idx withObject:timeModel];
        }];
    }
}

- (NSInteger )captureTimestampWithOutDaySecound:(CGFloat)stamp {
    
    CGFloat timeStamp = stamp;
    NSString *dateString = [NSString convertTimestampToTime:@(timeStamp) byDateFormat:@"YYYY-MM-dd HH:mm:ss"]?:@"";
    
    NSArray *dateTempArray = [dateString componentsSeparatedByString:@" "];
    NSString *dayTime = dateTempArray.lastObject;
    NSArray *dayTempTime = [dayTime componentsSeparatedByString:@":"];
    NSString *hourString = dayTempTime.firstObject;
    NSString *mitString = dayTempTime[1];
    NSString *secString = dayTempTime.lastObject;
        
    NSInteger hour = hourString.intValue;
    NSInteger minute = mitString.intValue;
    NSInteger second = secString.intValue;
    
    NSInteger totalSecond = second + minute*60 + hour*3600;
    
    return totalSecond;
}

- (void)dealloc
{
    [self stopPlayMovie];
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

- (void)configVideo {
    
        [self stopPlayMovie];
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrl] withOptions:options];
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.imageView.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;
        
        self.view.autoresizesSubviews = YES;
        [self.imageView addSubview:self.player.view];
        
        [self.player setOptionIntValue:10 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:10 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];

}

- (void)stopPlayMovie {
    [self.player stop];
    self.player = nil;
}

#pragma mark - lazy loading
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [[NSMutableArray alloc]init];
    }
    return _modelArray;
}

- (NSArray *)cloudStoreDateList {
    if (!_cloudStoreDateList) {
        _cloudStoreDateList = [[NSArray alloc]init];
    }
    return _cloudStoreDateList;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
