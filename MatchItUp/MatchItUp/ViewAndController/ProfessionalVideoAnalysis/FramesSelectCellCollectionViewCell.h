//
//  FramesSelectCellCollectionViewCell.h
//  MatchItUp
//
//  Created by GWJ on 2023/4/4.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"
NS_ASSUME_NONNULL_BEGIN

@interface FramesSelectCellCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView *leftImageView;
@property(nonatomic,strong) UIImageView *rightImageView;

@property(nonatomic,strong) UIButton *lockStateChange;


-(void) resettingCell;
@end

NS_ASSUME_NONNULL_END
