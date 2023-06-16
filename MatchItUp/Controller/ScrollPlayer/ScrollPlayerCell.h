//
//  ScrollPlayerCell.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import "ScrollPlayerVideoManager.h"
#import "ZHVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@class ScrollPlayerViewController;
@interface ScrollPlayerCell : UICollectionViewCell

@property(nonatomic, weak) ScrollPlayerViewController *myVC;

@property(nonatomic, weak) ScrollPlayerVideoManager *videoManager;

@property(nonatomic, strong) ZHVideoAsset *asset;

@property(nonatomic, strong, readonly) ScrollPlayerVideoView *videoView;

@property(nonatomic, copy) void (^singleTapAction)(ScrollPlayerCell *cell);

@property(nonatomic, copy) void (^doubleTapAction)(ScrollPlayerCell *cell);

@property(nonatomic, strong) NSIndexPath *indexPath;

- (void)willDisplay;

- (void)didDisplay;

@end

NS_ASSUME_NONNULL_END
