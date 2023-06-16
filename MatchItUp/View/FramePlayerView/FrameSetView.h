//
//  FrameSetView.h
//  test
//
//  Created by 胡跃坤 on 2021/8/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameSetView : UIView

@property (nonatomic, assign) float videoWidthAndHeightRate;
- (instancetype)initWithFrame:(CGRect)frame andFrameSet:(NSMutableArray *)array andRate:(float)Rate;

@end

NS_ASSUME_NONNULL_END
