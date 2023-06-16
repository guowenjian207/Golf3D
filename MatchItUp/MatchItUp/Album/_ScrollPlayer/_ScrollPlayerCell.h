//
//  _ScrollPlayerCell.h
//  MatchItUp
//
//  Created by 安子和 on 2021/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface _ScrollPlayerCell : UICollectionViewCell

@property(nonatomic, copy) void(^leftBtnTapAction)(NSUInteger);
@property(nonatomic, copy) void(^rightBtnTapAction)(NSUInteger);

@end

NS_ASSUME_NONNULL_END
