//
//  ScrollPlayerCell.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerCell.h"

@implementation ScrollPlayerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        [self.contentView addGestureRecognizer:singleTapRecognizer];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTapRecognizer];
        
        [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    }
    return self;
}

#pragma mark - public method
- (void)willDisplay{
    [self configVideoView];
    self.videoView.asset = self.asset;
    self.videoView.image = self.asset.cover;
}

- (void)didDisplay{
    if (self.videoView.asset != self.asset){
        [self willDisplay];
    }
    [self configPlayer];
}

#pragma mark - private method
- (void)configPlayer{
    self.videoManager.asset = self.asset;
    [self.videoView prepare];
}

- (void)configVideoView{
    if (_videoView == nil){
        _videoView = [[ScrollPlayerVideoView alloc] initWithFrame:self.bounds videoManager:self.videoManager];
        [self addSubview:_videoView];
    }
    for (UIView *subView in _videoView.subviews){
        [subView removeFromSuperview];
    }
}

- (void)singleTap{
    if (self.singleTapAction){
        self.singleTapAction(self);
    }
}

- (void)doubleTap{
    if (self.doubleTapAction){
        self.doubleTapAction(self);
    }
}

@end
