//
//  SpecitificationAlbumCollectionViewCell.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/16.
//

#import "SpecificationAlbumCollectionViewCell.h"

@implementation SpecificationAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backImageView = [[UIImageView alloc]init];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backImageView.layer.masksToBounds = YES;
        [self addSubview:_backImageView];
        [_backImageView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.top.width.equalTo(self);
            maker.height.mas_equalTo(self.mas_height).offset(-35);
        }];
        
        _bottomView = [[UIImageView alloc] init];
        [self addSubview:_bottomView];
        [_bottomView setBackgroundColor:[UIColor darkGrayColor]];
//        [_bottomView setAlpha:0.4];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self);
            maker.right.bottom.equalTo(self);
            maker.height.mas_equalTo(35);
        }];
        
        _timeLabel = [[UILabel alloc]init];
        [_bottomView addSubview:_timeLabel];
        [_timeLabel setTextColor: [UIColor blackColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel setFont: [UIFont systemFontOfSize:11]];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self).mas_offset(5);
            maker.right.equalTo(self);
            maker.bottom.equalTo(self->_bottomView.mas_bottom);
            maker.height.mas_equalTo(15);
        }];
        
        _remarkLabel = [[UILabel alloc]init];
        [_bottomView addSubview:_remarkLabel];
        [_remarkLabel setTextColor: [UIColor blackColor]];
        [_remarkLabel setTextAlignment:NSTextAlignmentLeft];
        [_remarkLabel setFont: [UIFont systemFontOfSize:13]];
        [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.equalTo(self).mas_offset(5);
            maker.right.equalTo(self);
            maker.top.equalTo(self ->_bottomView.mas_top);
            maker.height.mas_equalTo(18);
        }];
        
        [self.contentView setBackgroundColor:[UIColor darkGrayColor]];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.left.right.bottom.top.equalTo(_bottomView);
        }];
        
        _deleteButton = [[UIButton alloc]init];
        [self.contentView addSubview:_deleteButton];
        [_deleteButton setImage:[UIImage imageNamed:@"deleteFrame"] forState:UIControlStateNormal];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.top.equalTo(self.contentView.mas_top).offset(5);
            make.width.height.mas_equalTo(25);
        }];
        
        _stateChange = [[UIButton alloc]init];
        [self.contentView addSubview:_stateChange];
        [_stateChange setImage:[UIImage imageNamed:@"using"] forState:UIControlStateNormal];
        [_stateChange setImage:[UIImage imageNamed:@"stopUsing"] forState:UIControlStateSelected];
        [_stateChange mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.top.equalTo(self.contentView.mas_top).offset(3);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(25);
        }];
        [self.contentView setHidden:YES];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds=YES;
        self.layer.cornerRadius=10.0;
    }
    return self;
}

-(void) resettingCell{
    [self.bottomView setBackgroundColor:[UIColor darkGrayColor]];
    [self.contentView setHidden:YES];
    self.timeLabel.text = nil;
    self.remarkLabel.text = nil;
}
@end
