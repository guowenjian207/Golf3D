//
//  SpecitificationAlbumCollectionViewCell.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"
NS_ASSUME_NONNULL_BEGIN

@interface SpecificationAlbumCollectionViewCell : UICollectionViewCell
@property(nonatomic,assign) int index;
@property(nonatomic,strong) UIImageView *backImageView;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *remarkLabel;
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *stateView;
@property(nonatomic,strong) UIButton *deleteButton;
@property(nonatomic,strong) UIButton *stateChange;


-(void) resettingCell;
@end

NS_ASSUME_NONNULL_END
