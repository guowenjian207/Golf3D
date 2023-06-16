//
//  PlayerView.h
//  画中画探究
//
//  Created by 许明洋 on 2020/10/30.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@end

NS_ASSUME_NONNULL_END
