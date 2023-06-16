//
//  ViewController.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import "ZHVideoAsset.h"
#import "ScrollPlayer.h"
#import "ScrollPlayerBottomView.h"

@interface ScrollPlayerViewController : UIViewController

@property(nonatomic, assign) ScrollPlayerType type;
@property(nonatomic, assign) NSUInteger currentIndex;
@property(nonatomic, strong) ScrollPlayerBottomView *bottomView;
@property(nonatomic, assign) BOOL isFront;

+ (instancetype)playerViewControllerWithAssets:(NSMutableArray<ZHVideoAsset*> *)assets;

@end

