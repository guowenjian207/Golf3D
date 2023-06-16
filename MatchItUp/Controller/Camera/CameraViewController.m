//
//  CameraViewController.m
//  FrameCut
//
//  Created by 安子和 on 2021/1/5.
//

#import "CameraViewController.h"
#import "ScrollPlayerViewController.h"
#import "ZHVoiceControlManager.h"
#import "ZHPopupViewManager.h"
#import <CoreMotion/CoreMotion.h>
#import "protractorView.h"
#import "CoreLocation/CLLocationManagerDelegate.h"
#import "CoreLocation/CLHeading.h"
#import "ZHVideoModel.h"
#import "VideoAnalysisViewController.h"
#import "CountDownView.h"
#import "AlbumViewController.h"

typedef NS_OPTIONS(NSUInteger, RecordModal){
    VoiceControll = 1,      //声控录制
    Manual        = 1 << 1, //手动录制
    Auto          = 1 << 2  //声控录制
};

@interface CameraViewController () <ZHVoiceControlManagerDelegate, CLLocationManagerDelegate, protractorViewDelegate>
{
    //VideoCapture
    ZHVideoCapture *videoCapture;
    BOOL isRecording;
    
    //语音控制
    ZHVoiceControlManager *voiceControlManager;
    
    //自动录制
    BOOL isFront;
    
    //录制时常
    NSTimer *durationTimer;
    int count_cs;
    NSRunLoop *runLoop;
    
    dispatch_queue_t cameraQueue;
    RecordModal currentRecordModal;
    
    //是否处于声控模式
    BOOL isVoiceRecording;
    
//    myProtractorView *protractorView;
//    dispatch_group_t dispatchGroup;
//    double r1, r, kesai1, kesai;
    
    UIView *horizontalAngleView;
    CALayer *cameraBackLayer;
    CAShapeLayer *chestHeightLayer;
    CMMotionManager *motionManager;
    CLLocationManager *locationManager;
    CGFloat originAngle;
    BOOL needsUpdateOriginAngle;
    BOOL shouldUpdatePratractor;
    CountDownView *processView;
    CountDownView *trackView;
}

//顶部视图
@property(nonatomic,strong) UIView *topView;
//返回按键
@property(nonatomic,strong) UIButton *backBtn;
//录制时常
@property(nonatomic,strong) UILabel *durationLabel;
//辅助拍摄提示
@property(nonatomic,strong) UILabel *remindLabel;
//录制按键
@property(nonatomic,strong) UIButton *recordBtn;
//底部视图
@property(nonatomic,strong) UIView *buttomView;
//声控录制按键
@property(nonatomic,strong) UIButton *voiceControllBtn;
//手动录制按键
@property(nonatomic,strong) UIButton *manualBtn;
//自动录制按键
@property(nonatomic,strong) UIButton *autoBtn;
///视频分辨率button
@property(nonatomic,strong) UIButton *videoResolutionBtn;
///视频帧率button
@property(nonatomic,strong) UIButton *videoFrameRateBtn;
//视频输出时长
@property(nonatomic,strong) UIButton *videoDurationBtn;
///录制时长button
@property(nonatomic,strong) UIButton *recordingDurationBtn;

@property(nonatomic, strong) UIButton *autoRightBtn;
@property(nonatomic, strong) UIButton *autoFrontBtn;
@property(nonatomic, strong) UIButton *playMusicBtn;
//切换拍摄模式
@property(nonatomic, strong) UIButton *switchModelBtn;
//分析相册入口
@property(nonatomic,strong) UIImageView *albumImgView;
//红色按钮时间
@property (assign, nonatomic) NSInteger time;
@property (strong, nonatomic) NSTimer *myTimer;
///自动录制最大时长
@property (nonatomic, assign) int recordingDuration;

@property (nonatomic, assign) CGFloat currentZoomFactor;
@end

@implementation CameraViewController

#pragma mark - 控制器生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cameraQueue = dispatch_queue_create("相机控制", nil);
    currentRecordModal = Manual;

    _recordingDuration = 3;
    
    [GlobalVar sharedInstance].recordingDuration = _recordingDuration;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRecordingDurationBtn) name:@"hideRecordingDurationBtn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideRecordingDurationBtn) name:@"unhideRecordingDurationBtn" object:nil];
    
    [self outletConfig];
    [self outletLayout];
    isVoiceRecording = false;
    needsUpdateOriginAngle = YES;
    shouldUpdatePratractor = NO;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomChangePinchGestureRecognizerClick:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    self.currentZoomFactor = 2;
}

- (void)zoomChangePinchGestureRecognizerClick:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat currentZoomFactor = self.currentZoomFactor * pinchGestureRecognizer.scale;
        
        [videoCapture changeFactor:currentZoomFactor];
    }
    else
    {
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
        self.currentZoomFactor = self->videoCapture.cameraInput.device.videoZoomFactor;
    }
    return YES;
}

//- (void)calculateAR:(CMAccelerometerData*)accelerometerData {
//    double rollingX = accelerometerData.acceleration.x;
//    double rollingY = accelerometerData.acceleration.y;
//    double rollingZ = accelerometerData.acceleration.z;
//    
//    dispatch_group_enter(dispatchGroup);
//    if (rollingY == 0) {
//        if (rollingX > 0.0) {
//            r1 = 0.0;
//        }
//        else {
//            r1 = 90.0;
//        }
//    }
//    else
//    {
//        r1 = atan(rollingX / rollingY) * 180 / M_PI;
//        if (rollingY > 0.0) {
//            r1 = r1 + 180.0;
//        }
//        
//    }
//    r = r1;
//    if (-45 < r && r < 45) {
//        kesai1 = atan(rollingZ / rollingY);
//    }
//    if (135 < r && r < 225) {
//        kesai1  = -atan(rollingZ / rollingY);
//    }
//    if (45 <= r && r <= 135) {
//        kesai1 = atan(rollingZ / rollingX);
//    }
//    if (-90 <= r && r <= -45) {
//        kesai1 = -atan(rollingZ / rollingX);
//    }
//    if (225 <= r && r <= 270) {
//        kesai1 = -atan(rollingZ / rollingX);
//    }
//    kesai1 = kesai1 / M_PI * 180;
//    kesai = kesai1;
//    while (kesai > 90) {
//        kesai = kesai - 180;
//    }
//    while (kesai < -90) {
//        kesai = kesai + 180;
//    }
//    
//    if(isnan(r)){
//        r = 0;
//    }
//    if(isnan(kesai)){
//        kesai = 0;
//    }
//    dispatch_group_leave(dispatchGroup);
//    
//    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
//        CATransform3D protractor_transform = CATransform3DMakeRotation((CGFloat)((self->kesai * (-1.1442) + 63.879) * M_PI / 180), 1, 0, 0);
//        self->protractorView.myProtractorLayer.transform = [self CATransform3DPerspectWithT:protractor_transform andCenter:CGPointMake(0, 0) andDisZ:200];
//    });
//}

//- (CATransform3D)CATransform3DPerspectWithT:(CATransform3D)t andCenter:(CGPoint)center andDisZ:(float)disZ {
//    return CATransform3DConcat(t, [self CATransform3DMakePerspectiveWithCenter:center andDisZ:disZ]);
//}
//
//- (CATransform3D)CATransform3DMakePerspectiveWithCenter:(CGPoint)center andDisZ:(float)disZ {
//    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
//    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
//    CATransform3D scale = CATransform3DIdentity;
//    CGFloat tmp = (CGFloat)-1.0 / disZ;
//    scale.m34 = tmp;
//    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
//}

- (void)viewWillAppear:(BOOL)animated{
    motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue*queue = [[NSOperationQueue alloc]init];
    //加速计
    if(motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 0.25;
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData*accelerometerData,NSError*error){
            if(error) {
                [self->motionManager stopAccelerometerUpdates];
                NSLog(@"error");
            }else{
                double zTheta =atan2(accelerometerData.acceleration.z,sqrtf(accelerometerData.acceleration.x*accelerometerData.acceleration.x+accelerometerData.acceleration.y*accelerometerData.acceleration.y))/M_PI*(-90.0)*2-90;
                double horizontalAngle = -zTheta;
                double differ = horizontalAngle - 90;
                if (differ < 0) {
                    differ = -differ;
                }
                differ /= 90;
                UIColor *newColor = [UIColor colorWithRed:differ green:(1 - differ) blue:0 alpha:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration: 0.25 animations: ^{
                        self->horizontalAngleView.backgroundColor = newColor;
                        [self->horizontalAngleView setCenter:CGPointMake(20, self.view.centerY - 100 + horizontalAngle / 180 * 200)];
                    } completion: nil];
                });
//                [self calculateAR:accelerometerData];
            }
        }];
    }
    // 磁力计
    if ([CLLocationManager headingAvailable]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingHeading];
    }
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    [self setupVideoCapture];
    if (isVoiceRecording) {
        [self setupVoiceControl];
        [voiceControlManager run];
    }
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    if (needsUpdateOriginAngle) {
//        needsUpdateOriginAngle = NO;
//        originAngle = newHeading.magneticHeading;
//    }
//    if (shouldUpdatePratractor) {
//        CGFloat rotationAngle = newHeading.magneticHeading - originAngle + 360;
//        rotationAngle = rotationAngle >= 360 ? rotationAngle - 360 : rotationAngle;
//        CGFloat angle_now = protractorView.layer_end_angle - rotationAngle + 360;
//        NSLog(@"%f", protractorView.layer_end_angle);
//        if (angle_now >= 360 && angle_now <= 360 + 180) {
//            angle_now-= 360;
//        }
//        if (angle_now >= 270 && angle_now < 360) {
//            angle_now = angle_now - 360;
//        }
//        CGFloat radia_now = angle_to_radia(angle_now);
//        [protractorView.myProtractorLayer redrawIncludedAngleLineFromAngle:protractorView.myProtractorLayer.startAngle toAngle:radia_now];
//    }
//}

- (void)startPan {
    shouldUpdatePratractor = NO;
}

- (void)endPan {
    shouldUpdatePratractor = YES;
    needsUpdateOriginAngle = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    shouldUpdatePratractor = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [motionManager stopAccelerometerUpdates];
    [locationManager stopUpdatingHeading];
    [durationTimer invalidate];
    durationTimer = nil;
    [self removeVideoCapture];
    if (isVoiceRecording) {
        [voiceControlManager cancel];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    voiceControlManager = NULL;
}

#pragma mark - outlet
- (void)outletConfig{
    _topView = [[UIView alloc]init];
    _topView.backgroundColor = UIColor.clearColor;
    
    _backBtn = [[UIButton alloc]init];
    [_backBtn setImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    _durationLabel = [[UILabel alloc]init];
    _durationLabel.text = @"00:00:00";
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    _durationLabel.textColor = UIColor.whiteColor;
    _durationLabel.font = [[GlobalVar sharedInstance] titleFont];
    
    //设置栏
    _videoResolutionBtn = [[UIButton alloc] init];
    //[_videoResolutionBtn setTitle:[NSString stringWithFormat:@"%dP", videoCapture.videoResolution] forState:UIControlStateNormal];
    [_videoResolutionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [_videoResolutionBtn setValue:[[GlobalVar sharedInstance] titleFont] forKeyPath:@"titleLabel.font"];
    [_videoResolutionBtn addTarget:self action:@selector(changeVideoResolution) forControlEvents:UIControlEventTouchUpInside];
    
//    _videoFrameRateBtn = [[UIButton alloc] init];
//    //[_videoFrameRateBtn setTitle:[NSString stringWithFormat:@"%dFPS", videoCapture.frameRate] forState:UIControlStateNormal];
//    [_videoFrameRateBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [_videoFrameRateBtn addTarget:self action:@selector(changeVideoFrameRate) forControlEvents:UIControlEventTouchUpInside];
    
    _videoDurationBtn = [[UIButton alloc] init];
    //[_videoFrameRateBtn setTitle:[NSString stringWithFormat:@"%dFPS", videoCapture.frameRate] forState:UIControlStateNormal];
    [_videoDurationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_videoDurationBtn addTarget:self action:@selector(changeVideoDuration) forControlEvents:UIControlEventTouchUpInside];
    
    _recordingDurationBtn = [[UIButton alloc] init];
    [_recordingDurationBtn setTitle:[NSString stringWithFormat:@"%ds", _recordingDuration] forState:UIControlStateNormal];
    [_recordingDurationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_recordingDurationBtn addTarget:self action:@selector(changerecordingDuration) forControlEvents:UIControlEventTouchUpInside];
    
//    _remindLabel = [[UILabel alloc]init];
//    _remindLabel.textColor = UIColor.whiteColor;
//    //[_remindLabel setHidden:YES];
//    _remindLabel.textAlignment = NSTextAlignmentCenter;
//    _remindLabel.font = [[GlobalVar sharedInstance] titleFont];
    
    //_protractorView = [[myProtractorView alloc]init];
    
//    _recordBtn = [[UIButton alloc]init];
//    [_recordBtn setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
//    [_recordBtn addTarget:self action:@selector(recordBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _buttomView = [[UIView alloc]init];
    _buttomView.backgroundColor = UIColor.blackColor;
    
//    _voiceControllBtn = [[UIButton alloc]init];
//    [_voiceControllBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
//    [_voiceControllBtn setImage:[UIImage imageNamed:@"voiceSelected"] forState:UIControlStateSelected];
//    [_voiceControllBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    _voiceControllBtn.titleLabel.font = [GlobalVar sharedInstance].cameraBtnFont;
//    [_voiceControllBtn addTarget:self action:@selector(switchToVoiceControll) forControlEvents:UIControlEventTouchUpInside];
    _albumImgView = [[UIImageView alloc]init];
    _albumImgView.backgroundColor = UIColor.systemGray6Color;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(albumImgViewTap:)];
    self.albumImgView.userInteractionEnabled = YES;
    [self.albumImgView addGestureRecognizer:tap];

    
    _manualBtn = [[UIButton alloc]init];
    [_manualBtn setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
//    [_manualBtn setImage:[UIImage imageNamed:@"manualSelected"] forState:UIControlStateSelected];
//    [_manualBtn setTitleColor:UIColor.systemYellowColor forState:UIControlStateNormal];
//    _manualBtn.titleLabel.font = [GlobalVar sharedInstance].cameraBtnFont;
    [_manualBtn addTarget:self action:@selector(recordBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPG=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPG:)];
    [_manualBtn addGestureRecognizer:longPG];
    _manualBtn.selected = YES;
    
    _autoBtn = [[UIButton alloc]init];
    [_autoBtn setImage:[UIImage imageNamed:@"autoBtn"] forState:UIControlStateNormal];
    [_autoBtn setHidden:YES];
    
    _switchModelBtn= [[UIButton alloc] init];
    [_switchModelBtn setImage:[UIImage imageNamed:@"switchRecordModel"] forState:UIControlStateNormal];
    [_switchModelBtn addTarget:self action:@selector(switchRecordModel) forControlEvents:UIControlEventTouchUpInside];
//    [_autoBtn setImage:[UIImage imageNamed:@"autoBtnSelected"] forState:UIControlStateSelected];
//    [_autoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    _autoBtn.titleLabel.font = [GlobalVar sharedInstance].cameraBtnFont;
//    [_autoBtn addTarget:self action:@selector(switchToAuto) forControlEvents:UIControlEventTouchUpInside];
    
    _autoRightBtn = [[UIButton alloc] init];
    [_autoRightBtn setImage:[UIImage imageNamed:@"swing_right"] forState:UIControlStateNormal];
    _autoRightBtn.layer.cornerRadius = 25;
    [_autoRightBtn addTarget:self action:@selector(switchAutoToRight) forControlEvents:UIControlEventTouchUpInside];
    [_autoRightBtn setHidden:YES];
    
    _autoFrontBtn = [[UIButton alloc] init];
    [_autoFrontBtn setImage:[UIImage imageNamed:@"swing_front"] forState:UIControlStateNormal];
    _autoFrontBtn.layer.cornerRadius = 25;
    [_autoFrontBtn addTarget:self action:@selector(switchAutoToFront) forControlEvents:UIControlEventTouchUpInside];
    [_autoFrontBtn setHidden:NO];
    
    _playMusicBtn = [[UIButton alloc] init];
    [_playMusicBtn setImage:[UIImage imageNamed:@"playMusic"] forState:UIControlStateSelected];
    [_playMusicBtn setImage:[UIImage imageNamed:@"dontPlayMusic"] forState:UIControlStateNormal];
    [_playMusicBtn addTarget:self action:@selector(playMusicBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    //_playMusicBtn.backgroundColor = [UIColor whiteColor];
    [_playMusicBtn setHidden:YES];
    
    //按钮红圈
    trackView = [[CountDownView alloc]init];
    trackView.backgroundColor = [UIColor clearColor];
    trackView.flag = @"track";
    
    processView = [[CountDownView alloc]init];
    processView.backgroundColor = [UIColor clearColor];
    processView.flag = @"process";
    processView.time = 3;
    [self->processView setHidden:YES];
    [self->processView.shapeLayer removeAnimationForKey:@"strokeEndAnimation"];
//    protractorView = [[myProtractorView alloc] init];
//    protractorView.delegate = self;
//    dispatchGroup = dispatch_group_create();
    
    isFront = NO;
    
    CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
    lineLayer.frame = self.view.bounds;
    lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    [linePath moveToPoint:CGPointMake(20, self.view.centerY - 100)];
    [linePath addLineToPoint:CGPointMake(20, self.view.centerY + 100)];
    lineLayer.path = linePath.CGPath;
    [self.view.layer addSublayer:lineLayer];
    
    horizontalAngleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [horizontalAngleView setCenter:CGPointMake(20, self.view.centerY)];
    horizontalAngleView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    horizontalAngleView.layer.cornerRadius = 10;
    horizontalAngleView.layer.masksToBounds = YES;
    [self.view addSubview:horizontalAngleView];
    
    UIImageView *sunImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [sunImgView setCenter:CGPointMake(20, self.view.centerY)];
    [sunImgView setImage:[UIImage imageNamed:@"sun"]];
    [self.view addSubview:sunImgView];
}

- (void)outletLayout{
    [self.view addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.right.left.equalTo(self.view);
        maker.height.mas_equalTo(45+[GlobalVar sharedInstance].kStatusBarH);
    }];
    
    [_topView addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.bottom.equalTo(_topView).mas_offset(-5);
            maker.height.width.mas_equalTo(40);
            maker.left.equalTo(_topView).mas_offset(10);
    }];
    
    [_topView addSubview:_durationLabel];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.bottom.height.equalTo(_backBtn);
            maker.centerX.equalTo(_topView);
            maker.width.mas_equalTo(120);
    }];
    
//    [_topView addSubview:_videoFrameRateBtn];
//    [_videoFrameRateBtn mas_makeConstraints:^(MASConstraintMaker *maker){
//        maker.bottom.height.equalTo(_backBtn);
//        maker.right.equalTo(_topView).mas_offset(-10);
//        maker.width.mas_equalTo(65);
//    }];
    
    [_topView addSubview:_videoResolutionBtn];
    [_videoResolutionBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.height.equalTo(_backBtn);
        maker.right.equalTo(_topView).mas_offset(-10);
        maker.width.mas_equalTo(65);
    }];
    
    [_topView addSubview:_videoDurationBtn];
    [_videoDurationBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.height.equalTo(_backBtn);
        maker.right.mas_equalTo(_videoResolutionBtn.mas_left).mas_offset(10);
        maker.width.mas_equalTo(20);
    }];
    
    [_topView addSubview:_recordingDurationBtn];
    [_recordingDurationBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.height.equalTo(_backBtn);
        maker.left.equalTo(_backBtn.mas_right).mas_offset(10);
        maker.width.mas_equalTo(40);
    }];
    [_recordingDurationBtn setHidden:YES];
    
    [self.view addSubview:_remindLabel];
    [_remindLabel mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.centerX.centerY.width.equalTo(self.view);
            maker.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:_buttomView];
    [_buttomView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.left.right.equalTo(self.view);
        maker.height.mas_equalTo([GlobalVar sharedInstance].kTabbarH+21);
    }];
    
    [_buttomView addSubview:trackView];
    [_buttomView addSubview:processView];
    [_buttomView addSubview:_albumImgView];
    [_buttomView addSubview:_voiceControllBtn];
    [_buttomView addSubview:_manualBtn];
    [_buttomView addSubview:_autoBtn];
    [_buttomView addSubview:_switchModelBtn];
    
    [self.view addSubview:_autoFrontBtn];
    [self.view addSubview:_autoRightBtn];
    [_buttomView addSubview:_playMusicBtn];
    [_autoRightBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.mas_equalTo(_topView.mas_bottom).offset(30);
        maker.height.width.mas_equalTo(55);
        maker.centerX.equalTo(self.view);
    }];
//    [_voiceControllBtn mas_makeConstraints:^(MASConstraintMaker *maker){
//        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
//        maker.centerX.equalTo(_buttomView).multipliedBy(0.5);
//        maker.centerY.equalTo(_buttomView);
//    }];
    [_albumImgView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
        maker.centerX.equalTo(_buttomView).multipliedBy(0.3);
        maker.centerY.equalTo(_buttomView);
    }];
    [_manualBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 25);
        maker.center.equalTo(_buttomView);
    }];
    [_autoBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 25);
        maker.center.equalTo(_buttomView);
    }];
    [_switchModelBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
        maker.centerX.equalTo(_buttomView).multipliedBy(1.7);
        maker.centerY.equalTo(_buttomView);
    }];
    [_autoFrontBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.mas_equalTo(_topView.mas_bottom).offset(30);
        maker.height.width.mas_equalTo(55);
        maker.centerX.equalTo(self.view);
    }];
    [_playMusicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.top.right.equalTo(_buttomView);
    }];
    [trackView mas_makeConstraints:^(MASConstraintMaker *maker) {
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
        maker.center.equalTo(_buttomView);
    }];
    [processView mas_makeConstraints:^(MASConstraintMaker *maker) {
        maker.height.width.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
        maker.center.equalTo(_buttomView);
    }];
    [self.view addSubview:_recordBtn];
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.bottom.equalTo(_buttomView.mas_top).mas_offset(-5);
        maker.centerX.equalTo(self.view);
        maker.height.width.mas_equalTo(50);
    }];
    
//    [self.view addSubview:protractorView];
////    protractorView.transform = CGAffineTransformMakeRotation(180 * M_PI / 180.0);
//    [protractorView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.view);
//            make.bottom.mas_equalTo(self.recordBtn.mas_top).offset(-30);
//            make.width.equalTo(self.view);
//            make.height.equalTo(self.view).multipliedBy(0.25);
//    }];
//    [protractorView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.view);
//            make.bottom.mas_equalTo(self.recordBtn.top).offset(-30);
//            make.width.equalTo(self.view);
//            make.height.equalTo(self.view).multipliedBy(0.25);
//    }];
}

#pragma mark - event
- (void)back{
    if (isRecording) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] init];
        hud.mode = MBProgressHUDModeText;
        [self.view addSubview:hud];
        [hud mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_offset(150);
                make.height.mas_equalTo(80);
                make.center.equalTo(self.view);
        }];
        [hud showAnimated:YES];
        hud.label.text = @"请结束录制后再退出相机";
        [hud hideAnimated:YES afterDelay:1];
        return;
    }
    AlbumViewController *vc = [[AlbumViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)albumImgViewTap:(UITapGestureRecognizer *)tap {
    NSLog(@"用户点击了图片事件");
    //下面是跳转页面
    VideoAnalysisViewController *vc = nil;
    vc = [VideoAnalysisViewController playerViewControllerWithAssets:[[[ZHVideoModel alloc] initWithAnalysisVideos:[[CoreDataManager sharedManager] getAnalysisVideo]].assets mutableCopy]];
    vc.type = ScrollPlayerTypeLocal;
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    vc.currentIndex = 0;
    [self.navigationController pushViewController:vc animated:NO];
}
- (void)recordBtnTapped{
    dispatch_async(cameraQueue, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self->_recordBtn setEnabled:NO];
        });
        if (self->isRecording){
            [self endRecord];
        }else{
            [self startRecord];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self->_recordBtn setEnabled:YES];
        });
    });
}
-(void)longPG:(UILongPressGestureRecognizer *)pg{
    if(pg.state==UIGestureRecognizerStateBegan){
        [self startRecord];
    }else if(pg.state==UIGestureRecognizerStateEnded){
        [self endRecord];
    }
}
/**
 * @brief 切换至声控录制
 */
- (void)switchToVoiceControll{
    if (currentRecordModal==VoiceControll){
        return;
    }
    _manualBtn.selected = NO;
    _autoBtn.selected = NO;
    _voiceControllBtn.selected = YES;
    if (isRecording){
        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"Please end the recording before switching the recording mode" icon:NULL autoHideAfterDelayIfNeed:@1.5];
        return;
    }
    
    isVoiceRecording = true;
    [self setupVoiceControl];
    [voiceControlManager run];
    
    if (currentRecordModal == Manual){
        [_manualBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_recordBtn setHidden:YES];
    }else{
        [_recordingDurationBtn setHidden:YES];
        videoCapture.isAuto = NO;
        [_autoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _durationLabel.text = @"00:00:00";
        [_autoRightBtn setHidden:YES];
        [_autoFrontBtn setHidden:YES];
        [_playMusicBtn setHidden:YES];
        if (isFront){
            [videoCapture switchToFront];
        }else{
            [videoCapture switchToRigth];
        }
    }
    currentRecordModal = VoiceControll;
    [_voiceControllBtn setTitleColor:UIColor.systemYellowColor forState:UIControlStateNormal];
}

/**
 * @brief 切换至手动录制
 */
- (void)switchToManual{
    if (currentRecordModal==Manual){
        return;
    }
//    _manualBtn.selected = YES;
//    _autoBtn.selected = NO;
//    _voiceControllBtn.selected = NO;
    NSLog(@"切换到手动录制");
    if (isRecording){
        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"Please end the recording before switching the recording mode" icon:NULL autoHideAfterDelayIfNeed:@1.5];
        return;
    }
    
    isVoiceRecording = false;
    [voiceControlManager cancel];
    [videoCapture autoRecordCancel];
    
    if (currentRecordModal == Auto){
        videoCapture.isAuto = NO;
        [_autoRightBtn setHidden:YES];
        [_autoFrontBtn setHidden:NO];
        [_playMusicBtn setHidden:YES];
        [_autoBtn setHidden:YES];
        [_manualBtn setHidden:NO];
        [_recordingDurationBtn setHidden:YES];
        [_autoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _durationLabel.text = @"00:00:00";
        if (isFront){
            [videoCapture switchToFront];
        }else{
            [videoCapture switchToRigth];
        }
    }else{
        [_voiceControllBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    [self->processView setHidden:YES];
    currentRecordModal = Manual;
    [_recordBtn setHidden:NO];
    [_manualBtn setTitleColor:UIColor.systemYellowColor forState:UIControlStateNormal];
}

/**
 * @brief 切换至自动录制
 */
- (void)switchToAuto{
    if (currentRecordModal == Auto){
        return;
    }
    _manualBtn.selected = NO;
    _autoBtn.selected = YES;
    _voiceControllBtn.selected = NO;
    if (isRecording){
        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"Please end the recording before switching the recording mode" icon:NULL autoHideAfterDelayIfNeed:@1.5];
        return;
    }
    
    isVoiceRecording = false;
    [voiceControlManager cancel];
    
    [_recordingDurationBtn setHidden:NO];
    [_autoRightBtn setHidden:YES];
    [_autoFrontBtn setHidden:NO];
    [_playMusicBtn setHidden:NO];
    [_manualBtn setHidden:YES];
    [_autoBtn setHidden:NO];
    
    if (currentRecordModal == Manual){
        [_manualBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_recordBtn setHidden:YES];
    }else{
        [_voiceControllBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    currentRecordModal = Auto;
    videoCapture.isAuto = YES;
    _durationLabel.text = @"";
    [_autoBtn setTitleColor:UIColor.systemYellowColor forState:UIControlStateNormal];
}
/**
 * @brief 录制模式切换
 */
-(void)switchRecordModel{
    if(currentRecordModal==Manual){
        [self switchToAuto];
    }else if (currentRecordModal==Auto){
        [self switchToManual];
    }
}
- (void)switchAutoToRight{
    isFront = NO;
    [_autoRightBtn setHidden:YES];
    [_autoFrontBtn setHidden:NO];
    [videoCapture switchToRigth];
}

- (void)switchAutoToFront{
    isFront = YES;
    [_autoRightBtn setHidden:NO];
    [_autoFrontBtn setHidden:YES];
    [videoCapture switchToFront];
}

- (void)durationTimerUpdate{
    self->count_cs++;
    if (self->count_cs >= 6000){
        int mins = self->count_cs/6000;
        int secs = self->count_cs/100%60;
        int css = self->count_cs%100;
        self->_durationLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",mins,secs,css];
    }else{
        int secs = self->count_cs/100%60;
        int css = self->count_cs%100;
        self->_durationLabel.text = [NSString stringWithFormat:@"00:%02d:%02d",secs,css];
    }
    NSLog(@"草民啊");
}

- (void)changeVideoResolution{
    
    switch (videoCapture.videoResolution) {
        case 720:
            videoCapture.videoResolution = 1080;
            break;
        case 1080:
            videoCapture.videoResolution = 720;
        default:
            break;
    }
     
}

- (void)changeVideoFrameRate{
    switch (videoCapture.frameRate) {
        case 30:
            videoCapture.frameRate = 60;
            break;
        case 60:
            videoCapture.frameRate = 75;
            break;
        case 75:
            videoCapture.frameRate = 80;
            break;
        case 80:
            videoCapture.frameRate = 95;
            break;
        case 95:
            videoCapture.frameRate = 120;
            break;
        case 120:
            videoCapture.frameRate = 150;
            break;
        case 150:
            videoCapture.frameRate = 180;
            break;
        case 180:
            videoCapture.frameRate = 210;
            break;
        case 210:
            videoCapture.frameRate = 240;
            break;
        case 240:
            videoCapture.frameRate = 30;
            break;
        default:
            break;
    }
}
-(void) changeVideoDuration{
    switch (videoCapture.videoDuration) {
        case 2:
            videoCapture.videoDuration=3;
            processView.time=3;
            break;
        case 3:
            videoCapture.videoDuration=2;
            processView.time=2;
            break;
        default:
            break;
    }
}
#pragma mark - VideoCapture

- (void)setupVideoCapture{
    if (currentRecordModal == Auto){
        [_durationLabel setText:@""];
    }else{
        [_durationLabel setText:@"00:00:00"];
    }
    videoCapture = [[ZHVideoCapture alloc] initWithDelegate:self];
    [videoCapture setFrameRate:240];
    [videoCapture setVideoResolution:1080];
    [videoCapture setVideoDuration:3];
    if (currentRecordModal == Auto){
        videoCapture.isAuto = YES;
    }
    if (isFront){
        [videoCapture switchToFront];
    }else{
        [videoCapture switchToRigth];
    }
    //[self.view.layer addSublayer:videoCapture.videoPreviewLayer];
    videoCapture.videoPreviewLayer.frame = self.view.frame;
    cameraBackLayer = [[CALayer alloc] init];
    cameraBackLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor;
    cameraBackLayer.frame = videoCapture.videoPreviewLayer.frame;
    [videoCapture.videoPreviewLayer addSublayer:cameraBackLayer];
    [self.view insertSubview:videoCapture.personView atIndex:0];
    [self.view.layer insertSublayer:videoCapture.videoPreviewLayer atIndex:0];
    [videoCapture.personView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRect:videoCapture.personView.frame] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [cameraBackLayer setMask:shapeLayer];
    
    [chestHeightLayer removeFromSuperlayer];
    chestHeightLayer = [[CAShapeLayer alloc] init];
    chestHeightLayer.frame = videoCapture.personView.frame;
    chestHeightLayer.backgroundColor = [UIColor clearColor].CGColor;
    UIBezierPath *chestPath = [[UIBezierPath alloc] init];
    [chestPath moveToPoint:CGPointMake(0, chestHeightLayer.frame.size.height / 4)];
    [chestPath addLineToPoint:CGPointMake(chestHeightLayer.frame.size.width, chestHeightLayer.frame.size.height / 4)];
    chestHeightLayer.path            = chestPath.CGPath;
    chestHeightLayer.lineWidth       = 5.0f;
    chestHeightLayer.lineDashPattern = @[@4, @4];
    chestHeightLayer.fillColor       = [UIColor clearColor].CGColor;
    chestHeightLayer.strokeColor     = [UIColor orangeColor].CGColor;
    [videoCapture.videoPreviewLayer addSublayer:chestHeightLayer];
}

- (void)removeVideoCapture{
    [videoCapture.personView removeFromSuperview];
    [videoCapture.videoPreviewLayer removeFromSuperlayer];
    [videoCapture.detectTimer invalidate];
    videoCapture = nil;
}

- (void)startRecord{
    
    if (isRecording) {
        return;
    }
    
    count_cs = 0;
    self->isRecording = YES;
    [self hideVideoBtns];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_recordBtn setImage:[UIImage imageNamed:@"endRecord"] forState:UIControlStateNormal];
        self->durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer *timer){
            self->count_cs++;
            if (self->count_cs >= 6000){
                int mins = self->count_cs/6000;
                int secs = self->count_cs/100%60;
                int css = self->count_cs%100;
                self->_durationLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",mins,secs,css];
            }else{
                int secs = self->count_cs/100%60;
                int css = self->count_cs%100;
                self->_durationLabel.text = [NSString stringWithFormat:@"00:%02d:%02d",secs,css];
            }
        }];
        [self->processView setHidden:NO];
        [self->processView addAmation];
    });
    [videoCapture startRecord];
}

- (void)endRecord{
    
    if (!isRecording) {
        return;
    }
    
    self->isRecording = NO;
    [self unhideVideoBtns];
    [videoCapture endRecord];
    [durationTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_recordBtn setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
        [self->processView setHidden:YES];
        [self->processView.shapeLayer removeAllAnimations];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        self->_durationLabel.text = @"00:00:00";
    });
}

- (void)goToPlayWithIsCutted:(BOOL)isCutted {
    dispatch_async(dispatch_get_main_queue(), ^(void){
//        RealtimePlayerViewController *realtimePlayerVC = [[RealtimePlayerViewController alloc]init];
//        realtimePlayerVC.isCutted = isCutted;
//        realtimePlayerVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:realtimePlayerVC animated:true completion:nil];
        
        NSURL *videoURL = [NSURL fileURLWithPath: isCutted ? GlobalVar.sharedInstance.tmpNewVideoPath : GlobalVar.sharedInstance.tmpVideoPath];
        
        ZHVideoAsset *asset = [[ZHVideoAsset alloc] initWithLocalURL:videoURL andIsFront:!(self->isFront)];
        ScrollPlayerViewController *playerVC = [ScrollPlayerViewController playerViewControllerWithAssets:[@[asset] mutableCopy]];
        playerVC.type = ScrollPlayerTypeSingle;
        playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        playerVC.hidesBottomBarWhenPushed = YES;
        playerVC.isFront = !(self->isFront);
        [self.navigationController pushViewController:playerVC animated:YES];
    });
}

- (void)playMusic {
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.hyk.CardGame"] pathForResource:@"autoRecordEnd" ofType:@"mp3"];
    NSLog(@"声音");
    if (path) {
        SystemSoundID theSoundID;
        OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
        if (error == kAudioServicesNoError) {
            AudioServicesPlaySystemSound(theSoundID);
        }
        else
        {
            NSLog(@"Failed to create sound ");
        }
    }
}

- (void)playMusicBtnTapped {
    self.playMusicBtn.selected = !self.playMusicBtn.selected;
}

- (void)setAutoRecordLabel:(NSString *)str{
    if (currentRecordModal != Auto) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_durationLabel.text = str;
    });
}
- (void)addAmation{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->processView setHidden:NO];
        [self->processView addAmation];
    });
}
- (void)autoRecordEnd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playMusicBtn.isSelected) {
            [self playMusic];
        }
        [self->processView setHidden:YES];
        [self->processView.shapeLayer removeAllAnimations];
    });
}

- (void)setRemindLabel:(NSString *)str andOrientation:(UIDeviceOrientation)orientation{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_remindLabel.text = str;
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            self->_remindLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else if (orientation == UIDeviceOrientationLandscapeRight) {
            self->_remindLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            self->_remindLabel.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else {
            self->_remindLabel.transform = CGAffineTransformMakeRotation(0);
        }
    });
}

- (void)videoCaptureFrameRateChanged{
    [_videoFrameRateBtn setTitle:[NSString stringWithFormat:@"%dFPS", videoCapture.frameRate] forState:UIControlStateNormal];
}

- (void)videoCaptureVideoResolutionChanged{
    [_videoResolutionBtn setTitle:[NSString stringWithFormat:@"%dP", videoCapture.videoResolution] forState:UIControlStateNormal];
}
- (void)viderCaptureVideoDurationChanged{
    [_videoDurationBtn setTitle:[NSString stringWithFormat:@"%ds", videoCapture.videoDuration] forState:UIControlStateNormal];
}
- (void)changerecordingDuration{
    if (_recordingDuration == 15) {
        _recordingDuration = 20;
    }
    else {
        _recordingDuration = 15;
    }
    [_recordingDurationBtn setTitle:[NSString stringWithFormat:@"%ds", _recordingDuration] forState:UIControlStateNormal];
    [GlobalVar sharedInstance].recordingDuration = _recordingDuration;
}

- (void)hideVideoBtns {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoResolutionBtn.hidden = true;
        self.videoFrameRateBtn.hidden = true;
        self.videoDurationBtn.hidden = true;
    });
}

- (void)unhideVideoBtns {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoResolutionBtn.hidden = false;
        self.videoFrameRateBtn.hidden = false;
        self.videoDurationBtn.hidden = false;
    });
}

- (void)hideRecordingDurationBtn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_autoFrontBtn setEnabled:NO];
        [self->_autoRightBtn setEnabled:NO];
        self->isRecording = YES;
        self.recordingDurationBtn.hidden = true;
        [self hideVideoBtns];
    });
}

- (void)unhideRecordingDurationBtn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_autoFrontBtn setEnabled:YES];
        [self->_autoRightBtn setEnabled:YES];
        self->isRecording = NO;
        self.recordingDurationBtn.hidden = false;
        [self unhideVideoBtns];
    });
}

//MARK: - voice control
- (void)setupVoiceControl {
    voiceControlManager = [[ZHVoiceControlManager alloc] init];
    voiceControlManager.delegate = self;
}

@end
