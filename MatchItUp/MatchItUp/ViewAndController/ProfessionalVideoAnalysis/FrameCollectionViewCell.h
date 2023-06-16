//
//  FrameCollectionViewCell.h
//  切帧App
//
//  Created by 胡跃坤 on 2021/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameCollectionViewCell : UICollectionViewCell
@property(nonatomic,assign) int index;
- (void)setFrameImg:(UIImage *)frameImg withRate:(float)rate;
- (void)selectCell;
- (void)sesetting;
@end

NS_ASSUME_NONNULL_END
