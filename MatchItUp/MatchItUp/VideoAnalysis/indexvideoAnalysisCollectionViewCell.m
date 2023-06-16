//
//  indexvideoAnalysisCollectionViewCell.m
//  MatchItUp
//
//  Created by GWJ on 2022/12/14.
//

#import "indexvideoAnalysisCollectionViewCell.h"

@implementation indexvideoAnalysisCollectionViewCell{
   
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width - 4, frame.size.height - 4)];
        [self.contentView addSubview:_videoImgView];
    }
    return self;
}
- (void)setVideoCover:(UIImage *)videoCover {
    _videoImgView.image = videoCover;
}
@end
