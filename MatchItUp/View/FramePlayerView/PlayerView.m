//
//  PlayerView.m
//  画中画探究
//
//  Created by 许明洋 on 2020/10/30.
//

#import "PlayerView.h"

@implementation PlayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

//Override UIView method
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
