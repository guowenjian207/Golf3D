//
//  FrameViewController.h
//  FrameCut
//
//  Created by 胡跃坤 on 2021/9/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image andImageFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
