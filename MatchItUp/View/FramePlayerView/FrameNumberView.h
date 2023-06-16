//
//  FrameNumberView.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrameNumberDelegate <NSObject>

- (void)selectFrameWithIndex:(int)index;
- (void)deselectFrameWithIndex:(int)index;

@end

@interface FrameNumberView : UIView

@property (nonatomic, weak) id<FrameNumberDelegate> delegate;
@property (nonatomic, assign) BOOL isFront;
- (void) hasSelectedIndex:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
