//
//  FramePhotoZoom.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/9/17.
//

#import "FramePhotoZoom.h"

@implementation FramePhotoZoom

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 8.0f;
        _imageNormalHeight = frame.size.height;
        _imageNormalWidth = frame.size.width;
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.userInteractionEnabled = YES;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 延中心点缩放
    CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = scrollView.zoomScale * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
}

- (void)pictureZoomWithScale:(CGFloat)zoomScale {
    // 延中心点缩放
    CGFloat imageScaleWidth = 1 * self.imageNormalWidth;
    CGFloat imageScaleHeight = 1 * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    self.contentSize = CGSizeMake(imageScaleWidth,imageScaleHeight);
}

#pragma mark -- Setter
- (void)setImageNormalWidth:(CGFloat)imageNormalWidth{
    _imageNormalWidth = imageNormalWidth;
//    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
//    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setImageNormalHeight:(CGFloat)imageNormalHeight{
    _imageNormalHeight = imageNormalHeight;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.contentSize = CGSizeMake(_imageNormalWidth, _imageNormalHeight);
}

@end
