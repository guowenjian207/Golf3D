//
//  ButtonCollectionViewCell.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ButtonCollectionViewCell : UICollectionViewCell

- (void)setImageAndText:(NSString *)str withIsFront:(BOOL)isFront;
- (void)buttonSelect;
- (void)buttonCancel;
- (void)turnImage:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
