//
//  HomeViewController.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/28.
//

#import <UIKit/UIKit.h>
#import "ZHVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController

- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andisFront:(BOOL)isFront;
- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andisFront:(BOOL)isFront andFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
