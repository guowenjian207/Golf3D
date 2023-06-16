//
//  ScrollPlayerBottomView.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/23.
//

#import "ScrollPlayerBottomView.h"
#import <Masonry/Masonry.h>
#import "ZHDoubleSlider.h"
#import "GlobalVar.h"

@interface ScrollPlayerBottomView ()

@end

@implementation ScrollPlayerBottomView{
    //normal
    UIView *normalView;
    UIButton *middleBtn;
    UIButton *rightBtn;
    UISlider *slider;
    
    //逐帧播放
    UIView *frameView;
    UIButton *lastFrameBtn;
    UIButton *nextFrameBtn;
    UILabel *sumTitleLabel;
    UILabel *sumLabel;
    UILabel *indexTitleLabel;
    UILabel *indexLabel;
    UIStepper *frameStepper;
    UILabel *stepTitleLabel;
    UILabel *stepLabel;
    
    UIButton *cancelBtn;
    
    //剪裁
    ZHDoubleSlider *doubleSlider;
}

- (instancetype)initWithSuperview:(UIView *)superview{
    self = [super init];
    if (self){
        [superview addSubview:self];
        [self outletConfig];
        [self outletLayout];
    }
    return self;
}

#pragma mark - get & set
- (void)setType:(ScrollPlayerType)type{
    _type = type;
    switch (type) {
        case ScrollPlayerTypeLocal:
            [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            break;
        case ScrollPlayerTypeScreenRecord:
        case ScrollPlayerTypePosted:
            [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            break;
        case ScrollPlayerTypeSystem:
        case ScrollPlayerTypeSingle:
            [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)setMode:(ScrollPlayerMode)mode{
    if (_mode == mode){
        return;
    }
    switch (mode) {
        case ScrollPlayerModeEdit:
        {
            doubleSlider.frame = slider.frame;
            if (_mode == ScrollPlayerModeNormal){
                slider.hidden = YES;
                doubleSlider.hidden = NO;
            }else{
                normalView.hidden = YES;
            }
            [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        }
            break;
        case ScrollPlayerModeNormal:
        {
            if (_mode == ScrollPlayerModeEdit){
                doubleSlider.hidden = YES;
                slider.hidden = NO;
            }else{
                
                normalView.hidden = NO;
            }
            if (_type == ScrollPlayerTypeSingle || _type == ScrollPlayerTypeSystem) {
                [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
            } else {
                [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            }
        }
            break;
        case ScrollPlayerModeFramePlay:
        {
            frameView.hidden = NO;
        }
            break;
        default:
            break;
    }
    _mode = mode;
}

- (void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    if (_isPlaying){
        [middleBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }else{
        [middleBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)setSliderMaxValue:(float)sliderMaxValue {
    slider.maximumValue = sliderMaxValue;
    doubleSlider.maximumValue = sliderMaxValue;
    doubleSlider.rightValue = sliderMaxValue;
    doubleSlider.leftValue = 0;
}

- (void)setSliderCurrentValue:(float)sliderCurrentValue {
    if (!doubleSlider.hidden && sliderCurrentValue > doubleSlider.rightValue) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerSeekTo:)]) {
            [self.delegate playerSeekTo:doubleSlider.leftValue];
        }
    } else {
        slider.value = sliderCurrentValue;
    }
}

- (float)sliderMaxValue {
    return slider.maximumValue;
}

- (float)doubleSliderLeftValue {
    return doubleSlider.leftValue;
}

- (float)doubleSliderRightValue {
    return doubleSlider.rightValue;
}

#pragma mark - action
- (void)middleBtnTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playControl)]){
        [self.delegate playControl];
    }
}

- (void)rightBtnTapped{
    if (_mode == ScrollPlayerModeEdit) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(saveAsset)]){
            [self.delegate saveAsset];
        }
    }
}

- (void)dragSlider:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerSeekTo:)]) {
        [self.delegate playerSeekTo:slider.value];
    }
}

- (void)dragDoubleSliderLeft {
    [doubleSlider updateLeftValue:doubleSlider.leftValue / doubleSlider.maximumValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerSeekTo:)]) {
        [self.delegate playerSeekTo:doubleSlider.leftValue];
    }
}

- (void)dragDoubleSliderRight {
    [doubleSlider updateRightValue:doubleSlider.rightValue / doubleSlider.maximumValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerSeekTo:)]) {
        [self.delegate playerSeekTo:doubleSlider.rightValue];
    }
}

- (void)cancelBtnTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancel)]) {
        [self.delegate cancel];
    }
}

#pragma mark - outlet
- (void)outletLayout{
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.superview);
        make.height.mas_equalTo([GlobalVar sharedInstance].kTabbarH+21);
    }];
    
    [self addSubview:normalView];
    [normalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(self);
    }];
    
    [normalView addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(normalView.mas_top).mas_offset(-65);
        maker.left.equalTo(normalView).mas_offset(20);
        maker.right.equalTo(normalView).mas_offset(-20);
    }];
    
//    [normalView addSubview:doubleSlider];
//    [doubleSlider mas_makeConstraints:^(MASConstraintMaker *maker){
//        maker.top.equalTo(normalView.mas_top).mas_offset(15);
//        maker.left.equalTo(normalView).mas_offset(20);
//        maker.right.equalTo(normalView).mas_offset(-20);
//    }];
    
    [normalView addSubview:middleBtn];
    [middleBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(normalView);
        maker.height.width.mas_equalTo(50);
        //maker.bottom.equalTo(normalView).mas_offset(-15);
    }];
    
    [normalView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.height.width.mas_equalTo(50);
        maker.centerY.equalTo(middleBtn);
        maker.right.equalTo(normalView).mas_offset(-50);
    }];
    
    [normalView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(50);
            make.centerY.equalTo(middleBtn);
            make.left.equalTo(normalView).mas_offset(50);
    }];
}

- (void)outletConfig{
    normalView = [[UIView alloc] init];
    
    middleBtn = [[UIButton alloc]init];
    [middleBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [middleBtn addTarget:self action:@selector(middleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn = [[UIButton alloc]init];
    [rightBtn addTarget:self action:@selector(rightBtnTapped) forControlEvents:UIControlEventTouchUpInside];

    slider = [[UISlider alloc]init];
    [slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventValueChanged];
    [slider setContinuous:YES];
    [slider setMaximumTrackTintColor:[UIColor systemGrayColor]];
    slider.hidden = YES;
    
    doubleSlider = [[ZHDoubleSlider alloc] init];
    doubleSlider.hidden = YES;
    [normalView addSubview:doubleSlider];
    [doubleSlider addTarget:self action:@selector(dragDoubleSliderLeft) forEvent:ZHDoubleSliderEventLeftValueChanged];
    [doubleSlider addTarget:self action:@selector(dragDoubleSliderRight) forEvent:ZHDoubleSliderEventRightValueChanged];
    
    cancelBtn = [[UIButton alloc] init];
    [cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.x >= 0 && point.x <= self.frame.size.width && point.y >= -65 && point.y <= self.frame.size.height) {
        return true;
    }
    return false;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint newP = [self convertPoint:point toView:doubleSlider.leftImageView];
    if ([doubleSlider.leftImageView pointInside:newP withEvent:event]) {
        return doubleSlider.leftImageView;
    }
    newP = [self convertPoint:point toView:doubleSlider.rightImageView];
    if ([doubleSlider.rightImageView pointInside:newP withEvent:event]) {
        return doubleSlider.rightImageView;
    }
    return [super hitTest:point withEvent:event];
}

@end
