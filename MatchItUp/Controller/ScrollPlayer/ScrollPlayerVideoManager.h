//
//  ScrollPlayerVideoManager.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <Foundation/Foundation.h>
#import "ScrollPlayerLayerView.h"
#import "ScrollPlayerVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@class ScrollPlayerViewController;
@interface ScrollPlayerVideoManager : NSObject

@property(nonatomic, weak) ScrollPlayerViewController *myVC;

@property(nonatomic, weak) ScrollPlayerVideoView *videoView;

@property(nonatomic, strong) ZHVideoAsset *asset;

@property(nonatomic, readonly) ScrollPlayerLayerView *videoPlayer;

@property(nonatomic ,copy) void(^stateBlock)(ScrollPlayerState);

@property(nonatomic, assign) float playerRate;

- (void)destory;

@end

NS_ASSUME_NONNULL_END
