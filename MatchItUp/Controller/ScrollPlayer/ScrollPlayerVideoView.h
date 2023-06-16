//
//  ScrollPlayerView.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import "ScrollPlayerLayerView.h"

NS_ASSUME_NONNULL_BEGIN

@class ScrollPlayerVideoManager;
@interface ScrollPlayerVideoView : UIImageView

@property(nonatomic, readonly) BOOL isDisplayInScreen;

@property(nonatomic, strong) UIImage *cover;

@property(nonatomic, readonly) ScrollPlayerState state;

@property(nonatomic, strong) ZHVideoAsset *asset;

@property(nonatomic, strong) NSURL *videoURL;

- (instancetype)initWithFrame:(CGRect)frame videoManager:(ScrollPlayerVideoManager *)videoManager;
///
- (void)pause;

- (void)play;

- (void)prepare;

-(void)stop;

@end

NS_ASSUME_NONNULL_END
