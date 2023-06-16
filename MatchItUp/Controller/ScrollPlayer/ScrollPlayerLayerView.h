//
//  ScrollPlayerLayerView.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZHVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ScrollPlayerState) {
    ScrollPlayerStateNormal,
    ScrollPlayerStatePlaying,
    ScrollPlayerStatePause,
};

@class ScrollPlayerViewController;
@interface ScrollPlayerLayerView : UIView

///播放器
@property(nonatomic, strong) AVPlayer *player;
///
@property(nonatomic, strong) ZHVideoAsset *asset;
///即时回放
@property(nonatomic, strong) NSURL *videoURL;
///
@property(nonatomic, assign) ScrollPlayerState state;

@property (nonatomic, weak) ScrollPlayerViewController *myVC;

@property(nonatomic, assign) float playerRate;


- (void)prepare;
///暂停播放
- (void)pause;
///开始播放
- (void)play;
///继续播放
- (void)resume;
///结束播放
- (void)shutdown;

@end

NS_ASSUME_NONNULL_END
