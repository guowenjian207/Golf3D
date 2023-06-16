//
//  ScrollPlayerLayerView.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerLayerView.h"

@implementation ScrollPlayerLayerView{
    ZHVideoAsset *currentPlayAsset;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _playerRate = 1.0;
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark  - get & set
- (void)setPlayerRate:(float)playerRate {
    _playerRate = playerRate;
    self.player.rate = _playerRate;
    if (self.state != ScrollPlayerStatePlaying) {
        [self pause];
    }
}

#pragma mark  - public method
- (void)prepare {
    if (currentPlayAsset == self.asset) {
        return;
    }

    if (self.state != ScrollPlayerStateNormal) {
        [self shutdown];
    }
    
    playerItem = [[AVPlayerItem alloc] initWithURL:self.asset.videoURL];
    if (playerItem){
        [self initPlayer];
    }
    currentPlayAsset = self.asset;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)pause{
    if (currentPlayAsset != self.asset && _videoURL == nil){
        return;
    }
    
    [self.player pause];
    self.state = ScrollPlayerStatePause;
}

- (void)play{
    if (self.state != ScrollPlayerStateNormal) {
        [self shutdown];
    }
    
    if (currentPlayAsset != self.asset) {
        return;
    }
    
    if (!self.player && playerItem) {
        [self initPlayer];
    }
    
    self.hidden = NO;
//    [self.player play];
    self.player.rate = _playerRate;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.state = ScrollPlayerStatePlaying;
}

- (void)resume{
    if (currentPlayAsset != self.asset){
        return;
    }
    if (!self.player && playerItem){
        [self initPlayer];
    }
    [self.player play];
    self.state = ScrollPlayerStatePlaying;
}

- (void)shutdown{
    self.hidden = YES;
    currentPlayAsset = nil;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    self.state = ScrollPlayerStateNormal;
}

- (void)playComplete {
    self.state = ScrollPlayerStateNormal;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self prepare];
//    self.player.rate = _playerRate;
//    [self.player pause];
}

#pragma mark  - private
- (void)initPlayer{
    self.hidden = YES;
    
    if (self.player){
        [playerLayer removeFromSuperlayer];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }else{
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    }
    
//    _player.rate = _playerRate;
    
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = _asset.isFillScreen ? AVLayerVideoGravityResizeAspectFill : AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:playerLayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = NO;
    });
}

@end
