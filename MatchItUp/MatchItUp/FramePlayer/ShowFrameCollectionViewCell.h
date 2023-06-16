//
//  ShowFrameCollectionViewCell.h
//  FrameCut
//
//  Created by 胡跃坤 on 2021/7/28.
//

#import <UIKit/UIKit.h>
#import "ShowFramesViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DeleteFrameDelegate <NSObject>

- (void)deleteFrameAtIndex:(int)index;

@end

@interface ShowFrameCollectionViewCell : UICollectionViewCell

- (void)setFrameImg:(UIImage *)frameImg andLabel:(int)index;
- (void)setFrameSetViewWithArray:(NSMutableArray *)array;
@property (nonatomic, weak) ShowFramesViewController<DeleteFrameDelegate> *delegate;

@end

NS_ASSUME_NONNULL_END
