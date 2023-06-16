//
//  HomeScreenViewController.h
//  切帧App
//
//  Created by 胡跃坤 on 2021/7/19.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeScreenViewController : UIViewController

//@property (nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isFront;

@end

@protocol HomeScreenVCProtocol <NSObject>

- (void)updateHudWithFrameNum:(int)frameNum;
- (void)hideHud;

@end

NS_ASSUME_NONNULL_END
