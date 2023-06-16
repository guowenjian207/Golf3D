//
//  ScrollPlayerVideoManager.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerVideoManager.h"
#import "ScrollPlayerViewController.h"

@implementation ScrollPlayerVideoManager{
    NSTimer *timer;
    
    BOOL isTracking;
    
    NSMutableArray *registeredNotifications;
    
    ScrollPlayerState lastState;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        timer = [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(checkPlayerState) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        isTracking = NO;
        registeredNotifications = [NSMutableArray array];
        
        _videoPlayer = [[ScrollPlayerLayerView alloc] initWithFrame: UIScreen.mainScreen.bounds];
        _videoPlayer.userInteractionEnabled = NO;
        _videoPlayer.backgroundColor = [UIColor clearColor];
//        _videoPlayer.playerRate = 1.0;
        
        [self registerApplicationObservers];
        
        lastState = ScrollPlayerStateNormal;
    }
    return self;
}

#pragma mark - get & set
- (void)setMyVC:(ScrollPlayerViewController *)myVC{
    _myVC = myVC;
    self.videoPlayer.myVC = myVC;
}

- (void)setPlayerRate:(float)playerRate {
    self.videoPlayer.playerRate = playerRate;
}

- (float)playerRate {
    return self.videoPlayer.playerRate;
}

#pragma mark - public method
- (void)destory{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.videoPlayer removeObserver:self forKeyPath:@"state"];
    [timer invalidate];
    timer = nil;
    [_videoPlayer shutdown];
    _videoPlayer = nil;
}

#pragma mark - private method
//- (void)checkPlayerState{
//    @autoreleasepool {
//        BOOL tracking = [NSRunLoop currentRunLoop].currentMode == UITrackingRunLoopMode;
//        if (tracking && !isTracking) {
//            [self beginTrack];
//        }
//        if (tracking) {
//            [self onTracking];
//        }
//        if (!tracking && isTracking) {
//            [self endTrack];
//        }
//        isTracking = tracking;
//    }
//}
//
//- (void)beginTrack{
//
//}
//
//- (void)onTracking{
//    if (_videoView && _videoView.isDisplayInScreen){
//        [_videoView pause];
//    }
//}
//
//- (void)endTrack{
//    if (_videoView && _videoView.isDisplayInScreen){
//        [_videoView pause];
//    }
//}

- (void)registerApplicationObservers
{
    [self.videoPlayer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (object == self.videoPlayer){
            if ([keyPath isEqualToString:@"state"]){
                ScrollPlayerState state = self.videoPlayer.state;
                if (self->lastState != state){
                    self->lastState = state;
                    if (state == ScrollPlayerStatePlaying){
                        self.myVC.bottomView.isPlaying = YES;
                    }else{
                        self.myVC.bottomView.isPlaying = NO;
                    }
                }
            }
        }
    });
}

@end
