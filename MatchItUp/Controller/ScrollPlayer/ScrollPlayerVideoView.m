//
//  ScrollPlayerView.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerVideoView.h"
#import "ScrollPlayerVideoManager.h"

@interface ScrollPlayerVideoView ()

@property(nonatomic, weak) ScrollPlayerVideoManager *videoManager;

@end

@implementation ScrollPlayerVideoView

- (instancetype)initWithFrame:(CGRect)frame videoManager:(ScrollPlayerVideoManager *)videoManager{
    self = [super initWithFrame:frame];
    if (self){
        _videoManager = videoManager;
    }
    return self;
}

#pragma mark - get & set

- (BOOL)isDisplayInScreen{
    if (self.window == NULL){
        return NO;
    }
    
    CGRect screenRect = UIScreen.mainScreen.bounds;
    CGRect rect = [self convertRect:self.frame toView:UIApplication.sharedApplication.keyWindow];
    
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)){
        return NO;
    }
    
    if (self.isHidden){
        return NO;
    }
    
    if (self.superview == NULL){
        return NO;
    }
    
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)){
        return NO;
    }
    
    return YES;
}

- (void)setCover:(UIImage *)cover{
    _cover = cover;
    self.image = _cover;
}

- (void)setAsset:(ZHVideoAsset *)asset{
    _asset = asset;
    self.contentMode = _asset.isFillScreen ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
}

- (ScrollPlayerState)state{
    if (_asset == self.videoManager.asset && self.videoManager.videoPlayer.superview == self){
        return self.videoManager.videoPlayer.state;
    }else{
        return ScrollPlayerStateNormal;
    }
}

#pragma mark - public method

- (void)pause{
    if (_asset == self.videoManager.asset && _asset == self.videoManager.videoPlayer.asset){
        if (self.videoManager.videoPlayer.superview == self){
            [self.videoManager.videoPlayer pause];
        }
    }
}

- (void)play{
    if (_asset == self.videoManager.asset){
        if (self.videoManager.videoPlayer.superview == self){
            if (self.videoManager.videoPlayer.state == ScrollPlayerStateNormal) {
                [self.videoManager.videoPlayer play];
            }else if (self.videoManager.videoPlayer.state == ScrollPlayerStatePause){
                [self.videoManager.videoPlayer resume];
            }
        }else{
            if (_videoURL){
                self.videoManager.videoPlayer.videoURL = _videoURL;
            }else{
                self.videoManager.videoPlayer.asset = _asset;
            }
            [self.videoManager.videoPlayer removeFromSuperview];
            self.videoManager.videoPlayer.frame = self.bounds;
            [self addSubview:self.videoManager.videoPlayer];
            [self.videoManager.videoPlayer play];
        }
    }
}

- (void)prepare{
    if (_asset == self.videoManager.asset){
        if (self.videoManager.videoPlayer.superview == self){
            if (self.videoManager.videoPlayer.state == ScrollPlayerStateNormal){
                [self.videoManager.videoPlayer prepare];
            }
        }else{
            self.videoManager.videoPlayer.asset = _asset;
            [self.videoManager.videoPlayer removeFromSuperview];
            self.videoManager.videoPlayer.frame = self.bounds;
            [self addSubview:self.videoManager.videoPlayer];
            [self.videoManager.videoPlayer prepare];
        }
    }
}

- (void)stop{
    if ((_asset == self.videoManager.asset && _asset == self.videoManager.videoPlayer.asset)) {
        if (self.videoManager.videoPlayer.superview == self) {
            [self.videoManager.videoPlayer shutdown];
        }
    }
}

@end
