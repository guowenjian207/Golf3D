//
//  AlbumCollectionViewCell.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *backImageView;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UIImageView *favoriteImgView;
@property(nonatomic,strong) UILabel *scoreLabel;
@property(nonatomic,strong) UILabel *remarkLabel;
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *topView;

@property(nonatomic,strong) UIButton *duplicateButton;
@property(nonatomic,strong) UIButton *stateChange;
@property(nonatomic,strong) UIButton *bianjiButton;

-(void) resettingCell;

@end

NS_ASSUME_NONNULL_END
