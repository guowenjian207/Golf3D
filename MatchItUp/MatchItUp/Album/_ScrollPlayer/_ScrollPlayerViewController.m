//
//  _ScrollPlayerViewController.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/18.
//

#import "_ScrollPlayerViewController.h"

@interface _ScrollPlayerViewController (){
    //背景
    UIScrollView *scrollView;
    UIView *upView;
    UIView *middleView;
    UIView *downView;
    UIImageView *upImgView;
    UIImageView *middleImgView;
    UIImageView *downImgView;
    
    //上操作栏
    UIView *topView;
    UIButton *backBtn;
    UILabel *rateLabel;
    UIButton *optionBtn;
    
    //菜单
    UIView *optionView;
    UIButton *cutBtn;
    UIButton *rateBtn;
    UIButton *frameBtn;
    UIButton *toolBtn;
    
    //播放速率
    UIView *rateView;
    UIButton *rate0Btn;
    UIButton *rate1Btn;
    UIButton *rate2Btn;
    UIButton *rate3Btn;
    
    //底部操作栏
    UIView *bottomView;
    UISlider *slider;
    ZHDoubleSlider *doubleSlider;
    UIButton *leftBtn;
    UIButton *middleBtn;
    UIButton *rightBtn;
    UIButton *screenRecordBtn1;
    UIButton *screenRecordBtn2;
    
    //逐帧播放操作栏
    UIView *frameView;
    UIButton *lastFrameBtn;
    UIButton *nextFrameBtn;
    UILabel *sumTitleLabel;
    UILabel *sumLabel;
    UILabel *indexTitleLabel;
    UILabel *indexLabel;
    UIStepper *frameStepper;
    UILabel *stepTitleLabel;
    UILabel *stepLabel;

    //toolbox
    UIView *toolboxView;
    UIButton *closeBtn;
    UIButton *revokeBtn;
    UIButton *clearBtn;
    UIButton *lineBtn;
    UIButton *angleBtn;
    UIButton *rectBtn;

    ///操作栏隐藏计时器
    NSTimer *showTimer;
    ///进度条开始更新计时器
    NSTimer *updateTimer;
    
    ///是否正在播放
    BOOL isPlay;
    ///菜单是否显示
    BOOL menuIsShowing;
    ///底部顶部操作栏是否显示
    BOOL barIsShowing;
    ///是否在剪裁
    BOOL isCutting;
    ///辅助线栏是否显示
    BOOL toolBoxIsShowing;
    ///播放速率栏是否显示
    BOOL rateViewIsShowing;
    
    ///是否正在逐帧播放
    BOOL isFramePlaying;
    int sumOfFrame;
    int indexOfFrame;
    int step;
    NSTimer *nextTimer;
    NSTimer *lastTimer;
    float fps;
    
    //画具栏
    Canvas *canvas;
    
    //屏幕录制
    BOOL screenRecordIsRecording;
    BOOL screenRecordIsPauseing;
    ZHScreenRecordManager *screenRecordManager;
    
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
    NSURL *videoURL;
    CMTime tolerance;
    float currentRate;
    
    NSNotificationName playToRightNotificationName;
}

@end

@implementation _ScrollPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tolerance = CMTimeMake(1, 1000000);
    currentRate = 1.0;
    isPlay = YES;
    menuIsShowing = NO;
    barIsShowing = YES;
    isCutting = NO;
    isFramePlaying = NO;
    rateViewIsShowing = NO;
    toolBoxIsShowing = NO;
    screenRecordIsPauseing = NO;
    screenRecordIsRecording = NO;
    playToRightNotificationName = @"playToRightNotificationName";
    screenRecordManager = [[ZHScreenRecordManager alloc] init];
    
    [self setupPlayer];
    [self outletConfig];
    [self outletLayout];
    [self sliderConfig];
}

- (void)viewDidLayoutSubviews{
    [scrollView setContentOffset:CGPointMake(0, kScreenH)];
}

- (void)viewDidAppear:(BOOL)animated{
    [self startUpdateTimer];
    [self startShowTimer];
    if (isPlay){
        [player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [lastTimer invalidate];
    lastTimer = nil;
    [showTimer invalidate];
    showTimer = nil;
    [nextTimer invalidate];
    nextTimer = nil;
    [updateTimer invalidate];
    updateTimer = nil;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    player = nil;
    NSLog(@"没了没了");
}

#pragma mark - event
- (void)setupPlayer{
    switch (_videoSource) {
        case systemAlbum:
            videoURL = _photosVideoArr[_currentIndex].url;
            break;
        case screenRecordAlbum:
            videoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",[GlobalVar sharedInstance].screenRecordDir, _screenRecordArr[_currentIndex].videoFile]];
            break;
        default:
            videoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",[GlobalVar sharedInstance].albumDir, _videoArr[_currentIndex].videoFile]];
            break;
    }
    playerItem = [[AVPlayerItem alloc]initWithURL:videoURL];
    player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(replay) name:@"playToRightTime" object:nil];
}

- (void)replay{
    if (isCutting){
//        playerItem seekToTime:<#(CMTime)#> toleranceBefore:<#(CMTime)#> toleranceAfter:<#(CMTime)#> completionHandler:<#^(BOOL finished)completionHandler#>
    }else{
        [playerItem seekToTime:kCMTimeZero toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
        [player play];
        [player setRate:currentRate];
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)middleViewTapped{
    if (barIsShowing){
        [self middleBtnTapped];
    }else{
        [self startShowTimer];
    }
    if (rateViewIsShowing){
        rateViewIsShowing = NO;
        [rateView setHidden:YES];
    }
}

- (void)startUpdateTimer{
    [updateTimer invalidate];
    __weak typeof(self) weakSelf = self;
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->slider setValue:CMTimeGetSeconds(strongSelf->playerItem.currentTime)];
        if (self->isCutting && self->slider.value >= self->doubleSlider.rightValue){
            [[NSNotificationCenter defaultCenter] postNotificationName:self->playToRightNotificationName object:nil];
        }
    }];
}

- (void)startShowTimer{
    [showTimer invalidate];
    [topView setHidden:NO];
    if (isFramePlaying){
        [frameView setHidden:NO];
    }else{
        [bottomView setHidden:NO];
    }
    self->barIsShowing = YES;
    __weak typeof(self) weakSelf = self;
    showTimer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:NO block:^(NSTimer *timer){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->topView setHidden:YES];
        [strongSelf->bottomView setHidden:YES];
        //[strongSelf->frameView setHidden:YES];
        [strongSelf->optionView setHidden:YES];
        strongSelf->menuIsShowing = NO;
        strongSelf->barIsShowing = NO;
    }];
}

- (void)middleBtnTapped{
    [self startShowTimer];
    if (isPlay){
        [self playerPause];
    }else{
        [self playerPlay];
    }
}

- (void)playerPause{
    [middleBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [player pause];
    isPlay = false;
}

- (void)playerPlay{
    [middleBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [player play];
    isPlay = true;
}

- (void)optionBtnTapped{
    [self startShowTimer];
    [optionView setHidden:menuIsShowing];
    menuIsShowing = !menuIsShowing;
}

- (void)cutBtnTapped{
    [self startShowTimer];
    isCutting = !isCutting;
    if (isCutting){
        [doubleSlider setFrame:slider.frame];
        [doubleSlider setHidden:NO];
        [slider setHidden:YES];
        switch (_videoSource) {
            case systemAlbum:
                break;
            case appAlbum:
            {
                if (_videoArr[_currentIndex].postFlag){
                    [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                    [rightBtn setHidden:NO];
                    [leftBtn setHidden:NO];
                }else{
                    [rightBtn setHidden:YES];
                    [leftBtn setHidden:YES];
                }
            }
                break;
            case uploadedAlbum:
                [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            default:
                break;
        }
        [cutBtn setTitle:@"剪 裁" forState:UIControlStateNormal];
    }else{
        [doubleSlider setHidden:YES];
        [slider setHidden:NO];
        [leftBtn setHidden:NO];
        [rightBtn setHidden:NO];
        [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [cutBtn setTitle:@"退出剪裁" forState:UIControlStateNormal];
    }
}

- (void)toolBtnTapped{
    if(toolBoxIsShowing){
        [canvas closeToolbox];
    }else{
        [self startShowTimer];
    }
    [canvas.toolboxView setHidden:toolBoxIsShowing];
    [screenRecordBtn1 setHidden:toolBoxIsShowing];
    [screenRecordBtn2 setHidden:toolBoxIsShowing];
    [scrollView setScrollEnabled:toolBoxIsShowing];
    toolBoxIsShowing = !toolBoxIsShowing;
    [leftBtn setHidden:toolBoxIsShowing];
    [rightBtn setHidden:toolBoxIsShowing];
}

- (void)frameBtnTapped{
    isFramePlaying = !isFramePlaying;
    if (isFramePlaying){
        if (isPlay) [self middleBtnTapped];
        [playerItem seekToTime:kCMTimeZero toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
        indexOfFrame = 0;
        [indexLabel setText: [NSString stringWithFormat:@"%d", indexOfFrame]];
        [bottomView setHidden:YES];
        [frameView setHidden:NO];
        [rateLabel setHidden:YES];
        [frameBtn setTitle:@"正常播放" forState:UIControlStateNormal];
    }else{
        [bottomView setHidden:NO];
        [frameView setHidden:YES];
        [rateLabel setHidden:NO];
        [frameBtn setTitle:@"逐帧播放" forState:UIControlStateNormal];
    }
}

- (void)rateBtnTapped{
    [self startShowTimer];
    [rateView setHidden:rateViewIsShowing];
    rateViewIsShowing = !rateViewIsShowing;
}

- (void)rate0BtnTapped{
    [rateLabel setText:@"0.5X"];
    [rateView setHidden:YES];
    rateViewIsShowing = NO;
    currentRate = 0.5;
    [player setRate:currentRate];
}

- (void)rate1BtnTapped{
    [rateLabel setText:@"0.75X"];
    [rateView setHidden:YES];
    rateViewIsShowing = NO;
    currentRate = 0.75;
    [player setRate:currentRate];
}

- (void)rate2BtnTapped{
    [rateLabel setText:@"1.0X"];
    [rateView setHidden:YES];
    rateViewIsShowing = NO;
    currentRate = 1;
    [player setRate:currentRate];
}

- (void)rate3BtnTapped{
    [rateLabel setText:@"1.5X"];
    [rateView setHidden:YES];
    rateViewIsShowing = NO;
    currentRate = 1.5;
    [player setRate:currentRate];
}

- (void)leftBtnTapped{
    if (isPlay) [self playerPause];
    [self saveVideoWithUpload:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (void)rightBtnTapped{
    if (isPlay) [self playerPause];
    [self saveVideoWithUpload:NO completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (void)saveVideoWithUpload:(BOOL)isNeededUpload completion:(void (^)(void))completionBlock{
    if (isCutting){
        //保存所选的部分
        [[ZHFileManager sharedManager] cutVideo:videoURL withStartTime:doubleSlider.leftValue endTime:doubleSlider.rightValue remindView:nil angle:360 completion:^(NSURL *desURL){
            NSLog(@"new video %@", desURL);
            [[ZHFileManager sharedManager] deleteTmpVideo];
            completionBlock();
        }];
    }else{
        //保存整段视频
        [[ZHFileManager sharedManager] copyVideo:videoURL withAngle:360 completion:^(NSURL *desURL){
            NSLog(@"new video %@", desURL);
            [[ZHFileManager sharedManager] deleteTmpVideo];
            completionBlock();
        }];
    }
}

/**
 slider button 滑动
 */
- (void)dragSlider:(UISlider *)slider{
    [self startUpdateTimer];
    [self startShowTimer];
    [playerItem seekToTime:CMTimeMake(slider.value*1000000, 1000000) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
}

- (void)dragLeft{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startShowTimer];
        [self startUpdateTimer];
        [self->playerItem seekToTime:CMTimeMake(self->doubleSlider.leftValue*10000, 10000) toleranceBefore:self->tolerance toleranceAfter:self->tolerance completionHandler:nil];
    });
}

- (void)dragRight{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startShowTimer];
        [self startUpdateTimer];
        [self->playerItem seekToTime:CMTimeMake(self->doubleSlider.rightValue*10000, 10000) toleranceBefore:self->tolerance toleranceAfter:self->tolerance completionHandler:nil];
    });
}

- (void)lastFrameBtnTapped{
    if (indexOfFrame > 0){
        --indexOfFrame;
        [playerItem seekToTime:CMTimeMake(indexOfFrame, fps) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
        [indexLabel setText:[NSString stringWithFormat:@"%d", indexOfFrame]];
    }
}

- (void)lastFrameBtnLongPress:(UILongPressGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer){
                if (self->indexOfFrame>=self->step){
                    self->indexOfFrame-=self->step;
                }else{
                    self->indexOfFrame = 0;
                }
                [self->playerItem seekToTime:CMTimeMake(self->indexOfFrame, self->fps) toleranceBefore:self->tolerance toleranceAfter:self->tolerance completionHandler:nil];
                [self->indexLabel setText:[NSString stringWithFormat:@"%d", self->indexOfFrame]];
            }];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [lastTimer invalidate];
        }
            break;
        default:
            break;
    }
}

- (void)nextFrameBtnTapped{
    if (indexOfFrame < sumOfFrame){
        ++indexOfFrame;
        [playerItem seekToTime:CMTimeMake(indexOfFrame, fps) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
        [indexLabel setText:[NSString stringWithFormat:@"%d", indexOfFrame]];
    }
}

- (void)nextFrameBtnLongPress:(UILongPressGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            nextTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer){
                if (self->indexOfFrame + self->step <= self->sumOfFrame){
                    self->indexOfFrame+=self->step;
                }else{
                    self->indexOfFrame = self->sumOfFrame;
                }
                [self->playerItem seekToTime:CMTimeMake(self->indexOfFrame, self->fps) toleranceBefore:self->tolerance toleranceAfter:self->tolerance completionHandler:nil];
                [self->indexLabel setText:[NSString stringWithFormat:@"%d", self->indexOfFrame]];
            }];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [nextTimer invalidate];
            break;
        }
        default:
            break;
    }
}

- (void)stepChanged: (UIStepper *)stepper{
    step = stepper.value;
    [stepLabel setText: [NSString stringWithFormat:@"%d", step]];
}

- (void)screenRecordBtn1Tapped{
    screenRecordIsRecording = !screenRecordIsRecording;
    if (screenRecordIsRecording){
        [screenRecordManager startRecord];
        [screenRecordBtn1 setTitle:@"结束录屏" forState:UIControlStateNormal];
        [screenRecordBtn2 setTitle:@"暂停录屏" forState:UIControlStateNormal];
    }else{
        [screenRecordManager endReocrd:^(NSString *filePath){
            [ZHFileManager.sharedManager copyScreenRecord:[NSURL fileURLWithPath:filePath]];
        }];
        [screenRecordBtn1 setTitle:@"开始录屏" forState:UIControlStateNormal];
        [screenRecordBtn2 setTitle:@"" forState:UIControlStateNormal];
    }
    
    screenRecordIsPauseing = NO;
}

- (void)screenRecordBtn2Tapped{
    if (screenRecordIsRecording){
        screenRecordIsPauseing = !screenRecordIsPauseing;
        if (screenRecordIsPauseing){
            [screenRecordManager startRecord];
            [screenRecordBtn2 setTitle:@"继续录屏" forState:UIControlStateNormal];
            screenRecordIsPauseing = YES;
        }else{
            [screenRecordManager pauseRecord];
            [screenRecordBtn2 setTitle:@"暂停录屏" forState:UIControlStateNormal];
            screenRecordIsPauseing = NO;
        }
    }
}

#pragma mark - outlet
- (void)outletConfig{
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    
    scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(kScreenW, 3*kScreenH);
    scrollView.contentOffset = CGPointMake(0, kScreenH);
    [scrollView setPagingEnabled:YES];
    [scrollView setOpaque:YES];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    upView = [[UIView alloc]initWithFrame:self.view.bounds];
    middleView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH, kScreenW, kScreenH)];
    downView = [[UIView alloc]initWithFrame:CGRectMake(0, 2*kScreenH, kScreenW, kScreenH)];
    [scrollView addSubview:upView];
    [scrollView addSubview:middleView];
    [scrollView addSubview:downView];
    
    UITapGestureRecognizer *middleViewTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(middleViewTapped)];
    [middleView addGestureRecognizer:middleViewTapRecognizer];
    
    [playerLayer setFrame:middleView.bounds];
    [middleView.layer addSublayer:playerLayer];
    
    canvas = [[Canvas alloc]initWithFrame:middleView.bounds];
    [canvas setDelegate:self];
    [middleView addSubview:canvas];
    
    upImgView = [[UIImageView alloc]initWithFrame:[upView bounds]];
    middleImgView = [[UIImageView alloc]initWithFrame:[middleView bounds]];
    downImgView = [[UIImageView alloc]initWithFrame:[downView bounds]];
    [upImgView setContentMode:UIViewContentModeScaleAspectFill];
    [middleImgView setContentMode:UIViewContentModeScaleAspectFill];
    [downImgView setContentMode:UIViewContentModeScaleAspectFill];
    [upView addSubview:upImgView];
    [middleView addSubview:middleImgView];
    [downView addSubview:downImgView];
    
    [middleImgView setHidden:YES];
    
    topView = [[UIView alloc]init];
    [topView setBackgroundColor: [UIColor colorWithWhite:0.7 alpha:0.5]];
    [middleView addSubview:topView];
    
    backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"left_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    rateLabel = [[UILabel alloc]init];
    [rateLabel setText:@"1.0X"];
    [rateLabel setTextColor:[UIColor whiteColor]];
    [rateLabel setFont:[GlobalVar sharedInstance].titleFont];
    [rateLabel setTextAlignment:NSTextAlignmentCenter];
    [topView addSubview:rateLabel];
    
    optionBtn = [[UIButton alloc]init];
    [optionBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [optionBtn addTarget:self action:@selector(optionBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:optionBtn];
    
    optionView = [[UIView alloc]init];
    [optionView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [optionView setHidden:YES];
    [middleView addSubview:optionView];
    
    cutBtn = [[UIButton alloc]init];
    [cutBtn setTitle:@"剪 裁" forState:UIControlStateNormal];
    [cutBtn addTarget:self action:@selector(cutBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:cutBtn];
    
    rateBtn = [[UIButton alloc]init];
    [rateBtn setTitle:@"倍 速" forState:UIControlStateNormal];
    [rateBtn addTarget:self action:@selector(rateBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:rateBtn];
    
    frameBtn = [[UIButton alloc]init];
    [frameBtn setTitle:@"逐帧播放" forState:UIControlStateNormal];
    [frameBtn addTarget:self action:@selector(frameBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:frameBtn];
    
    toolBtn = [[UIButton alloc]init];
    [toolBtn setTitle:@"辅助线" forState:UIControlStateNormal];
    [toolBtn addTarget:self action:@selector(toolBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:toolBtn];
    
    rateView = [[UIView alloc]init];
    [rateView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [rateView setHidden:YES];
    [middleView addSubview:rateView];
    
    rate0Btn = [[UIButton alloc]init];
    [rate0Btn setTitle:@"0.5X" forState:UIControlStateNormal];
    [rate0Btn addTarget:self action:@selector(rate0BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [rateView addSubview:rate0Btn];
    
    rate1Btn = [[UIButton alloc]init];
    [rate1Btn setTitle:@"0.75X" forState:UIControlStateNormal];
    [rate1Btn addTarget:self action:@selector(rate1BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [rateView addSubview:rate1Btn];
    
    rate2Btn = [[UIButton alloc]init];
    [rate2Btn setTitle:@"1.0X" forState:UIControlStateNormal];
    [rate2Btn addTarget:self action:@selector(rate2BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [rateView addSubview:rate2Btn];
    
    rate3Btn = [[UIButton alloc]init];
    [rate3Btn setTitle:@"1.5X" forState:UIControlStateNormal];
    [rate3Btn addTarget:self action:@selector(rate3BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [rateView addSubview:rate3Btn];
    
    bottomView = [[UIView alloc]init];
    [bottomView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [middleView addSubview:bottomView];
    
    leftBtn = [[UIButton alloc]init];
    [leftBtn setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:leftBtn];
    
    middleBtn = [[UIButton alloc]init];
    [middleBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [middleBtn addTarget:self action:@selector(middleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:middleBtn];
    
    rightBtn = [[UIButton alloc]init];
    switch (_videoSource) {
        case uploadedAlbum:
            [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            break;
        case appAlbum:
            if (_videoArr[_currentIndex].postFlag){
                [rightBtn setHidden:YES];
                [leftBtn setHidden:YES];
            }
            [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            break;
        default:
            [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
            break;
    }
    [rightBtn addTarget:self action:@selector(rightBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rightBtn];
    NSLog(@"%@",videoURL);
    
    //录屏
    screenRecordBtn1 = [[UIButton alloc] init];
    [screenRecordBtn1 setHidden:YES];
    [screenRecordBtn1 setTitle:@"开始录屏" forState:UIControlStateNormal];
    [screenRecordBtn1 addTarget:self action:@selector(screenRecordBtn1Tapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:screenRecordBtn1];
    
    screenRecordBtn2 = [[UIButton alloc] init];
    [screenRecordBtn2 setHidden:YES];
    [screenRecordBtn2 setTitle:@"" forState:UIControlStateNormal];
    [screenRecordBtn2 addTarget:self action:@selector(screenRecordBtn2Tapped) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:screenRecordBtn2];
    
    //进度条
    slider = [[UISlider alloc]init];
    [slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventValueChanged];
    [slider setContinuous:YES];
    [slider setMaximumTrackTintColor:[UIColor systemGrayColor]];
    [bottomView addSubview:slider];
    
    //双滑动条
    doubleSlider = [[ZHDoubleSlider alloc] init];
    [bottomView addSubview:doubleSlider];
    [doubleSlider setHidden:YES];
    [doubleSlider addTarget:self action:@selector(dragLeft) forEvent:ZHDoubleSliderEventLeftValueChanged];
    [doubleSlider addTarget:self action:@selector(dragRight) forEvent:ZHDoubleSliderEventRightValueChanged];
    
    //逐帧播放操作栏
    frameView = [[UIView alloc]init];
    [frameView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [frameView setHidden:YES];
    [middleView addSubview:frameView];
    //后退btn
    lastFrameBtn = [[UIButton alloc]init];
    [lastFrameBtn setImage:[UIImage imageNamed:@"left_back2"] forState:UIControlStateNormal];
    UITapGestureRecognizer *lastFrameBtnTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastFrameBtnTapped)];
    UILongPressGestureRecognizer *lastFrameBtnLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lastFrameBtnLongPress:)];
    [lastFrameBtn addGestureRecognizer:lastFrameBtnTapRecognizer];
    [lastFrameBtn addGestureRecognizer:lastFrameBtnLongPressRecognizer];
    [frameView addSubview:lastFrameBtn];
    //前进btn
    nextFrameBtn = [[UIButton alloc]init];
    [nextFrameBtn setImage:[UIImage imageNamed:@"right_back2"] forState:UIControlStateNormal];
    UITapGestureRecognizer *nextFrameBtnTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextFrameBtnTapped)];
    UILongPressGestureRecognizer *nextFrameBtnLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(nextFrameBtnLongPress:)];
    [nextFrameBtn addGestureRecognizer:nextFrameBtnTapRecognizer];
    [nextFrameBtn addGestureRecognizer:nextFrameBtnLongPressRecognizer];
    [frameView addSubview:nextFrameBtn];
    //总帧数标题
    sumTitleLabel = [[UILabel alloc]init];
    [sumTitleLabel setText:@"总帧数"];
    [sumTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:sumTitleLabel];
    //总帧数
    sumLabel = [[UILabel alloc]init];
    [sumLabel setText:[NSString stringWithFormat:@"%d",sumOfFrame]];
    [sumLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:sumLabel];
    //帧号标题
    indexTitleLabel = [[UILabel alloc]init];
    [indexTitleLabel setText:@"当前帧"];
    [indexTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:indexTitleLabel];
    //帧号
    indexLabel = [[UILabel alloc]init];
    [indexLabel setText:@"1"];
    [indexLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:indexLabel];
    //步速标题
    stepTitleLabel = [[UILabel alloc]init];
    [stepTitleLabel setText:@"快帧帧速"];
    [stepTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:stepTitleLabel];
    //步速
    stepLabel = [[UILabel alloc]init];
    [stepLabel setText:@"1"];
    [stepLabel setTextAlignment:NSTextAlignmentCenter];
    [frameView addSubview:stepLabel];
    //stepper
    frameStepper = [[UIStepper alloc]init];
    [frameStepper setAutorepeat:NO];
    [frameStepper setContinuous:YES];
    [frameStepper setMinimumValue:1];
    [frameStepper setMaximumValue:10];
    [frameStepper setStepValue:1];
    [frameStepper setValue:1];
    [frameStepper addTarget:self action:@selector(stepChanged:) forControlEvents:UIControlEventValueChanged];
    [frameView addSubview:frameStepper];
    
    //toolboxView
    toolboxView = [[UIView alloc]initWithFrame:CGRectMake(5, [GlobalVar sharedInstance].kStatusBarH+45, 50, 300)];
    [toolboxView setBackgroundColor:topView.backgroundColor];
    UIPanGestureRecognizer *toolboxLongPressRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(toolboxPan:)];
    [toolboxView addGestureRecognizer:toolboxLongPressRecognizer];
    [toolboxView setHidden:YES];
    [middleView insertSubview:toolboxView atIndex:2];
    
    closeBtn = [[UIButton alloc]init];
    [closeBtn setTitle:@"close" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [closeBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:closeBtn];
    
    revokeBtn = [[UIButton alloc]init];
    [revokeBtn setTitle:@"undo" forState:UIControlStateNormal];
    [revokeBtn addTarget:self action:@selector(revokeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [revokeBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [revokeBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:revokeBtn];
    
    clearBtn = [[UIButton alloc]init];
    [clearBtn setTitle:@"clear" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [clearBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:clearBtn];
    
    lineBtn = [[UIButton alloc]init];
    [lineBtn setTitle:@"line" forState:UIControlStateNormal];
    [lineBtn addTarget:self action:@selector(lineBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [lineBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [lineBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:lineBtn];
    
    angleBtn = [[UIButton alloc]init];
    [angleBtn setTitle:@"angle" forState:UIControlStateNormal];
    [angleBtn addTarget:self action:@selector(angleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [angleBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [angleBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:angleBtn];
    
    rectBtn = [[UIButton alloc]init];
    [rectBtn setTitle:@"rectangle" forState:UIControlStateNormal];
    [rectBtn addTarget:self action:@selector(rectBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [rectBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
    [rectBtn.layer setBorderWidth:1.5];
    [toolboxView addSubview:rectBtn];
}

- (void)outletLayout{
    [topView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.right.equalTo(middleView);
        maker.height.mas_equalTo([GlobalVar sharedInstance].kStatusBarH+40);
    }];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.equalTo(topView);
        maker.width.height.mas_equalTo(40);
        maker.left.equalTo(topView).mas_offset(15);
    }];
    
    [rateLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.centerX.equalTo(topView);
        maker.width.mas_equalTo(60);
        maker.height.mas_equalTo(40);
    }];
    
    [optionBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.height.width.equalTo(backBtn);
        maker.right.equalTo(topView).mas_offset(-15);
    }];
    
    [optionView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(topView.mas_bottom);
        maker.right.equalTo(middleView);
        maker.width.mas_equalTo(110);
        maker.height.mas_equalTo(190);
    }];
    
    [cutBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.right.left.equalTo(optionView);
        maker.height.mas_equalTo(40);
    }];
    
    [rateBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(cutBtn);
        maker.top.equalTo(cutBtn.mas_bottom).mas_offset(10);
    }];
    
    [frameBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(cutBtn);
        maker.top.equalTo(rateBtn.mas_bottom).mas_offset(10);
    }];
    
    [toolBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(cutBtn);
        maker.top.equalTo(frameBtn.mas_bottom).mas_offset(10);
    }];
    
    [rateView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(middleView);
        maker.width.mas_equalTo(110);
        maker.height.mas_equalTo(230);
    }];
    
    [rate0Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.top.equalTo(rateView);
        maker.height.mas_equalTo(50);
    }];
    
    [rate1Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(rate0Btn);
        maker.top.equalTo(rate0Btn.mas_bottom).mas_offset(10);
    }];
    
    [rate2Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(rate0Btn);
        maker.top.equalTo(rate1Btn.mas_bottom).mas_offset(10);
    }];
    
    [rate3Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.height.equalTo(rate0Btn);
        maker.top.equalTo(rate2Btn.mas_bottom).mas_offset(10);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.bottom.equalTo(middleView);
        maker.height.mas_equalTo(140);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(bottomView.mas_top).mas_offset(15);
        maker.left.equalTo(bottomView).mas_offset(20);
        maker.right.equalTo(bottomView).mas_offset(-20);
    }];
    
    [middleBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(bottomView);
        maker.height.width.mas_equalTo(70);
        //maker.bottom.equalTo(bottomView).mas_offset(-15);
    }];
    
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.equalTo(bottomView).mas_offset(50);
        maker.height.width.mas_equalTo(50);
        maker.centerY.equalTo(middleBtn);
    }];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.height.width.equalTo(leftBtn);
        maker.right.equalTo(bottomView).mas_offset(-50);
    }];
    
    [screenRecordBtn1 mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.right.bottom.equalTo(leftBtn);
        maker.left.equalTo(bottomView);
    }];
    
    [screenRecordBtn2 mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.bottom.equalTo(rightBtn);
        maker.right.equalTo(bottomView);
    }];
    
    [frameView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.bottom.right.equalTo(middleView);
        maker.height.mas_equalTo(145);
    }];
    
    [lastFrameBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.equalTo(frameView).mas_offset(30);
        maker.height.width.mas_equalTo(60);
        maker.centerY.equalTo(frameView);
    }];
    
    [nextFrameBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.centerY.height.width.equalTo(lastFrameBtn);
        maker.right.equalTo(frameView).mas_offset(-30);
    }];
    
    [sumTitleLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.right.equalTo(frameView.mas_centerX).mas_offset(-5);
        maker.top.equalTo(frameView);
        maker.width.mas_equalTo(80);
        maker.height.mas_equalTo(30);
    }];
    
    [sumLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.width.height.equalTo(sumTitleLabel);
        maker.left.equalTo(frameView.mas_centerX).mas_offset(5);
    }];
    
    [indexTitleLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(sumTitleLabel.mas_bottom).mas_offset(5);
        maker.left.width.height.equalTo(sumTitleLabel);
    }];
    
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.width.height.equalTo(indexTitleLabel);
        maker.left.equalTo(sumLabel);
    }];
    
    [stepTitleLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(indexTitleLabel.mas_bottom).mas_offset(5);
        maker.left.width.height.equalTo(sumTitleLabel);
    }];
    
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.width.height.equalTo(stepTitleLabel);
        maker.left.equalTo(sumLabel);
    }];
    
    [frameStepper setFrame:CGRectMake(kScreenW/2-47, 110, 94, 32)];
}

- (void)sliderConfig{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    Float64 duration = CMTimeGetSeconds(asset.duration);
    fps = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject.nominalFrameRate;
    sumOfFrame = duration * fps;
    
    [sumLabel setText: [NSString stringWithFormat:@"%d", sumOfFrame]];
    indexOfFrame = 0;
    step = 1;
    [indexLabel setText: [NSString stringWithFormat:@"%d", indexOfFrame]];

    [slider setMinimumValue:0];
    [slider setMaximumValue:duration];
    [slider setValue:0];
    
    [doubleSlider setMinimumValue:0];
    [doubleSlider setMaximumValue:duration];
    [doubleSlider setLeftValue:0];
    [doubleSlider setRightValue:duration];
}

#pragma mark - CanvasDelegate
- (void)hideToolbox{
    [self toolBtnTapped];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.y;
    if (offset >= 2 * kScreenH){
        //下一视频
        [player replaceCurrentItemWithPlayerItem:nil];
        [upImgView setImage:middleImgView.image];
        [middleImgView setImage:downImgView.image];
        [scrollView setContentOffset:CGPointMake(0, kScreenH)];
        if (_videoSource == systemAlbum){
            _currentIndex = _currentIndex == _photosVideoArr.count-1 ? 0 : _currentIndex+1;
            videoURL = _photosVideoArr[_currentIndex].url;
            int nextIndex = _currentIndex == _photosVideoArr.count-1 ? 0 : _currentIndex+1;
            [downImgView setImage:_photosVideoArr[nextIndex].img];
        }else if (_videoSource == screenRecordAlbum){
            _currentIndex = _currentIndex == _screenRecordArr.count-1 ? 0 : _currentIndex+1;
            videoURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].screenRecordDir, _screenRecordArr[_currentIndex].videoFile]];
            int nextIndex = _currentIndex == _screenRecordArr.count-1 ? 0 : _currentIndex+1;
            [downImgView setImage: [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].shotPicDir, _screenRecordArr[nextIndex].shotPicFile]]];
        }else{
            _currentIndex = _currentIndex == _videoArr.count-1 ? 0 : _currentIndex+1;
            videoURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].albumDir, _videoArr[_currentIndex].videoFile]];
            int nextIndex = _currentIndex == _videoArr.count-1 ? 0 : _currentIndex+1;
            [downImgView setImage: [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].shotPicDir, _videoArr[nextIndex].shotPicFile]]];
        }
    }else if (offset <= 0){
        [player replaceCurrentItemWithPlayerItem:nil];
        [downImgView setImage: middleImgView.image];
        [middleImgView setImage: upImgView.image];
        [scrollView setContentOffset:CGPointMake(0, kScreenH)];
        if (_videoSource == systemAlbum){
            _currentIndex = _currentIndex == 0 ? _photosVideoArr.count-1 : _currentIndex-1;
            videoURL = _photosVideoArr[_currentIndex].url;
            int lastIndex = _currentIndex == 0 ? _photosVideoArr.count-1 : _currentIndex-1;
            [upImgView setImage:_photosVideoArr[lastIndex].img];
        }else if (_videoSource == screenRecordAlbum){
            _currentIndex = _currentIndex == 0 ? _screenRecordArr.count-1 : _currentIndex-1;
            videoURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].screenRecordDir, _screenRecordArr[_currentIndex].videoFile]];
            int lastIndex = _currentIndex == 0 ? _screenRecordArr.count-1 : _currentIndex-1;
            [downImgView setImage: [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].shotPicDir, _screenRecordArr[lastIndex].shotPicFile]]];
        }else{
            _currentIndex = _currentIndex == 0 ? _videoArr.count-1 : _currentIndex-1;
            videoURL = [NSURL fileURLWithPath: [NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].albumDir, _videoArr[_currentIndex].videoFile]];
            int lastIndex = _currentIndex == 0 ? _videoArr.count-1 : _currentIndex-1;
            [downImgView setImage: [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", [GlobalVar sharedInstance].shotPicDir, _videoArr[lastIndex].shotPicFile]]];
        }
    }else{
        return;
    }
    
    [self sliderConfig];
    isCutting = NO;
    [cutBtn setTitle:@"剪 裁" forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [player replaceCurrentItemWithPlayerItem:playerItem];
    if (!isFramePlaying){
        if (isPlay){
            [player play];
            [player setRate:currentRate];
        }else{
            [self middleBtnTapped];
        }
    }
    switch (_videoSource) {
        case systemAlbum:
            break;
        case appAlbum:
        {
            if (_videoArr[_currentIndex].postFlag){
                [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                [rightBtn setHidden:NO];
                [leftBtn setHidden:NO];
            }else{
                [rightBtn setHidden:YES];
                [leftBtn setHidden:YES];
            }
        }
            break;
        case uploadedAlbum:
            [rightBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        default:
            break;
    }
}

@end
