//
//  ComposedView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/29.
//

#import "ComposedView.h"
#import "Tool.h"
#import "CanvasView_update.h"
#import <Masonry/Masonry.h>
#import "scoreTool.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "scoreCanvasView.h"
#import "MyScoreViewBtn.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import <SSZipArchive/SSZipArchive.h>
#import "myUILabel.h"
#import "CoreDataManager.h"
#import <AVKit/AVKit.h>

@interface ComposedView ()<CanvasViewDelegate, scoreCanvasDelegate>

@property (nonatomic, strong) NSMutableArray *canvasToolArray;
@property (nonatomic, strong) CanvasView_update *canvas;
@property (nonatomic, strong) scoreCanvasView *scoreCanvas;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) Video *video;
//pip 画中画
@property (nonatomic, strong) AVPictureInPictureController *pipVC;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation ComposedView {
    UIScrollView *scrollView;
    UIImageView *bottomView;
    BOOL isFront;
    UIImageView *composedImageView;
    CGFloat scrollViewOriginH;
    UIButton *starBtn;
    UIView *scoreView;
    UIButton *markBtn;
    UIButton *scoreBtn;
    UITextView *markTextView;
    CGFloat bottomViewH;
    CGFloat markTextHeight;
    CGFloat offset;
    BOOL hasChangeHeight;
    BOOL islocked;
    NSMutableArray *scoreTools;
    CGFloat scoreViewHeight;
    UIImageView *swingImgView;
    UIButton *stepOneBtn;
    UIButton *stepTwoBtn;
    UIButton *stepThreeBtn;
    UIButton *closeScoreBtn;
    UIImageView *scoreImgView;
    UILabel *scoreLabel;
    UILabel *timeLabel;
    UILabel *analyzerLabel;
    NSMutableArray *adjustScoreTools;
    NSMutableArray *displayScoreTools;
    MyScoreViewBtn *postureBtn, *planeBtn;
    UIButton *redB, *yellowB, *greenB, *blackB, *blueB;
    CGFloat postureAndPlaneBtnHeight;
    CALayer *tmpLayer;
    MBProgressHUD *hud;
    NSNumber *framesKey;
    NSNumber *videoId;
    myUILabel *autoDrawWaitLabel;
    NSTimer *autoDrawLineProgressTimer;
//    MBProgressHUD *autoDrawLineProgressHUD;
    NSInteger lastState;
    UITapGestureRecognizer *changeFrontGes;
    BOOL isScoring;
}

- (void)toolArrayAddObj:(Tool *)newTool {
    [self.canvasToolArray addObject:newTool];
}

- (void)deleteAllTools {
    for (Tool *tmpTool in self.canvasToolArray) {
        [tmpTool.toolLayer removeFromSuperlayer];
        [tmpTool.toolPath removeAllPoints];
        [tmpTool.angleLabel removeFromSuperview];
    }
    [self.canvasToolArray removeAllObjects];
}

- (void)toolArrayRemoveObj:(Tool *)tool {
    [self.canvasToolArray removeObject:tool];
}

- (BOOL)viewIsLocked {
    return islocked;
}

- (CGFloat)computeDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    p1 = CGPointMake(p1.x * scrollView.contentSize.width, p1.y * scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * scrollView.contentSize.width, p2.y * scrollView.contentSize.height);
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
    p1 = CGPointMake(p1.x * scrollView.contentSize.width, p1.y * scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * scrollView.contentSize.width, p2.y * scrollView.contentSize.height);
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
    for (Tool *tool in self.canvasToolArray) {
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

- (void)mas_makeConstraintsFor:(UIButton *)pencilBtn and:(UIButton *)eraseBtn and:(UIButton *)deleteAllBtn and:(UIButton *)lineBtn and:(UIButton *)redBtn and:(UIButton *)rectBtn and:(UIButton *)yellowBtn and:(UIButton *)angleBtn and:(UIButton *)greenBtn and:(UIButton *)circleBtn and:(UIButton *)blueBtn and:(UIButton *)curveBtn and:(UIButton *)blackBtn {
    redB = redBtn;
    greenB = greenBtn;
    blackB = blackBtn;
    yellowB = yellowBtn;
    blueB = blueBtn;
    
    [pencilBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.centerX.equalTo(bottomView).multipliedBy(0.4);
    }];
    
    [eraseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(pencilBtn.mas_right).offset(5);
    }];

    [deleteAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.right.equalTo(eraseBtn);
    }];

    [lineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(eraseBtn.mas_right).offset(5);
    }];

    [redBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.centerX.equalTo(lineBtn);
    }];

    [rectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(lineBtn.mas_right).offset(5);
    }];

    [yellowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.centerX.equalTo(rectBtn);
    }];

    [angleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(rectBtn.mas_right).offset(5);
    }];

    [greenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.centerX.equalTo(angleBtn);
    }];

    [circleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(angleBtn.mas_right).offset(5);
    }];

    [blueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.centerX.equalTo(circleBtn);
    }];

    [curveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(bottomView);
        make.left.mas_equalTo(circleBtn.mas_right).offset(5);
    }];

    [blackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(bottomView.mas_top);
        make.centerX.equalTo(curveBtn);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    redB.layer.cornerRadius = redB.frame.size.width / 2;
    greenB.layer.cornerRadius = redB.frame.size.width / 2;
    blackB.layer.cornerRadius = redB.frame.size.width / 2;
    yellowB.layer.cornerRadius = redB.frame.size.width / 2;
    blueB.layer.cornerRadius = redB.frame.size.width / 2;
}

- (void)startDraw {
    islocked = true;
    [scrollView.panGestureRecognizer setEnabled:NO];
    [scrollView.pinchGestureRecognizer setEnabled:NO];
    [markBtn setHidden:YES];
    [starBtn setHidden:YES];
    [scoreBtn setHidden:YES];
}

- (void)endDraw {
    islocked = false;
    [scrollView.panGestureRecognizer setEnabled:YES];
    [scrollView.pinchGestureRecognizer setEnabled:YES];
    [markBtn setHidden:NO];
    [starBtn setHidden:NO];
    [scoreBtn setHidden:NO];
}

- (instancetype)initWithFrame:(CGRect)frame andisFront:(BOOL)isFrontParam andVideoURL:(NSURL *)videoURL andVideo:(nonnull Video *)video
{
    self = [super initWithFrame:frame];
    if (self) {
        self.canvasToolArray = [[NSMutableArray alloc] init];
        islocked = false;
        scrollViewOriginH = (self.frame.size.width - 10) / 4 * 3;
        isFront = isFrontParam;
        scrollView = [[UIScrollView alloc] init];
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = self.frame.size.width / ((self.frame.size.width - 10) / 5);
        scrollView.bouncesZoom = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        _frameViewArray = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 13; i++) {
            UIImageView *tmpView;
            if (isFront) {
                tmpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", i]]];
            }
            else {
                tmpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", i]]];
            }
            if (i == 5 || i == 9) {
                UIImageView *tmpView1;
                if (isFront) {
                    tmpView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", i]]];
                }
                else {
                    tmpView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", i]]];
                }
                [_frameViewArray addObject:tmpView1];
                [scrollView addSubview:tmpView1];
            }
            [_frameViewArray addObject:tmpView];
            [scrollView addSubview:tmpView];
        }
        [self addSubview:scrollView];
        scrollView.delegate = self;
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width, ((self.frame.size.width - 10) / 4) * 3);
        scrollView.contentSize = CGSizeMake(self.frame.size.width, ((self.frame.size.width - 10) / 4) * 3);
        
        UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, NO, 0.0);
        for (int i = 0; i < 15; i++) {
            CGFloat width = ((self.frame.size.width - 10) / 5);
            CGFloat height = ((self.frame.size.width - 10) / 4);
            CGFloat x, y;
            if (i % 5 == 0) {
                x = 0;
            }
            else {
                x = 10 + (i % 5) * width;
            }
            y = i / 5 * height;
            [((UIImageView *)_frameViewArray[i]).image drawInRect:CGRectMake(x, y, width, height)];
            ((UIImageView *)_frameViewArray[i]).frame = CGRectMake(x, y, width, height);
            [((UIImageView *)_frameViewArray[i]) setHidden:YES];
            [((UIImageView *)_frameViewArray[i]) addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        }
        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获得最终图片
        UIGraphicsEndImageContext();//关闭上下文
        composedImageView = [[UIImageView alloc] initWithImage:resultImg];
        composedImageView.frame = scrollView.bounds;
        [scrollView addSubview:composedImageView];
        
        changeFrontGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFront)];
        [changeFrontGes setNumberOfTapsRequired:2];
        [scrollView addGestureRecognizer:changeFrontGes];
        
        markTextView = [[UITextView alloc] init];
        [markTextView setHidden:YES];
        markTextView.backgroundColor = [UIColor whiteColor];
        markTextView.returnKeyType = UIReturnKeyDone;
        markTextView.delegate = self;
        [markTextView setFont:[UIFont fontWithName:@"Helvetica"size:15]];
        [self addSubview:markTextView];
        
        bottomView = [[UIImageView alloc] init];
        [bottomView setImage:[UIImage imageNamed:@"bottomView"]];
//        bottomView.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor redColor];
        bottomView.userInteractionEnabled = YES;
        bottomViewH = 50;
        bottomView.frame = CGRectMake(0, ((self.frame.size.width - 10) / 4) * 3, self.frame.size.width, bottomViewH);
        [self addSubview:bottomView];
        
        starBtn = [[UIButton alloc] init];
        starBtn.frame = CGRectMake(0, 0, 40, 40);
        [starBtn setCenter:CGPointMake(bottomView.frame.size.width / 6 * 3, 25)];
        [starBtn setImage:[UIImage imageNamed:@"unStar"] forState:UIControlStateNormal];
        [starBtn setImage:[UIImage imageNamed:@"star"] forState:UIControlStateSelected];
        [starBtn addTarget:self action:@selector(starBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:starBtn];
        
        markBtn = [[UIButton alloc] init];
        markBtn.frame = CGRectMake(0, 0, 40, 40);
        [markBtn setCenter:CGPointMake(bottomView.frame.size.width / 6 * 2, 25)];
        [markBtn setImage:[UIImage imageNamed:@"mark"] forState:UIControlStateNormal];
        [markBtn addTarget:self action:@selector(markBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:markBtn];
        
        scoreBtn = [[UIButton alloc] init];
        scoreBtn.frame = CGRectMake(0, 0, 40, 40);
        [scoreBtn setCenter:CGPointMake(bottomView.frame.size.width / 6 * 4, 25)];
        [scoreBtn setImage:[UIImage imageNamed:@"analyzer"] forState:UIControlStateNormal];
        [scoreBtn addTarget:self action:@selector(scoreBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:scoreBtn];
        
        _playButton=[[UIButton alloc] init];
        _playButton.frame= CGRectMake(0, 0, 40, 40);
        [_playButton setCenter:CGPointMake(bottomView.frame.size.width / 6 * 5, 25)];
        [_playButton setImage:[UIImage imageNamed:@"swingPath"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(openOrClose)
              forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:_playButton];
        _playButton.userInteractionEnabled=NO;
        _playButton.alpha=0.4;
        
        _canvas = [[CanvasView_update alloc] init];
        _canvas.delegate = self;
        [_canvas initializeWithScrollView:scrollView andSuperView:self];
        
        _videoURL = videoURL;
        _video = video;
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"composedToolsData"];
        NSMutableArray *tmpToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
        if (tmpToolsArray) {
            self.canvasToolArray = tmpToolsArray;
            [self drawCanvas];
        }
        NSString *videoSavePath = [filePath stringByAppendingPathComponent:@"out_up.mp4"];
        if([[NSFileManager defaultManager] fileExistsAtPath:videoSavePath]){
            [self playVideoPIP];
        }
        NSString *framesKeySavePath = [filePath stringByAppendingPathComponent:@"framesKeyData"];
        framesKey = [NSKeyedUnarchiver unarchiveObjectWithFile:framesKeySavePath];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeFront) name:@"changeVideoFront" object:nil];
        
        //注册通知,监听键盘弹出事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
           name:UIKeyboardWillShowNotification object:nil];

        //注册通知,监听键盘消失事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:)
           name:UIKeyboardWillHideNotification object:nil];
        
        lastState = -1;
        isScoring = false;
    }
    return self;
}

- (void)linesPredictFailed {
    [hud hideAnimated:YES];
    MBProgressHUD *failHud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    failHud.mode = MBProgressHUDModeText;
    failHud.detailsLabel.text = @"Lines prediction failed, please try to draw manually.";
    failHud.userInteractionEnabled= NO;
    [failHud hideAnimated:YES afterDelay:3.0f];
    [autoDrawLineProgressTimer invalidate];
    autoDrawLineProgressTimer = nil;
    [self closeScoreBtnTapped];
    [self removeAutoDrawLabel];
}

- (void)changeFront {
    [[CoreDataManager sharedManager] changeFrontForVideo:_video];
}

- (void)hasChangeFront {
    isFront = !isFront;
    
    for (int i = 1; i <= 15; i++) {
        int index;
        if (i >= 1 && i <= 5) {
            index = i;
        }
        else if (i >= 6 && i <= 10) {
            index = i - 1;
        }
        else {
            index = i - 2;
        }
        if (isFront) {
            [self.frameViewArray[i - 1] setImage:[UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", index]]];
        }
        else {
            [self.frameViewArray[i - 1] setImage:[UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", index]]];
        }
    }
}

- (void)drawCanvas {
    for (Tool *tool in self.canvasToolArray) {
        [self.canvas drawCanvasWithTool:tool];
    }
}

- (void)setVideoName:(NSString *)videoName {
    _videoName = [videoName copy];
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    if (dic[_videoName] != nil) {
        starBtn.selected = [dic[_videoName] boolValue];
    }
    
    filepath = [docPath stringByAppendingPathComponent:@"markInfo.plist"];
    dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    if (dic[_videoName] != nil) {
        markTextView.text = [dic[_videoName] mutableCopy];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, NO, 0.0);
    for (int i = 0; i < 15; i++) {
        CGFloat width = ((self.frame.size.width - 10) / 5);
        CGFloat height = ((self.frame.size.width - 10) / 4);
        CGFloat x, y;
        if (i % 5 == 0) {
            x = 0;
        }
        else {
            x = 10 + (i % 5) * width;
        }
        y = i / 5 * height;
        [((UIImageView *)_frameViewArray[i]).image drawInRect:CGRectMake(x, y, width, height)];
    }
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获得最终图片
    UIGraphicsEndImageContext();//关闭上下文
    composedImageView.image = resultImg;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return composedImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    for (Tool *tool in self.canvasToolArray) {
        [tool updateWithContentSize:scrollView.contentSize];
    }
    
    if (stepOneBtn.isSelected) {
        for (scoreTool *tool in scoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:(float)_video.videoWidth];
        }
    }
    else if (stepTwoBtn.isSelected) {
        for (scoreTool *tool in adjustScoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:(float)_video.videoWidth];
        }
    }
    else {
        for (scoreTool *tool in displayScoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:(float)_video.videoWidth];
        }
    }
}

// 视图已经放大或缩小
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height < self.frame.size.width / 4 * 5) {
        scrollView.frame = CGRectMake(scrollView.frame.origin.x
                                      , scrollView.frame.origin.y
                                      , scrollView.frame.size.width
                                      , scrollView.contentSize.height);
        if (markTextView.isHidden) {
            if (scoreView) {
                self.frame = CGRectMake(self.frame.origin.x
                                        , self.frame.origin.y
                                        , self.frame.size.width
                                        , scrollView.contentSize.height + bottomViewH + scoreViewHeight);
            }
            else {
                self.frame = CGRectMake(self.frame.origin.x
                                        , self.frame.origin.y
                                        , self.frame.size.width
                                        , scrollView.contentSize.height + bottomViewH);
            }
            bottomView.frame = CGRectMake(bottomView.frame.origin.x
                                          , scrollView.frame.origin.y + scrollView.frame.size.height
                                          , bottomView.frame.size.width
                                          , bottomView.frame.size.height);
        }
        else {
            if (scoreView) {
                self.frame = CGRectMake(self.frame.origin.x
                                        , self.frame.origin.y
                                        , self.frame.size.width
                                        , scrollView.contentSize.height + bottomViewH + markTextHeight + scoreViewHeight);
            }
            else {
                self.frame = CGRectMake(self.frame.origin.x
                                        , self.frame.origin.y
                                        , self.frame.size.width
                                        , scrollView.contentSize.height + bottomViewH + markTextHeight);
            }
            markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                       scrollView.frame.origin.y + scrollView.frame.size.height,
                                       markTextView.frame.size.width,
                                       markTextView.frame.size.height);
            
            bottomView.frame = CGRectMake(bottomView.frame.origin.x
                                          , markTextView.frame.origin.y + markTextView.frame.size.height
                                          , bottomView.frame.size.width
                                          , bottomView.frame.size.height);
        }
    }
    for (Tool *tool in self.canvasToolArray) {
        [tool updateWithContentSize:scrollView.contentSize];
    }
    if (stepOneBtn.isSelected) {
        for (scoreTool *tool in scoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:_video.videoWidth];
        }
    }
    else if (stepTwoBtn.isSelected) {
        for (scoreTool *tool in adjustScoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:_video.videoWidth];
        }
    }
    else {
        for (scoreTool *tool in displayScoreTools) {
            [tool updateWithContentSize:scrollView.contentSize andvideoH:_video.videoHeight andvideoW:_video.videoWidth];
        }
    }
}

- (void)restoreSize {
    CGFloat scrollViewHeightTmp = scrollView.frame.size.height;
    scrollView.zoomScale = 1.0;
    scrollView.frame = CGRectMake(scrollView.frame.origin.x
                                  , scrollView.frame.origin.y
                                  , scrollView.frame.size.width
                                  , scrollViewOriginH);
    if (markTextView.isHidden) {
        self.frame = CGRectMake(self.frame.origin.x
                                , self.frame.origin.y
                                , self.frame.size.width
                                , self.frame.size.height - scrollViewHeightTmp + scrollViewOriginH);
        bottomView.frame = CGRectMake(bottomView.frame.origin.x
                                      , scrollView.frame.origin.y + scrollView.frame.size.height
                                      , bottomView.frame.size.width
                                      , bottomView.frame.size.height);
    }
    else {
        markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                   scrollView.frame.origin.y + scrollView.frame.size.height,
                                   markTextView.frame.size.width,
                                   markTextView.frame.size.height);
        self.frame = CGRectMake(self.frame.origin.x
                                , self.frame.origin.y
                                , self.frame.size.width
                                , self.frame.size.height - scrollViewHeightTmp + scrollViewOriginH);
        bottomView.frame = CGRectMake(bottomView.frame.origin.x
                                      , markTextView.frame.origin.y + markTextView.frame.size.height
                                      , bottomView.frame.size.width
                                      , bottomView.frame.size.height);
    }
}

- (void)starBtnTapped {
    starBtn.selected = !starBtn.selected;
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            dic[_videoName] = [NSNumber numberWithBool:starBtn.selected];
        }
        else {
            [dic setObject:[NSNumber numberWithBool:starBtn.selected] forKey:_videoName];
        }
    }
    else {
        dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithBool:starBtn.selected] forKey:_videoName];
    }
    [self removeStarInfo];
    [dic writeToFile:filepath atomically:YES];
}

- (void)removeStarInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (void)removeScoreInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"scoreInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (void)removeTimeInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"timeInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (void)markBtnTapped {
    markBtn.selected = !markBtn.selected;
    markTextHeight = 80;
    if (markBtn.selected) {
        [markTextView setHidden:NO];
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height + markTextHeight);
        markTextView.frame = CGRectMake(0, scrollView.frame.origin.y + scrollView.frame.size.height, self.frame.size.width, markTextHeight);
        bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                      bottomView.frame.origin.y + markTextHeight,
                                      bottomView.frame.size.width,
                                      bottomView.frame.size.height);
    }
    else {
        [markTextView setHidden:YES];
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height - markTextHeight);
        [markTextView setHidden:YES];
        bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                      bottomView.frame.origin.y - markTextHeight,
                                      bottomView.frame.size.width,
                                      bottomView.frame.size.height);
    }
}

- (void)scoreBtnTapped {
    if (isScoring) {
        [stepOneBtn setHidden:NO];
        [stepTwoBtn setHidden:NO];
        [stepThreeBtn setHidden:NO];
        [stepOneBtn setEnabled:YES];
        [stepTwoBtn setEnabled:YES];
        [stepThreeBtn setEnabled:NO];
        [stepOneBtn setSelected:YES];
        [stepTwoBtn setSelected:NO];
        [stepThreeBtn setSelected:NO];
        
        if (postureBtn && planeBtn) {
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.frame.size.width,
                                    self.frame.size.height - postureAndPlaneBtnHeight);
            scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                          scrollView.frame.origin.y - postureAndPlaneBtnHeight,
                                          scrollView.frame.size.width,
                                          scrollView.frame.size.height);
            if (!markTextView.hidden) {
                markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                                markTextView.frame.origin.y - postureAndPlaneBtnHeight,
                                                markTextView.frame.size.width,
                                                markTextView.frame.size.height);
            }
            bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                          bottomView.frame.origin.y - postureAndPlaneBtnHeight,
                                          bottomView.frame.size.width,
                                          bottomView.frame.size.height);
        }
        
        [tmpLayer removeFromSuperlayer];
        tmpLayer = nil;
        [postureBtn removeFromSuperview];
        [planeBtn removeFromSuperview];
        postureBtn = nil;
        planeBtn = nil;
        [timeLabel removeFromSuperview];
        timeLabel = nil;
        [scoreImgView removeFromSuperview];
        scoreImgView = nil;
        [scoreLabel removeFromSuperview];
        scoreLabel = nil;
        
        [scoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.toolLayer removeFromSuperlayer];
        }];
        [adjustScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.toolLayer removeFromSuperlayer];
        }];
        [displayScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj.toolLayer removeFromSuperlayer];
        }];
        [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[UIImageView class]]) {
                [obj removeFromSuperview];
            }
        }];
        [self showScoreTools];
        
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *savePath = [filePath stringByAppendingPathComponent:@"scoreBtnData"];
        if ([NSKeyedArchiver archiveRootObject:@1 toFile:savePath]) {
            NSLog(@"写入成功");
        }
        else {
            NSLog(@"写入失败");
        }
    }
    else {
        isScoring = true;
        [scoreBtn setImage:[UIImage imageNamed:@"loop"] forState:UIControlStateNormal];
        if (![self.delegate hasCompleteFrameSelect]) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] init];
            hud.mode = MBProgressHUDModeText;
            [self addSubview:hud];
            [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_offset(150);
                    make.height.mas_equalTo(80);
                    make.center.equalTo(self);
            }];
            [hud showAnimated:YES];
            hud.label.text = @"Please complete the frame selection first";
            [hud hideAnimated:YES afterDelay:1];
            return;
        }
        
        [scrollView removeGestureRecognizer:changeFrontGes];
        
        // 如果scoreToolsData文件夹为空，才弹出提示框
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"scoreToolsData"];
        NSMutableArray *tmpScoreToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
        if (tmpScoreToolsArray) {
            [self layoutViewsForDrawLines];
            scoreTools = tmpScoreToolsArray;
            NSString *savePath = [filePath stringByAppendingPathComponent:@"scoreBtnData"];
            NSNumber *btnNumber = [NSKeyedUnarchiver unarchiveObjectWithFile:savePath];
            if ([btnNumber isEqual:@1] || !btnNumber) {
                [self showScoreTools];
            }
            else if ([btnNumber isEqual:@2]) {
                [self stepTwoBtnTapped];
            }
            else {
                [self stepThreeBtnTapped];
            }
        }
        else {
            // 尝试下载zip文件
            if (framesKey) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayAutoDrawLinesResult) name:[NSString stringWithFormat:@"LinesPredictForFrames%@", framesKey] object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linesPredictFailed) name:[NSString stringWithFormat:@"LinesPredictFailed%@", framesKey] object:nil];
                NSLog(@"接收通知%@", [NSString stringWithFormat:@"LinesPredictForFrames%@", framesKey]);
                [self layoutViewsForDrawLines];
                [self displayAutoDrawLabel];
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate downLoadZIPDataWithFramesKey:framesKey andFront:isFront];
                
                self->autoDrawLineProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(queryProgress) userInfo:nil repeats:YES];
            }
            else {
                [self chooseWhichWayToDrawLines];
            }
        }
    }
}

- (void)displayAutoDrawLabel {
    autoDrawWaitLabel = [[myUILabel alloc] initWithFrame:scrollView.frame];
    autoDrawWaitLabel.text = @"Auto draw line in progress, please wait...";
    autoDrawWaitLabel.font = [UIFont systemFontOfSize:30];
    autoDrawWaitLabel.backgroundColor = [UIColor grayColor];
    autoDrawWaitLabel.alpha = 0.7;
    autoDrawWaitLabel.numberOfLines = 0;
    [self addSubview:autoDrawWaitLabel];
    [autoDrawWaitLabel setVerticalAlignment:VerticalAlignmentBottom];
    [scrollView setUserInteractionEnabled:NO];
}

- (void)queryProgress {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://219.238.233.6:37577/progolf/auto_draw_line_progress" parameters:@{@"key" : framesKey} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
                    self->hud.label.text = @"(1/5)Image calibration in progress";
                    self->lastState = status;
                    break;
                case 2:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(2/5)Getting bounding box";
                    self->lastState = status;
                    break;
                case 3:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(3/5)Getting key point information";
                    self->lastState = status;
                    break;
                case 4:
                    self->hud.progress = progress;
                    self->hud.label.text = @"(4/5)Getting human contour information";
                    self->lastState = status;
                    break;
                case 5:
                    if(self->lastState!=5){
                        self->hud.progress = progress;
                        self->hud.label.text = @"(4/5)Getting human contour information";
                        self->lastState = status;
                        break;
                    }
                    self->hud.progress = progress;
                    self->hud.label.text = @"(5/5)Getting swing tracer";
                    self->lastState = status;
                    break;
                case -1:
                    if (self->lastState != -1) {
                        self->hud.progress = 1;
                        self->hud.label.text = @"(5/5)Getting swing tracer";
                        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                        if (self->framesKey) {
                            [appDelegate downLoadZIPDataWithFramesKey:self->framesKey andFront:self->isFront];
                        }
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

- (void)removeAutoDrawLabel {
    [hud hideAnimated:YES];
    [autoDrawWaitLabel removeFromSuperview];
    autoDrawWaitLabel = nil;
    [scrollView setUserInteractionEnabled:YES];
    [autoDrawLineProgressTimer invalidate];
    autoDrawLineProgressTimer = nil;
    [hud hideAnimated:YES];
    framesKey = nil;
}

- (void)chooseWhichWayToDrawLines {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose how to draw lines" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Manual line drawing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self layoutViewsForDrawLines];
        [self manualDrawLines];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Automatic line drawing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self layoutViewsForDrawLines];
        [self restoreSize];
        [self displayAutoDrawLabel];
        [self autoDrawLines];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isScoring = false;
        [scoreBtn setImage:[UIImage imageNamed:@"analyzer"] forState:UIControlStateNormal];
        [self->scrollView addGestureRecognizer:changeFrontGes];
        return;
    }]];
    // 弹出对话框
    [self.delegate presentAlertView:alert];
}

- (void)layoutViewsForDrawLines {
    _scoreCanvas = [[scoreCanvasView alloc] init];
    _scoreCanvas.delegate = self;
    [_scoreCanvas initializeWithScrollView:scrollView andSuperView:self];
    [self.delegate disableSelectFrame];
//    [scoreBtn setEnabled:NO];
    scoreViewHeight = 80;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height + scoreViewHeight);
    scoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, scoreViewHeight)];
    scoreView.backgroundColor = [UIColor whiteColor];
    [self addSubview:scoreView];
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y + scoreViewHeight,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
    if (!markTextView.hidden) {
        markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                        markTextView.frame.origin.y + scoreViewHeight,
                                        markTextView.frame.size.width,
                                        markTextView.frame.size.height);
    }
    bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                  bottomView.frame.origin.y + scoreViewHeight,
                                  bottomView.frame.size.width,
                                  bottomView.frame.size.height);
    
    CGFloat aveW = (scoreView.frame.size.width - 7 * 10) / 16;
    CGFloat btnW = fmin(aveW * 3, scoreView.frame.size.height * 0.8);
    CGFloat gap = (scoreView.frame.size.width - btnW * 5 - btnW / 3) / 7;
    swingImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swing"]];
    swingImgView.frame = CGRectMake(0, 0, btnW, btnW);
    analyzerLabel = [[UILabel alloc] init];
    stepOneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, btnW)];
    stepTwoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, btnW)];
    stepThreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, btnW)];
    closeScoreBtn = [[UIButton alloc] init];
    [scoreView addSubview:swingImgView];
    [scoreView addSubview:analyzerLabel];
    [scoreView addSubview:stepOneBtn];
    [scoreView addSubview:stepTwoBtn];
    [scoreView addSubview:stepThreeBtn];
    [scoreView addSubview:closeScoreBtn];
    [swingImgView setCenter:CGPointMake(gap * 1 + 0 * btnW + btnW / 2, scoreView.frame.size.height / 2)];
    analyzerLabel.frame = CGRectMake(gap + btnW, swingImgView.frame.origin.y, btnW + gap, btnW / 2);
    [stepOneBtn setCenter:CGPointMake(gap * 3 + 2 * btnW + btnW / 2, scoreView.frame.size.height / 2)];
    [stepTwoBtn setCenter:CGPointMake(gap * 4 + 3 * btnW + btnW / 2, scoreView.frame.size.height / 2)];
    [stepThreeBtn setCenter:CGPointMake(gap * 5 + 4 * btnW + btnW / 2, scoreView.frame.size.height / 2)];
    closeScoreBtn.frame = CGRectMake(6 * gap + 5 * btnW, swingImgView.frame.origin.y, btnW / 3, btnW / 3);
    analyzerLabel.text = @"13 frames ai Analyzer";
    analyzerLabel.numberOfLines = 2;
    [analyzerLabel setFont:[UIFont systemFontOfSize:11.0]];
    [stepOneBtn setImage:[UIImage imageNamed:@"stepOne"] forState:UIControlStateNormal];
    [stepTwoBtn setImage:[UIImage imageNamed:@"stepTwo"] forState:UIControlStateNormal];
    [stepThreeBtn setImage:[UIImage imageNamed:@"stepThree"] forState:UIControlStateNormal];
    [stepOneBtn setImage:[UIImage imageNamed:@"stepOneSelected"] forState:UIControlStateSelected];
    [stepTwoBtn setImage:[UIImage imageNamed:@"stepTwoSelected"] forState:UIControlStateSelected];
    [closeScoreBtn setImage:[UIImage imageNamed:@"closeScore"] forState:UIControlStateNormal];
    [stepOneBtn setSelected:YES];
    [stepThreeBtn setEnabled:NO];
    [stepTwoBtn addTarget:self action:@selector(stepTwoBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [stepThreeBtn addTarget:self action:@selector(stepThreeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [closeScoreBtn addTarget:self action:@selector(closeScoreBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)manualDrawLines {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    if (!isFront) {
        path = [bundle pathForResource:@"PrincipalLineSide" ofType:@"plist"];
    }
    else {
        path = [bundle pathForResource:@"PrincipalLine" ofType:@"plist"];
    }
    NSMutableArray *scoreToolsTmp = [NSMutableArray arrayWithContentsOfFile:path];
    scoreTools = [[NSMutableArray alloc] init];
    [scoreToolsTmp enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [scoreTools addObject:[scoreTool scoreToolWithDic:obj]];
    }];
    [self showScoreTools];
}

- (void)autoDrawLines {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[self->_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    if(videoId==nil){
        [self uplodVideoWithIdPath:videoIdSavePath];
    }else{
        [self uplod13Pics];
    }
}
- (void)uplodVideoWithIdPath:(NSString*) videoIdSavePath{
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
                    self->videoId = responseObject[@"data"][@"videoId"];
                    
                    if ([NSKeyedArchiver archiveRootObject:self->videoId toFile:videoIdSavePath]) {
                        NSLog(@"写入成功");
                    }
                    else {
                        NSLog(@"写入失败");
                    }
                    [self uplod13Pics];
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
- (void)uplod13Pics {
    // 上传13帧图片
    if (!self->hud) {
        self->hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        self->hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self->hud.userInteractionEnabled= NO;
    }
    self->hud.label.text = @"Frames uploading...";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //13帧图片
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    NSMutableArray *frameDataArray = [NSMutableArray arrayWithContentsOfFile:frameSavePath];
    [frameDataArray removeObjectAtIndex:10];
    [frameDataArray removeObjectAtIndex:5];
    [manager POST:@"http://219.238.233.6:37577/progolf/upload" parameters:@{@"type" : @1} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (int i = 0; i < 13; i++) {
                [formData appendPartWithFileData:frameDataArray[i] name:@"file" fileName:[NSString stringWithFormat:@"%04d.jpg", i] mimeType:@"image/jpeg"];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->hud.progress = uploadProgress.fractionCompleted;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", responseObject);
                if ([responseObject[@"status"] isEqual:@"success"]) {
//                    [self->hud hideAnimated:YES];
//                    autoDrawLineProgressHUD = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
//                    autoDrawLineProgressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
//                    autoDrawLineProgressHUD.userInteractionEnabled= NO;
                    self->autoDrawLineProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(queryProgress) userInfo:nil repeats:YES];
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
//                        hud.detailsLabel.text = @"Key Frames upload succeeded, drawing lines...\r\nPlease wait...";
//                        [hud hideAnimated:YES afterDelay:3];
//                    }
                    
//                    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"waiting" ofType:@"gif"];
//                    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
//                    UIImage *image = [UIImage sd_imageWithGIFData:imageData];
//                    [self.autoChooseFrameBtn setImage:image forState:UIControlStateNormal];
//                    self.autoChooseFrameBtn.enabled = false;
                    
                    self->framesKey = responseObject[@"data"][@"framesKey"];
                    [[NSUserDefaults standardUserDefaults] setObject:[self.videoURL absoluteString] forKey:self->framesKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    // 保存framesKey
                    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[self->_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
                    NSString *framesKeySavePath = [filePath stringByAppendingPathComponent:@"framesKeyData"];
                    if ([NSKeyedArchiver archiveRootObject:self->framesKey toFile:framesKeySavePath]) {
                        NSLog(@"写入成功");
                    }
                    else {
                        NSLog(@"写入失败");
                    }
                    
                    [self preDictLines];
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
                        hud.detailsLabel.text = @"Key frames upload failed.\r\nPlease try again.";
                        [hud hideAnimated:YES afterDelay:3];
                    }
                }

            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
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
- (void)displayAutoDrawLinesResult {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"scoreToolsData"];
    NSMutableArray *tmpScoreToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
    if (tmpScoreToolsArray) {
        // 移除之前的
        [scoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.toolLayer removeFromSuperlayer];
        }];
        [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[UIImageView class]]) {
                [obj removeFromSuperview];
            }
        }];
        
        scoreTools = tmpScoreToolsArray;
        [self showScoreTools];
    }
    NSString *videoSavePath = [filePath stringByAppendingPathComponent:@"out_up.mp4"];
    if([[NSFileManager defaultManager] fileExistsAtPath:videoSavePath]){
        [self playVideoPIP];
    }
    [self removeAutoDrawLabel];
}

- (void)preDictLines {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
    NSNumber *side;
    if (isFront) {
        side = @1;
    }
    else {
        side = @2;
    }
    //13帧序号
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameListSavePath = [filePath stringByAppendingPathComponent:@"frameList"];
    NSMutableArray *frameListArray = [NSMutableArray arrayWithContentsOfFile:frameListSavePath];
    [frameListArray removeObjectAtIndex:10];
    [frameListArray removeObjectAtIndex:5];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:frameListArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    NSLog(@"jsonString  %@",mutStr);
    
    NSLog(@"videoId====%@",videoId);
//    manager.responseSerializer.acceptableContentTypes= [NSSet setWithObjects:@"text/plain",@"application/json", nil];
    if(videoId!=nil){
        [manager POST:@"http://219.238.233.6:37577/progolf/autodrawlineandcurve/withpics" parameters:@{@"frames_key" : framesKey, @"deviceToken" : deviceToken, @"side" : side, @"video_id" : videoId, @"frame_list" : mutStr} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@", responseObject);
            if ([responseObject[@"status"] isEqual:@"success"]) {
    //            [self->hud hideAnimated:YES];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayAutoDrawLinesResult) name:[NSString stringWithFormat:@"LinesPredictForFrames%@", self->framesKey] object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linesPredictFailed) name:[NSString stringWithFormat:@"LinesPredictFailed%@", self->framesKey] object:nil];
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
                    hud.detailsLabel.text = @"Auto draw lines failed.\r\nPlease try again.";
                    [hud hideAnimated:YES afterDelay:3];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
            [self->hud hideAnimated:YES];
            [self linesPredictFailed];
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
        }];
    }
//        else{
//        [manager POST:@"http://219.238.233.6:37577/progolf/autodrawline/withpics" parameters:@{@"frames_key" : framesKey, @"deviceToken" : deviceToken, @"side" : side} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"%@", responseObject);
//            if ([responseObject[@"status"] isEqual:@"success"]) {
//    //            [self->hud hideAnimated:YES];
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayAutoDrawLinesResult) name:[NSString stringWithFormat:@"LinesPredictForFrames%@", self->framesKey] object:nil];
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linesPredictFailed) name:[NSString stringWithFormat:@"LinesPredictFailed%@", self->framesKey] object:nil];
//            }
//            else {
//                [self->hud hideAnimated:YES];
//                if (self.superview.window) { // 正显示在屏幕上
//                    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//                    hud.mode = MBProgressHUDModeText;
//                    [self.superview addSubview:hud];
//                    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                            make.width.mas_offset(150);
//                            make.height.mas_equalTo(80);
//                            make.center.equalTo(self.superview);
//                    }];
//                    [hud showAnimated:YES];
//                    hud.detailsLabel.text = @"Auto draw lines failed.\r\nPlease try again.";
//                    [hud hideAnimated:YES afterDelay:3];
//                }
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"%@", error);
//            [self->hud hideAnimated:YES];
//            [self linesPredictFailed];
//            if (error.code == -1002 || error.code == -1003 || error.code == -1004) {
//                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//                hud.mode = MBProgressHUDModeText;
//                [self.superview addSubview:hud];
//                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                        make.width.mas_offset(150);
//                        make.height.mas_equalTo(80);
//                        make.center.equalTo(self.superview);
//                }];
//                [hud showAnimated:YES];
//                hud.detailsLabel.text = @"Upload failed, please check the server connection.";
//                [hud hideAnimated:YES afterDelay:3];
//            }
//            else if (error.code == -1009) {
//                MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//                hud.mode = MBProgressHUDModeText;
//                [self.superview addSubview:hud];
//                [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                        make.width.mas_offset(150);
//                        make.height.mas_equalTo(80);
//                        make.center.equalTo(self.superview);
//                }];
//                [hud showAnimated:YES];
//                hud.detailsLabel.text = @"Upload failed, please check the network connection.";
//                [hud hideAnimated:YES afterDelay:3];
//            }
//        }];
//    }
}

- (void)showScoreTools {
    for (scoreTool *tool in scoreTools) {
        [_scoreCanvas drawCanvasWithTool:tool andvideoH:_video.videoHeight andvideoW:_video.videoWidth];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)willDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [autoDrawLineProgressTimer invalidate];
    autoDrawLineProgressTimer = nil;
}

-(void)playVideoPIP {
    _playButton.userInteractionEnabled=YES;
    _playButton.alpha=1.0;
//    NSURL *url = [NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[self->_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *videoSavePath = [filePath stringByAppendingPathComponent:@"out_up.mp4"];
    NSLog(@"1212121%@",videoSavePath);
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:videoSavePath]];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(100, 80, 100, 200);
//    [self.player play];
    //1.判断是否支持画中画功能
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
       //2.开启权限
       @try {
           NSError *error = nil;
           [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeMoviePlayback options:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:&error];
           // 为什么注释掉这里？你会发现有时 AVAudioSession 会有开启失败的情况。故用上面的方法
//           [[AVAudioSession sharedInstance] setCategory:AVAudioSessionOrientationBack error:&error];
//           [[AVAudioSession sharedInstance] setActive:YES error:&error];
       } @catch (NSException *exception) {
           NSLog(@"AVAudioSession发生错误");
       }
       self.pipVC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
       self.pipVC.delegate = self;
   }
    [self.layer addSublayer:self.playerLayer];
    [self.playerLayer setHidden:YES];
}
- (void)openOrClose {
    if (self.pipVC.isPictureInPictureActive) {
        [self.pipVC stopPictureInPicture];
    } else {
        [self.pipVC startPictureInPicture];
    }
}
#pragma mark 实现监听到键盘变化时的触发的方法
// 键盘弹出时
-(void)keyboardDidShow:(NSNotification *)notification
{
    if (hasChangeHeight) {
        return;
    }
    hasChangeHeight = true;
    //获取键盘高度
    NSValue *keyboardObject = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardObject getValue:&keyboardRect];
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    offset = (keyboardRect.origin.y - (self.frame.origin.y + markTextView.frame.origin.y + markTextView.frame.size.height));
    [UIView animateWithDuration:duration animations:^{
        [self.delegate changeHeightWithOffset:self->offset];
    }];

}

//键盘消失时
-(void)keyboardDidHidden:(NSNotification *)notification
{
    hasChangeHeight = false;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.delegate changeHeightWithOffset:-self->offset];
    }];
}

- (void)saveCurrentState {
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"markInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            dic[_videoName] = markTextView.text;
        }
        else {
            [dic setObject:markTextView.text forKey:_videoName];
        }
    }
    else {
        dic = [NSMutableDictionary dictionary];
        [dic setObject:markTextView.text forKey:_videoName];
    }
    [self removeMarkInfo];
    [dic writeToFile:filepath atomically:YES];
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"composedToolsData"];
    if ([NSKeyedArchiver archiveRootObject:self.canvasToolArray toFile:toolsSavePath]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
    
    if (scoreTools.count) {
        toolsSavePath = [filePath stringByAppendingPathComponent:@"scoreToolsData"];
        if ([NSKeyedArchiver archiveRootObject:scoreTools toFile:toolsSavePath]) {
            NSLog(@"写入成功");
        }
        else {
            NSLog(@"写入失败");
        }
    }
}

- (void)removeMarkInfo{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"markInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:nil];
}

- (scoreTool *)getHeadPositionTool {
    if (!isFront) {
        return [scoreTools objectAtIndex:4];
    }
    else {
        return [scoreTools objectAtIndex:3];
    }
}

- (scoreTool *)chooseNearestScoreToolWithX:(CGPoint)x0 {
    scoreTool *nearestTool = nil;
    CGFloat minDis = CGFLOAT_MAX;
    NSMutableArray *tmpScoreTools;
    if ([stepOneBtn isSelected]) {
        tmpScoreTools = scoreTools;
    }
    else if ([stepTwoBtn isSelected]) {
        tmpScoreTools = adjustScoreTools;
    }
    else {
        tmpScoreTools = displayScoreTools;
    }
    for (scoreTool *tool in tmpScoreTools) {
        int frameIdx = [tool.frame intValue];
        float aveWidth = (scrollView.contentSize.width - 10) / 5;
        float aveHeight = scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * 10;
        float offsetY = frameIdx / 5 * aveHeight;
        CGPoint point1, point2, point3, point4;
        if ([tool.type isEqual:@"Line"] || [tool.type isEqual:@"LineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"ExternLineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            offset = CGPointMake(offset.x / 3, offset.y / 3);
            point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
            point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"SingleExternLineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            offset = CGPointMake(offset.x, offset.y);
    //        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
            point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"Rect"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
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
        else if ([tool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
        }
        else if ([tool.type isEqual:@"RotateRect"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / scrollView.contentSize.width, point3.y / scrollView.contentSize.height);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:x0 andP1:point3 andP2:point4];
            CGFloat dis4 = [self computeDisWith:x0 andP1:point1 andP2:point4];
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
        else if ([tool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
            point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / scrollView.contentSize.width, point3.y / scrollView.contentSize.height);
            point4 = CGPointMake(point4.x / scrollView.contentSize.width, point4.y / scrollView.contentSize.height);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point4];
            CGFloat dis3 = [self computeDisWith:x0 andP1:point3 andP2:point4];
            CGFloat dis4 = [self computeDisWith:x0 andP1:point1 andP2:point3];
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
        else if ([tool.type isEqual:@"Angle"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / scrollView.contentSize.width, point3.y / scrollView.contentSize.height);
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point4];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point3];
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

- (void)stepTwoBtnTapped {
    if (stepTwoBtn.selected) {
        return;
    }
//    __block BOOL flag = false;
//    [scoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (!obj.hasAdjust) {
//                NSLog(@"%@ %@", obj.frame, obj.name);
//                flag = true;
//                stop = YES;
//            }
//    }];
//    if (flag) {
//        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//        hud.mode = MBProgressHUDModeText;
//        [self addSubview:hud];
//        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_offset(150);
//                make.height.mas_equalTo(80);
//                make.center.equalTo(self);
//        }];
//        [hud showAnimated:YES];
//        hud.label.text = @"Please adjust the canvas first";
//        [hud hideAnimated:YES afterDelay:1];
//         return;
//    }
    [stepOneBtn setEnabled:NO];
    [stepThreeBtn setEnabled:YES];
    [stepTwoBtn setSelected:YES];
    [stepOneBtn setSelected:NO];
    
    [scoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.toolLayer removeFromSuperlayer];
    }];
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    if (!isFront) {
        path = [bundle pathForResource:@"Adjust Line" ofType:@"plist"];
    }
    else {
        path = [bundle pathForResource:@"Adjust Line Front" ofType:@"plist"];
    }
    NSDictionary *adjustScoreToolsDic = [NSDictionary dictionaryWithContentsOfFile:path];
    adjustScoreTools = [[NSMutableArray alloc] init];
    [adjustScoreToolsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *obj, BOOL * _Nonnull stop) {
        int idx = [key intValue];
//        scoreTool *tool = [scoreTools[idx] copy];
//        tool.Rotatable = false;
//        tool.UDMovable = false;
//        tool.LRMovable = false;
//        tool.hasAdjust = true;
//        [adjustScoreTools addObject:tool];
        [obj enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger i, BOOL * _Nonnull stop) {
            scoreTool *tool = [scoreTools[idx] copy];
            tool.frame = obj;
            tool.hasAdjust = false;
            tool.fatherID = @(idx);
            tool.isSubItem = true;
            tool.adjustColor = [UIColor yellowColor];
            if ([tool.name isEqual:@"Head Height"]) {
                tool.Rotatable = false;
                tool.UDMovable = true;
                tool.LRMovable = false;
            }
            else if ([tool.name isEqual:@"Head Position"] || [tool.name isEqual:@"Hip Depth"]) {
                tool.Rotatable = false;
                tool.UDMovable = false;
                tool.LRMovable = true;
            }
            [adjustScoreTools addObject:tool];
            
            scoreTool *toolTemplate = [tool copy];
            toolTemplate.Rotatable = false;
            toolTemplate.UDMovable = false;
            toolTemplate.LRMovable = false;
            toolTemplate.hasAdjust = true;
            toolTemplate.isTemplate = true;
            toolTemplate.isSubItem = false;
            [adjustScoreTools addObject:toolTemplate];
        }];
    }];
    [self showAdjustScoreTools];
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *savePath = [filePath stringByAppendingPathComponent:@"scoreBtnData"];
    if ([NSKeyedArchiver archiveRootObject:@2 toFile:savePath]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
}

- (void)showAdjustScoreTools {
    for (scoreTool *tool in adjustScoreTools) {
        [_scoreCanvas drawCanvasWithTool:tool andvideoH:_video.videoHeight andvideoW:_video.videoHeight];
    }
}

- (NSString *)getScore {
    // TODO
    return @"TODO";
}

- (void)stepThreeBtnTapped {
//    __block BOOL flag = false;
//    [adjustScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (!obj.hasAdjust) {
//                flag = true;
//                stop = YES;
//            }
//    }];
//    if (flag) {
//        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
//        hud.mode = MBProgressHUDModeText;
//        [self addSubview:hud];
//        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_offset(150);
//                make.height.mas_equalTo(80);
//                make.center.equalTo(self);
//        }];
//        [hud showAnimated:YES];
//        hud.label.text = @"Please adjust the canvas first";
//        [hud hideAnimated:YES afterDelay:1];
//        return;
//    }
    [stepOneBtn setHidden:YES];
    [stepTwoBtn setHidden:YES];
    [stepThreeBtn setHidden:YES];
    [stepOneBtn setSelected:NO];
    [stepTwoBtn setSelected:NO];
    
    scoreImgView = [[UIImageView alloc] initWithFrame:stepThreeBtn.frame];
    [scoreImgView setImage:[UIImage imageNamed:@"score"]];
    [scoreView addSubview:scoreImgView];
    scoreLabel = [[UILabel alloc] initWithFrame:stepTwoBtn.frame];
    
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"scoreInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            scoreLabel.text = dic[_videoName];
        }
        else {
            scoreLabel.text = [self getScore];
            [dic setObject:scoreLabel.text forKey:_videoName];
            [self removeScoreInfo];
            [dic writeToFile:filepath atomically:YES];
        }
    }
    else {
        scoreLabel.text = [self getScore];
        dic = [NSMutableDictionary dictionary];
        [dic setObject:scoreLabel.text forKey:_videoName];
        [self removeScoreInfo];
        [dic writeToFile:filepath atomically:YES];
    }
    
    [scoreLabel setFont:[UIFont systemFontOfSize:15]];
    scoreLabel.textColor = [UIColor redColor];
    [scoreView addSubview:scoreLabel];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(analyzerLabel.frame.origin.x,
                                                          stepOneBtn.frame.origin.y + stepOneBtn.frame.size.height - analyzerLabel.frame.size.height,
                                                          analyzerLabel.frame.size.width,
                                                          analyzerLabel.frame.size.height)];
    [scoreView addSubview:timeLabel];
    timeLabel.numberOfLines = 2;
    [timeLabel setFont:[UIFont systemFontOfSize:11.0]];
    filepath = [docPath stringByAppendingPathComponent:@"timeInfo.plist"];
    dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            timeLabel.text = dic[_videoName];
        }
        else {
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
            [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm"];//设定时间格式,这里可以设置成自己需要的格式
            NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
            timeLabel.text = dateString;
            [dic setObject:timeLabel.text forKey:_videoName];
            [self removeTimeInfo];
            [dic writeToFile:filepath atomically:YES];
        }
    }
    else {
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
        [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm"];//设定时间格式,这里可以设置成自己需要的格式
        NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
        timeLabel.text = dateString;
        dic = [NSMutableDictionary dictionary];
        [dic setObject:timeLabel.text forKey:_videoName];
        [self removeTimeInfo];
        [dic writeToFile:filepath atomically:YES];
    }
    
    [adjustScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.toolLayer removeFromSuperlayer];
    }];
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    displayScoreTools = [[NSMutableArray alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    if (isFront) {
        path = [bundle pathForResource:@"PostureOutLine Front" ofType:@"plist"];
    }
    else {
        path = [bundle pathForResource:@"PostureOutLine" ofType:@"plist"];
    }
    NSDictionary *diaplayScoreToolsDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [diaplayScoreToolsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *obj, BOOL * _Nonnull stop) {
        int idx = [key intValue];
        [obj enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger i, BOOL * _Nonnull stop) {
            scoreTool *tool = [scoreTools[idx] copy];
            tool.isForDisplay = true;
            tool.fatherFrame = tool.frame;
            tool.frame = obj;
            [displayScoreTools addObject:tool];
        }];
    }];
    if (isFront) {
        for (scoreTool *adjustTool in adjustScoreTools) {
            if ([adjustTool.type isEqual:@"Quadrilateral"] && adjustTool.isSubItem) {
                scoreTool *tool = [adjustTool copy];
                tool.isForDisplay = true;
                tool.isSubItem = true;
                [displayScoreTools addObject:tool];
            }
        }
    }
    [self showDisplayTools];
    postureAndPlaneBtnHeight = self.frame.size.width * 0.05;
    postureBtn = [[MyScoreViewBtn alloc] initWithFrame:CGRectMake(0, scrollView.frame.origin.y - 10, self.frame.size.width, postureAndPlaneBtnHeight + 10)];
    planeBtn = [[MyScoreViewBtn alloc] initWithFrame:CGRectMake(0, scrollView.frame.origin.y - 10, self.frame.size.width, postureAndPlaneBtnHeight + 10)];
    [postureBtn setImage:[UIImage imageNamed:@"postureOutline"] forState:UIControlStateNormal];
    [planeBtn setImage:[UIImage imageNamed:@"planeOutline"] forState:UIControlStateNormal];
    tmpLayer = [[CALayer alloc] init];
    tmpLayer.backgroundColor = [UIColor whiteColor].CGColor;
    tmpLayer.frame = CGRectMake(0, scrollView.frame.origin.y - 10, self.frame.size.width, postureAndPlaneBtnHeight + 10);
    [self.layer addSublayer:tmpLayer];
    postureBtn.myBtnName = @"postureOutlineBtn";
    planeBtn.myBtnName = @"planeOutlineBtn";
    [self addSubview:planeBtn];
    [self addSubview:postureBtn];
    [postureBtn addTarget:self action:@selector(postureBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [planeBtn addTarget:self action:@selector(planeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height + postureAndPlaneBtnHeight);
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y + postureAndPlaneBtnHeight,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
    if (!markTextView.hidden) {
        markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                        markTextView.frame.origin.y + postureAndPlaneBtnHeight,
                                        markTextView.frame.size.width,
                                        markTextView.frame.size.height);
    }
    bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                  bottomView.frame.origin.y + postureAndPlaneBtnHeight,
                                  bottomView.frame.size.width,
                                  bottomView.frame.size.height);
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *savePath = [filePath stringByAppendingPathComponent:@"scoreBtnData"];
    if ([NSKeyedArchiver archiveRootObject:@3 toFile:savePath]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
}

- (void)postureBtnTapped {
    
    [displayScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.toolLayer removeFromSuperlayer];
    }];
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    [postureBtn removeFromSuperview];
    [self addSubview:postureBtn];
    displayScoreTools = [[NSMutableArray alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"PostureOutLine" ofType:@"plist"];
    NSDictionary *diaplayScoreToolsDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [diaplayScoreToolsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *obj, BOOL * _Nonnull stop) {
        int idx = [key intValue];
        [obj enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger i, BOOL * _Nonnull stop) {
            scoreTool *tool = [scoreTools[idx] copy];
            tool.isForDisplay = true;
            tool.fatherFrame = tool.frame;
            tool.frame = obj;
            [displayScoreTools addObject:tool];
        }];
    }];
    [self showDisplayTools];
}

- (void)planeBtnTapped {
    
    [displayScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.toolLayer removeFromSuperlayer];
    }];
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    [planeBtn removeFromSuperview];
    [self addSubview:planeBtn];
    displayScoreTools = [[NSMutableArray alloc] init];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    if (isFront) {
        path = [bundle pathForResource:@"PlaneOutLine Front" ofType:@"plist"];
    }
    else {
        path = [bundle pathForResource:@"PlaneOutLine" ofType:@"plist"];
    }
    NSDictionary *diaplayScoreToolsDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [diaplayScoreToolsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray *obj, BOOL * _Nonnull stop) {
        int idx = [key intValue];
        [obj enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger i, BOOL * _Nonnull stop) {
            scoreTool *tool = [scoreTools[idx] copy];
            tool.isForDisplay = true;
            tool.fatherFrame = tool.frame;
            tool.frame = obj;
            [displayScoreTools addObject:tool];
        }];
    }];
    [self showDisplayTools];
}

- (void)showDisplayTools {
    for (scoreTool *tool in displayScoreTools) {
        [_scoreCanvas drawCanvasWithTool:tool andvideoH:_video.videoHeight andvideoW:_video.videoWidth];
    }
}

- (void)closeScoreBtnTapped {
    [autoDrawLineProgressTimer invalidate];
    autoDrawLineProgressTimer = nil;
    [scoreBtn setImage:[UIImage imageNamed:@"analyzer"] forState:UIControlStateNormal];
    isScoring = false;
    if (postureBtn && planeBtn) {
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.frame.size.height - postureAndPlaneBtnHeight);
        scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                      scrollView.frame.origin.y - postureAndPlaneBtnHeight,
                                      scrollView.frame.size.width,
                                      scrollView.frame.size.height);
        if (!markTextView.hidden) {
            markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                            markTextView.frame.origin.y - postureAndPlaneBtnHeight,
                                            markTextView.frame.size.width,
                                            markTextView.frame.size.height);
        }
        bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                      bottomView.frame.origin.y - postureAndPlaneBtnHeight,
                                      bottomView.frame.size.width,
                                      bottomView.frame.size.height);
    }
    
    [scrollView addGestureRecognizer:changeFrontGes];
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height - scoreViewHeight);
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y - scoreViewHeight,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
    if (!markTextView.hidden) {
        markTextView.frame = CGRectMake(markTextView.frame.origin.x,
                                        markTextView.frame.origin.y - scoreViewHeight,
                                        markTextView.frame.size.width,
                                        markTextView.frame.size.height);
    }
    bottomView.frame = CGRectMake(bottomView.frame.origin.x,
                                  bottomView.frame.origin.y - scoreViewHeight,
                                  bottomView.frame.size.width,
                                  bottomView.frame.size.height);
    
    [tmpLayer removeFromSuperlayer];
    tmpLayer = nil;
    [postureBtn removeFromSuperview];
    [planeBtn removeFromSuperview];
    postureBtn = nil;
    planeBtn = nil;
    [scoreView removeFromSuperview];
    scoreView = nil;
    
//    [stepOneBtn setEnabled:YES];
//    [stepTwoBtn setEnabled:YES];
//    [stepThreeBtn setEnabled:NO];
//    [stepOneBtn setSelected:YES];
//    [stepTwoBtn setSelected:NO];
//    [scoreImgView removeFromSuperview];
//    [timeLabel removeFromSuperview];
//    [scoreLabel removeFromSuperview];
//    [stepOneBtn setHidden:NO];
//    [stepTwoBtn setHidden:NO];
//    [stepThreeBtn setHidden:NO];
    
    [scoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.toolLayer removeFromSuperlayer];
    }];
    [adjustScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.toolLayer removeFromSuperlayer];
    }];
    [displayScoreTools enumerateObjectsUsingBlock:^(scoreTool *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.toolLayer removeFromSuperlayer];
    }];
    [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }];
    scoreTools = nil;
    [self removeAutoDrawLabel];
    [self.delegate enableSelectFrame];
    
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *path = [bundle pathForResource:@"PrincipalLine" ofType:@"plist"];
//    NSMutableArray *scoreToolsTmp = [NSMutableArray arrayWithContentsOfFile:path];
//    scoreTools = [[NSMutableArray alloc] init];
//    [scoreToolsTmp enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [scoreTools addObject:[scoreTool scoreToolWithDic:obj]];
//    }];
//    [self showScoreTools];
    
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"scoreInfo.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            [dic removeObjectForKey:_videoName];
            [self removeScoreInfo];
            [dic writeToFile:filepath atomically:YES];
        }
    }
    filepath = [docPath stringByAppendingPathComponent:@"timeInfo.plist"];
    dic = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (dic) {
        if (dic[_videoName]) {
            [dic removeObjectForKey:_videoName];
            [self removeTimeInfo];
            [dic writeToFile:filepath atomically:YES];
        }
    }

    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *deletePath = [filePath stringByAppendingPathComponent:@"scoreBtnData"];
    if ([[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil]) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败");
    }
    
    deletePath = [filePath stringByAppendingPathComponent:@"scoreToolsData"];
    if ([[NSFileManager defaultManager] removeItemAtPath:deletePath error:nil]) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败");
    }
    
//    [scoreBtn setEnabled:YES];
    
    framesKey = nil;
    NSString *framesKeySavePath = [filePath stringByAppendingPathComponent:@"framesKeyData"];
    if ([[NSFileManager defaultManager] removeItemAtPath:framesKeySavePath error:nil]) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败");
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
