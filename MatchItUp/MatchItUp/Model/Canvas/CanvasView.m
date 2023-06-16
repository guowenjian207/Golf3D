//
//  CanvasView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/23.
//

#import "CanvasView.h"
#import "AngleTool.h"

@implementation CanvasView {
    AngleTool *angleTool;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if (self = [super init]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.userInteractionEnabled = YES;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        angleTool = [[AngleTool alloc] initWithSuperiew:self andColor:[UIColor redColor]];
    }
    return self;
}

@end
