//
//  ZHDoubleSlider.h
//  MatchItUp
//
//  Created by 安子和 on 2021/3/28.
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"

typedef NS_ENUM(NSUInteger, ZHDoubleSliderEvent){
    ZHDoubleSliderEventLeftValueChanged,
    ZHDoubleSliderEventRightValueChanged,
};

typedef NS_OPTIONS(UInt16, ZHDoubleSliderError) {
    ZHDoubleSliderErrorTooShort         = 1,
    ZHDoubleSliderErrorTooThin          = 2,
    ZHDoubleSliderErrorTooShortAndThin  = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface ZHDoubleSlider : UIView

@property(nonatomic, strong) UIImage *maximumValueImage;
@property(nonatomic, strong) UIImage *minimumValueImage;

@property(nonatomic, strong) UIImage *leftImage;
@property(nonatomic, strong) UIImage *rightImage;

@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) UIImage *leftTrackImage;
@property(nonatomic, strong) UIImage *rightTrackImage;

@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;

@property(nonatomic) double leftValue;
@property(nonatomic) double rightValue;

@property(nonatomic) CGFloat minimumInterval;
@property(nonatomic) CGFloat maximumInterval;

@property(nonatomic, strong) UIImageView *leftImageView;
@property(nonatomic, strong) UIImageView *rightImageView;

- (void)addTarget:(nonnull id)target action:(SEL)action forEvent:(ZHDoubleSliderEvent)event;
- (void)updateLeftValue:(double)leftRate;
- (void)updateRightValue:(double)rightRate;

@end

NS_ASSUME_NONNULL_END


