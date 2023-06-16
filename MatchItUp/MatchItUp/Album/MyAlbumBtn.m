//
//  MyAlbumBtn.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/4/11.
//

#import "MyAlbumBtn.h"

@implementation MyAlbumBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat offset = 20;
    if ([_myAlbumBtnName isEqual:@"myAlbum"]) {
        if (point.x >= 0 && point.x <= self.frame.size.width * 375 / 1280 && point.y >= -offset && point.y <= self.frame.size.height + offset) {
            return true;
        }
    }
    else {
        if (point.x >= self.frame.size.width * 375 / 1280 && point.x <= 2 * self.frame.size.width * 375 / 1280 && point.y >= -offset && point.y <= self.frame.size.height + offset) {
            return true;
        }
    }
    return false;
}

@end
