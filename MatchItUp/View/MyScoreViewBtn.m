//
//  MyScoreViewBtn.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/4/11.
//

#import "MyScoreViewBtn.h"

@implementation MyScoreViewBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([_myBtnName isEqual:@"postureOutlineBtn"]) {
        if (point.x >= 0 && point.x <= self.frame.size.width * 550 / 1280 && point.y >= 0 && point.y <= self.frame.size.height) {
            return true;
        }
    }
    else {
        if (point.x >= self.frame.size.width - self.frame.size.width * 550 / 1280 && point.x <= self.frame.size.width && point.y >= 0 && point.y <= self.frame.size.height) {
            return true;
        }
    }
    return false;
}

@end
