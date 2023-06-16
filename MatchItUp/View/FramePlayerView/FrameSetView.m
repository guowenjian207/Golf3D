//
//  FrameSetView.m
//  test
//
//  Created by 胡跃坤 on 2021/8/16.
//

#import "FrameSetView.h"
#import <Masonry/Masonry.h>

@interface FrameSetView ()

@property (nonatomic, strong) NSMutableArray *frameSetViewArray;

@end

@implementation FrameSetView

- (NSMutableArray *)frameSetViewArray {
    if (!_frameSetViewArray) {
        _frameSetViewArray = [[NSMutableArray alloc] init];
    }
    return _frameSetViewArray;
}

- (instancetype)initWithFrame:(CGRect)frame andFrameSet:(NSMutableArray *)array andRate:(float)Rate
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoWidthAndHeightRate = Rate;
        [self initViewWithFrameSet:array];
        [self layoutView];
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)initViewWithFrameSet:(NSMutableArray *)array {
    for (int i = 0; i < 15; i++) {
        int real_idx;
        if (i < 5) {
            real_idx = i;
        }
        else if (i < 10) {
            real_idx = i - 1;
        }
        else {
            real_idx = i - 2;
        }
        if ([array[real_idx] isKindOfClass:[UIImage class]]) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:array[real_idx]];
            [self.frameSetViewArray addObject:imgView];
            [self addSubview:imgView];
        }
        else {
            UIImage *img = [self imageWithColor:[UIColor whiteColor]];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
            [self.frameSetViewArray addObject:imgView];
            [self addSubview:imgView];
        }
    }
}

- (void)layoutView {
    float width  = self.bounds.size.width;
    float aveWidth  = width  / 5;
    float aveHeight = aveWidth / _videoWidthAndHeightRate;
    if (aveHeight > self.bounds.size.height / 3) {
        aveHeight = self.bounds.size.height / 3;
        aveWidth = aveHeight * _videoWidthAndHeightRate;
    }
    float offsetF = (self.frame.size.width - aveWidth * 5 - 5) / 2;
    for (int i = 0; i < 15; i++) {
        [self.frameSetViewArray[i] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(aveWidth);
            make.height.mas_equalTo(aveHeight);
            if (i % 5 == 0) {
                make.left.equalTo(self).offset(offsetF);
            }
            else if (i % 5 == 1) {
                make.left.equalTo(((UIImageView *)self.frameSetViewArray[i-1]).mas_right).offset(5);
            }
            else {
                make.left.equalTo(((UIImageView *)self.frameSetViewArray[i-1]).mas_right);
            }
            if (i < 5) {
                make.top.equalTo(self);
            }
            else {
                make.top.equalTo(((UIImageView *)self.frameSetViewArray[i-5]).mas_bottom);
            }
        }];
    }
}

@end
