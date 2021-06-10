//
//  UIButton+LQRelayout.m
//  LQToolKit-ObjectiveC
//
//

#import "UIButton+LQRelayout.h"

@implementation UIButton (LQRelayout)

- (void)relayoutButton:(XDPButtonLayoutStyle)type {

    [self layoutIfNeeded];
    
    CGFloat marge = 10;
    
    CGSize titleSize = self.titleLabel.bounds.size;
    CGSize imageSize = self.imageView.frame.size;
    
    CGFloat spaceOffset = marge/2.0;
    
    CGFloat imageWidthOffset = titleSize.width/2.0;
    CGFloat imageHeightOffset = titleSize.height/2.0;
    CGFloat titleWidthOffset = imageSize.width/2.0;
    CGFloat titleHeightOffset = imageSize.height/2.0;
    
    switch (type) {
        case XDPButtonLayoutStyleTop:
            self.titleEdgeInsets = UIEdgeInsetsMake(titleHeightOffset+marge, -titleWidthOffset, -titleHeightOffset-spaceOffset, +titleWidthOffset);
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageHeightOffset-spaceOffset, imageWidthOffset, imageHeightOffset+spaceOffset, -imageWidthOffset);
            break;
        case XDPButtonLayoutStyleBottom:
            self.titleEdgeInsets = UIEdgeInsetsMake(-titleHeightOffset-spaceOffset, -titleWidthOffset, titleHeightOffset+spaceOffset, titleWidthOffset);
            self.imageEdgeInsets = UIEdgeInsetsMake(imageHeightOffset+spaceOffset, imageWidthOffset, -imageHeightOffset-spaceOffset, -imageWidthOffset);
            break;
        case XDPButtonLayoutStyleLeft:
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spaceOffset, 0, -spaceOffset);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spaceOffset, 0, spaceOffset);
            break;
        case XDPButtonLayoutStyleRight:
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -2*titleWidthOffset - spaceOffset, 0, 2*titleWidthOffset + spaceOffset);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 2*imageWidthOffset + spaceOffset, 0, -2*imageWidthOffset - spaceOffset);
            break;
    }
}

- (void)setButtonFormateWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:titlt forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHexString:titleColorString] forState:UIControlStateNormal];
    self.titleLabel.font = font;
}
@end
