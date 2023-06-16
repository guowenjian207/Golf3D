//
//  ScrollPlayerOptionView.m
//  MatchItUp
//
//  Created by 安子和 on 2021/6/21.
//

#import "ScrollPlayerOptionView.h"

#define OptionViewWidth 100
#define OptionButtonHeight 40

@implementation ScrollPlayerOptionButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
        [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self setTitle:_title forState:UIControlStateNormal];
}

- (void)tapped {
    if (_tapAction) {
        _tapAction();
    }
}

@end

@implementation ScrollPlayerOptionView

- (void)setButtons:(NSArray<ScrollPlayerOptionButton *> *)buttons {
    _buttons = buttons;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.frame = CGRectMake(0, 0, OptionViewWidth, OptionButtonHeight * buttons.count);
    for (NSUInteger i = 0; i < buttons.count; ++i) {
        ScrollPlayerOptionButton *btn = _buttons[i];
        btn.frame = CGRectMake(0, i * OptionButtonHeight, OptionViewWidth, OptionButtonHeight);
        [self addSubview:btn];
    }
}

@end
