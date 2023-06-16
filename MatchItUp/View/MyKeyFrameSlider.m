//
//  MyKeyFrameSlider.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/4/21.
//

#import "MyKeyFrameSlider.h"
#import <Masonry/Masonry.h>

@implementation MyKeyFrameSlider {
    NSMutableArray *keyFrameSliderBtnArray;
    NSArray *framelist;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        keyFrameSliderBtnArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 13; i++) {
            UIButton *keyFrameSliderBtn = [[UIButton alloc] init];
            keyFrameSliderBtn.tag = i;
            [keyFrameSliderBtn addTarget:self action:@selector(showFrame:) forControlEvents:UIControlEventTouchUpInside];
            [keyFrameSliderBtn setImage:[UIImage imageNamed:@"keyFrameSlider"] forState:UIControlStateNormal];
            [self addSubview:keyFrameSliderBtn];
            [keyFrameSliderBtnArray addObject:keyFrameSliderBtn];
        }
    }
    return self;
}

- (void)makeConstrainsForKeyFrameSlider:(NSArray *)frameList withFrameNum:(int)frameNum {
    framelist = [frameList copy];
    for (int i = 0; i < 13; i++) {
        CGFloat ratio = (float)[frameList[i] intValue] / frameNum;
        [keyFrameSliderBtnArray[i] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).multipliedBy(1.05);
            make.left.mas_equalTo(self.mas_left).offset((ratio * (self.frame.size.width - self.frame.size.height * 0.5)) - 2);
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.5);
        }];
    }
}

- (void)showFrame:(UIButton *)btn {
    self.value = [framelist[btn.tag] intValue];
    [self.delegate updateFrame];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint convertPoint = [self.sliderThumbImg convertPoint:point fromView:self];
    if (CGRectContainsPoint(self.sliderThumbImg.bounds, convertPoint)) {
        return self;
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

@end
