//
//  ScrollPlayerTopBar.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerTopBar.h"
#import <Masonry/Masonry.h>

@interface ScrollPlayerTopBar ()

@property(nonatomic, strong) UIButton *backBtn;
@property(nonatomic, strong) UIButton *menuBtn;
@property(nonatomic, strong) UILabel *rateLabel;

@property(nonatomic, strong) UIView *menuView;

@property(nonatomic, strong) UIView *rateView;

@end

@implementation ScrollPlayerTopBar{
    UIButton *rate0Btn;
    UIButton *rate1Btn;
    UIButton *rate2Btn;
    UIButton *rate3Btn;
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
- (void)setTitle:(NSString *)title {
    self.rateLabel.text = title;
}

- (NSString *)title {
    return self.rateLabel.text;
}

- (void)outletLayout{
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-10);
        make.left.equalTo(self).mas_offset(10);
        make.height.width.mas_equalTo(40);
    }];
    
    [_rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(_backBtn);
        make.width.mas_equalTo(100);
        make.centerX.equalTo(self);
    }];
    
    [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.bottom.equalTo(_backBtn);
        make.right.equalTo(self).mas_offset(-10);
    }];
    
    [_rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.superview);
        make.width.mas_equalTo(self.superview.frame.size.width / 3);
        make.height.mas_equalTo(170);
    }];
    
    [rate0Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_rateView);
        make.top.left.equalTo(_rateView).mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.equalTo(_rateView).mas_offset(-20);
    }];
    
    [rate1Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(rate0Btn);
        make.top.mas_equalTo(rate0Btn.mas_bottom).offset(10);
    }];
    
    [rate2Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(rate0Btn);
        make.top.mas_equalTo(rate1Btn.mas_bottom).offset(10);
    }];
    
    [rate3Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(rate0Btn);
        make.top.mas_equalTo(rate2Btn.mas_bottom).offset(10);
    }];
}

- (void)outletConfig{
    
    self.backgroundColor = [UIColor blackColor];
    
    _backBtn = [[UIButton alloc] init];
    [_backBtn setImage:[UIImage imageNamed:@"left_back2"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];
    
    _menuBtn = [[UIButton alloc] init];
    [_menuBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [_menuBtn addTarget:self action:@selector(menuBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_menuBtn];
    
    _rateLabel = [[UILabel alloc] init];
    [_rateLabel setText:@"1.0X"];
    _rateLabel.textAlignment = NSTextAlignmentCenter;
    _rateLabel.font = [UIFont boldSystemFontOfSize:15];
    _rateLabel.textColor = [UIColor whiteColor];
    [self addSubview:_rateLabel];
}

#pragma mark - action
- (void)backBtnTapped{
    if (self.delegate && [self.delegate respondsToSelector:@selector(back)]){
        [self.delegate back];
    }
}

- (void)menuBtnTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuBtnTapped)]){
        [self.delegate menuBtnTapped];
    }
}

@end
