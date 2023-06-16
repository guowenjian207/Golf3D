//
//  AlbumCollectionViewCell.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import "AlbumCollectionViewCell.h"

@implementation AlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _backImageView = [[UIImageView alloc]init];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backImageView.layer.masksToBounds = YES;
        [self addSubview:_backImageView];
        [_backImageView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.top.height.width.equalTo(self);
        }];
        
        _timeLabel = [[UILabel alloc]init];
        [self addSubview:_timeLabel];
        [_timeLabel setTextColor: [UIColor yellowColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self).mas_offset(5);
            maker.right.equalTo(self);
            maker.bottom.equalTo(self).mas_offset(-5);
            maker.height.mas_equalTo(15);
        }];
        
        _favoriteImgView = [[UIImageView alloc]init];
        _favoriteImgView.layer.masksToBounds = YES;
        _favoriteImgView.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:_favoriteImgView];
        
        
        
        _scoreLabel = [[UILabel alloc]init];
        [self addSubview:_scoreLabel];
        [_scoreLabel setTextColor: [UIColor yellowColor]];
        [_scoreLabel setFont:[UIFont systemFontOfSize:20]];
        _scoreLabel.textAlignment = NSTextAlignmentLeft;
        _scoreLabel.frame = CGRectMake(0, 30, 60, 30);
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
//        [self.contentView mas_makeConstraints:^(MASConstraintMaker *maker){
//            maker.left.right.top.equalTo(self);
//            maker.height.mas_equalTo(50);
//        }];
        
        _topView = [[UIView alloc]init];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.right.top.equalTo(self);
            maker.height.mas_equalTo(50);
        }];
        
        _duplicateButton = [[UIButton alloc]init];
        [_topView addSubview:_duplicateButton];
        [_duplicateButton setImage:[UIImage imageNamed:@"复制"] forState:UIControlStateNormal];
        [_duplicateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.top.equalTo(self.contentView.mas_top).offset(5);
            make.width.height.mas_equalTo(40);
        }];
        
        _stateChange = [[UIButton alloc]init];
        [_topView addSubview:_stateChange];
        [_stateChange setImage:[UIImage imageNamed:@"using"] forState:UIControlStateNormal];
        [_stateChange setImage:[UIImage imageNamed:@"stopUsing"] forState:UIControlStateSelected];
        [_stateChange mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.top.equalTo(self.contentView.mas_top).offset(3);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(40);
        }];
        
        _bottomView = [[UIView alloc] init];
        [self.contentView addSubview:_bottomView];
        [_bottomView setBackgroundColor:[UIColor blackColor]];
        [_bottomView setAlpha:0.4];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self);
            maker.right.bottom.equalTo(self);
            maker.height.mas_equalTo(50);
        }];
        
        _remarkLabel = [[UILabel alloc]init];
        [self addSubview:_remarkLabel];
        [_remarkLabel setTextColor: [UIColor blackColor]];
        [_remarkLabel setAlpha:1];
        [_remarkLabel setTextAlignment:NSTextAlignmentLeft];
        [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self).mas_offset(5);
            maker.right.equalTo(self);
            maker.top.equalTo(_bottomView);
            maker.height.mas_equalTo(30);
        }];
        
        _bianjiButton = [[UIButton alloc]init];
//        _bianjiButton.backgroundColor = [UIColor redColor];
        [_bottomView addSubview:_bianjiButton];
        [_bianjiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_bottomView);
        }];
        
        [_topView setHidden:YES];
        [self.bottomView setHidden:YES];
        [self.timeLabel setHidden:YES];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void) resettingCell{
    [_bottomView setBackgroundColor:[UIColor blackColor]];
    [_bottomView setAlpha:0.4];
    [_bottomView setHidden:YES];
    [self.topView setHidden:YES];
    self.timeLabel.text = nil;
    self.remarkLabel.text = nil;
}
@end
