//
//  FramePlayerView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/28.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "FramePlayerView.h"
#import <Masonry/Masonry.h>
#import "FrameCollectionViewCell.h"
#import "Tool.h"
#import "CoreDataManager.h"
#import "CanvasView_update.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "UIImage+GIF.h"
#import "MyKeyFrameSlider.h"

@interface FramePlayerView ()<UICollectionViewDelegate,UICollectionViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate, NSCacheDelegate, CanvasViewDelegate, MyKeyFrameSliderDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) ZHVideoAsset *asset;
@property (nonatomic, assign) BOOL isFront;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) MyKeyFrameSlider *slider;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, assign) int frameIndex;
@property (nonatomic, assign) int frameNum;
@property (nonatomic, strong) UIImage *currentFrame;
@property (nonatomic, strong) UIImageView *imgView;
//@property (nonatomic, strong) UICollectionViewCell *currentSelectedCell;
@property (nonatomic, strong) CanvasView_update *canvas;
@property (nonatomic, strong) UIView *tmpView;
@property (nonatomic, strong) UIButton *lockBtn;
@property (nonatomic, strong) UIButton *swingPathBtn;
@property (nonatomic, strong) NSMutableArray *toolArray;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *pre13Btn;
@property (nonatomic, strong) UIButton *next13Btn;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *changeSpeedBtn;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation FramePlayerView {
    CGFloat originTmpH;
    CGFloat originH;
    CGFloat originZoomScale;
    CGFloat originMiniZoomScale;
    CGPoint originOffset;
    UIImageView *tmpImgView;
    BOOL islocked;
    CGFloat originScale;
    UIPanGestureRecognizer *panTopViewGestureRecognizer;
    CGFloat totalSeconds;
    BOOL topViewHiddenFlag;
    NSMutableArray *subViewHiddenFlagArray;
    UIButton *confirmBtn;
    UIButton *cancelBtn;
    int totalFrameNum;
    UILongPressGestureRecognizer *longPress;
    UIImageView *topDragView;
    UIImageView *formworkImgView;
    UIButton *redB, *yellowB, *greenB, *blackB, *blueB, *deleteAllB;
    MBProgressHUD *hud;
    NSNumber *videoId;
    UIImageView *sliderThumbImg;
    NSTimer *progressTimer;
    NSInteger lastState;
    NSArray *frameList;
    NSInteger indexOf13Frame;
    float speed;
    int indexSpeed;
    NSMutableArray *frameStateArray;
    NSMutableArray *frameIndexArray;
    
    UITapGestureRecognizer *changeFrontGes;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)toolArrayAddObj:(Tool *)newTool {
    [self.toolArray addObject:newTool];
}

- (void)deleteAllTools {
    for (Tool *tmpTool in self.toolArray) {
        [tmpTool.toolLayer removeFromSuperlayer];
        [tmpTool.toolPath removeAllPoints];
        [tmpTool.angleLabel removeFromSuperview];
    }
    [self.toolArray removeAllObjects];
}

- (void)toolArrayRemoveObj:(Tool *)tool {
    [self.toolArray removeObject:tool];
}

- (BOOL)viewIsLocked {
    return islocked;
}

- (void)mas_makeConstraintsFor:(UIButton *)pencilBtn and:(UIButton *)eraseBtn and:(UIButton *)deleteAllBtn and:(UIButton *)lineBtn and:(UIButton *)redBtn and:(UIButton *)rectBtn and:(UIButton *)yellowBtn and:(UIButton *)angleBtn and:(UIButton *)greenBtn and:(UIButton *)circleBtn and:(UIButton *)blueBtn and:(UIButton *)curveBtn and:(UIButton *)blackBtn {
    redB = redBtn;
    greenB = greenBtn;
    blackB = blackBtn;
    yellowB = yellowBtn;
    blueB = blueBtn;
    deleteAllB = deleteAllBtn;
    
    [pencilBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(self.topView.mas_bottom).offset(30);
    }];
    
    [eraseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(pencilBtn.mas_bottom);
    }];
    
    [deleteAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
        make.width.mas_equalTo(self.mas_height).multipliedBy(0.16);
        make.right.equalTo(eraseBtn.mas_left);
        make.top.equalTo(pencilBtn.mas_bottom);
    }];
    
    [lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(eraseBtn.mas_bottom);
    }];
    
    [redBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.06);
                make.right.equalTo(lineBtn.mas_left).offset(-10);
                make.centerY.equalTo(lineBtn);
    }];
    
    [rectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(lineBtn.mas_bottom);
    }];
    
    [yellowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.06);
                make.right.equalTo(rectBtn.mas_left).offset(-10);
        make.centerY.equalTo(rectBtn);
    }];
    
    [angleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(rectBtn.mas_bottom);
    }];
    
    [greenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.06);
                make.right.equalTo(angleBtn.mas_left).offset(-10);
        make.centerY.equalTo(angleBtn);
    }];
    
    [circleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(angleBtn.mas_bottom);
    }];
    
    [blueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.06);
                make.right.equalTo(circleBtn.mas_left).offset(-10);
        make.centerY.equalTo(circleBtn);
    }];
    
    [curveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                make.right.equalTo(self).offset(-20);
                make.top.equalTo(circleBtn.mas_bottom);
    }];
    
    [blackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.06);
                make.right.equalTo(curveBtn.mas_left).offset(-10);
        make.centerY.equalTo(curveBtn);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    redB.layer.cornerRadius = redB.frame.size.width / 2;
    greenB.layer.cornerRadius = redB.frame.size.width / 2;
    blackB.layer.cornerRadius = redB.frame.size.width / 2;
    yellowB.layer.cornerRadius = redB.frame.size.width / 2;
    blueB.layer.cornerRadius = redB.frame.size.width / 2;
    deleteAllB.titleLabel.font = [UIFont systemFontOfSize:20.0 * self.scrollView.zoomScale];
}

- (CGFloat)computeDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
    CGFloat a = p2.y - p1.y;
    CGFloat b = p1.x - p2.x;
    CGFloat c = p2.x * p1.y - p1.x * p2.y;

//    CGFloat x = (b * b * x0.x - a * b * x0.y - a * c) / (a * a + b * b);
//    CGFloat y = (-a * b * x0.x + a * a * x0.y - b * c) / (a * a + b * b);

    CGFloat d = (a * x0.x + b * x0.y + c) / sqrt(pow(a, 2) + pow(b, 2));
    if (d < 0) {
        d = -d;
    }
    if (((x0.x >= p1.x && x0.x <= p2.x) || (x0.x >= p2.x && x0.x <= p1.x)) || ((x0.y >= p1.y && x0.y <= p2.y ) || (x0.y >= p2.y && x0.y <= p1.y))) {
        if (d <= 20) {
            return d;
        }
    }
    return CGFLOAT_MAX;
}

- (CGFloat)computeCircleDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
    CGFloat xMin = fmin(p1.x, p2.x);
    CGFloat xMax = fmax(p1.x, p2.x);
    CGFloat m = (p1.x + p2.x) / 2;
    CGFloat n = (p1.y + p2.y) / 2;
    CGFloat a = fabs(p1.x - p2.x) / 2;
    CGFloat b = fabs(p1.y - p2.y) / 2;
    CGFloat d = CGFLOAT_MAX;
    for (CGFloat i = xMin; i <= xMax; i += 1) {
        CGFloat tmp = sqrt((1 - (i - m) * (i - m) / (a * a)) * (b * b));
        CGFloat y1 = tmp + n;
        CGFloat y2 = -tmp + n;
        CGFloat dis = sqrt((x0.x - i) * (x0.x - i) + (x0.y - y1) * (x0.y - y1));
        d = fmin(d, dis);
        dis = sqrt((x0.x - i) * (x0.x - i) + (x0.y - y2) * (x0.y - y2));
        d = fmin(d, dis);
    }
    if (d <= 20) {
        return d;
    }
    return CGFLOAT_MAX;
}

- (Tool *)chooseNearestToolWithX:(CGPoint)x0 {
    Tool *nearestTool = nil;
    CGFloat minDis = CGFLOAT_MAX;
    for (Tool *tool in self.toolArray) {
        if (tool.tool == Line) {
            CGFloat dis = [self computeDisWith:x0 andP1:CGPointFromString(tool.pointArray[0]) andP2:CGPointFromString(tool.pointArray[1])];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if (tool.tool == Rectangle) {
            CGPoint point1 = CGPointFromString(tool.pointArray[0]);
            CGPoint point2 = CGPointFromString(tool.pointArray[1]);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point2.x, point1.y)];
            CGFloat dis3 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis4 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
            if (dis3 < minDis && dis3 <= 20) {
                nearestTool = tool;
                minDis = dis3;
            }
            if (dis4 < minDis && dis4 <= 20) {
                nearestTool = tool;
                minDis = dis4;
            }
        }
        else if (tool.tool == Curve) {
            for (int i = 0; i < tool.pointArray.count - 1; i++) {
                CGFloat dis = [self computeDisWith:x0 andP1:CGPointFromString(tool.pointArray[i]) andP2:CGPointFromString(tool.pointArray[i + 1])];
                if (dis < minDis && dis <= 20) {
                    nearestTool = tool;
                    minDis = dis;
                }
            }
        }
        else if (tool.tool == Circle) {
            CGFloat dis = [self computeCircleDisWith:x0 andP1:CGPointFromString(tool.pointArray[0]) andP2:CGPointFromString(tool.pointArray[1])];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if (tool.tool == Angle) {
            CGFloat dis1 = [self computeDisWith:x0 andP1:CGPointFromString(tool.pointArray[0]) andP2:CGPointFromString(tool.pointArray[1])];
            CGFloat dis2 = [self computeDisWith:x0 andP1:CGPointFromString(tool.pointArray[1]) andP2:CGPointFromString(tool.pointArray[2])];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
        }
    }
    return nearestTool;
}

- (NSCache *)cache{
    if (!_cache) {
          _cache = [[NSCache alloc] init];
         // 设置成本为41 当存储的数据超过总成本数，NSCache会自动回收对象
          _cache.totalCostLimit = 41;
         // 设置代理 代理方法一般不会用到，一般是进行测试的时候使用
         _cache.delegate = self;
      }
      return _cache;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andVideo:(nonnull Video *)video andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _videoURL = videoURL;
        _isFront = video.isFront;
        _video = video;
        _asset = asset;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getFrameNum];
        });
        
        _tmpView = [[UIView alloc] init];
        [self addSubview:_tmpView];
        _tmpView.clipsToBounds = YES;
        _tmpView.backgroundColor = [UIColor redColor];
        
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.width / 720 * 1280);
        [_scrollView setShowsVerticalScrollIndicator:NO];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.bouncesZoom = NO;
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width / 720 * 1280)];
        [_scrollView addSubview:_imgView];
        [_tmpView addSubview:_scrollView];
        
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectFrame:)];
        longPress.minimumPressDuration = 0.5f;
        longPress.delegate = self;
        [self.scrollView addGestureRecognizer:longPress];
        
        _topView = [[UIImageView alloc] init];//WithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        [_topView setImage:[UIImage imageNamed:@"topView"]];
        _topView.userInteractionEnabled = YES;
        [self addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(self);
                    make.height.mas_equalTo(30);
        }];
        
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"left_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(popNavigation) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:_backBtn];
        [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(10);
            make.top.equalTo(self.topView).offset(3);
            make.bottom.equalTo(self.topView).offset(-3);
            make.width.mas_equalTo(25);
        }];
        
        _shareBtn = [[UIButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareButtonDidTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:_shareBtn];
        [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topView).offset(-10);
            make.top.equalTo(self.topView);
            make.bottom.equalTo(self.topView);
            make.width.mas_equalTo(30);
        }];
        
        UILabel *topLabel = [[UILabel alloc]init];
        [topLabel setFont: [UIFont boldSystemFontOfSize:20]];
        [topLabel setTextAlignment:NSTextAlignmentCenter];
        topLabel.text = @"Model  Swings";
        topLabel.textColor = [UIColor whiteColor];
        [self.topView addSubview:topLabel];
        [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self.topView);
            make.top.equalTo(self.topView);
            make.bottom.equalTo(self.topView);
        }];
        _bottomView = [[UIImageView alloc] init];
        [_bottomView setImage:[UIImage imageNamed:@"framePlayerBottomView"]];
        _bottomView.userInteractionEnabled = YES;
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.width.equalTo(self);
                    make.height.mas_equalTo(30);
                    make.top.equalTo(self.scrollView.mas_bottom);
        }];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 行列间距
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        // 设置item大小
        CGFloat kItemWidth = self.frame.size.width/13;
        CGFloat kItemHeight = kItemWidth/354*399;
        layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
        // 设置滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.frameCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.frameCollectionView.backgroundColor = [UIColor blackColor];
        self.frameCollectionView.showsHorizontalScrollIndicator = NO;
        self.frameCollectionView.scrollEnabled = YES;
        [self addSubview:_frameCollectionView];
        self.frameCollectionView.delegate = self;
        self.frameCollectionView.dataSource = self;
        [self.frameCollectionView registerClass:[FrameCollectionViewCell class] forCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID"];
        [self.frameCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.bottomView.mas_bottom);
        }];
        [_frameCollectionView setHidden:NO];
        
        changeFrontGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFront)];
        [changeFrontGes setNumberOfTapsRequired:2];
        [_frameCollectionView addGestureRecognizer:changeFrontGes];
        
        self.slider = [[MyKeyFrameSlider alloc] init];
        self.slider.delegate = self;
        self.slider.minimumValue = 0;
        self.slider.maximumTrackTintColor = [UIColor grayColor];
        
        UIFont *font = [UIFont boldSystemFontOfSize:15];
        UIImage *image = [UIImage imageNamed:@"sliderThumb"];
        UIGraphicsBeginImageContext(CGSizeMake(40, 60));
        [image drawInRect:CGRectMake(0,20,20,20)];
        CGRect rect = CGRectMake(0, 0, 40, 10);
        [[UIColor whiteColor] set];
        [@"  0.0s" drawInRect:CGRectIntegral(rect) withFont:font];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.slider setThumbImage:newImage forState:UIControlStateNormal];
        [self addSubview:_slider];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.mas_width).offset(-60);
                make.centerX.equalTo(self);
                make.height.mas_equalTo(40);
                make.bottom.equalTo(self.bottomView.mas_top);
        }];
        [self.slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        [self.slider addObserver:self forKeyPath:@"maximumValue" options:NSKeyValueObservingOptionNew context:nil];
        
        sliderThumbImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sliderThumb"]];
        self.slider.sliderThumbImg = sliderThumbImg;
        [self.slider addSubview:sliderThumbImg];
        sliderThumbImg.frame = CGRectMake(0, 11, 20, 20);
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_videoURL options:nil];
        CMTime time = asset.duration;
        totalSeconds = time.value/time.timescale;
        NSLog(@"totalSeconds:%f", totalSeconds);
        
        _tmpView.frame = CGRectMake(0, 30, self.frame.size.width, self.frame.size.width / 4 * 5);
        _scrollView.frame = _tmpView.bounds;
        
//        UIImageView *dragView = [[UIImageView alloc] init];
//        [dragView setImage:[UIImage imageNamed:@"dragView"]];
//        dragView.userInteractionEnabled = YES;
//        [_bottomView addSubview:dragView];
//        [dragView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.height.top.equalTo(_bottomView);
//                    make.width.mas_equalTo(40);
//        }];
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];
//        panGesture.delegate = self;
//        [dragView addGestureRecognizer:panGesture];
        
        panTopViewGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTopViewGestureRecognize:)];
        panTopViewGestureRecognizer.delegate = self;
        
        self.lockBtn = [[UIButton alloc] init];
        [self.lockBtn addTarget:self action:@selector(lockOrUnlock) forControlEvents:UIControlEventTouchUpInside];
        [self.lockBtn setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        [self.lockBtn setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateSelected];
        [self addSubview:self.lockBtn];
        [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
                    make.left.equalTo(self).offset(30);
                    make.top.equalTo(self.topView.mas_bottom).offset(30);
        }];
        
//        self.swingPathBtn  = [[UIButton alloc] init];
//        [self.swingPathBtn addTarget:self action:@selector(shareButtonDidTouched) forControlEvents:UIControlEventTouchUpInside];
//        [self.swingPathBtn setImage:[UIImage imageNamed:@"swingPath"] forState:UIControlStateNormal];
//        [self addSubview:self.swingPathBtn];
//        [self.swingPathBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
//            make.right.equalTo(self).offset(-20);
//            make.top.equalTo(self.topView.mas_bottom).offset(20);
//        }];
        
        self.autoChooseFrameBtn  = [[UIButton alloc] init];
        [self.autoChooseFrameBtn addTarget:self action:@selector(autoChooseFrame) forControlEvents:UIControlEventTouchUpInside];
        [self.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame"] forState:UIControlStateNormal];
        [self addSubview:self.autoChooseFrameBtn];
        [self.autoChooseFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
            make.left.equalTo(self).offset(30);
            make.top.equalTo(self.lockBtn.mas_bottom).offset(30);
        }];
        
        self.toolArray = [[NSMutableArray alloc] init];
        
        topViewHiddenFlag = false;
        
//        self.pre13Btn = [[UIButton alloc] init];
//        [self.pre13Btn setImage:[UIImage imageNamed:@"icons8-backward-48"] forState:UIControlStateNormal];
//        [self.pre13Btn addTarget:self action:@selector(previous13Frame) forControlEvents:UIControlEventTouchUpInside];
//        [self.bottomView addSubview:_pre13Btn];
        
        self.preBtn = [[UIButton alloc] init];
        [self.preBtn setImage:[UIImage imageNamed:@"leftFrame"] forState:UIControlStateNormal];
        [self.preBtn addTarget:self action:@selector(previousFrame) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_preBtn];
        
        self.playOrPauseBtn = [[UIButton alloc] init];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"playFrame"] forState:UIControlStateNormal];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"pauseFrame"] forState:UIControlStateSelected];
        [self.playOrPauseBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_playOrPauseBtn];
        
        self.nextBtn = [[UIButton alloc] init];
        [self.nextBtn setImage:[UIImage imageNamed:@"rightFrame"] forState:UIControlStateNormal];
        [self.nextBtn addTarget:self action:@selector(nextFrame) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_nextBtn];
        
//        self.next13Btn = [[UIButton alloc] init];
//        [self.next13Btn setImage:[UIImage imageNamed:@"icons8-end-48"] forState:UIControlStateNormal];
//        [self.next13Btn addTarget:self action:@selector(changeSpeed) forControlEvents:UIControlEventTouchUpInside];
//        [self.bottomView addSubview:_next13Btn];
        
        _pre13Btn.userInteractionEnabled=NO;
        _pre13Btn.alpha=0.4;
        _next13Btn.userInteractionEnabled=YES;
        _next13Btn.alpha=0.4;
        self.isPlaying = false;
        
        [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.bottomView);
                make.width.height.mas_equalTo(30);
        }];
        
        [self.preBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.right.equalTo(_playOrPauseBtn.mas_left).offset(-30);
        }];
        
//        [self.pre13Btn mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.width.height.bottom.equalTo(_preBtn);
//                make.right.equalTo(_preBtn.mas_left).offset(-30);
//        }];
        
        [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.left.equalTo(_playOrPauseBtn.mas_right).offset(30);
        }];
        
        [self.next13Btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_nextBtn);
                make.left.equalTo(_nextBtn.mas_right).offset(30);
        }];
        
        self.deleteBtn = [[UIButton alloc] init];
        [self.deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(removeVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.left.equalTo(_bottomView.mas_left).offset(10);
        }];
        
        self.changeSpeedBtn = [[UIButton alloc] init];
        [self.changeSpeedBtn setImage:[UIImage imageNamed:@"0.25x"] forState:UIControlStateNormal];
        [self.changeSpeedBtn addTarget:self action:@selector(changeSpeed) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_changeSpeedBtn];
        [self.changeSpeedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.right.equalTo(_bottomView.mas_right).offset(-10);
        }];
        
        _canvas = [[CanvasView_update alloc] init];
        _canvas.delegate = self;
        [_canvas initializeWithScrollView:self.scrollView andSuperView:self];
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[self->_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
        videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
        if(videoId){
            NSNumber *videoModelState = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
            if([videoModelState isEqual:@1]){
                [self.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame1"] forState:UIControlStateNormal];
            }else if ([videoModelState isEqual:@2]){
                [self.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame2"] forState:UIControlStateNormal];
            }else if ([videoModelState isEqual:@3]){
                [self.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame3"] forState:UIControlStateNormal];
            }
        }
        
        NSString *frameStateSavePath = [filePath stringByAppendingPathComponent:@"frameState"];
        frameStateArray = [NSMutableArray arrayWithContentsOfFile:frameStateSavePath];
        if(!frameStateArray){
            frameStateArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < 13; i++) {
                [frameStateArray addObject:@-1];
            }
        }
        
        NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
        frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        
        if (!(existed && isDir)) {
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            NSLog(@"创建目录");
        }
        else {
            NSLog(@"没有创建目录");
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:@"sceneWillResignActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFrameSelectionResult) name:[NSString stringWithFormat:@"keyFramesPredictForVideo%@", videoId] object:nil];
        [self initializeView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeFront) name:@"changeVideoFront" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyFramesPredictFailed) name:[NSString stringWithFormat:@"keyFramesPredictFailed%@", videoId] object:nil];
        
        lastState = -1;
        speed = 0.13;
        indexSpeed = 1;
    }
    return self;
}

- (void)keyFramesPredictFailed {
    // Key frame prediction failed, please try to select manually
    [hud hideAnimated:YES];
    MBProgressHUD *failHud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    failHud.mode = MBProgressHUDModeText;
    failHud.detailsLabel.text = @"Key frame prediction failed, please try to select manually.";
    failHud.userInteractionEnabled= NO;
    [failHud hideAnimated:YES afterDelay:3.0f];
    [progressTimer invalidate];
    progressTimer = nil;
}

- (void)changeFront {
    [[CoreDataManager sharedManager] changeFrontForVideo:_video];
}

- (void)hasChangeFront {
    _isFront = !_isFront;
    [_frameCollectionView reloadData];
}

- (void)updateFrame {
    [self showFrameAtIndex:self.slider.value];
}

- (void)showSwingPath {
    // TODO
}

- (void)autoChooseFrame {
    [progressTimer invalidate];
    progressTimer = nil;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *videoModelState = [def objectForKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
   
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[self->_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    if (videoId) {
        if([videoModelState isEqual:@1]){
            
            [def setObject:@2 forKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
            NSLog(@"videoId%@",videoId);
            [def synchronize];
            videoModelState = [def objectForKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
            CGPoint offset = self.scrollView.contentOffset;
            //CGFloat scale = self.scrollView.zoomScale;
            CGFloat x, y, w, h;
            x = offset.x / self.scrollView.contentSize.width;
            y = offset.y / self.scrollView.contentSize.height;
            w = self.tmpView.frame.size.width / self.scrollView.contentSize.width;
            h = (float)720 / 4 * 5 / 1280 * w;
            [self.delegate autoSelectedWithX:x andY:y andW:w andH:h];
            [self.delegate videoModeChange:videoModelState];
            return;
        }else if ([videoModelState isEqual:@2]){
            return;
        }else if ([videoModelState isEqual:@3]){
            [self.delegate videoModeChange:@3];
            return;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFrameSelectionResult) name:[NSString stringWithFormat:@"keyFramesPredictForVideo%@", self->videoId] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyFramesPredictFailed) name:[NSString stringWithFormat:@"keyFramesPredictFailed%@", self->videoId] object:nil];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate downLoadFramesIdxWithVideoId:self->videoId isFromInit:NO];
        self->progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(queryProgress) userInfo:nil repeats:YES];
        return;
    }
    
    // 上传视频
    hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Video uploading...";
    hud.userInteractionEnabled= NO;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://219.238.233.6:37577/progolf/upload" parameters:@{@"type" : @0} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileURL:self.videoURL name:@"file" error:nil];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->hud.progress = uploadProgress.fractionCompleted;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"123\r\n%@", responseObject);
                if ([responseObject[@"status"] isEqual:@"success"]) {
//                    [self->hud hideAnimated:YES];
//                    if (self.superview.window) { // 正显示在屏幕上
//                        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//                        hud.mode = MBProgressHUDModeText;
//                        [self.superview addSubview:hud];
//                        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                                make.width.mas_offset(150);
//                                make.height.mas_equalTo(80);
//                                make.center.equalTo(self.superview);
//                        }];
//                        [hud showAnimated:YES];
//                        hud.detailsLabel.text = @"Video upload succeeded, extracting key frames...\r\nPlease wait...";
//                        [hud hideAnimated:YES afterDelay:3];
//                    }
                    self->videoId = responseObject[@"data"][@"videoId"];
                    self->progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(queryProgress) userInfo:nil repeats:YES];
                    
                    if ([NSKeyedArchiver archiveRootObject:self->videoId toFile:videoIdSavePath]) {
                        NSLog(@"写入成功");
                    }
                    else {
                        NSLog(@"写入失败");
                    }
                    
                    [self predictKeyFrames];
                }
                else {
                    [self->hud hideAnimated:YES];
                    if (self.superview.window) { // 正显示在屏幕上
                        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                        hud.mode = MBProgressHUDModeText;
                        [self.superview addSubview:hud];
                        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.width.mas_offset(150);
                                make.height.mas_equalTo(80);
                                make.center.equalTo(self.superview);
                        }];
                        [hud showAnimated:YES];
                        hud.detailsLabel.text = @"Video upload failed.\r\nPlease try again.";
                        [hud hideAnimated:YES afterDelay:3];
                    }
                }
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            NSLog(@"%@", self.videoURL);
            [self->hud hideAnimated:YES];
            if (error.code == -1002 || error.code == -1003 || error.code == -1004) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.superview addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.superview);
                }];
                [hud showAnimated:YES];
                hud.detailsLabel.text = @"Upload failed, please check the server connection.";
                [hud hideAnimated:YES afterDelay:3];
            }
            else if (error.code == -1009) {
                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                hud.mode = MBProgressHUDModeText;
                [self.superview addSubview:hud];
                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.mas_offset(150);
                        make.height.mas_equalTo(80);
                        make.center.equalTo(self.superview);
                }];
                [hud showAnimated:YES];
                hud.detailsLabel.text = @"Upload failed, please check the network connection.";
                [hud hideAnimated:YES afterDelay:3];
            }
        }
    ];
}

- (void)queryProgress {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://219.238.233.6:37577/progolf/key_frames_progress" parameters:@{@"video_id" : videoId} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"status"] isEqual:@"success"]) {
            
            if (!self->hud) {
                self->hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                self->hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                self->hud.userInteractionEnabled= NO;
            }
            
            NSInteger status = [responseObject[@"data"][@"state"] integerValue];
            CGFloat progress = [responseObject[@"data"][@"percent"] floatValue];
            switch (status) {
                case 1:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(1/6)Video framing in progress";
                    self->lastState = status;
                    break;
                case 2:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(2/6)Getting bounding box";
                    self->lastState = status;
                    break;
                case 3:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(3/6)Getting key point information";
                    self->lastState = status;
                    break;
                case 4:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(4/6)Video optical flow processing";
                    self->lastState = status;
                    break;
                case 5:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(5/6)Extracting key frames";
                    self->lastState = status;
                    break;
                case 6:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(6/6)Fusion key frame in progress";
                    self->lastState = status;
                    break;
                case -1:
                    if (self->lastState != -1) {
                        self->hud.progress = 1;
                        self->hud.label.text = @"(6/6)Fusion key frame in progress";
                        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                        [appDelegate downLoadFramesIdxWithVideoId:self->videoId isFromInit:NO];
                        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                        [def setObject:@1 forKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
                        [def synchronize];
                        [self.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame1"] forState:UIControlStateNormal];
                    }
//                    [self->hud hideAnimated:YES];
                    break;

                default:
                    break;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)predictKeyFrames {
    // 预测13帧
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    [manager POST:@"http://219.238.233.6:37577/progolf/predict" parameters:@{@"video_id" : videoId, @"deviceToken" : deviceToken} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"111\r\n%@", responseObject);
            if ([responseObject[@"status"] isEqual:@"success"]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFrameSelectionResult) name:[NSString stringWithFormat:@"keyFramesPredictForVideo%@", self->videoId] object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyFramesPredictFailed) name:[NSString stringWithFormat:@"keyFramesPredictFailed%@", self->videoId] object:nil];
            }
            else {
                [self->hud hideAnimated:YES];
                if (self.superview.window) { // 正显示在屏幕上
                    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
                    hud.mode = MBProgressHUDModeText;
                    [self.superview addSubview:hud];
                    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_offset(150);
                            make.height.mas_equalTo(80);
                            make.center.equalTo(self.superview);
                    }];
                    [hud showAnimated:YES];
                    hud.detailsLabel.text = @"Video upload failed.\r\nPlease try again.";
                    [hud hideAnimated:YES afterDelay:3];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求失败111");
            [progressTimer invalidate];
            progressTimer = nil;
        }];
    NSLog(@"请求预测");
}

- (void)popNavigation {
    [self saveCurrentState];
    [self.delegate popNavigationVC];
    [self.delegate saveCurrentState];
    [progressTimer invalidate];
    progressTimer = nil;
}

- (void)willResignActive {
    [self saveCurrentState];
    [self.delegate saveCurrentState];
}

- (void)willDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [progressTimer invalidate];
    progressTimer = nil;
}

- (void)initializeView {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *scrollSavePath = [filePath stringByAppendingPathComponent:@"scrollData"];
    NSData *scrollData = [NSData dataWithContentsOfFile:scrollSavePath];
    if (scrollData) {
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:scrollData options:NSJSONReadingMutableContainers error:nil];
        _scrollView.zoomScale = [[resultDic valueForKey:@"zoomScale"] floatValue];
        _scrollView.contentOffset = CGPointMake([[resultDic valueForKey:@"offsetX"] floatValue] * _scrollView.contentSize.width,
                                                [[resultDic valueForKey:@"offsetY"] floatValue] * _scrollView.contentSize.height);
        islocked = [[resultDic valueForKey:@"islocked"] boolValue];
        if (islocked) {
            self.lockBtn.selected = NO;
        }
        else {
            self.lockBtn.selected = YES;
            formworkImgView = [[UIImageView alloc] init];
            [formworkImgView setImage:[UIImage imageNamed:@"formwork"]];
            [self.tmpView addSubview:formworkImgView];
            [formworkImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.bottom.left.right.equalTo(self.tmpView);
            }];
        }
    }
    else {
        _scrollView.zoomScale = 1.0;
        _scrollView.contentOffset = CGPointMake(0, (self.frame.size.width / 720 * 1280 - self.frame.size.width / 4 * 5) / 2);
        islocked = YES;
        self.lockBtn.selected = NO;
    }
    
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"toolsData"];
    NSMutableArray *tmpToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
    if (tmpToolsArray) {
        self.toolArray = tmpToolsArray;
        [self drawCanvas];
    }
    
    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    
    if (videoId) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate downLoadFramesIdxWithVideoId:videoId isFromInit:YES];
    }
}

- (void)displayFrameSelectionResult {
    NSLog(@"videoId:%@", videoId);
    // 先拿着videoId去userdefaults里面找到framelist
    frameList = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", videoId]];
    NSLog(@"frameList:%@", frameList);
    if (!frameList) {
        return;
    }
    // 再显示
//    _pre13Btn.userInteractionEnabled=YES;
//    _pre13Btn.alpha=1.0;
//    _next13Btn.userInteractionEnabled=YES;
//    _next13Btn.alpha=1.0;
//    [self.slider makeConstrainsForKeyFrameSlider:frameList withFrameNum:self.frameNum];
    [hud hideAnimated:YES];
    [progressTimer invalidate];
    progressTimer = nil;
}

- (void)initLockState {
    if (islocked) {
        [self.scrollView.panGestureRecognizer setEnabled:NO];
        [self.scrollView.pinchGestureRecognizer setEnabled:NO];
        self.lockBtn.selected = NO;
    }
    else {
        [self.scrollView.panGestureRecognizer setEnabled:YES];
        [self.scrollView.pinchGestureRecognizer setEnabled:YES];
        self.lockBtn.selected = YES;
    }
}

- (void)drawCanvas {
    for (Tool *tool in self.toolArray) {
        [self.canvas drawCanvasWithTool:tool];
    }
}

- (void)saveCurrentState {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    
    NSNumber *zoom = [NSNumber numberWithFloat:self.scrollView.zoomScale * self.frame.size.width / 4 * 5 / self.tmpView.frame.size.height];
    
    CGFloat offsetX = self.scrollView.contentOffset.x / self.scrollView.contentSize.width;
    CGFloat offsetY = self.scrollView.contentOffset.y / self.scrollView.contentSize.height;
    
    NSMutableDictionary *saveDic = [[NSMutableDictionary alloc] init];
    [saveDic setValue:zoom forKey:@"zoomScale"];
    [saveDic setValue:[NSNumber numberWithFloat:offsetX] forKey:@"offsetX"];
    [saveDic setValue:[NSNumber numberWithFloat:offsetY] forKey:@"offsetY"];
    [saveDic setValue:[NSNumber numberWithBool:islocked] forKey:@"islocked"];
    
    NSData *saveData = [NSJSONSerialization dataWithJSONObject:saveDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *scrollSavePath = [filePath stringByAppendingPathComponent:@"scrollData"];
    if ([saveData writeToFile:scrollSavePath atomically:YES]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"toolsData"];
    if ([NSKeyedArchiver archiveRootObject:self.toolArray toFile:toolsSavePath]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    for (Tool *tool in self.toolArray) {
        [tool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    for (Tool *tool in self.toolArray) {
        [tool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)lockOrUnlock {
    islocked = !islocked;
    self.lockBtn.selected = !self.lockBtn.selected;
    if (islocked) {
        [self.scrollView.panGestureRecognizer setEnabled:NO];
        [self.scrollView.pinchGestureRecognizer setEnabled:NO];
//        [formworkImgView removeFromSuperview];
//        formworkImgView = nil;
    }
    else {
        [self.scrollView.panGestureRecognizer setEnabled:YES];
        [self.scrollView.pinchGestureRecognizer setEnabled:YES];
        [self.canvas deselectCurrentTool];
//        formworkImgView = [[UIImageView alloc] init];
//        [formworkImgView setImage:[UIImage imageNamed:@"formwork"]];
//        [self.tmpView addSubview:formworkImgView];
//        [formworkImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.top.bottom.left.right.equalTo(self.tmpView);
//        }];
    }
}

- (void)selectFrame:(UILongPressGestureRecognizer *)recognizer {
    
    if (!islocked) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!tmpImgView) {
            CGPoint offset = self.scrollView.contentOffset;
            //CGFloat scale = self.scrollView.zoomScale;
            CGFloat x, y, w, h;
            x = offset.x / self.scrollView.contentSize.width;
            y = offset.y / self.scrollView.contentSize.height;
            w = self.tmpView.frame.size.width / self.scrollView.contentSize.width;
            h = (float)720 / 4 * 5 / 1280 * w;
            tmpImgView = [[UIImageView alloc] init];
            tmpImgView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(_currentFrame.CGImage, CGRectMake(_currentFrame.size.width * x, _currentFrame.size.height * y, _currentFrame.size.width * w, _currentFrame.size.height * h))];
            CGPoint point = [recognizer locationInView:self];
            tmpImgView.frame = CGRectMake(0, 0, 244, 305);
            tmpImgView.center = point;
            [self.superview addSubview:tmpImgView];
            [self.delegate beginSelect];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self];
        tmpImgView.frame = CGRectMake(0, 0, 244, 305);
        tmpImgView.center = point;
        [self.delegate choosingFrame:point];
        
    }
    else {
        CGPoint point = [recognizer locationInView:self];
        [self.delegate finishSelect:tmpImgView.image andframeindex:_frameIndex andPoint:point];
        [tmpImgView removeFromSuperview];
        tmpImgView = nil;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgView;
}

- (void)panGestureRecognize:(UIPanGestureRecognizer *)gestureRecognizer {
    if (topViewHiddenFlag) {
        return;
    }
    CGPoint offset = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.canvas deselectCurrentTool];
        originTmpH = self.tmpView.frame.size.height;
        originMiniZoomScale = self.scrollView.minimumZoomScale;
        originH = self.frame.size.height;
        originZoomScale = self.scrollView.zoomScale;
        _scrollView.minimumZoomScale = 0;
        originOffset = self.scrollView.contentOffset;
        [self.delegate panBegan];
        [self.canvas disableBtns];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat tmpViewW = (originTmpH + offset.y) / 5 * 4;
        CGFloat tmpViewH = originTmpH + offset.y;
        if (tmpViewH < 60) {
            self.backgroundColor = [UIColor clearColor];
            topViewHiddenFlag = true;
            subViewHiddenFlagArray = [[NSMutableArray alloc] init];
            for (UIView *tmpView in self.subviews) {
                if (tmpView != self.topView) {
                    if (tmpView.isHidden) {
                        [subViewHiddenFlagArray addObject:@1];
                    }
                    else {
                        [subViewHiddenFlagArray addObject:@0];
                    }
                    [tmpView setHidden:YES];
                }
            }
            [self.delegate panChangedWithOffset:-(originH - 30)];
            [self.topView addGestureRecognizer:panTopViewGestureRecognizer];
            
            topDragView = [[UIImageView alloc] init];
            [topDragView setImage:[UIImage imageNamed:@"topDragView"]];
            [self.topView addSubview:topDragView];
            [topDragView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.topView);
                make.height.equalTo(self.topView).multipliedBy(0.5);
                make.width.equalTo(self.topView).multipliedBy(0.06);
            }];
            [self.canvas enableBtns];
            
            return;
        }
        if (tmpViewH > self.frame.size.width / 4 * 5 || tmpViewH > [UIScreen mainScreen].bounds.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height - 30 - 80) {
            return ;
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, originH + offset.y);
        self.tmpView.frame = CGRectMake((self.frame.size.width - tmpViewW) / 2, self.tmpView.frame.origin.y, tmpViewW, tmpViewH);
        _scrollView.contentSize = CGSizeMake(tmpViewW, tmpViewW / 720 * 1280);
        _scrollView.frame = _tmpView.bounds;
        [self.scrollView setZoomScale:originZoomScale * tmpViewH / originTmpH animated:NO];
        self.scrollView.contentOffset = CGPointMake(originOffset.x * tmpViewH / originTmpH, originOffset.y * tmpViewH / originTmpH);
        [self.delegate panChangedWithOffset:offset.y];
    }
    else {
        _scrollView.minimumZoomScale = originMiniZoomScale * self.tmpView.frame.size.height / originTmpH;
        [self.canvas enableBtns];
    }
}

- (void)panTopViewGestureRecognize:(UIPanGestureRecognizer *)recognizer {
    if (!topViewHiddenFlag) {
        return;
    }
    if ([recognizer translationInView:self.topView].y > 100) {
        self.backgroundColor = [UIColor blackColor];
        topViewHiddenFlag = false;
        int idx = 0;
        for (UIView *tmpView in self.subviews) {
            if (tmpView != self.topView) {
                if ([subViewHiddenFlagArray[idx] intValue]) {
                    [tmpView setHidden:YES];
                }
                else {
                    [tmpView setHidden:NO];
                }
                idx++;
            }
        }
        [self.delegate panBegan];
        [self.delegate panChangedWithOffset:self.frame.size.height - 30];
        [self.topView removeGestureRecognizer:panTopViewGestureRecognizer];
        [topDragView removeFromSuperview];
        topDragView = nil;
    }
}

- (void)scrollZoomByRate:(CGFloat)rate {
    CGFloat originMiniZoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.minimumZoomScale = 0;
    CGPoint originOffset = self.scrollView.contentOffset;
    CGFloat originZoomScale = self.scrollView.zoomScale;
    CGFloat tmpViewW = self.tmpView.frame.size.width * rate;
    CGFloat tmpViewH = self.tmpView.frame.size.height * rate;
    self.tmpView.frame = CGRectMake((self.frame.size.width - tmpViewW) / 2, self.tmpView.frame.origin.y, tmpViewW, tmpViewH);
    _scrollView.contentSize = CGSizeMake(tmpViewW, tmpViewW / 720 * 1280);
    _scrollView.frame = _tmpView.bounds;
    [self.scrollView setZoomScale:originZoomScale * rate animated:NO];
    self.scrollView.contentOffset = CGPointMake(originOffset.x * rate, originOffset.y * rate);
    self.scrollView.minimumZoomScale = originMiniZoomScale * rate;
}

- (UIImage *)convertTo720:(UIImage *)image {
    UIGraphicsBeginImageContext(CGSizeMake(720, 1280));
    CGFloat convertHeight = 720 * image.size.height / image.size.width;
    [[UIImage imageNamed:@"black"] drawInRect:CGRectMake(0, 0, 720, 1280)];
    [image drawInRect:CGRectMake(0, (1280 - convertHeight) / 2, 720, convertHeight)];// 先把第一张图片 画到上下文中
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();// 从当前上下文中获得最终图片
    UIGraphicsEndImageContext();// 关闭上下文
    return resultImg;
}

- (void)getFrameNum {
    // 得到帧数
    NSString *path = NSTemporaryDirectory();
    NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[_videoURL lastPathComponent] stringByDeletingPathExtension]]];
    NSString *tmpString = [[_videoURL absoluteString] substringFromIndex:7];
    NSFileManager *fileManager = [NSFileManager defaultManager];
       
    BOOL isDir = NO;
       
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:destinationPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
       
       // 在 tmp 目录下创建一个 二级 目录
       [fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
        cv::VideoCapture capture((char *)[tmpString UTF8String]);
        totalFrameNum = capture.get(cv::CAP_PROP_FRAME_COUNT);
        int imgIndex = 0;
        __block BOOL firstTime = YES;
        if (!capture.isOpened())
        {
            return;
        }
        //dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t serialQueue = dispatch_queue_create("MatchItUpQueue", DISPATCH_QUEUE_SERIAL);
        while (true) {
            @autoreleasepool {
                cv::Mat frame;
                capture >> frame;
                if (frame.empty()) {
                    frame.release();
                    break;
                }
                dispatch_sync(serialQueue, ^{
                    cvtColor(frame, frame, cv::COLOR_BGR2RGB);
                    UIImage *img = MatToUIImage(frame);
                    
                    img = [self convertTo720:img];
                    
                    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);

                    NSString *filePath = [destinationPath stringByAppendingPathComponent:
                                          [NSString stringWithFormat:@"%04d.jpg", imgIndex]];  // 保存文件的名称
                   
                    if([imageData writeToFile:filePath atomically:NO]){
//                        NSLog(@"%@",filePath);
                    }
                    if (imgIndex % 20 == 0 && imgIndex) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.slider.maximumValue = imgIndex - 1;
                            self.frameNum = imgIndex;
                            [self.delegate hideHud];
                            [self.frameCollectionView reloadData];
                            [self.frameCollectionView layoutIfNeeded];
                            if (firstTime) {
                                firstTime = NO;
                                [self showFrameAtIndex:0];
                            }else {
                                [self selectCurrentFrame];
                            }
                        });
                    }
                });
                imgIndex++;
                frame.release();
            }
        }
        self.frameNum = imgIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.slider.maximumValue = self->_frameNum - 1;
            [self.frameCollectionView reloadData];
            [self.frameCollectionView layoutIfNeeded];
            [self selectCurrentFrame];
            if (videoId) {
                [self displayFrameSelectionResult];
            }
        });
        capture.release();
    }else{
        cv::VideoCapture capture((char *)[tmpString UTF8String]);
        totalFrameNum = capture.get(cv::CAP_PROP_FRAME_COUNT);
        int imgIndex = 0;
        __block BOOL firstTime = YES;
        if (!capture.isOpened())
        {
            return;
        }
        //dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t serialQueue = dispatch_queue_create("MatchItUpQueue", DISPATCH_QUEUE_SERIAL);
        while (true) {
            @autoreleasepool {
                cv::Mat frame;
                capture >> frame;
                if (frame.empty()) {
                    frame.release();
                    break;
                }
                dispatch_sync(serialQueue, ^{
                    cvtColor(frame, frame, cv::COLOR_BGR2RGB);
                    UIImage *img = MatToUIImage(frame);
                    
                    img = [self convertTo720:img];
                    
                    NSData *imageData = UIImageJPEGRepresentation(img, 1);

                    NSString *filePath = [destinationPath stringByAppendingPathComponent:
                                          [NSString stringWithFormat:@"%04d.jpg", imgIndex]];  // 保存文件的名称
                   
                    if([imageData writeToFile:filePath atomically:NO]){
//                        NSLog(@"%@",filePath);
                    }
                    if (imgIndex % 20 == 0 && imgIndex) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.slider.maximumValue = imgIndex - 1;
                            self.frameNum = imgIndex;
                            [self.delegate hideHud];
                            [self.frameCollectionView reloadData];
                            [self.frameCollectionView layoutIfNeeded];
                            if (firstTime) {
                                firstTime = NO;
                                [self showFrameAtIndex:0];
                            }else {
                                [self selectCurrentFrame];
                            }
                        });
                    }
                });
                imgIndex++;
                frame.release();
            }
        }
        self.frameNum = imgIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.slider.maximumValue = self->_frameNum - 1;
            [self.frameCollectionView reloadData];
            [self.frameCollectionView layoutIfNeeded];
            [self selectCurrentFrame];
            if (videoId) {
                [self displayFrameSelectionResult];
            }
        });
        capture.release();
    }
    
}

- (UIImage *)getFrameWithFrameIndex:(int)frameIndex {
    UIImage *img;
    img = [self.cache objectForKey:@(frameIndex)];
    if (!img) {
        img = [self getFrameFromFile:frameIndex];
    }
    [self.cache setObject:img forKey:@(frameIndex) cost:1];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = frameIndex - 20; i <= frameIndex + 20; i++) {
            if (i >= 0 && i <= self->_frameNum - 1) {
                if (![self.cache objectForKey:@(i)]) {
                    [self.cache setObject:[self getFrameFromFile:i] forKey:@(i)];
                }
            }
        }
    });
    return img;
}

- (UIImage *)getFrameFromFile:(int)frameIndex {
    NSString *path = NSTemporaryDirectory();
    NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[_videoURL lastPathComponent] stringByDeletingPathExtension]]];
    NSString *filePath = [destinationPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%04d.jpg", frameIndex]];
    
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}

- (void)showFrameAtIndex:(int)index {
    UIImage *tmpImg = [self getFrameWithFrameIndex:index];
    self.currentFrame = tmpImg;
    [self.imgView setImage:_currentFrame];
    
    int preFrameIndex = _frameIndex;
    _frameIndex = index;
    _slider.value = index;
//
//    [self.frameCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:preFrameIndex inSection:0], nil]];
//
//    NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:index inSection:0];
//    [self.frameCollectionView scrollToItemAtIndexPath:tmpPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
//    [self.frameCollectionView layoutIfNeeded];
//    [self.frameCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_frameIndex inSection:0], nil]];
    
}

- (void)selectCurrentFrame {
//    NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:_frameIndex inSection:0];
//    UICollectionViewCell *cell = [_frameCollectionView cellForItemAtIndexPath:tmpPath];
//    self.currentSelectedCell = cell;
//    [self.frameCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_frameIndex inSection:0], nil]];
}

// 拖动 slider
- (void)sliderValueChanged:(UISlider *)slider {
    //self.frameIndex = (int)slider.value;
    
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    UIImage *image = [UIImage imageNamed:@"sliderThumb"];
    UIGraphicsBeginImageContext(CGSizeMake(40, 60));
    [image drawInRect:CGRectMake(20 * self.slider.value / self.slider.maximumValue,20,20,20)];
    CGRect rect = CGRectMake(0, 0, 40, 10);
    [[UIColor whiteColor] set];
    if (self.slider.value / totalFrameNum * totalSeconds < 10) {
        [[NSString stringWithFormat:@"  %.1fs", self.slider.value / totalFrameNum * totalSeconds] drawInRect:CGRectIntegral(rect) withFont:font];
    }
    else {
        [[NSString stringWithFormat:@"%.1fs", self.slider.value / totalFrameNum * totalSeconds] drawInRect:CGRectIntegral(rect) withFont:font];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.slider setThumbImage:newImage forState:UIControlStateNormal];
    
    [self showFrameAtIndex:(int)slider.value];
    
    CGFloat x = self.slider.value / self.slider.maximumValue * (self.slider.frame.size.width - 20) + 10;
    x -= 10;
    sliderThumbImg.frame = CGRectMake(x, 11, 20, 20);
}
- (void)previous13Frame {
    if (!_isPlaying) {
        indexOf13Frame=0;
        while (indexOf13Frame<13&&[frameList[indexOf13Frame] intValue]<self.frameIndex) {
            indexOf13Frame++;
        }
        if (indexOf13Frame>0) {
            [self showFrameAtIndex:[frameList[indexOf13Frame-1] intValue]];
            self.slider.value = [frameList[indexOf13Frame-1] intValue];
        }
    }
}

- (void)previousFrame {
    if (!_isPlaying) {
        if (_frameIndex) {
            [self showFrameAtIndex:self.frameIndex - 1];
            self.slider.value = _frameIndex;
        }
    }
}

- (void)nextFrame {
    if (!_isPlaying) {
        if (_frameIndex + 1 != _frameNum) {
            [self showFrameAtIndex:self.frameIndex + 1];
            self.slider.value = _frameIndex;
        }
    }
}

- (void)next13Frame {
    if (!_isPlaying) {
        indexOf13Frame=12;
        while (indexOf13Frame>-1&&[frameList[indexOf13Frame] intValue]>self.frameIndex) {
            indexOf13Frame--;
        }
        if (indexOf13Frame<12) {
            [self showFrameAtIndex:[frameList[indexOf13Frame+1] intValue]];
            self.slider.value =[frameList[indexOf13Frame+1] intValue];
        }
    }
}

- (void)autoNextFrame {
    if (_frameIndex + 1 != _frameNum) {
        [self showFrameAtIndex:self.frameIndex + 1];
        self.slider.value = _frameIndex;
    }
    else {
        [self pause];
    }
}

- (void)playOrPause {
    if (_isPlaying) {
        [self pause];
    }
    else {
        [self play];
    }
}

- (void)play {
    // 开启定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(autoNextFrame) userInfo:nil repeats:YES];
    self.isPlaying = true;
    self.playOrPauseBtn.selected = YES;
}

- (void)pause {
    // 销毁定时器
    [self.timer invalidate];
    self.timer = nil;
    self.isPlaying = false;
    self.playOrPauseBtn.selected = NO;
}

- (void)changeSpeed{
    if(indexSpeed == 1){
        speed = 0.07;
        indexSpeed = 2;
        [self.changeSpeedBtn setImage:[UIImage imageNamed:@"0.5x"] forState:UIControlStateNormal];
    }else if(indexSpeed == 2){
        indexSpeed = 3;
        speed = 0.03;
        [self.changeSpeedBtn setImage:[UIImage imageNamed:@"1x"] forState:UIControlStateNormal];
    }else if (indexSpeed == 3){
        indexSpeed = 1;
        speed = 0.13;
        [self.changeSpeedBtn setImage:[UIImage imageNamed:@"0.25x"] forState:UIControlStateNormal];
    }
    if(self.timer){
        [self pause];
        [self play];
    }
}

- (void)removeVideo {
    UIView *tmpView;
    tmpView = [[UIView alloc] init];
    tmpView.backgroundColor = [UIColor colorWithRed:0.382 green:0.039 blue:0.039 alpha:1];
    [self addSubview:tmpView];
    [tmpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.tmpView);
            make.left.right.equalTo(self);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(self.mas_width).multipliedBy(0.2);
    }];
    confirmBtn = [[UIButton alloc] init];
    [confirmBtn addTarget:self action:@selector(confirmRemoveVideo) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setImage:[UIImage imageNamed:@"yes"] forState:UIControlStateNormal];
    [tmpView addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tmpView);
        make.centerX.equalTo(tmpView).multipliedBy(0.5);
        make.width.height.mas_equalTo(tmpView.mas_height).multipliedBy(0.3);
    }];
    
    UIImageView *tmpImageView = [[UIImageView alloc] init];
    [tmpImageView setImage:[UIImage imageNamed:@"delete"]];
    [tmpView addSubview:tmpImageView];
    [tmpImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tmpView);
        make.centerX.equalTo(tmpView);
        make.width.height.mas_equalTo(tmpView.mas_height).multipliedBy(0.3);
    }];
    
    cancelBtn = [[UIButton alloc] init];
    [cancelBtn addTarget:self action:@selector(cancelRemoveVideo) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"no"] forState:UIControlStateNormal];
    [tmpView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tmpView);
        make.centerX.equalTo(tmpView).multipliedBy(1.5);
        make.width.height.mas_equalTo(tmpView.mas_height).multipliedBy(0.3);
    }];
}

- (void)confirmRemoveVideo {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *framesKeySavePath = [filePath stringByAppendingPathComponent:@"framesKeyData"];
    NSNumber *framesKey = [NSKeyedUnarchiver unarchiveObjectWithFile:framesKeySavePath];
    [CoreDataManager.sharedManager deleteVideo:_asset.video];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[_asset.videoURL absoluteString]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@", videoId]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString
    stringWithFormat:@"videoModelState%@",videoId]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@", framesKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // other
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:nil]) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败");
    }
    
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"markInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]]) {
            [dic removeObjectForKey:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        }
        [self removeMarkInfo];
        [dic writeToFile:filepath atomically:YES];
    }
    
    filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]]) {
            [dic removeObjectForKey:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        }
        [self removeStarInfo];
        [dic writeToFile:filepath atomically:YES];
    }
    
    [self.delegate popNavigationVC];
}

- (void)removeMarkInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"markInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (void)removeStarInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (void)cancelRemoveVideo {
    [confirmBtn.superview removeFromSuperview];
    confirmBtn = nil;
    cancelBtn = nil;
}

- (void)shareButtonDidTouched{
    [self.delegate shareButtonDidTouched];
}

#pragma mark -collectionview 数据源方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 13;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    
    if([frameStateArray[indexPath.row] isEqual:@1]){
        [cell setFrameImg:[UIImage imageWithData:frameIndexArray[indexPath.row]] withRate:0];
    }else{
        if(_isFront){
            UIImage *cellImg = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
            [cell setFrameImg:cellImg withRate:0];
        }else{
            UIImage *cellImg = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
            [cell setFrameImg:cellImg withRate:0];
        }
        
    }
    
    cell.index = (int)indexPath.row+1;
    UIView *tmpView = [[UIView alloc] initWithFrame:cell.frame];
    tmpView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = tmpView;
    if((int)indexPath.row==0){
        [cell setSelected:YES];
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    for(FrameCollectionViewCell *indexcell in _frameCollectionView.visibleCells){
        if(indexcell==cell){
            [indexcell setSelected:YES];
            indexcell.backgroundColor = [UIColor redColor];
        }else{
            [indexcell setSelected:NO];
            indexcell.backgroundColor = [UIColor blackColor];
        }
    }
//    _currentFrameOf13 = indexPath.row;
    [self showFrameAtIndex:[frameList[indexPath.row] intValue]];
    [self.delegate scrollToFrame:(int) indexPath.row];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.slider) {
        UIFont *font = [UIFont boldSystemFontOfSize:15];
        UIImage *image = [UIImage imageNamed:@"sliderThumb"];
        UIGraphicsBeginImageContext(CGSizeMake(40, 60));
        [image drawInRect:CGRectMake(20 * self.slider.value / self.slider.maximumValue,20,20,20)];
        CGRect rect = CGRectMake(0, 0, 40, 10);
        [[UIColor whiteColor] set];
        if (self.slider.value / totalFrameNum * totalSeconds < 10) {
            [[NSString stringWithFormat:@"  %.1fs", self.slider.value / totalFrameNum * totalSeconds] drawInRect:CGRectIntegral(rect) withFont:font];
        }
        else {
            [[NSString stringWithFormat:@"%.1fs", self.slider.value / totalFrameNum * totalSeconds] drawInRect:CGRectIntegral(rect) withFont:font];
        }
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.slider setThumbImage:newImage forState:UIControlStateNormal];
        
        CGFloat x = self.slider.value / self.slider.maximumValue * (self.slider.frame.size.width - 20) + 10;
        x -= 10;
        sliderThumbImg.frame = CGRectMake(x, 11, 20, 20);
    }
}

- (void)enableSelectFrame {
    [longPress setEnabled:YES];
}

- (void)disableSelectFrame {
    [longPress setEnabled:NO];
}

@end
