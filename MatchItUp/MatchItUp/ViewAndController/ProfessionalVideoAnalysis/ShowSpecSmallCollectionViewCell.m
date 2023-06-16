//
//  ShowSpecSmallCollectionViewCell.m
//  MatchItUp
//
//  Created by GWJ on 2023/4/14.
//

#import "ShowSpecSmallCollectionViewCell.h"

@implementation ShowSpecSmallCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:_imageView];
    }
    return self;
}
@end
