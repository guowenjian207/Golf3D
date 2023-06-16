//
//  ScrollPlayerTopBar.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import "ScrollPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ScrollPlayerTopBarDelegate <NSObject>

@property(nonatomic, assign) ScrollPlayerMode mode;

- (void)back;
- (void)menuBtnTapped;

@end

@interface ScrollPlayerTopBar : UIView

@property(nonatomic, weak) id<ScrollPlayerTopBarDelegate> delegate;

@property(nonatomic, strong) NSString *title;

- (instancetype)initWithSuperview:(UIView *)superview;

@end

NS_ASSUME_NONNULL_END
