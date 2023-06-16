//
//  MyKeyFrameSlider.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyKeyFrameSlider : UISlider

- (void)makeConstrainsForKeyFrameSlider:(NSArray *)frameList withFrameNum:(int)frameNum;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIImageView *sliderThumbImg;

@end

@protocol MyKeyFrameSliderDelegate <NSObject>

- (void)updateFrame;

@end

NS_ASSUME_NONNULL_END
