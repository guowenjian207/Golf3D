//
//  indexvideoAnalysisCollectionViewCell.h
//  MatchItUp
//
//  Created by GWJ on 2022/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface indexvideoAnalysisCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) UIImageView *videoImgView;



- (void)setVideoCover:(UIImage *)videoCover;
@end

NS_ASSUME_NONNULL_END
