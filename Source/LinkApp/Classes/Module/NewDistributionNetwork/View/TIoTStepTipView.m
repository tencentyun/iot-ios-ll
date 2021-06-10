//
//  TIoTStepTipView.m
//  LinkApp
//
//

#import "TIoTStepTipView.h"

@interface TIoTStepTipView()

@property (nonatomic, strong) NSArray *titlesArray;

@end

@implementation TIoTStepTipView

- (instancetype)initWithTitlesArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _titlesArray = array;
        _showAnimate = YES;
    }
    return self;
}

- (void)setupUI{
    for (int i = 0; i < _titlesArray.count; i++) {
        CGFloat kSelfWidth = kScreenWidth;
        
        CGFloat edgeSpace = 30.0f + 15;
        CGFloat stepLabelWidth = 21.0f;
        CGFloat viewWidth = (kSelfWidth - 2*edgeSpace - _titlesArray.count*stepLabelWidth)/(_titlesArray.count - 1.0f);
        CGFloat viewHeight = 1.0f;
        
        UILabel *stepLabel = [[UILabel alloc] init];
        stepLabel.frame = CGRectMake(edgeSpace + (stepLabelWidth + viewWidth)*i, 0, stepLabelWidth, stepLabelWidth);
        stepLabel.text = [NSString stringWithFormat:@"%d", i+1];
        stepLabel.font = [UIFont wcPfMediumFontOfSize:12];
        stepLabel.textColor = [UIColor whiteColor];
        stepLabel.textAlignment = NSTextAlignmentCenter;
        stepLabel.layer.masksToBounds = YES;
        stepLabel.layer.cornerRadius = stepLabelWidth*0.5f;
        [self addSubview:stepLabel];
        
        if (_titlesArray.count != i+1) {
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(CGRectGetMaxX(stepLabel.frame), (stepLabelWidth - viewHeight)*0.5, viewWidth, viewHeight);
            [self addSubview:view];
            if (self.step < i+1) {
                view.backgroundColor = [UIColor colorWithHexString:@"#E7E8EB"];
            } else if (self.step == i + 1) {
                view.backgroundColor = [UIColor colorWithHexString:@"#E7E8EB"];
                
                if (_showAnimate) {
                    CAShapeLayer *layer = [CAShapeLayer layer];
                    layer.fillColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
                    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, view.frame.size.width*0.5, view.frame.size.height)];
                    layer.path = path.CGPath;
                    [view.layer addSublayer:layer];
                    
                    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
                    pathAnima.duration = 2.0f;
                    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
                    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
                    pathAnima.fillMode = kCAFillModeForwards;
                    pathAnima.removedOnCompletion = NO;
                    [layer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
                }

            } else {
                view.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            }
        }
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        if (LanguageIsEnglish) {
            tipLabel.bounds = CGRectMake(0, 0, kScreenWidth/_titlesArray.count - 20, stepLabelWidth);
            tipLabel.numberOfLines = 0;
            CGFloat xOffet = stepLabel.center.x;
//            if (i == 0) {
//                xOffet = stepLabel.center.x;
//            }
            tipLabel.text = _titlesArray[i];
            tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
            [tipLabel sizeToFit];
            tipLabel.center = CGPointMake(xOffet, CGRectGetMaxY(stepLabel.frame) + 18.0f + 8);
        }else {
            tipLabel.bounds = CGRectMake(0, 0, stepLabelWidth, stepLabelWidth);
            tipLabel.text = _titlesArray[i];
            tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
            [tipLabel sizeToFit];
            tipLabel.center = CGPointMake(stepLabel.center.x, CGRectGetMaxY(stepLabel.frame) + 18.0f + 8);
        }
        
        [self addSubview:tipLabel];
        
        if (self.step < i+1) {
            stepLabel.backgroundColor = [UIColor colorWithHexString:@"#C2C5CC"];
            tipLabel.textColor = [UIColor colorWithHexString:kPhoneEmailHexColor];
        } else {
            stepLabel.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            tipLabel.textColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        }
    }
}

#pragma mark setter or getter

- (void)setStep:(NSInteger)step {
    _step = step;
    [self setupUI];
}

@end
