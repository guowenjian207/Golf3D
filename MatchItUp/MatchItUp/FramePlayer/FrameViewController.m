//
//  FrameViewController.m
//  FrameCut
//
//  Created by 胡跃坤 on 2021/9/16.
//

#import "FrameViewController.h"
#import "Canvas.h"

@interface FrameViewController ()<UIScrollViewDelegate, CanvasDelegate>

@property (nonatomic, strong) UIButton *canvasBtn;
@property(nonatomic, strong) Canvas *canvas;

@end

@implementation FrameViewController{
    UIScrollView *bgView;
    UIScrollView *scrollView;
    UIImageView *lastImageView;
    CGRect originalFrame;
    UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (Canvas *)canvas {
    if (_canvas == NULL) {
        _canvas = [[Canvas alloc] initWithFrame:self.view.bounds];
        _canvas.delegate = self;
        _canvas.hidden = YES;
    }
    return _canvas;
}

- (instancetype)initWithImage:(UIImage *)image andImageFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        bgView = [[UIScrollView alloc] init];
        bgView.frame = [UIScreen mainScreen].bounds;
        bgView.backgroundColor = [UIColor blackColor];
        
        imageView = [[UIImageView alloc] init];
        imageView.image = image;
        imageView.frame = frame;
        imageView.center = bgView.center;
        [bgView addSubview:imageView];
        [self.view addSubview:bgView];
        
        lastImageView = imageView;
        originalFrame = imageView.frame;
        scrollView = bgView;
        //最大放大比例
        scrollView.maximumZoomScale = 5;
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        self.canvasBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.canvasBtn.backgroundColor = [UIColor blackColor];
        [self.canvasBtn setTitle:@"画布" forState:UIControlStateNormal];
        [self.canvasBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.canvasBtn addTarget:self action:@selector(showCanvas) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_canvasBtn];
        
        [self.canvasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40);
                make.width.mas_equalTo(100);
                make.left.equalTo(self.view);
                make.top.equalTo(self.view).offset(50);
        }];
        
        [self.view addSubview:self.canvas];
    }
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return lastImageView;
}

- (void)showCanvas {
    self.canvas.hidden = NO;
}

- (void)closeCanvas {
    [self.canvas clear];
    self.canvas.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
