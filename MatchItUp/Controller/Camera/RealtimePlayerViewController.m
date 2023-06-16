//
//  RealtimePlayerViewController.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/7.
//

#import "RealtimePlayerViewController.h"

@interface RealtimePlayerViewController ()
{
    
}

@end

@implementation RealtimePlayerViewController{
    UIView *topView;
    UIButton *backBtn;
    UILabel *rateLabel;
    UIButton *optionBtn;
    UIView *optionView;
    UIButton *rateBtn;
    UIButton *cutBtn;
    UIView *rateView;
    UIButton *rate0Btn;
    UIButton *rate1Btn;
    UIButton *rate2Btn;
    UIButton *rate3Btn;
    UIView *bottomView;
    UIButton *leftBtn;
    UIButton *middleBtn;
    UIButton *rightBtn;
    UISlider *slider;
    ZHDoubleSlider *doubleSlider;
    
    ///是否正在播放
    BOOL isPlay;
    ///菜单是否显示
    BOOL menuIsShowing;
    ///底部顶部操作栏是否显示
    BOOL barIsShowing;
    ///是否在剪裁
    BOOL isCutting;
    ///播放速率栏是否显示
    BOOL rateViewIsShowing;
    
    Float64 currentRate;
    
    NSNotificationName playToRightNotificationName;
    
    AVPlayer *player;
    AVPlayerItem *playerItem;
    NSURL *videoURL;
    Float64 angle;
    
    NSTimer *showTimer;
    NSTimer *sliderTimer;
    NSTimer *updateTimer;
    CMTime tolerance;
}

- (void)viewDidLoad {
    tolerance = CMTimeMake(1, 1000000);
    currentRate = 1.0;
    isPlay = YES;
    menuIsShowing = NO;
    barIsShowing = YES;
    isCutting = NO;
    rateViewIsShowing = NO;
    playToRightNotificationName = @"playToRightNotificationName";
    
    [super viewDidLoad];
    [self setupPlayer];
    [self outletConfig];
    [self outletLayout];
    [self sliderConfig];
}

- (void)viewDidAppear:(BOOL)animated{
    [self startUpdateTimer];
    [self startShowTimer];
    if (isPlay){
        [player play];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [showTimer invalidate];
    [updateTimer invalidate];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setupPlayer{
    tolerance = CMTimeMake(1, 1000000);
    
    videoURL = [NSURL fileURLWithPath: _isCutted ? GlobalVar.sharedInstance.tmpNewVideoPath : GlobalVar.sharedInstance.tmpVideoPath];
    playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    NSLog(@"playeritem duration : %f", playerItem.duration.value/playerItem.duration.timescale);
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer setFrame:self.view.bounds];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer insertSublayer:playerLayer atIndex:0];
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:playToRightNotificationName object:nil];
}

#pragma mark - Event

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

- (void)middleBtnTapped{
    [self startShowTimer];
    if (isPlay){
        [self playerPause];
    }else{
        [self playerPlay];
    }
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
        [cutBtn setTitle:@"退出剪裁" forState:UIControlStateNormal];
    }else{
        [doubleSlider setHidden:YES];
        [slider setHidden:NO];
        [cutBtn setTitle:@"剪 裁" forState:UIControlStateNormal];
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
    currentRate = 0.5;
    rateViewIsShowing = NO;
    [player setRate:currentRate];
}

- (void)rate1BtnTapped{
    [rateLabel setText:@"0.75X"];
    [rateView setHidden:YES];
    currentRate = 0.75;
    rateViewIsShowing = NO;
    [player setRate:currentRate];
}

- (void)rate2BtnTapped{
    [rateLabel setText:@"1.0X"];
    [rateView setHidden:YES];
    currentRate = 1.0;
    rateViewIsShowing = NO;
    [player setRate:currentRate];
}

- (void)rate3BtnTapped{
    [rateLabel setText:@"2.0X"];
    [rateView setHidden:YES];
    currentRate = 2.0;
    rateViewIsShowing = NO;
    [player setRate:currentRate];
}

- (void)dragSlider:(UISlider *)slider{
    [playerItem seekToTime:CMTimeMake(slider.value*10000, 10000) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
    [self startShowTimer];
    [self startUpdateTimer];
}

- (void)dragLeft{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startShowTimer];
        [self startUpdateTimer];
        [playerItem seekToTime:CMTimeMake(doubleSlider.leftValue*10000, 10000) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
    });
}

- (void)dragRight{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startShowTimer];
        [self startUpdateTimer];
        [playerItem seekToTime:CMTimeMake(doubleSlider.rightValue*10000, 10000) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
    });
}

#pragma mark - event
- (void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
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

- (void)saveVideoWithUpload:(BOOL)isNeededUpload completion:(void (^)(void))completionBlock{
    if (isCutting){
        //保存所选的部分
        [[ZHFileManager sharedManager] cutVideo:videoURL withStartTime:doubleSlider.leftValue endTime:doubleSlider.rightValue remindView:nil angle:angle completion:^(NSURL *desURL){
            NSLog(@"new video %@", desURL);
            [[ZHFileManager sharedManager] deleteTmpVideo];
            completionBlock();
        }];
    }else{
        //保存整段视频
        [[ZHFileManager sharedManager] copyVideo:videoURL withAngle:angle completion:^(NSURL *desURL){
            NSLog(@"new video %@", desURL);
            [[ZHFileManager sharedManager] deleteTmpVideo];
            completionBlock();
        }];
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
    [bottomView setHidden:NO];
    barIsShowing = YES;
    __weak typeof(self) weakSelf = self;
    showTimer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:NO block:^(NSTimer *timer){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->topView setHidden:YES];
        [strongSelf->bottomView setHidden:YES];
        [strongSelf->optionView setHidden:YES];
        strongSelf->menuIsShowing = NO;
        strongSelf->barIsShowing = NO;
    }];
}

- (void)viewTapped{
    if (barIsShowing){
        [self middleBtnTapped];
    }
    [self startShowTimer];
    if (rateViewIsShowing){
        rateViewIsShowing = NO;
        [rateView setHidden:YES];
    }
}

- (void)replay{
    if (isCutting){
        [playerItem seekToTime:CMTimeMake(doubleSlider.leftValue*10000, 10000) toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
    }else{
        [playerItem seekToTime:kCMTimeZero toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:nil];
    }
    [player play];
    [player setRate:currentRate];
}

#pragma mark - outlet
- (void)outletConfig{
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    
    topView = [[UIView alloc] init];
    [topView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"left_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventAllTouchEvents];
    
    rateLabel = [[UILabel alloc] init];
    [rateLabel setText:@"1.0X"];
    [rateLabel setFont:[UIFont boldSystemFontOfSize:19]];
    [rateLabel setTextColor:[UIColor whiteColor]];
    [rateLabel setTextAlignment:NSTextAlignmentCenter];
    
    optionBtn = [[UIButton alloc] init];
    [optionBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [optionBtn addTarget:self action:@selector(optionBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    optionView = [[UIView alloc] init];
    //[optionView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [optionView setBackgroundColor:[UIColor redColor]];
    [optionView setHidden:YES];
    [optionView setUserInteractionEnabled:YES];
    
    cutBtn = [[UIButton alloc] init];
    [cutBtn setTitle:@"剪 裁" forState:UIControlStateNormal];
    [cutBtn addTarget:self action:@selector(cutBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rateBtn = [[UIButton alloc] init];
    [rateBtn setTitle:@"倍 速" forState:UIControlStateNormal];
    [rateBtn addTarget:self action:@selector(rateBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rateView = [[UIView alloc] init];
    [rateView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    [rateView setHidden:YES];
    
    rate0Btn = [[UIButton alloc] init];
    [rate0Btn setTitle:@"0.5X" forState:UIControlStateNormal];
    [rate0Btn addTarget:self action:@selector(rate0BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rate1Btn = [[UIButton alloc] init];
    [rate1Btn setTitle:@"0.75X" forState:UIControlStateNormal];
    [rate1Btn addTarget:self action:@selector(rate1BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rate2Btn = [[UIButton alloc] init];
    [rate2Btn setTitle:@"1.0X" forState:UIControlStateNormal];
    [rate2Btn addTarget:self action:@selector(rate2BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rate3Btn = [[UIButton alloc] init];
    [rate3Btn setTitle:@"2.0X" forState:UIControlStateNormal];
    [rate3Btn addTarget:self action:@selector(rate3BtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    bottomView = [[UIView alloc] init];
    [bottomView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    
    leftBtn = [[UIButton alloc] init];
    [leftBtn setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn = [[UIButton alloc] init];
    [rightBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    middleBtn = [[UIButton alloc] init];
    [middleBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [middleBtn addTarget:self action:@selector(middleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
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
}

- (void)outletLayout{
    NSLog(@"&&&&&&&&&&&&&&&&%@",[NSThread currentThread]);
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.right.equalTo(self.view);
        maker.height.mas_equalTo([GlobalVar sharedInstance].kStatusBarH + 40);
    }];
    
    [topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(topView).mas_offset([GlobalVar sharedInstance].kStatusBarH);
        maker.bottom.equalTo(topView);
        maker.left.equalTo(topView).mas_offset(15);
        maker.width.mas_equalTo(40);
    }];
    
    [topView addSubview:rateLabel];
    [rateLabel mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(backBtn);
        maker.bottom.centerX.equalTo(topView);
        maker.width.mas_equalTo(60);
    }];
    
    [topView addSubview:optionBtn];
    [optionBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.bottom.width.equalTo(backBtn);
        maker.right.equalTo(topView).mas_offset(-15);
    }];
    
    [self.view addSubview:optionView];
    [optionView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(topView.mas_bottom);
        maker.right.equalTo(self.view);
        maker.width.mas_equalTo(110);
        maker.height.mas_equalTo(90);
    }];
    
    [optionView addSubview:cutBtn];
    [cutBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.right.equalTo(optionView);
        maker.height.mas_equalTo(40);
    }];
    
    [optionView addSubview:rateBtn];
    [rateBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(cutBtn.mas_bottom).mas_offset(10);
        maker.left.right.equalTo(optionView);
        maker.height.equalTo(cutBtn);
    }];
    
    [self.view addSubview:rateView];
    [rateView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(self.view);
        maker.height.mas_equalTo(230);
        maker.width.mas_offset(100);
    }];
    
    [rateView addSubview:rate0Btn];
    [rate0Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.right.equalTo(rateView);
        maker.height.mas_equalTo(50);
    }];
    
    [rateView addSubview:rate1Btn];
    [rate1Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(rate0Btn.mas_bottom).mas_offset(10);
        maker.left.height.right.equalTo(rate0Btn);
    }];
    
    [rateView addSubview:rate2Btn];
    [rate2Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(rate1Btn.mas_bottom).mas_offset(10);
        maker.left.height.right.equalTo(rate0Btn);
    }];
    
    [rateView addSubview:rate3Btn];
    [rate3Btn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(rate2Btn.mas_bottom).mas_offset(10);
        maker.left.height.right.equalTo(rate0Btn);
    }];
    
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.left.right.equalTo(self.view);
        maker.height.mas_equalTo(140);
    }];
    
    [bottomView addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(bottomView).mas_offset(15);
        maker.left.equalTo(bottomView).mas_offset(20);
        maker.right.equalTo(bottomView).mas_offset(-20);
    }];
    
    [bottomView addSubview:middleBtn];
    [middleBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(bottomView);
        maker.height.width.mas_equalTo(70);
        //maker.bottom.equalTo(bottomView).mas_offset(-15);
    }];
    
    [bottomView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.equalTo(middleBtn).mas_offset(5);
        maker.height.width.mas_equalTo(50);
        maker.left.equalTo(bottomView).offset(50);
    }];
    
    [bottomView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.height.width.equalTo(leftBtn);
        maker.right.equalTo(bottomView).mas_offset(-50);
    }];
}

- (void)sliderConfig{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    Float64 duration = CMTimeGetSeconds(asset.duration);

    [slider setMinimumValue:0];
    [slider setMaximumValue:duration];
    [slider setValue:0];
    
    [doubleSlider setMinimumValue:0];
    [doubleSlider setMaximumValue:duration];
    [doubleSlider setLeftValue:0];
    [doubleSlider setRightValue:duration];
}

@end
