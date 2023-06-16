//
//  ButtonCollectionViewCell.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/27.
//

#import "ButtonCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface ButtonCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) UIColor *color;

@end

@implementation ButtonCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (UIImage *)UIImage:(UIImage *)originalImage AddWaterMarkWithStr:(NSString *)waterString andColor:(UIColor *)color{
    UIGraphicsBeginImageContext(originalImage.size);
    
    // 原始图片渲染
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:500], NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:paragraphStyle};
    [waterString drawInRect:CGRectMake(0, 0, originalImage.size.width / 3, originalImage.size.width / 3) withAttributes:dic];
    
    
    // UIImage
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageNew;
}

- (void)setImageAndText:(NSString *)str withIsFront:(BOOL)isFront{
    if (!isFront) {
        self.flag = false;
        self.imageView.image = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%@", str]];
    }
    else {
        self.flag = true;
        self.imageView.image = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%@", str]];
    }
    self.color = [UIColor whiteColor];
    self.imageView.image = [self UIImage:self.imageView.image AddWaterMarkWithStr:str andColor:self.color];
    self.number = str;
}

- (void)buttonSelect {
    self.color = [UIColor greenColor];
    self.imageView.image = [self UIImage:self.imageView.image AddWaterMarkWithStr:self.number andColor:self.color];
}

- (void)buttonCancel {
    self.color = [UIColor whiteColor];
    self.imageView.image = [self UIImage:self.imageView.image AddWaterMarkWithStr:self.number andColor:self.color];
}

- (void)turnImage:(NSString *)str {
    if (!self.flag) {
        self.imageView.image = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%@", str]];
    }
    else {
        self.imageView.image = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%@", str]];
    }
    self.imageView.image = [self UIImage:self.imageView.image AddWaterMarkWithStr:str andColor:self.color];
    _flag = !_flag;
}

@end
