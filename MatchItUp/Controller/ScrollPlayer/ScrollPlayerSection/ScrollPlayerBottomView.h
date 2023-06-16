//
//  ScrollPlayerBottomView.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/23.
//

#import <UIKit/UIKit.h>
#import "ScrollPlayer.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScrollPlayerBottomViewDelegate <NSObject>

///删除应用沙盒视频
- (void)removeAsset;

///播放 暂停
- (void)playControl;

///保存 -- addVideo
- (void)saveAsset;

///上传
- (void)uploadAsset;

///控制播放进度
- (void)playerSeekTo:(float)time;

- (void)cancel;

@end

@interface ScrollPlayerBottomView : UIView

@property(nonatomic, assign) ScrollPlayerType type;

@property(nonatomic, assign) ScrollPlayerMode mode;

@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, weak) id<ScrollPlayerBottomViewDelegate> delegate;

@property(nonatomic, assign) float sliderMaxValue;

@property(nonatomic, assign) float sliderCurrentValue;

@property(nonatomic, readonly) float doubleSliderLeftValue;

@property(nonatomic, readonly) float doubleSliderRightValue;

- (instancetype)initWithSuperview:(UIView *)superview;

@end

NS_ASSUME_NONNULL_END
