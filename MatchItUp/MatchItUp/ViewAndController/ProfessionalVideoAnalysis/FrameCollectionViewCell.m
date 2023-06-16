//
//  FrameCollectionViewCell.m
//  切帧App
//
//  Created by 胡跃坤 on 2021/7/20.
//

#import "FrameCollectionViewCell.h"

@implementation FrameCollectionViewCell{
    UIImageView *frameImgView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *blackView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - 4, frame.size.height - 4)];
        blackView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:blackView];
        
        frameImgView = [[UIImageView alloc] init];
        [self.contentView addSubview:frameImgView];
    }
    return self;
}

- (void)setFrameImg:(UIImage *)frameImg withRate:(float)rate {
    frameImgView.frame = CGRectMake(1, 1, self.frame.size.width - 4, self.frame.size.height - 4);
    frameImgView.image = frameImg;
}
- (void)selectCell{
    frameImgView.alpha = 0.4;
}

- (void)sesetting{
    frameImgView.alpha = 1;
}
@end
