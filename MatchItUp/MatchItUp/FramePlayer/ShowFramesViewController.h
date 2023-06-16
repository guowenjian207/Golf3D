//
//  ShowFramesViewController.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowFramesViewController : UIViewController

@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, strong) NSMutableArray *selectedFramesIndex;
- (instancetype)initViewWithSelectedFrames:(NSMutableArray *)frames andRate:(float)Rate;
@property (nonatomic, assign) float videoWidthAndHeightRate;

@end

NS_ASSUME_NONNULL_END
