//
//  PlayerRateView.m
//  MatchItUp
//
//  Created by 安子和 on 2021/6/21.
//

#import "PlayerRateView.h"
#import "GlobalVar.h"

#define RateButtonHeight 50.0

@implementation PlayerRateView

- (instancetype)initWithRates:(NSArray<NSNumber *> *)rates {
    self = [super init];
    if (self) {
        self.rates = rates;
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
    return self;
}

- (void)setRates:(NSArray<NSNumber *> *)rates {
    _rates = rates;
    for (UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }
    
    CGFloat height = RateButtonHeight * _rates.count;
    
    self.frame = CGRectMake(kScreenW / 4, (kScreenH - height) / 2, kScreenW / 2, height);
    for (NSUInteger index = 0; index < rates.count; ++index) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = index;
        btn.frame = CGRectMake(0, index * RateButtonHeight, kScreenW / 2, RateButtonHeight);
        [btn setTitle:[NSString stringWithFormat:@"%@X", _rates[index]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(setPlayerRate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)setPlayerRate:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setPlayerRate:)]) {
        [self.delegate setPlayerRate:[_rates[btn.tag] floatValue]];
        self.hidden = YES;
    }
}

@end
