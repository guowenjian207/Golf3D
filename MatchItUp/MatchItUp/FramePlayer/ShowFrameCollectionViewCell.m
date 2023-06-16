//
//  ShowFrameCollectionViewCell.m
//  FrameCut
//
//  Created by 胡跃坤 on 2021/7/28.
//

#import "ShowFrameCollectionViewCell.h"
#import "FrameSetView.h"
#import <Masonry/Masonry.h>
#import "FrameViewController.h"

@implementation ShowFrameCollectionViewCell{
    FrameSetView *frameSetView;
    UIImageView *frameImgView;
    UILabel *label;
    UIButton *btn;
    UIButton *seeMoreBtn;
    int idx;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frameImgView = [[UIImageView alloc] init];
        [self.contentView addSubview:frameImgView];
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        btn = [[UIButton alloc] init];
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:@"deleteFrame"] forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        [btn addTarget:self action:@selector(deleteFrame) forControlEvents:UIControlEventTouchUpInside];
        seeMoreBtn = [[UIButton alloc] init];
        seeMoreBtn.backgroundColor = [UIColor clearColor];
        [seeMoreBtn setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
        [self.contentView addSubview:seeMoreBtn];
        [seeMoreBtn addTarget:self action:@selector(seeMore) forControlEvents:UIControlEventTouchUpInside];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.top.left.equalTo(self.contentView);
                    make.height.mas_equalTo(40);
        }];
        
        [frameImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.left.bottom.equalTo(self.contentView);
                    make.top.equalTo(label.mas_bottom);
        }];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.right.equalTo(frameImgView);
                    make.width.height.mas_equalTo(40);
        }];
        
        [seeMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.equalTo(self.contentView);
                    make.width.height.mas_equalTo(40);
        }];
    }
    return self;
}

- (void)deleteFrame {
    [self.delegate deleteFrameAtIndex:idx];
}

- (void)setFrameImg:(UIImage *)frameImg andLabel:(int)index{
    idx = index;
    frameImgView.image = frameImg;
    [label setText:[NSString stringWithFormat:@"第%d帧", index+1]];
    [frameSetView setHidden:true];
    [btn setHidden:false];
    [frameImgView setHidden:false];
}

- (void)setFrameSetViewWithArray:(NSMutableArray *)array {
    [label setText:@"13帧合成图"];
    [frameSetView setHidden:false];
    [btn setHidden:true];
    [frameImgView setHidden:true];
    frameSetView = [[FrameSetView alloc] initWithFrame:CGRectMake(0, (self.contentView.bounds.size.height - self.contentView.bounds.size.width) / 2, self.contentView.bounds.size.width, self.contentView.bounds.size.width) andFrameSet:array];
    [self.contentView addSubview:frameSetView];
    [frameSetView setBackgroundColor:[UIColor whiteColor]];
}

//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)convertViewToImage:(UIView *)view {
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
}

- (void)seeMore {
    FrameViewController *frameViewController;
    if ([self.reuseIdentifier isEqual:@"SHOWFRAMES_1"]) {
        frameViewController = [[FrameViewController alloc] initWithImage:[self convertViewToImage:frameSetView] andImageFrame:frameSetView.frame];
    }
    else {
        frameViewController = [[FrameViewController alloc] initWithImage:frameImgView.image andImageFrame:frameImgView.frame];
    }
    
    [self.delegate.navigationController pushViewController:frameViewController animated:YES];
}

@end
