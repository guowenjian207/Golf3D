//
//  FramesSelectCellCollectionViewCell.m
//  MatchItUp
//
//  Created by GWJ on 2023/4/4.
//

#import "FramesSelectCellCollectionViewCell.h"

@implementation FramesSelectCellCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithRed:32/255.f green:32/255.f blue:32/255.f alpha:1];
        _leftImageView = [[UIImageView alloc]init];
        _leftImageView.backgroundColor = [UIColor blackColor];
//        _leftImageView.contentMode = UIViewContentModeCenter;
        [self addSubview: _leftImageView];
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(frame.size.height/5*4);
            make.right.equalTo(self).offset(-frame.size.width/2-1);
        }];
        
        _rightImageView = [[UIImageView alloc]init];
        _rightImageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_rightImageView];
        [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(frame.size.height/5*4);
            make.left.equalTo(self).offset(frame.size.width/2+1);
        }];
        
        self.contentView.backgroundColor =[UIColor clearColor];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.bottom.equalTo(_rightImageView);
        }];
        
        _lockStateChange = [[UIButton alloc]init];
        [_lockStateChange setImage:[UIImage imageNamed:@"imageopen"] forState:UIControlStateNormal];
        [_lockStateChange setImage:[UIImage imageNamed:@"imagelock"] forState:UIControlStateSelected];
        [self.contentView addSubview:_lockStateChange];
        [_lockStateChange mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_rightImageView).offset(102);
            make.width.height.mas_equalTo(40);
            make.top.equalTo(_rightImageView).offset(132.5);
        }];
        
        [self.contentView setHidden:YES];
    }
    return self;
}
-(void) resettingCell{
    [self.contentView setHidden:YES];
    [_lockStateChange setSelected:NO];
}
@end
