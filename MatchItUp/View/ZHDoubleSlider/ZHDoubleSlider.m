//
//  ZHDoubleSlider.m
//  MatchItUp
//
//  Created by 安子和 on 2021/3/28.
//

#import "ZHDoubleSlider.h"
#import "CoreDataManager.h"

@interface ZHDoubleSlider ()

@property(nonatomic, strong) UIImageView *maximumValueImageView;
@property(nonatomic, strong) UIImageView *minimumValueImageView;
@property(nonatomic, strong) UIImageView *backgroundImageView;
@property(nonatomic, strong) UIImageView *contentImageView;
@property(nonatomic, strong) UIImageView *centerImageView;
@property(nonatomic, strong) UIImageView *leftTrackImageView;
@property(nonatomic, strong) UIImageView *rightTrackImageView;
@property(nonatomic, strong) UILabel *timeLabel;

@end

@implementation ZHDoubleSlider{
    CAShapeLayer *leftShapeLayer;
    CAShapeLayer *rightShapeLayer;
    
    NSNotificationName leftTrackNotificationName;
    NSNotificationName rightTrackNotificationName;
    
    CGFloat leftTrackLastLocation;
    CGFloat rightTrackLastLocation;
}

- (instancetype)init
{
    self = [super init];
//    self = [super initWithFrame:CGRectMake(50, 200, 300, 40)];
    if (self) {
        leftTrackNotificationName = @"leftTrackNotification";
        rightTrackNotificationName = @"rightTrackNotification";
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        _minimumInterval = 20.0;
        [self initOfSubviews];
    }
    return self;
}

- (void)initOfSubviews{
    self.backgroundColor = [UIColor clearColor];
    
    CGSize originSize = CGSizeMake(30, 30);
    
    _minimumValueImageView = [[UIImageView alloc] init];
    _maximumValueImageView = [[UIImageView alloc] init];
    _minimumValueImageView.size = originSize;
    _maximumValueImageView.size = originSize;
    [self addSubview:_minimumValueImageView];
    [self addSubview:_maximumValueImageView];
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.height = 5;
    _backgroundImageView.layer.cornerRadius = 2.5;
    _backgroundImageView.layer.masksToBounds = YES;
    _backgroundImageView.backgroundColor = [UIColor darkGrayColor];
    [self addSubview: _backgroundImageView];
    
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.height = 5;
    _contentImageView.backgroundColor = [UIColor blueColor];
    [self addSubview: _contentImageView];
    
    _leftTrackImageView = [[UIImageView alloc] init];
    _rightTrackImageView = [[UIImageView alloc] init];
    _leftTrackImageView.height = 5;
    _rightTrackImageView.height = 5;
    _leftTrackImageView.backgroundColor = [UIColor clearColor];
    _rightTrackImageView.backgroundColor = [UIColor clearColor];
    leftShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_leftTrackImageView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
    rightShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_leftTrackImageView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
    [_leftTrackImageView.layer setMask:leftShapeLayer];
    [_rightTrackImageView.layer setMask:rightShapeLayer];
    [self addSubview:_leftTrackImageView];
    [self addSubview:_rightTrackImageView];
    
    _leftImageView = [[UIImageView alloc] init];
    _rightImageView = [[UIImageView alloc] init];
    _leftImageView.size = originSize;
    _rightImageView.size = originSize;
    [_leftImageView setUserInteractionEnabled:YES];
    [_rightImageView setUserInteractionEnabled:YES];
    _leftImageView.backgroundColor = [UIColor clearColor];
    _rightImageView.backgroundColor = [UIColor clearColor];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.leftImage = [UIImage imageNamed:@"left"];
    self.rightImage = [UIImage imageNamed:@"right"];
    [self addSubview:_leftImageView];
    [self addSubview:_rightImageView];
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeftImageView:)];
    [_leftImageView addGestureRecognizer:leftPan];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRightImageView:)];
    [_rightImageView addGestureRecognizer:rightPan];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_timeLabel];
}

#pragma mark - get set
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self updateSubViews];
}

- (void)setMaximumValueImage:(UIImage *)maximumValueImage{
    _maximumValueImage = maximumValueImage;
    [self.maximumValueImageView setImage:_maximumValueImage];
}

- (void)setMinimumValueImage:(UIImage *)minimumValueImage{
    _minimumValueImage = minimumValueImage;
    [_minimumValueImageView setImage:_minimumValueImage];
}

- (double)leftValue{
    double currentRange = _leftImageView.centerX - self.backgroundImageView.headX;
    double totalRange = self.backgroundImageView.width;
    return currentRange / totalRange * (_maximumValue - _minimumValue) + _minimumValue;
}

- (double)rightValue{
    double currentRange = _rightImageView.centerX - self.backgroundImageView.headX;
    double totalRange = self.backgroundImageView.width;
    return currentRange / totalRange * (_maximumValue - _minimumValue) + _minimumValue;
}

- (void)setLeftValue:(double)leftValue{
    if (leftValue < _minimumValue) leftValue = _minimumValue;
    if (leftValue > self.rightValue) leftValue = self.rightValue;
    double currentRange = leftValue - _minimumValue;
    double totalRange = _maximumValue - _minimumValue;
    _leftImageView.centerX = _backgroundImageView.headX + currentRange / totalRange * _backgroundImageView.width;
    _leftTrackImageView.tailX = _leftImageView.centerX;
    [leftShapeLayer setPath: [UIBezierPath bezierPathWithRoundedRect:_leftTrackImageView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(2.5, 2.5)].CGPath];
    _centerImageView.headX = _leftImageView.centerX;
    _contentImageView.headX = _leftImageView.centerX;
}

- (void)setRightValue:(double)rightValue{
    if (rightValue < self.leftValue) rightValue = self.leftValue;
    if (rightValue > _maximumValue) rightValue = _maximumValue;
    double currentRange = rightValue - _minimumValue;
    double totalRange = _maximumValue - _minimumValue;
    _rightImageView.centerX = _backgroundImageView.headX + currentRange / totalRange * _backgroundImageView.width;
    _rightTrackImageView.headX = _rightImageView.centerX;
    [rightShapeLayer setPath: [UIBezierPath bezierPathWithRoundedRect:_rightTrackImageView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(2.5, 2.5)].CGPath];
    _contentImageView.tailX = _rightImageView.centerX;
    _timeLabel.frame = CGRectMake((_leftImageView.centerX + _rightImageView.centerX) / 2 - 15, _leftImageView.frame.origin.y - 15, 40, 15);
    CMTime start;
    CMTime end;
    start = CMTimeMake(self.leftValue * 10000, 10000);
    end = CMTimeMake(self.rightValue * 10000, 10000);
    CMTime durationT = CMTimeSubtract(end, start);
    float duration = CMTimeGetSeconds(durationT);
    _timeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
}

- (void)updateLeftValue:(double)leftRate{
    _contentImageView.headX = _backgroundImageView.headX + leftRate * _backgroundImageView.width;
    _timeLabel.frame = CGRectMake((_leftImageView.centerX + _rightImageView.centerX) / 2 - 15, _leftImageView.frame.origin.y - 15, 40, 15);
    CMTime start;
    CMTime end;
    start = CMTimeMake(self.leftValue * 10000, 10000);
    end = CMTimeMake(self.rightValue * 10000, 10000);
    CMTime durationT = CMTimeSubtract(end, start);
    float duration = CMTimeGetSeconds(durationT);
    _timeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
}

- (void)updateRightValue:(double)rightRate {
    _contentImageView.tailX = _backgroundImageView.headX + rightRate * _backgroundImageView.width;
    _timeLabel.frame = CGRectMake((_leftImageView.centerX + _rightImageView.centerX) / 2 - 15, _leftImageView.frame.origin.y - 15, 40, 15);
    CMTime start;
    CMTime end;
    start = CMTimeMake(self.leftValue * 10000, 10000);
    end = CMTimeMake(self.rightValue * 10000, 10000);
    CMTime durationT = CMTimeSubtract(end, start);
    float duration = CMTimeGetSeconds(durationT);
    _timeLabel.text = [NSString stringWithFormat:@"%.1fs", duration];
}

- (void)setLeftTrackImage:(UIImage *)leftTrackImage{
    _leftTrackImage = leftTrackImage;
    [_leftTrackImageView setImage: _leftTrackImage];
}

- (void)setRightTrackImage:(UIImage *)rightTrackImage{
    _rightImage = rightTrackImage;
    [_rightTrackImageView setImage: _rightImage];
}

- (void)setLeftImage:(UIImage *)leftImage{
    _leftImage = leftImage;
    [_leftImageView setImage:_leftImage];
}

- (void)setRightImage:(UIImage *)rightImage{
    _rightImage = rightImage;
    [_rightImageView setImage:_rightImage];
}

#pragma mark - action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    leftTrackLastLocation = _leftImageView.centerX;
    rightTrackLastLocation = _rightImageView.centerX;
}

- (void)panLeftImageView:(UIPanGestureRecognizer *)recognzier{
    switch (recognzier.state) {
        case UIGestureRecognizerStateBegan:
        {
            leftTrackLastLocation = _leftImageView.centerX;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat translationX = [recognzier translationInView:self].x;
            CGFloat tmp = leftTrackLastLocation+translationX;
            CGFloat max = _rightImageView.centerX - _minimumInterval;
            if (tmp>max){
                tmp = max;
            }else if (tmp<_backgroundImageView.headX){
                tmp = _backgroundImageView.headX;
            }
            _leftImageView.centerX = tmp;
            _leftTrackImageView.tailX = _leftImageView.centerX;
            leftShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_leftTrackImageView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
            [NSNotificationCenter.defaultCenter postNotificationName:leftTrackNotificationName object:nil];
        }
            break;
        default:
            break;
    }
}

- (void)panRightImageView:(UIPanGestureRecognizer *)recognzier{
    switch (recognzier.state) {
        case UIGestureRecognizerStateBegan:
        {
            rightTrackLastLocation = _rightImageView.centerX;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat translationX = [recognzier translationInView:self].x;
            CGFloat tmp = rightTrackLastLocation+translationX;
            CGFloat min = _leftImageView.centerX + _minimumInterval;
            if (tmp<min){
                tmp = min;
            }else if (tmp>_backgroundImageView.tailX){
                tmp = _backgroundImageView.tailX;
            }
            _rightImageView.centerX = tmp;
            _rightTrackImageView.tailX = _rightImageView.centerX;
            rightShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_rightTrackImageView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
            [NSNotificationCenter.defaultCenter postNotificationName:rightTrackNotificationName object:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - method
- (void)updateSubViews{
    CGFloat centerY = self.height / 2;
    _minimumValueImageView.x = 0;
    _maximumValueImageView.x = self.width - _maximumValueImageView.width;
    _minimumValueImageView.centerY = centerY;
    _maximumValueImageView.centerY = centerY;
    
    _backgroundImageView.tailX = _maximumValueImageView.headX - 5.0 - _rightImageView.width/2;
    _backgroundImageView.headX = _minimumValueImageView.tailX + 5.0 + _leftImageView.width/2;
    _backgroundImageView.centerY = centerY;

    _leftImageView.x = _minimumValueImageView.tailX + 5.0;
    _leftImageView.centerY = centerY;
    _rightImageView.x = _maximumValueImageView.headX - 5.0 - _rightImageView.width;
    _rightImageView.centerY = centerY;

    _leftTrackImageView.headX = _backgroundImageView.headX;
    _leftTrackImageView.tailX = _leftImageView.centerX;
    _leftTrackImageView.centerY = centerY;
    
    _rightTrackImageView.tailX = _backgroundImageView.tailX;
    _rightTrackImageView.headX = _rightImageView.centerX;
    _rightTrackImageView.centerY = centerY;
    
    _contentImageView.centerY = centerY;
    
    leftShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_leftTrackImageView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
    rightShapeLayer.path = [[UIBezierPath bezierPathWithRoundedRect:_rightTrackImageView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(2.5, 2.5)] CGPath];
}

- (void)addTarget:(nonnull id)target action:(SEL)action forEvent:(ZHDoubleSliderEvent)event{
    if (event == ZHDoubleSliderEventLeftValueChanged){
        [NSNotificationCenter.defaultCenter removeObserver:target name:leftTrackNotificationName object:nil];
        [NSNotificationCenter.defaultCenter addObserver:target selector:action name:leftTrackNotificationName object:nil];
        
    }
    if (event == ZHDoubleSliderEventRightValueChanged){
        [NSNotificationCenter.defaultCenter removeObserver:target name:rightTrackNotificationName object:nil];
        [NSNotificationCenter.defaultCenter addObserver:target selector:action name:rightTrackNotificationName object:nil];
    }
}

@end
