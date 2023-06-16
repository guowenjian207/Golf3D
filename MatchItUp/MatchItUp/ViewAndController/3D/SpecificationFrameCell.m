//
//  SpecificationFrameCell.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/24.
//

#import "SpecificationFrameCell.h"
#import <Masonry/Masonry.h>

@implementation SpecificationFrameCell

- (instancetype)init{
    self = [super init];
    if (self) {
        _contentsView = [[UIView alloc]init];
        [self addSubview:_contentsView];
        [_contentsView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.top.bottom.width.height.equalTo(self);
        }];
        _deleteButton = [[UIButton alloc]init];
        [_contentsView addSubview:_deleteButton];
        [_deleteButton setImage:[UIImage imageNamed:@"deleteFrame"] forState:UIControlStateNormal];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(50);
            make.top.equalTo(self.mas_top).offset(60);
            make.width.height.mas_equalTo(40);
        }];
        [_contentsView setHidden:YES];
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end
