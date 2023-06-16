//
//  SpecificationFrameCell.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpecificationFrameCell : UIImageView
@property(nonatomic,strong) UIButton *deleteButton;
@property(nonatomic,strong) UIView *contentsView;
@end

NS_ASSUME_NONNULL_END
