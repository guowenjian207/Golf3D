//
//  FramePlayerView.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/28.
//

#import <UIKit/UIKit.h>
#import "ZHVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface FramePlayerView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UICollectionView *frameCollectionView;
@property (nonatomic, strong) UIButton *autoChooseFrameBtn;

- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andVideo:(nonnull Video *)video andFrame:(CGRect)frame;
- (void)scrollZoomByRate:(CGFloat)rate;
- (void)initLockState;
- (void)enableSelectFrame;
- (void)disableSelectFrame;
- (void)willDisappear;
- (void)showFrameAtIndex:(int)index;
- (UIImage *)getFrameFromFile:(int)frameIndex;
- (void)autoSelectedWithX:(CGFloat)x andY:(CGFloat)y andW:(CGFloat)w andH:(CGFloat)h;
@end

@protocol FramePlayerViewDelegate <NSObject>

-(void)updateHudWithFrameNum:(int)frameNum;
-(void)hideHud;
-(void)panBegan;
-(void)panChangedWithOffset:(CGFloat)offsetY;
-(void)beginSelect;
-(void)choosingFrame:(CGPoint)point;
-(void)finishSelect:(UIImage *)image andframeindex:(int) fameindex andPoint:(CGPoint)point;
-(void)popNavigationVC;
-(void)saveCurrentState;
- (void)shareButtonDidTouched;
- (void)scrollToFrame:(int) frameN;
- (void)videoModeChange:(NSNumber*) num;
//-(void)loadFrames;

@end

NS_ASSUME_NONNULL_END
