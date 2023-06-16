//
//  HomeScreenViewController.m
//  切帧App
//
//  Created by 胡跃坤 on 2021/7/19.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "HomeScreenViewController.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import "FrameCollectionViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "FrameNumberView.h"
#import "ShowFramesViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "PoseView.h"
#import "PoseNetMobileNet100S8FP16.h"

@interface HomeScreenViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,FrameNumberDelegate>
{
    UIBezierPath *currentPath;
    CGPoint origin;
    CGSize originImgViewSize;
    CAShapeLayer *currentLayer;
    CGRect cutArea;
    BOOL hasCut;
}

@property (nonatomic, strong) UIImage *currentFrame;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIButton *selectFrameBtn;
@property (nonatomic, strong) UIButton *showSelectedFramesBtn;
@property (nonatomic, strong) UIButton *cropBtn;
@property (nonatomic, strong) UIButton *rotateBtn;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) int frameIndex;
@property (nonatomic, assign) int frameNum;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *frameLabel;
@property (nonatomic, strong) UICollectionView *frameCollectionView;
@property (nonatomic, strong) UICollectionViewCell *currentSelectedCell;
@property (nonatomic, strong) UISlider *slider;
// 保存选择的13帧图片
@property (nonatomic, strong) NSMutableArray *selectedFrames;
@property (nonatomic, strong) FrameNumberView *frameNumberView;
@property (nonatomic, strong) NSMutableArray *selectedFramesIndex;
// pip
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *leftPIPButton;
@property (nonatomic, strong) UIButton *rightPIPButton;
@property (nonatomic, strong) UIButton *pipPlayOrPauseBtn;
// 显示关键点
@property (nonatomic, strong) PoseView *poseView;
@property (nonatomic, strong) PoseNetMobileNet100S8FP16 *model;
@property (nonatomic, strong) UIButton *showPoseViewBtn;
// 裁剪图片
@property (nonatomic, strong) UIPanGestureRecognizer *addRectanglePanGestureRecognizer;

@end

@implementation HomeScreenViewController {
    int rotateAngel;
    int currentSelectIndex;
    CGPoint lastPlayerViewLocation;
    CGRect oldFrame;
    BOOL isPlayEnded;
    NSInteger readyToPlayAnimationNums;
    BOOL isShowPose;
    float imgViewHeight;
}

// 懒加载
- (NSMutableArray *)selectedFrames {
    if (!_selectedFrames) {
        _selectedFrames = [NSMutableArray arrayWithCapacity:13];
        for (int i = 0; i < 13; i++) {
            [_selectedFrames addObject:[[NSObject alloc] init]];
        }
    }
    return _selectedFrames;
}

- (NSMutableArray *)selectedFramesIndex {
    if (!_selectedFramesIndex) {
        _selectedFramesIndex = [NSMutableArray arrayWithCapacity:13];
        for (int i = 0; i < 13; i++) {
            [_selectedFramesIndex addObject:[NSNumber numberWithInteger:-1]];
        }
    }
    return _selectedFramesIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getFrameNum];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutView];
    [self.view layoutIfNeeded];
}

- (void)getSelectedFramesFromNSUserDefaults:(NSArray *) indexArray{
    for (int i = 0; i < 13; i++) {
        NSNumber *tmp = indexArray[i];
        if ([tmp intValue] != -1) {
            self.selectedFrames[i] = [self getFrameWithFrameIndex:[tmp intValue]];
        }
    }
}

- (void)initView {
    [self.view addSubview:self.playerView];
    
    self.blackView = [[UIView alloc] init];
    self.blackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackView];
    
    self.imgView = [[UIImageView alloc] init];
    [self.view addSubview:_imgView];
    self.imgView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imglongTapClick:)];
    [self.imgView addGestureRecognizer:longTap];
    UITapGestureRecognizer *hiddenNumberViewTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapClick)];
    [self.imgView addGestureRecognizer:hiddenNumberViewTap1];
    UITapGestureRecognizer *hiddenNumberViewTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapClick)];
    [self.blackView addGestureRecognizer:hiddenNumberViewTap2];
    
    self.whiteView = [[UIView alloc] init];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_whiteView];
    
    _addRectanglePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addRectangle:)];
    
    isShowPose = false;
    _poseView = [[PoseView alloc] init];
    [self.view addSubview:_poseView];
    _poseView.backgroundColor = [UIColor clearColor];
    _poseView.hidden = YES;
    
    self.preBtn = [[UIButton alloc] init];
    [self.preBtn setImage:[UIImage imageNamed:@"leftFrame"] forState:UIControlStateNormal];
    [self.preBtn addTarget:self action:@selector(previousFrame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_preBtn];
    
    self.playOrPauseBtn = [[UIButton alloc] init];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"playFrame"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"pauseFrame"] forState:UIControlStateSelected];
    [self.playOrPauseBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playOrPauseBtn];
    
    self.nextBtn = [[UIButton alloc] init];
    [self.nextBtn setImage:[UIImage imageNamed:@"rightFrame"] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextFrame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    self.selectFrameBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectFrameBtn.backgroundColor = [UIColor blackColor];
    [self.selectFrameBtn setTitle:@"选为关键帧" forState:UIControlStateNormal];
    [self.selectFrameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectFrameBtn addTarget:self action:@selector(selectFrame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectFrameBtn];
    
    self.showSelectedFramesBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.showSelectedFramesBtn.backgroundColor = [UIColor blackColor];
    [self.showSelectedFramesBtn setTitle:@"查看关键帧" forState:UIControlStateNormal];
    [self.showSelectedFramesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.showSelectedFramesBtn addTarget:self action:@selector(showFrames) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_showSelectedFramesBtn];
    
    self.cropBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cropBtn.backgroundColor = [UIColor blackColor];
    [self.cropBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    [self.cropBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cropBtn addTarget:self action:@selector(cropImages) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cropBtn];
    
    self.rotateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rotateBtn.backgroundColor = [UIColor clearColor];
    [self.rotateBtn setBackgroundImage:[UIImage imageNamed:@"rotateImg"] forState:UIControlStateNormal];
    [self.rotateBtn addTarget:self action:@selector(rotateImg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rotateBtn];
    
    self.showPoseViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showPoseViewBtn setImage:[UIImage imageNamed:@"showPose"] forState:UIControlStateNormal];
    [self.showPoseViewBtn setImage:[UIImage imageNamed:@"unshowPose"] forState:UIControlStateSelected];
    [self.showPoseViewBtn addTarget:self action:@selector(showPose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_showPoseViewBtn];
    
    self.frameLabel = [[UILabel alloc] init];
    self.frameLabel.backgroundColor = [UIColor blackColor];
    self.frameLabel.textColor = [UIColor whiteColor];
    self.frameLabel.textAlignment = NSTextAlignmentCenter;
    self.frameLabel.text = @"0 / 0";
    [self.view addSubview:_frameLabel];
    
    // 创建collectionView的布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 行列间距
    static const float kSpacing = 4;
    layout.minimumLineSpacing = kSpacing;
    // 设置item大小
    static const CGFloat kItemWidth = 60;
    static const CGFloat kItemHeight = 100;
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    // 设置滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 创建 collectionView
    self.frameCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.frameCollectionView.backgroundColor = [UIColor whiteColor];
    self.frameCollectionView.showsHorizontalScrollIndicator = NO;
    self.frameCollectionView.scrollEnabled = YES;
    [self.view addSubview:_frameCollectionView];
    self.frameCollectionView.delegate = self;
    self.frameCollectionView.dataSource = self;
    [self.frameCollectionView registerClass:[FrameCollectionViewCell class] forCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID"];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.slider.minimumValue = 0;
    self.slider.maximumTrackTintColor = [UIColor grayColor];
    [self.view addSubview:_slider];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.frameNumberView = [[FrameNumberView alloc] init];
    [self.view addSubview:_frameNumberView];
    [self.frameNumberView setHidden:YES];
    self.frameNumberView.delegate = self;
    self.frameNumberView.isFront = self.isFront;
    
    self.frameIndex = 0;
    self.isPlaying = false;
    // 将旋转角度存储到NSUserDefaults
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tmpString = [NSString stringWithFormat:@"%@rotateAngel", _videoUrl];
    if ([def valueForKey:tmpString]) {
        NSNumber *tmpNumber = [def valueForKey:tmpString];
        rotateAngel = [tmpNumber intValue];
    }
    
    currentSelectIndex = 1;
    
    // pip
    //获取视频尺寸
    AVURLAsset *asset = [AVURLAsset assetWithURL:_videoUrl];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerView = [[UIView alloc] init];
    _playerView.frame = CGRectMake(self.view.frame.size.width * 2 / 3, self.view.frame.size.height - self.view.frame.size.width / 3 * videoSize.height / videoSize.width - 230, self.view.frame.size.width / 3, self.view.frame.size.width / 3 * videoSize.height / videoSize.width);
    _playerView.userInteractionEnabled = YES;
    _playerView.backgroundColor = [UIColor darkGrayColor];
    [_playerView.layer addSublayer:_playerLayer];
    _playerLayer.frame = _playerView.bounds;
    _playerView.layer.masksToBounds = YES;
    _playerView.layer.cornerRadius = 5;
    _playerView.layer.borderColor = [UIColor whiteColor].CGColor;
    _playerView.layer.borderWidth = 2;
    [self.view addSubview:_playerView];
    [self.playerView setHidden:YES];
    
    _leftPIPButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 68)];
    _rightPIPButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 68)];
    [_leftPIPButton setImage:[UIImage imageNamed:@"leftPIPButton"] forState:UIControlStateNormal];
    [_rightPIPButton setImage:[UIImage imageNamed:@"rightPIPButton"] forState:UIControlStateNormal];
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:_leftPIPButton.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer=[[CAShapeLayer alloc]init];
    maskLayer.frame = _leftPIPButton.bounds;
    maskLayer.path = maskPath.CGPath;
    _leftPIPButton.layer.mask = maskLayer;
    maskPath=[UIBezierPath bezierPathWithRoundedRect:_rightPIPButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    maskLayer=[[CAShapeLayer alloc]init];
    maskLayer.frame = _rightPIPButton.bounds;
    maskLayer.path = maskPath.CGPath;
    _rightPIPButton.layer.mask = maskLayer;
    _leftPIPButton.tag = 1;
    _rightPIPButton.tag = 2;
    _leftPIPButton.hidden = YES;
    _rightPIPButton.hidden = YES;
    [_leftPIPButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [_rightPIPButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [_leftPIPButton addTarget:self action:@selector(showPIP:) forControlEvents:UIControlEventTouchUpInside];
    [_rightPIPButton addTarget:self action:@selector(showPIP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftPIPButton];
    [self.view addSubview:_rightPIPButton];
    
    UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_playerView addGestureRecognizer:panRecognizer1];
    UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_leftPIPButton addGestureRecognizer:panRecognizer2];
    UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_rightPIPButton addGestureRecognizer:panRecognizer3];
    _playerView.tag = 0;
    
    // 缩放手势
    oldFrame = _playerView.frame;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [_playerView addGestureRecognizer:pinchGesture];
    
    // 单击和双击手势
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapView:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [_playerView addGestureRecognizer:singleTapGesture];
    
    _pipPlayOrPauseBtn = [[UIButton alloc] init];
    [_pipPlayOrPauseBtn setImage:[UIImage imageNamed:@"pipPlay"] forState:UIControlStateNormal];
    [_pipPlayOrPauseBtn setImage:[UIImage imageNamed:@"pipPause"] forState:UIControlStateSelected];
    [_pipPlayOrPauseBtn addTarget:self action:@selector(playOrPausePIP) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:_pipPlayOrPauseBtn];
    [_pipPlayOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(34);
            make.centerX.equalTo(_playerView);
            make.bottom.mas_equalTo(_playerView.mas_bottom).offset(-5);
    }];
    
    //添加播放结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    _pipPlayOrPauseBtn.selected = NO;
    [self.player pause];
    isPlayEnded = NO;
    readyToPlayAnimationNums = 0;
    
    readyToPlayAnimationNums++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readyToPlayAnimationNums == 1) {
            [UIView animateWithDuration:0.5f animations:^{
                self->_pipPlayOrPauseBtn.alpha = 0;
            }];
        }
        self->readyToPlayAnimationNums--;
    });
    
    hasCut = NO;
}

- (void)singleTapView:(UITapGestureRecognizer *)tapGesture {
    if (_pipPlayOrPauseBtn.alpha == 1) {
        _pipPlayOrPauseBtn.alpha = 0;
        return;
    }
    _pipPlayOrPauseBtn.alpha = 1;
    readyToPlayAnimationNums++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readyToPlayAnimationNums == 1) {
            [UIView animateWithDuration:0.5f animations:^{
                self->_pipPlayOrPauseBtn.alpha = 0;
            }];
        }
        self->readyToPlayAnimationNums--;
    });
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGesture
{
    
    UIView *view = pinchGesture.view;
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGesture.scale, pinchGesture.scale);
        if (view.frame.size.width <= oldFrame.size.width ) {
            [UIView animateWithDuration:0.5f animations:^{
                            view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            }];
        }
        if (view.frame.size.width > 2 * oldFrame.size.width) {
            [UIView animateWithDuration:0.5f animations:^{
                            view.transform = CGAffineTransformMake(2, 0, 0, 2, 0, 0);
            }];
        }

        pinchGesture.scale = 1;
    }
}

- (void)playFinished {
    _pipPlayOrPauseBtn.selected = NO;
    isPlayEnded = YES;
    _pipPlayOrPauseBtn.alpha = 1;
    readyToPlayAnimationNums++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readyToPlayAnimationNums == 1) {
            [UIView animateWithDuration:0.5f animations:^{
                self->_pipPlayOrPauseBtn.alpha = 0;
            }];
        }
        self->readyToPlayAnimationNums--;
    });
}

- (void)playOrPausePIP {
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [_player pause];
        _pipPlayOrPauseBtn.selected = NO;
    }
    else {
        _pipPlayOrPauseBtn.selected = YES;
        if (isPlayEnded) {
            [self.player seekToTime:CMTimeMake(0, 1)];
        }
        isPlayEnded = NO;
        [_player play];
    }
}

- (void)panView:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        lastPlayerViewLocation = recognizer.view.center;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGFloat tmpX = lastPlayerViewLocation.x + translation.x;
        CGFloat tmpY = lastPlayerViewLocation.y + translation.y;
        if (tmpY - recognizer.view.frame.size.height / 2 <= 45) {
            [UIView animateWithDuration:1.0f animations:^{
                            recognizer.view.center = CGPointMake(recognizer.view.center.x, 45 + recognizer.view.frame.size.height / 2);
            }];
        }
        if (tmpY + recognizer.view.frame.size.height / 2 >= self.view.frame.size.height - 70) {
            [UIView animateWithDuration:1.0f animations:^{
                            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.view.frame.size.height - 70 - recognizer.view.frame.size.height / 2);
            }];
        }
        if (recognizer.view.tag == 0) {
            if (tmpX <= 0) {
                _playerView.hidden = YES;
                _leftPIPButton.hidden = NO;
                _leftPIPButton.center = CGPointMake(_leftPIPButton.frame.size.width / 2, _playerView.center.y);
            }
            if (tmpX >= self.view.frame.size.width) {
                _playerView.hidden = YES;
                _rightPIPButton.hidden = NO;
                _rightPIPButton.center = CGPointMake(self.view.frame.size.width - _leftPIPButton.frame.size.width / 2, _playerView.center.y);
            }
        }
    }
    else {
        CGPoint translation = [recognizer translationInView:self.view];
        CGFloat tmpX = lastPlayerViewLocation.x + translation.x;
        CGFloat tmpY = lastPlayerViewLocation.y + translation.y;
        _playerView.center = CGPointMake(tmpX, tmpY);
        if (recognizer.view.tag == 0) {
            _playerView.center = CGPointMake(tmpX, tmpY);
        }
        else if (recognizer.view.tag == 1) {
            _leftPIPButton.center = CGPointMake(_leftPIPButton.frame.size.width / 2, tmpY);
        }
        else {
            _rightPIPButton.center = CGPointMake(self.view.frame.size.width - _rightPIPButton.frame.size.width / 2, tmpY);
        }
    }
}

- (void)showPIP:(UIButton *)button {
    button.hidden = YES;
    _playerView.hidden = NO;
    if (button.tag == 1) {
        [UIView animateWithDuration:1.0f animations:^{
            self->_playerView.center = CGPointMake(self->_playerView.frame.size.width / 2, button.center.y);
        }];
    }
    else {
        [UIView animateWithDuration:1.0f animations:^{
            self->_playerView.center = CGPointMake(self.view.frame.size.width - self->_playerView.frame.size.width / 2, button.center.y);
        }];
    }
}

- (void)layoutView {
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.height.mas_equalTo(40);
            make.bottom.equalTo(self.view).offset(-30);
    }];
    
    [self.preBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.bottom.equalTo(_playOrPauseBtn);
            make.right.equalTo(_playOrPauseBtn.mas_left).offset(-30);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.bottom.equalTo(_playOrPauseBtn);
            make.left.equalTo(_playOrPauseBtn.mas_right).offset(30);
    }];
    
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(24);
            make.centerY.equalTo(self.nextBtn);
            make.left.equalTo(self.nextBtn.mas_right).offset(30);
    }];
    
    [self.showPoseViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.centerY.equalTo(self.nextBtn);
            make.right.equalTo(self.preBtn.mas_left).offset(-30);
    }];

    [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(45);
            make.bottom.equalTo(_playOrPauseBtn.mas_top);
            make.width.equalTo(self.view);
    }];
    
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_playOrPauseBtn.mas_top);
            make.width.bottom.equalTo(self.view);
    }];
    
    [self.frameCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(_playOrPauseBtn.mas_top);
            make.height.mas_equalTo(100);
    }];
    
    [self.frameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(40);
            make.left.equalTo(_imgView);
            make.bottom.equalTo(_frameCollectionView.mas_top);
    }];
    
    [self.selectFrameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.frameLabel);
            make.width.mas_equalTo(130);
            make.right.equalTo(_imgView);
            make.bottom.equalTo(_frameCollectionView.mas_top);
    }];
    
    [self.showSelectedFramesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.frameLabel);
            make.width.mas_equalTo(130);
            make.right.equalTo(_imgView);
            make.top.equalTo(self.view.mas_top).offset(45);
    }];
    
    [self.cropBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.frameLabel);
            make.width.mas_equalTo(100);
            make.left.equalTo(_imgView);
            make.top.equalTo(self.view.mas_top).offset(45);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.view.mas_width).offset(-60);
            make.centerX.equalTo(self.view);
            make.height.equalTo(self.selectFrameBtn);
            make.bottom.equalTo(self.selectFrameBtn.mas_top);
    }];
    
    [self.frameNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.slider);
            make.center.equalTo(self.view);
            make.height.mas_equalTo(self.view).offset(-500);
    }];
}

-(void)imglongTapClick:(UILongPressGestureRecognizer*)gesture
{
    if(gesture.state==UIGestureRecognizerStateBegan)
    {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"保存到手机" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 保存图片到相册
            UIImageWriteToSavedPhotosAlbum(self->_currentFrame, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        [alertControl addAction:cancel];
        [alertControl addAction:confirm];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.mode = MBProgressHUDModeText;
    [self.view addSubview:hud];
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(150);
            make.height.mas_equalTo(80);
            make.center.equalTo(self.view);
    }];
    [hud showAnimated:YES];
    if(!error) {
        hud.label.text = @"保存成功";
    }
    else {
        hud.label.text = @"保存失败";
    }
    [hud hideAnimated:YES afterDelay:1];
}

/*
- (void)getFramNum {
    // 得到帧数
    AVAssetTrack *t = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    self.frameNum = t.nominalFrameRate * self.videoAsset.duration.value / self.videoAsset.duration.timescale;
    [self.frameCollectionView reloadData];
    [self.frameCollectionView layoutIfNeeded];
    [self showFrameAtIndex:0];
    self.slider.maximumValue = _frameNum - 1;
}*/

- (void)getFrameNum {
    // 得到帧数
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *tmpString = [[_videoUrl absoluteString] substringFromIndex:7];
    
    cv::VideoCapture capture((char *)[tmpString UTF8String]);
    dispatch_async(dispatch_get_main_queue(), ^{
        AVAsset *asset = [AVAsset assetWithURL:self->_videoUrl];
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if([tracks count] > 0) {
            AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
            self->imgViewHeight = self.view.frame.size.width / videoTrack.naturalSize.width * videoTrack.naturalSize.height;
        }
        self->_imgView.frame = CGRectMake(0, (self.view.frame.size.height - 45 - 70 - 2 - self->imgViewHeight) / 2 + 45, self.view.frame.size.width, self->imgViewHeight);
        self->_poseView.frame = self->_imgView.frame;
    });
    int frameNumTmp = capture.get(cv::CAP_PROP_FRAME_COUNT);
    int imgIndex = 0;
    if (!capture.isOpened())
    {
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    while (true) {
        cv::Mat frame;
        capture >> frame;
        if (frame.empty()) {
            frame.release();
            break;
        }
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            cvtColor(frame, frame, cv::COLOR_BGR2RGB);
            UIImage *img = MatToUIImage(frame);
            NSData *imageData = UIImageJPEGRepresentation(img, 0.01);
            NSString *filePath = [[path objectAtIndex:0] stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"frame%d.jpg", imgIndex]];  // 保存文件的名称
            [imageData writeToFile:filePath atomically:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateHudWithFrameNum:frameNumTmp];
            });
        });
        imgIndex++;
        frame.release();
    }
    self.frameNum = imgIndex;
    capture.release();
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.delegate hideHud];
        [self.frameCollectionView reloadData];
        [self.frameCollectionView layoutIfNeeded];
        [self showFrameAtIndex:0];
        self.slider.maximumValue = self->_frameNum - 1;
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if ([def valueForKey:[self->_videoUrl absoluteString]]) {
            NSArray *indexArray = [def valueForKey:[self->_videoUrl absoluteString]];
            self.selectedFramesIndex = [indexArray mutableCopy];
            [self getSelectedFramesFromNSUserDefaults:indexArray];
            [self.frameNumberView hasSelectedIndex:indexArray];
        }
    });
}

- (UIImage *)getFrameWithFrameIndex:(int)frameIndex {
    // 得到指定视频的某一帧图片
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[path objectAtIndex:0] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"frame%d.jpg", frameIndex]];  // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return [self fixOrientation:img];
}

- (void)rotateImg {
    
    self->imgViewHeight = self.imgView.frame.size.width * self.view.frame.size.width / self.imgView.frame.size.height;
    self->_imgView.frame = CGRectMake(0, (self.view.frame.size.height - 45 - 70 - 2 - self->imgViewHeight) / 2 + 45, self.view.frame.size.width, self->imgViewHeight);
    self->_poseView.frame = self->_imgView.frame;
    originImgViewSize = CGSizeMake(originImgViewSize.height, originImgViewSize.width);
    
    rotateAngel = (rotateAngel + 90) % 360;
    
    // 将旋转角度存储到NSUserDefaults
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tmpString = [NSString stringWithFormat:@"%@rotateAngel", _videoUrl];
    [def setValue:[NSNumber numberWithInt:rotateAngel] forKey:tmpString];
    [def synchronize];
    
    [self.frameCollectionView reloadData];
    [self.frameCollectionView layoutIfNeeded];
    [self showFrameAtIndex:_frameIndex];
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (rotateAngel == 0) {
        return aImage;
    }
    UIImageOrientation newOrientation;
    switch (aImage.imageOrientation) {
        case UIImageOrientationUp:
            if (rotateAngel == 90) {
                newOrientation = UIImageOrientationRight;
            }
            else if (rotateAngel == 180) {
                newOrientation = UIImageOrientationDown;
            }
            else {
                newOrientation = UIImageOrientationLeft;
            }
            break;
        case UIImageOrientationLeft:
            if (rotateAngel == 90) {
                newOrientation = UIImageOrientationUp;
            }
            else if (rotateAngel == 180) {
                newOrientation = UIImageOrientationRight;
            }
            else {
                newOrientation = UIImageOrientationDown;
            }
            break;
        case UIImageOrientationDown:
            if (rotateAngel == 90) {
                newOrientation = UIImageOrientationLeft;
            }
            else if (rotateAngel == 180) {
                newOrientation = UIImageOrientationUp;
            }
            else {
                newOrientation = UIImageOrientationRight;
            }
            break;
        case UIImageOrientationRight:
            if (rotateAngel == 90) {
                newOrientation = UIImageOrientationDown;
            }
            else if (rotateAngel == 180) {
                newOrientation = UIImageOrientationLeft;
            }
            else {
                newOrientation = UIImageOrientationUp;
            }
            break;
    }
    UIImage *rotatedImage = [UIImage imageWithCGImage:aImage.CGImage scale:1.0f orientation:newOrientation];
    return rotatedImage;
}

- (void)disableBtns {
    self.preBtn.enabled = false;
    self.nextBtn.enabled = false;
    self.playOrPauseBtn.enabled = false;
    self.selectFrameBtn.enabled = false;
}

- (void)enableBtns {
    self.preBtn.enabled = true;
    self.nextBtn.enabled = true;
    self.playOrPauseBtn.enabled = true;
    self.selectFrameBtn.enabled = true;
}

- (void)showFrameAtIndex:(int)index {
    self.frameLabel.text = [NSString stringWithFormat:@"%d / %d", index + 1, _frameNum];
    UIImage *tmpImg = [self getFrameWithFrameIndex:index];
    
    if (hasCut) {
        UIImage *image = tmpImg;
        CGRect cutAreaReal = CGRectMake(cutArea.origin.x / originImgViewSize.width * image.size.width,
                                        cutArea.origin.y / originImgViewSize.height * image.size.height,
                                        cutArea.size.width / originImgViewSize.width * image.size.width,
                                        cutArea.size.height / originImgViewSize.height * image.size.height);
        
        CGImageRef imageRef = image.CGImage;
        CGImageRef cgImage = CGImageCreateWithImageInRect(imageRef, cutAreaReal);
        UIImage *cutImage = [[UIImage alloc] initWithCGImage:cgImage];
        //CGImageRelease(imageRef);
        //CGImageRelease(cgImage);
        [self.imgView setImage:cutImage];
        self.currentFrame = cutImage;
    }
    else {
        self.currentFrame = tmpImg;
        [self.imgView setImage:_currentFrame];
    }
    
    if (_currentSelectedCell) {
        [self.currentSelectedCell setSelected:NO];
    }
    NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [_frameCollectionView cellForItemAtIndexPath:tmpPath];
    [self.frameCollectionView scrollToItemAtIndexPath:tmpPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.frameCollectionView layoutIfNeeded];
    [cell setSelected:YES];
    self.currentSelectedCell = cell;
}

- (void)previousFrame {
    if (!_isPlaying) {
        if (_frameIndex) {
            self.frameIndex--;
            [self showFrameAtIndex:self.frameIndex];
            self.slider.value = _frameIndex;
        }
    }
}

- (void)nextFrame {
    if (!_isPlaying) {
        if (_frameIndex + 1 != _frameNum) {
            self.frameIndex++;
            [self showFrameAtIndex:self.frameIndex];
            self.slider.value = _frameIndex;
        }
    }
}

- (void)autoNextFrame {
    if (_frameIndex + 1 != _frameNum) {
        self.frameIndex++;
        [self showFrameAtIndex:self.frameIndex];
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(autoNextFrame) userInfo:nil repeats:YES];
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

#pragma mark -collectionview 数据源方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _frameNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    
    UIImage *cellImg = [self getFrameWithFrameIndex:(int)indexPath.row];
    if (hasCut) {
        UIImage *image = cellImg;
        CGRect cutAreaReal = CGRectMake(cutArea.origin.x / originImgViewSize.width * image.size.width,
                                        cutArea.origin.y / originImgViewSize.height * image.size.height,
                                        cutArea.size.width / originImgViewSize.width * image.size.width,
                                        cutArea.size.height / originImgViewSize.height * image.size.height);
        
        CGImageRef imageRef = image.CGImage;
        CGImageRef cgImage = CGImageCreateWithImageInRect(imageRef, cutAreaReal);
        UIImage *cutImage = [[UIImage alloc] initWithCGImage:cgImage];
        CGImageRelease(imageRef);
        //CGImageRelease(cgImage);
        cellImg = cutImage;
    }
    
    [cell setFrameImg:cellImg withRate:_imgView.frame.size.width / _imgView.frame.size.height];

    UIView *tmpView = [[UIView alloc] initWithFrame:cell.frame];
    tmpView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = tmpView;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.frameIndex = (int)indexPath.row;
    [self showFrameAtIndex:(int)indexPath.row];
    self.slider.value = indexPath.row;
}

// 拖动 slider
- (void)sliderValueChanged:(UISlider *)slider {
    self.frameIndex = (int)slider.value;
    [self showFrameAtIndex:_frameIndex];
}

// 选择关键帧
- (void)selectFrame {
    if (self.frameNumberView.hidden) {
        [self.frameNumberView setHidden:NO];
    }
    else {
        [self.frameNumberView setHidden:YES];
    }
}

- (void)backgroundTapClick {
    if (self.frameNumberView.isHidden) {
        if (self.cropBtn.isHidden) {
            [self.cropBtn setHidden:NO];
            [self.preBtn setHidden:NO];
            [self.nextBtn setHidden:NO];
            [self.rotateBtn setHidden:NO];
            [self.selectFrameBtn setHidden:NO];
            [self.playOrPauseBtn setHidden:NO];
            [self.showPoseViewBtn setHidden:NO];
            [self.showSelectedFramesBtn setHidden:NO];
            [self.frameLabel setHidden:NO];
            [self.frameCollectionView setHidden:NO];
            [self.whiteView setHidden:NO];
        }
        else {
            [self.cropBtn setHidden:YES];
            [self.preBtn setHidden:YES];
            [self.nextBtn setHidden:YES];
            [self.rotateBtn setHidden:YES];
            [self.selectFrameBtn setHidden:YES];
            [self.playOrPauseBtn setHidden:YES];
            [self.showPoseViewBtn setHidden:YES];
            [self.showSelectedFramesBtn setHidden:YES];
            [self.frameLabel setHidden:YES];
            [self.frameCollectionView setHidden:YES];
            [self.whiteView setHidden:YES];
        }
    }
    else {
        [self.frameNumberView setHidden:YES];
    }
}

- (void)selectFrameWithIndex:(int)index {
    [self.frameNumberView setHidden:YES];
    self.selectedFrames[index] = _currentFrame;
    self.selectedFramesIndex[index] = [NSNumber numberWithInteger:_frameIndex];
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.mode = MBProgressHUDModeText;
    [self.view addSubview:hud];
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(150);
            make.height.mas_equalTo(80);
            make.center.equalTo(self.view);
    }];
    [hud showAnimated:YES];
    hud.label.text = [NSString stringWithFormat:@"选为第%d帧", index + 1];
    [hud hideAnimated:YES afterDelay:1];
    
    // 将选择的这一帧保存到NSUserDefaults
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[_selectedFramesIndex copy] forKey:[_videoUrl absoluteString]];
    [def synchronize];
}

- (void)deselectFrameWithIndex:(int)index {
    self.selectedFrames[index] = [[NSObject alloc] init];
    self.selectedFramesIndex[index] = [NSNumber numberWithInteger:-1];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[_selectedFramesIndex copy] forKey:[_videoUrl absoluteString]];
    [def synchronize];
}

- (void)showFrames {
    ShowFramesViewController *vc = [[ShowFramesViewController alloc] initViewWithSelectedFrames:_selectedFrames andRate:_imgView.frame.size.width / _imgView.frame.size.height];
    vc.videoUrl = _videoUrl;
    vc.selectedFramesIndex = _selectedFramesIndex;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (!self.navigationController.viewControllers) {
        // 出栈
        // 删除图片文件
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        for (int i = 0; i < _frameNum; i++) {
            NSString *filePath = [[path objectAtIndex:0] stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"frame%d.jpg", i]];  // 保存文件的名称
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

- (AVPlayer *)player {
    if (_player) {
        return _player;
    }
    _player = [[AVPlayer alloc] initWithURL:_videoUrl];
    return _player;
}

// 显示关键点
- (void)setCurrentFrame:(UIImage *)currentFrame {
    _currentFrame = currentFrame;
    
    if (!isShowPose) {
        return;
    }
    
    [self predictPose];
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];

    CVPixelBufferRef pxbuffer = NULL;

    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);

    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);

    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);

    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}

- (void)predictPose {
    NSString *path_document = NSTemporaryDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_document stringByAppendingString:@"/predictImg.jpg"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(_currentFrame) writeToFile:imagePath atomically:YES];
    
    cv::Mat src = cv::imread((char *)[imagePath UTF8String]);
    cv::Size srcSize = cv::Size(513, 513);
    cv::resize(src, src, srcSize, 0, 0, cv::INTER_LINEAR);
    cv::imwrite((char *)[imagePath UTF8String], src);
    
    UIImage *inputImg = [[UIImage alloc] initWithContentsOfFile:imagePath];
    CGImageRef inputImgRef = inputImg.CGImage;
    CVPixelBufferRef pixelBufferRef = [self pixelBufferFromCGImage:inputImgRef];
    NSDate* tmpStartData = [NSDate date];
    PoseNetMobileNet100S8FP16Output *outPut = [self.model predictionFromImage:pixelBufferRef error:nil];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"cost time = %f", deltaTime);
    //CGImageRelease(inputImgRef);
    CVPixelBufferRelease(pixelBufferRef);
    MLMultiArray *heatmap = outPut.heatmap;
    MLMultiArray *offsets = outPut.offsets;
    float ***heatmapA = NULL;  // p[pen_num][row][col];
    int pen_num = 17, row = 65, col = 65;
    heatmapA = (float ***)malloc(pen_num * sizeof(float **));
    for (int i = 0; i < pen_num; i++)
    {
        heatmapA[i] = (float **)malloc(row * sizeof(float *));
        for (int j = 0; j < row; j++)
        {
            heatmapA[i][j] = (float *)malloc(col * sizeof(float));
        }
    }
    
    float ***offsetsA;
    pen_num = 34;
    offsetsA = (float ***)malloc(pen_num * sizeof(float **));
    for (int i = 0; i < pen_num; i++)
    {
        offsetsA[i] = (float **)malloc(row * sizeof(float *));
        for (int j = 0; j < row; j++)
        {
            offsetsA[i][j] = (float *)malloc(col * sizeof(float));
        }
    }
    [self convertFrom:heatmap to:heatmapA with:17 and:65 and:65];
    [self convertFrom:offsets to:offsetsA with:34 and:65 and:65];
    NSMutableArray *dots = [[NSMutableArray alloc] init];
    for (int i = 0; i < 17; i++) {
        float maxPossible = -1;
        float jPossible = 0, kPossible = 0;
        for (int j = 0; j < 65; j++) {
            for (int k = 0; k < 65; k++) {
                if (heatmapA[i][j][k] > maxPossible) {
                    maxPossible = heatmapA[i][j][k];
                    jPossible = j;
                    kPossible = k;
                }
            }
        }
        [dots addObject:[NSValue valueWithCGPoint:CGPointMake(kPossible / 65 * 513 + offsetsA[i + 17][(int)jPossible][(int)kPossible], jPossible / 65 * 513 + offsetsA[i][(int)jPossible][(int)kPossible])]];
    }
    
    for (int i = 0; i < pen_num; i++)
    {
        for (int j = 0; j < row; j++)
        {
            free(offsetsA[i][j]);
        }
    }
    for (int i = 0; i < pen_num; i++)
    {
        free(offsetsA[i]);
    }
    free(offsetsA);
    
    pen_num = 17;
    for (int i = 0; i < pen_num; i++)
    {
        for (int j = 0; j < row; j++)
        {
            free(heatmapA[i][j]);
        }
    }
    for (int i = 0; i < pen_num; i++)
    {
        free(heatmapA[i]);
    }
    free(heatmapA);
    
    for (int i = 0; i < 17; i++) {
        dots[i] = [NSValue valueWithCGPoint:CGPointMake([dots[i] CGPointValue].x / 513 * self.view.frame.size.width, [dots[i] CGPointValue].y / 513 * imgViewHeight)];
    }
    [self.poseView setDots:dots];
}

- (void)convertFrom:(MLMultiArray *)array1 to:(float***)array2 with:(int)I and:(int)J and:(int)K {
    int idx = 0;
    for (int i = 0; i < I; i++) {
        for (int j = 0; j < J; j++) {
            for (int k = 0; k < K; k++) {
                array2[i][j][k] = array1[idx].floatValue;
                idx++;
            }
        }
    }
}

- (PoseNetMobileNet100S8FP16 *)model {
    if (!_model) {
        _model = [[PoseNetMobileNet100S8FP16 alloc] init];
    }
    return _model;
}

- (void)showPose {
    if (isShowPose) {
        self.showPoseViewBtn.selected = NO;
        self.poseView.hidden = YES;
    }
    else {
        [self predictPose];
        self.showPoseViewBtn.selected = YES;
        self.poseView.hidden = NO;
    }
    isShowPose = !isShowPose;
}

- (void)cropImages {
    [_cropBtn setBackgroundColor:[UIColor orangeColor]];
    [_imgView addGestureRecognizer:_addRectanglePanGestureRecognizer];
}

- (void)endAddRectangle{
    [_imgView removeGestureRecognizer:_addRectanglePanGestureRecognizer];
    [_cropBtn setBackgroundColor:[UIColor blackColor]];
}

- (void)addRectangle:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self.view];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:_imgView.bounds];
            currentLayer.lineWidth = 5;
            currentLayer.strokeColor = [UIColor redColor].CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.view.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            CGPoint translation = [recognizer translationInView:_imgView];
            if (origin.y + translation.y > _imgView.frame.origin.y + _imgView.frame.size.height) {
                translation.y = _imgView.frame.origin.y + _imgView.frame.size.height - origin.y;
            }
            if (origin.y + translation.y < _imgView.frame.origin.y) {
                translation.y = _imgView.frame.origin.y - origin.y;
            }
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x, origin.y+translation.y)];
            [currentPath closePath];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            
            UIAlertController * newAlert=[UIAlertController
                                          alertControllerWithTitle: @"确认裁剪？"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert
                                          ];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                float x, y, w, h;
                [self->currentPath removeAllPoints];
                CGPoint translation = [recognizer translationInView:self->_imgView];
                if (self->origin.y + translation.y > self->_imgView.frame.origin.y + self->_imgView.frame.size.height) {
                    translation.y = self->_imgView.frame.origin.y + self->_imgView.frame.size.height - self->origin.y;
                }
                if (self->origin.y + translation.y < self->_imgView.frame.origin.y) {
                    translation.y = self->_imgView.frame.origin.y - self->origin.y;
                }
                w = abs(translation.x);
                h = abs(translation.y);
                if (self->origin.x + translation.x < self->origin.x) {
                    x = self->origin.x + translation.x;
                }
                else {
                    x = self->origin.x;
                }
                
                if (self->origin.y + translation.y < self->origin.y) {
                    y = self->origin.y + translation.y;
                }
                else {
                    y = self->origin.y;
                }
                y -= self->_imgView.frame.origin.y;
                if (!self->hasCut) {
                    self->cutArea = CGRectMake(x, y, w, h);
                    self->hasCut = YES;
                    originImgViewSize = self.imgView.frame.size;
                }
                else {
                    self->cutArea = CGRectMake(self->cutArea.origin.x + x * self->cutArea.size.width / self->_imgView.frame.size.width,
                                         self->cutArea.origin.y + y * self->cutArea.size.height / self->_imgView.frame.size.height,
                                         w * self->cutArea.size.width / self->_imgView.frame.size.width,
                                         h * self->cutArea.size.height / self->_imgView.frame.size.height);
                }
                
                UIImage *image = self->_imgView.image;
                CGRect cutAreaTmp = CGRectMake(x, y, w, h);
                CGRect cutAreaReal = CGRectMake(cutAreaTmp.origin.x / self->_imgView.frame.size.width * image.size.width,
                                                cutAreaTmp.origin.y / self->_imgView.frame.size.height * image.size.height,
                                                cutAreaTmp.size.width / self->_imgView.frame.size.width * image.size.width,
                                                cutAreaTmp.size.height / self->_imgView.frame.size.height * image.size.height);
                
                CGImageRef imageRef = image.CGImage;
                CGImageRef cgImage = CGImageCreateWithImageInRect(imageRef, cutAreaReal);
                UIImage *cutImage = [[UIImage alloc] initWithCGImage:cgImage];
                //CGImageRelease(imageRef);
                //CGImageRelease(cgImage);
                [self.imgView setImage:cutImage];
                self->imgViewHeight = self.view.frame.size.width / w * h;
                self->_imgView.frame = CGRectMake(0, (self.view.frame.size.height - 45 - 70 - 2 - self->imgViewHeight) / 2 + 45, self.view.frame.size.width, self->imgViewHeight);
                self->_poseView.frame = self->_imgView.frame;
                self->_currentFrame = cutImage;
                [self.frameCollectionView reloadData];
                [self.frameCollectionView layoutIfNeeded];
            }];
            [newAlert addAction:confirm];
            [newAlert addAction:cancel];
            [self presentViewController:newAlert animated:YES completion:nil];
            
            [currentLayer removeFromSuperlayer];
            currentLayer = nil;
            [self endAddRectangle];
            break;
        }
        default:
            break;
    }
}

@end
