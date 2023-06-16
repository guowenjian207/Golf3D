//
//  VideoAnalysisViewController.h
//  MatchItUp
//
//  Created by GWJ on 2022/12/12.
//

#import <UIKit/UIKit.h>
#import "ZHVideoAsset.h"
#import "ScrollPlayer.h"
#import "ScrollPlayerBottomView.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoAnalysisViewController : UIViewController
@property(nonatomic, assign) ScrollPlayerType type;
@property(nonatomic, assign) NSUInteger currentIndex;
@property(nonatomic, strong) ScrollPlayerBottomView *bottomView;
@property(nonatomic, assign) BOOL isFront;

+ (instancetype)playerViewControllerWithAssets:(NSMutableArray<ZHVideoAsset*> *)assets;
@end

NS_ASSUME_NONNULL_END
