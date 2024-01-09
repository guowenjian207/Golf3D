//
//  ZHVideoCapture.m
//  FrameCut
//
//  Created by 安子和 on 2021/1/5.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "ZHVideoCapture.h"
#import <Photos/Photos.h>
@implementation ZHVideoCapture
{
    //视频捕获
    AVCaptureSession *captureSession;
    AVCaptureDevice *cameraDevice;
//    AVCaptureDeviceInput *cameraInput;
    AVCaptureVideoDataOutput *cameraOutput;
    dispatch_queue_t videoCaptureQueue;
    
    //文件生成
    AVAssetWriter *assetWriter;
    AVAssetWriterInput *writerInput;
    
    AVAssetWriter *assetWriter2;
    AVAssetWriterInput *writerInput2;
    //录制控制
    BOOL isRecording;
    
    //人体预测
    HumanBodyPoseDetector *humanDetector;
    //检测人30FPS
    int flagOfHumanDetect;
    int indexOfHumanDetect;
    
    int32_t _framePerSecond;
    int32_t _videoResolutionHeight;
    int32_t _videoDuration;
    
    NSMutableArray *_previousSecondTimestamps;
    BOOL flag;
    NSMutableArray *frameRateArray;
    int currentUrl;
    NSString *tmpVideoPath;
    NSString *willVideoPath;
    //时间片检测humanbox
    BOOL isDetect;
//    NSTimer *detectTimer;
    dispatch_queue_t myGCDTimerQueue;
    CIContext *context;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ZHVideoCaptureDelegate>)delegate{
    self = [super init];
    if (self){
        self.delegate = delegate;
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    writerInput = nil;
    assetWriter = nil;
    [captureSession stopRunning];
    cameraDevice = nil;
    captureSession = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

/**
 * @brief 配置相机
 */
- (void)setup{
    NSLog(@"创建屏幕旋转监听");
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    UIDevice *device = [UIDevice currentDevice];                    //Get the device object
    [device beginGeneratingDeviceOrientationNotifications];            //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];    //Get the notification centre for the app
    [nc addObserver:self                                            //Add yourself as an observer
          selector:@selector(orientationChanged:)
              name:UIDeviceOrientationDidChangeNotification
            object:device];
    
    captureSession = [[AVCaptureSession alloc]init];
    //开始配置会话
    [captureSession beginConfiguration];
    //选择视频质量
//    captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    //选择镜头
//    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//    for (AVCaptureDevice *device in [discoverySession devices]){
//        cameraDevice = device;
//    }
    [self getTheAVCaptureDevice];
//    cameraDevice.videoZoomFactor = 1;
    
    NSError *err;
    
    //添加相机输入
    _cameraInput = [[AVCaptureDeviceInput alloc]initWithDevice:cameraDevice error:&err];
    if (err!=nil){
        NSLog(@"获取镜头输入失败：%@",err.localizedDescription);
        return;
    }
    if ([captureSession canAddInput:_cameraInput]){
        [captureSession addInput:_cameraInput];
    }else{
        NSLog(@"添加相机输入失败");
    }
    
    //预览层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //相机队列
    videoCaptureQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    
    //添加相机输出
    cameraOutput = [[AVCaptureVideoDataOutput alloc]init];
    cameraOutput.alwaysDiscardsLateVideoFrames = NO;
    cameraOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]};
    [cameraOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
    if ([captureSession canAddOutput:cameraOutput]){
        [captureSession addOutput:cameraOutput];
    }else{
        NSLog(@"添加相机输出失败");
    }
    
    //设置视频防抖
    AVCaptureConnection *connection = [cameraOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoStabilizationSupported]) {
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    }

    //设置视频方向
    //connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"home在右方");
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"home在左方");
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"屏幕反着");
        connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    else {
        NSLog(@"屏幕正着");
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    //设置视频参数
    _framePerSecond = 240;
    self.videoResolution = 1080;
    _videoDuration=3;
//    for (AVCaptureDeviceFormat *format in cameraDevice.formats){
//        CMVideoDimensions dimensions =  CMVideoFormatDescriptionGetDimensions(format.formatDescription);
//        NSArray<AVFrameRateRange *> *ranges = format.videoSupportedFrameRateRanges;
//        //full range 420f
//        BOOL is420f = (CMFormatDescriptionGetMediaSubType(format.formatDescription)==875704422);
//        if (ranges.firstObject && ranges.firstObject.maxFrameRate > 240.0 && dimensions.height == _videoResolutionHeight && is420f){
//            [cameraDevice lockForConfiguration:&err];
//            if (err!=nil){
//                NSLog(@"配置相机是失败：%@",err.localizedDescription);
//                return;
//            }
//            cameraDevice.activeFormat = format;
//            cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, _framePerSecond);
//            cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, _framePerSecond);
//            [cameraDevice unlockForConfiguration];
//            break;
//        }
//    }
    
//    NSLog(@"%@",cameraDevice.activeFormat);
//    NSLog(@"%d%d",CMVideoFormatDescriptionGetDimensions(cameraDevice.activeFormat.formatDescription).height,CMVideoFormatDescriptionGetDimensions(cameraDevice.activeFormat.formatDescription).width);
    
    //人体
    humanDetector = [[HumanBodyPoseDetector alloc]init];
    humanDetector.delegate = self;
    _personView = [[UIView alloc]init];
//    _personView.layer.borderColor = UIColor.redColor.CGColor;
    _personView.layer.borderWidth = 2;
    indexOfHumanDetect = 0;
    flagOfHumanDetect = 1;
    _previousSecondTimestamps = [[NSMutableArray alloc] init];
    
    currentUrl=1;
    //完成配置并启动
    [captureSession commitConfiguration];
    [captureSession startRunning];
    frameRateArray = [NSMutableArray arrayWithCapacity:10];
    flag=NO;
    isDetect=YES;
    if (@available(iOS 10.0, *)) {
        _detectTimer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull detectTimer) {
//            if(self->isDetect){
//                self->isDetect=NO;
//            }else{
//                self->isDetect=YES;
//            }
                self->flag=YES;
//            NSLog(@"和姐夫和姐夫和姐夫交话费姐夫家%@",isDetect?@"YES":@"NO");
        }];
    }
}

//最小缩放值
- (CGFloat)minZoomFactor
{
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = cameraDevice.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}
 
//最大缩放值
- (CGFloat)maxZoomFactor
{
    CGFloat maxZoomFactor = cameraDevice.activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = cameraDevice.maxAvailableVideoZoomFactor;
    }
    
//    if (maxZoomFactor > 6.0) {
//        maxZoomFactor = 6.0;
//    }
    return maxZoomFactor;
}
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
//        self.currentZoomFactor = self.device.videoZoomFactor;
//    }
//    return YES;
//}

-(void) changeFactor:(CGFloat)currentZoomFactor{
    if (currentZoomFactor < self.maxZoomFactor &&
        currentZoomFactor >= self.minZoomFactor){
        
        NSError *error = nil;
        if ([cameraDevice lockForConfiguration:&error] ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [cameraDevice rampToVideoZoomFactor:currentZoomFactor withRate:3];//rate越大，动画越慢
//                self.device.videoZoomFactor = currentZoomFactor;//无动画
            NSLog(@"currentZoomFactor:%f",currentZoomFactor);
                [cameraDevice unlockForConfiguration];
//            });
 
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

- (void)getTheAVCaptureDevice
{
    if (@available(iOS 10.2, *)) {
        
        NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera,AVCaptureDeviceTypeBuiltInUltraWideCamera,AVCaptureDeviceTypeBuiltInDualWideCamera];//设备类型：广角镜头、双镜头,超广角
        AVCaptureDeviceDiscoverySession *sessionDiscovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        NSArray<AVCaptureDevice *> *devices = sessionDiscovery.devices;//当前可用的AVCaptureDevice集合
        __block AVCaptureDevice *newVideoDevice = nil;
        //遍历所有可用的AVCaptureDevice，获取 后置双镜头
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( device.position == AVCaptureDevicePositionBack && [device.deviceType isEqualToString:AVCaptureDeviceTypeBuiltInWideAngleCamera] ) {
                newVideoDevice = device;
                * stop = YES;
            }
        }];
        
        if (!newVideoDevice){
            //如果后置双镜头获取失败，则获取广角镜头
            [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
                if ( device.position == AVCaptureDevicePositionBack) {
                    newVideoDevice = device;
                    * stop = YES;
                }
            }];
        }
        cameraDevice = newVideoDevice;
        
    } else {
        
        //获取指定mediaType类型的AVCaptureDevice集合
        NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        __block AVCaptureDevice *newVideoDevice = nil;
        //遍历所有可用的AVCaptureDevice，获取后置镜头
        [devices enumerateObjectsUsingBlock:^(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( device.position == AVCaptureDevicePositionBack) {
                newVideoDevice = device;
                * stop = YES;
            }
        }];
        cameraDevice = newVideoDevice;
    }
    NSError *error = nil;
    if ([cameraDevice lockForConfiguration:&error] ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            [cameraDevice rampToVideoZoomFactor:currentZoomFactor withRate:3];//rate越大，动画越慢
        cameraDevice.videoZoomFactor = 2;//无动画
//        NSLog(@"currentZoomFactor:%f",currentZoomFactor);
            [cameraDevice unlockForConfiguration];
//            });

    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

-(void)isDeyectChange{
    if(isDetect){
        isDetect=NO;
    }else{
        isDetect=YES;
    }
    NSLog(@"和姐夫和姐夫和姐夫交话费姐夫家%@",isDetect?@"YES":@"NO");
}

//********** ORIENTATION CHANGED **********
- (void)orientationChanged:(NSNotification *)note
{
    AVCaptureConnection *connection = [cameraOutput connectionWithMediaType:AVMediaTypeVideo];

    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"home在右方");
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"home在左方");
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"屏幕反着");
        connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    else {
        NSLog(@"屏幕正着");
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

/**
 * @brief 开始录制
 */
- (void)startRecord{
    isRecording = YES;
    NSError *err;
    NSString *tmpVideoPath = [GlobalVar sharedInstance].tmpVideoPath;
    if ([[NSFileManager defaultManager]fileExistsAtPath:tmpVideoPath]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpVideoPath error:&err];
        if (err != nil){
            NSLog(@"删除原临时视频文件失败:%@",err.localizedDescription);
            return;
        }
    }
    AVCaptureConnection *connection = [cameraOutput connectionWithMediaType:AVMediaTypeVideo];

    if (connection.videoOrientation == AVCaptureVideoOrientationLandscapeRight ||
        connection.videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        NSDictionary *dic = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoWidthKey:@1280,
            AVVideoHeightKey:@720
        };
        writerInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:dic];
    }
    else {
        NSDictionary *dic = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoWidthKey:@720,
            AVVideoHeightKey:@1280
        };
        writerInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:dic];
    }
    [writerInput setExpectsMediaDataInRealTime:NO];
    assetWriter = [[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:tmpVideoPath] fileType:AVFileTypeMPEG4 error:&err];
    if (err != nil){
        NSLog(@"创建assetwrier失败:%@",err.localizedDescription);
        return;
    }
    if ([assetWriter canAddInput:writerInput]){
        [assetWriter addInput:writerInput];
    }else{
        NSLog(@"assetwrier添加视频输入失败失败:%@",[assetWriter error]);
    }
}

/**
 * @brief 结束录制
 */
- (void)endRecord{
    if (assetWriter){
        isRecording = NO;
        NSLog(@"%@",frameRateArray);
        frameRateArray=nil;
        dispatch_async(videoCaptureQueue, ^(void){
            if (self->assetWriter.status == AVAssetWriterStatusWriting){
                NSLog(@"status%ld",(long)self->assetWriter.status);
                [self->writerInput markAsFinished];
                NSLog(@"status%ld",(long)self->assetWriter.status);
                [self->assetWriter finishWritingWithCompletionHandler: ^(void){
                    self->assetWriter = nil;
                    self->writerInput = nil;
                   
                    bool s= [[NSFileManager defaultManager]fileExistsAtPath:[GlobalVar sharedInstance].tmpVideoPath];
                    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
                     [photoLibrary performChanges:^{
                       // 将视频保存到相册中
                       PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpVideoPath]];
                       // 修改视频的创建时间属性
                       request.creationDate = [NSDate date];
                     } completionHandler:^(BOOL success, NSError * _Nullable error) {
                         if (success) {
                             NSLog(@"已将视频保存至相册");
                         } else {
                             NSLog(@"未能保存视频到相册");
                         }
                     
                     }];
                    AVURLAsset *tmpAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpVideoPath] options:nil];
                    NSLog(@"录制完成\n时常:%lld",tmpAsset.duration.value/tmpAsset.duration.timescale);
//                    if ([self->_delegate respondsToSelector:@selector(goToPlayWithIsCutted:)]){
//                        if (tmpAsset.duration.value/tmpAsset.duration.timescale>3){
//                            [ZHFileManager.sharedManager cutTmpVideo:_videoDuration With:^{
//                                [self->_delegate setAutoRecordLabel:@""];
//                                [self->_delegate goToPlayWithIsCutted:YES];
//                            }];
//                        }else{
//                            [self->_delegate setAutoRecordLabel:@""];
//                            [self->_delegate goToPlayWithIsCutted:NO];
//                        }
//                    }
                    if (tmpAsset.duration.value/tmpAsset.duration.timescale>3){
                        [ZHFileManager.sharedManager cutTmpVideo:_videoDuration With:^{
                            [self->_delegate setAutoRecordLabel:@""];
                            [CoreDataManager.sharedManager addAnalysisVideo:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpNewVideoPath] withisFront:YES completion:^(AnalysisVideo * _Nonnull) {
                            }];
                        }];
                    }else{
                        [self->_delegate setAutoRecordLabel:@""];
                        [CoreDataManager.sharedManager addAnalysisVideo:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpVideoPath] withisFront:YES completion:^(AnalysisVideo * _Nonnull) {
                        }];
                    }
                }];
            }
        });
    }
}
- (void)autoRecordBegin{
    NSError *err;
    switch (currentUrl) {
        case 1:
            tmpVideoPath = [GlobalVar sharedInstance].tmpVideoPath;
            currentUrl=2;
            break;
        case 2:
            tmpVideoPath = [GlobalVar sharedInstance].tmpVideoPath2;
            currentUrl=3;
            break;
        case 3:
            tmpVideoPath = [GlobalVar sharedInstance].tmpVideoPath3;
            currentUrl=1;
            break;
        default:
            break;
    }
    NSLog(@"现在Url:%@",tmpVideoPath);
    if ([[NSFileManager defaultManager]fileExistsAtPath:tmpVideoPath]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpVideoPath error:&err];
        if (err != nil){
            NSLog(@"删除原临时视频文件失败:%@",err.localizedDescription);
            return;
        }
    }
    [_delegate addAmation];
    AVCaptureConnection *connection = [cameraOutput connectionWithMediaType:AVMediaTypeVideo];

    if (connection.videoOrientation == AVCaptureVideoOrientationLandscapeRight ||
        connection.videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        NSDictionary *dic = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoWidthKey:@1280,
            AVVideoHeightKey:@720
        };
        writerInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:dic];
    }
    else {
        NSDictionary *dic = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoWidthKey:@720,
            AVVideoHeightKey:@1280
        };
        writerInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:dic];
    }
    [writerInput setExpectsMediaDataInRealTime:YES];
    assetWriter = [[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:tmpVideoPath] fileType:AVFileTypeMPEG4 error:&err];
    if (err != nil){
        NSLog(@"创建assetwrier失败:%@",err.localizedDescription);
        return;
    }
    
    if ([assetWriter canAddInput:writerInput]){
        [assetWriter addInput:writerInput];
    }else{
        NSLog(@"assetwrier添加视频输入失败失败:%@",[assetWriter error]);
    }
}

- (void)autoRecordFinishedWith:(NSTimeInterval)interval{
    [_delegate setAutoRecordLabel:@"Over"];
    _isAuto=NO;
    NSString * nowtmpVideoPath=tmpVideoPath;
    if (assetWriter){
        NSLog(@"有没有一秒");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval*700000000), videoCaptureQueue, ^{
            if (self->assetWriter.status == AVAssetWriterStatusWriting){
                NSLog(@"status%ld",(long)self->assetWriter.status);
                [self->writerInput markAsFinished];
                NSLog(@"status%ld",(long)self->assetWriter.status);
                [self->_delegate setAutoRecordLabel:@"Saving..."];
                [self->_delegate autoRecordEnd];
                [self->assetWriter finishWritingWithCompletionHandler: ^(void){
                    self->assetWriter = nil;
                    self->writerInput = nil;
                    NSArray *urls=[[NSArray alloc] initWithObjects:[NSURL fileURLWithPath:self->willVideoPath],[NSURL fileURLWithPath:nowtmpVideoPath], nil];
                    [ZHFileManager.sharedManager mergeVideosToOne:urls];
//                    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
//                     [photoLibrary performChanges:^{
//                       // 将视频保存到相册中
//                       PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpVideoPath]];
//                       // 修改视频的创建时间属性
//                       request.creationDate = [NSDate date];
//                     } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                         if (success) {
//                             NSLog(@"已将视频保存至相册");
//                         } else {
//                             NSLog(@"未能保存视频到相册");
//                         }
//
//                     }];
//                    AVURLAsset *tmpAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpmergeVideoPath] options:nil];
//                    NSLog(@"录制完成\n时常:%lld",tmpAsset.duration.value/tmpAsset.duration.timescale);
//                    if (tmpAsset.duration.value/tmpAsset.duration.timescale>3){
//                        [ZHFileManager.sharedManager cutTmpVideo:_videoDuration With:^{
//                            [self->_delegate setAutoRecordLabel:@""];
//                            [CoreDataManager.sharedManager addAnalysisVideo:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpNewVideoPath] withisFront:YES completion:^(AnalysisVideo * _Nonnull) {
//                            }];
//                        }];
//                    }else{
//                        [self->_delegate setAutoRecordLabel:@""];
//                        [CoreDataManager.sharedManager addAnalysisVideo:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpmergeVideoPath] withisFront:YES completion:^(AnalysisVideo * _Nonnull) {
//                        }];
//                    }
                    _isAuto=YES;
                }];
            }
        });
    }
}
- (void)autoRecordEndByTime{
    [_delegate setAutoRecordLabel:@"Over"];
    willVideoPath=tmpVideoPath;
    if (assetWriter){
        NSLog(@"bytime");
        if (self->assetWriter.status == AVAssetWriterStatusWriting){
            NSLog(@"status%ld",(long)self->assetWriter.status);
            [self->writerInput markAsFinished];
            NSLog(@"status%ld",(long)self->assetWriter.status);
            [self->_delegate setAutoRecordLabel:@"Saving..."];
            [self->_delegate autoRecordEnd];
            [self->assetWriter finishWritingWithCompletionHandler: ^(void){
                self->assetWriter = nil;
                self->writerInput = nil;
//                PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
//                 [photoLibrary performChanges:^{
//                   // 将视频保存到相册中
//                   PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:willVideoPath]];
//                   // 修改视频的创建时间属性
//                   request.creationDate = [NSDate date];
//                 } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                     if (success) {
//                         NSLog(@"已将视频保存至相册%@",willVideoPath);
//                     } else {
//                         NSLog(@"未能保存视频到相册");
//                     }
//                 
//                 }];
                if(_isAuto){
                    [self autoRecordBegin];
                }
            }];
        }
        dispatch_async(videoCaptureQueue, ^{
//            if (self->assetWriter.status == AVAssetWriterStatusWriting){
//                NSLog(@"status%ld",(long)self->assetWriter.status);
//                [self->writerInput markAsFinished];
//                NSLog(@"status%ld",(long)self->assetWriter.status);
//                [self->_delegate setAutoRecordLabel:@"Saving..."];
//                [self->_delegate autoRecordEnd];
//                [self->assetWriter finishWritingWithCompletionHandler: ^(void){
//                    self->assetWriter = nil;
//                    self->writerInput = nil;
//                    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
//                     [photoLibrary performChanges:^{
//                       // 将视频保存到相册中
//                       PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:willVideoPath]];
//                       // 修改视频的创建时间属性
//                       request.creationDate = [NSDate date];
//                     } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                         if (success) {
//                             NSLog(@"已将视频保存至相册%@",willVideoPath);
//                         } else {
//                             NSLog(@"未能保存视频到相册");
//                         }
//
//                     }];
//                }];
//            }
        });
    }
}
- (void)autoRecordReady{
    [_delegate setAutoRecordLabel:@"Ready"];
}

- (void)autoRecordNotReady{
    [_delegate setAutoRecordLabel:@""];
}

- (void)autoRecordWillFinish{
    [_delegate setAutoRecordLabel:@"Over"];
}

- (void)autoRecordCancel{
    [self->humanDetector cancelAutoRecord];
}

- (void)switchToFront{
    NSLog(@"咋回事");
    self->humanDetector.isFront = YES;
    dispatch_async(videoCaptureQueue, ^(void){
        NSLog(@"咋回事");
        if (self->_isAuto){
            if (self->assetWriter != nil && self->assetWriter.status == AVAssetWriterStatusWriting){
                [self->writerInput markAsFinished];

                [self->assetWriter finishWritingWithCompletionHandler: ^(void){
                    self->assetWriter = nil;
                    self->writerInput = nil;
                    
                    [self->humanDetector detectionInitialize];
                }];
            }
        }else{
            self->humanDetector.isFront = YES;
            [self->humanDetector detectionInitialize];
        }
    });
}

- (void)switchToRigth{
    self->humanDetector.isFront = NO;
    dispatch_async(videoCaptureQueue, ^(void){
        if (self->_isAuto){
            if (self->assetWriter != nil && self->assetWriter.status == AVAssetWriterStatusWriting){
                [self->writerInput markAsFinished];

                [self->assetWriter finishWritingWithCompletionHandler: ^(void){
                    self->assetWriter = nil;
                    self->writerInput = nil;
                    self->humanDetector.isFront = NO;
                    [self->humanDetector detectionInitialize];
                }];
            }
        }else{
            self->humanDetector.isFront = NO;
            [self->humanDetector detectionInitialize];
        }
    });
}

#pragma mark - set & get
- (void)setFrameRate:(int32_t)frameRate{
    AVCaptureDevice *cameraDevice = _cameraInput.device;
    AVFrameRateRange *range =  cameraDevice.activeFormat.videoSupportedFrameRateRanges.firstObject;
    if (!range || frameRate<range.minFrameRate || frameRate>range.maxFrameRate){
        return;
    }
    NSError *err = nil;
    [cameraDevice lockForConfiguration:&err];
    if (err!=nil){
        NSLog(@"配置相机是失败：%@",err.localizedDescription);
        return;
    }
    NSLog(@"最大：%d",frameRate);
    cameraDevice.activeFormat = cameraDevice.activeFormat;
    cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, frameRate);
    cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, frameRate);
    [cameraDevice unlockForConfiguration];
    _framePerSecond = frameRate;
    flagOfHumanDetect = frameRate / 30 - 1;
    if ([_delegate respondsToSelector:@selector(videoCaptureFrameRateChanged)]){
        [_delegate videoCaptureFrameRateChanged];
    }
}

- (int32_t)frameRate{
    return _framePerSecond;
}

- (void)setVideoResolution:(int32_t)videoResolution{
    if ((videoResolution != 720) && (videoResolution != 1080)){
        return;
    }
    for (AVCaptureDeviceFormat *format in cameraDevice.formats){
        CMVideoDimensions dimensions =  CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        NSArray<AVFrameRateRange *> *ranges = format.videoSupportedFrameRateRanges;
        //full range 420f
        BOOL is420f = (CMFormatDescriptionGetMediaSubType(format.formatDescription)==875704422);
        if (ranges.firstObject && ranges.firstObject.maxFrameRate > 120.0 && dimensions.height == videoResolution && is420f){
            NSLog(@"weight:%d",dimensions.width);
            NSError *err = nil;
            [cameraDevice lockForConfiguration:&err];
            if (err!=nil){
                NSLog(@"配置相机是失败：%@",err.localizedDescription);
                return;
            }
            cameraDevice.activeFormat = format;
            cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, _framePerSecond);
            cameraDevice.activeVideoMinFrameDuration = CMTimeMake(1, _framePerSecond);
            [cameraDevice unlockForConfiguration];
            _videoResolutionHeight = videoResolution;
            if ([_delegate respondsToSelector:@selector(videoCaptureVideoResolutionChanged)]){
                [_delegate videoCaptureVideoResolutionChanged];
            }
            break;
        }
    }
}

- (int32_t)videoResolution{
    return _videoResolutionHeight;
}

-(void)setVideoDuration:(int32_t)videoDuration{
    _videoDuration=videoDuration;
    if ([_delegate respondsToSelector:@selector(viderCaptureVideoDurationChanged)]){
        [_delegate viderCaptureVideoDurationChanged];
    }
}
-(int32_t)videoDuration{
    return _videoDuration;
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    //实时fps计算
    CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    [self calculateFramerateAtTimestamp:startTime];
    if (assetWriter != nil){
        if (assetWriter.status == AVAssetWriterStatusUnknown){
            NSLog(@"开始录制");
            [_delegate setAutoRecordLabel:@"Recording..."];
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [assetWriter startWriting];
            [assetWriter startSessionAtSourceTime:startTime];
        }else if (assetWriter.status == AVAssetWriterStatusFailed){
            NSLog(@"assetWriter出事了:%@",assetWriter.error.localizedDescription);
            return;
        }
        
        if (writerInput.isReadyForMoreMediaData){
            [writerInput appendSampleBuffer:sampleBuffer];
        }
    }
    
    if (flagOfHumanDetect == indexOfHumanDetect){
        NSLog(@"%d",flagOfHumanDetect);
        indexOfHumanDetect = 0;
        if(!isRecording){
            [self predictHumanBBox:sampleBuffer];
        }
        if(isDetect){
            //NSLog(@"%@",_isAuto?@"自动录制":@"不自动");
            [self->humanDetector predict:sampleBuffer isAutoRecord:_isAuto];
        }
    }else{
        indexOfHumanDetect++;
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
//    NSLog(@"丢了");
}
//- (CVPixelBufferRef)copyPixelbuffer:(CVPixelBufferRef)pixel {
//
//    NSAssert(CFGetTypeID(pixel) == CVPixelBufferGetTypeID(), @"typeid !=");
//    CVPixelBufferRef _copy = NULL;
//
//    CVPixelBufferCreate(nil, CVPixelBufferGetWidth(pixel), CVPixelBufferGetHeight(pixel), CVPixelBufferGetPixelFormatType(pixel), CVBufferGetAttachments(pixel, kCVAttachmentMode_ShouldPropagate), &_copy);
//
//    if (_copy != NULL) {
//        CVPixelBufferLockBaseAddress(pixel, kCVPixelBufferLock_ReadOnly);
//        CVPixelBufferLockBaseAddress(_copy, 0);
//        size_t count =  CVPixelBufferGetPlaneCount(pixel);
//        size_t img_widstp = CVPixelBufferGetBytesPerRowOfPlane(pixel, 0);
//        size_t img_heistp = CVPixelBufferGetBytesPerRowOfPlane(pixel, 1);
//        NSLog(@"img_widstp = %d, img_heistp = %d", img_widstp, img_heistp);
//        for (size_t plane = 0; plane < count; plane++) {
//            void *dest = CVPixelBufferGetBaseAddressOfPlane(_copy, plane);
//            void *source = CVPixelBufferGetBaseAddressOfPlane(pixel, plane);
//            size_t height = CVPixelBufferGetHeightOfPlane(pixel, plane);
//            size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixel, plane);
//
//            memcpy(dest, source, height * bytesPerRow);
//        }
//
//        CVPixelBufferUnlockBaseAddress(_copy, 0);
//        CVPixelBufferUnlockBaseAddress(pixel, kCVPixelBufferLock_ReadOnly);
//    }
//    return _copy;
//}
- (void)calculateFramerateAtTimestamp:(CMTime)timestamp
{
    [_previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
    CMTime oneSecond = CMTimeMake( 1, 1 );
    CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
    while( CMTIME_COMPARE_INLINE( [_previousSecondTimestamps[0] CMTimeValue], <, oneSecondAgo ) ) {
        [_previousSecondTimestamps removeObjectAtIndex:0];
    }
    
    if ( [_previousSecondTimestamps count] > 1 ) {
        const Float64 duration = CMTimeGetSeconds( CMTimeSubtract( [[_previousSecondTimestamps lastObject] CMTimeValue], [_previousSecondTimestamps[0] CMTimeValue] ) );
        const float newRate = (float)( [_previousSecondTimestamps count] - 1 ) / duration;
//        self.previewFrameRate = newRate;
        if(assetWriter != nil){
            if(flag){
                NSNumber *number = [NSNumber numberWithFloat:newRate];
                [frameRateArray addObject:number];
                flag=NO;
            }
        }
        NSLog(@"FrameRate - %f", newRate);
    }
}

- (CGRect)convertWithX:(float)x andY:(float)y andW:(float)w andH:(float)h {
    float xx = (kScreenW/9*16 - kScreenH)/2;
//    xx =0;
    return CGRectMake(kScreenW * x - kScreenW * w / 2, kScreenW/9*16 * y - kScreenW/9*16 * h / 2-xx, kScreenW * w, kScreenW/9*16 * h);
    
}

- (cv::Mat) matFromImageBuffer: (CVPixelBufferRef) buffer {
    cv::Mat mat ;
    CVPixelBufferLockBaseAddress(buffer, 0);
    void *address = CVPixelBufferGetBaseAddress(buffer);
    int width = (int) CVPixelBufferGetWidth(buffer);
    int height = (int) CVPixelBufferGetHeight(buffer);
    mat = cv::Mat(height, width, CV_8UC4, address, 0);
//    cv::cvtColor(mat, mat, COLOR_BGRA2BGR);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return mat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat{
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    size_t elemsize = cvMat.elemSize();
    if (elemsize == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= (elemsize == 4) ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNone;
    }
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:elemsize * cvMat.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                 // width
                                        cvMat.rows,                 // height
                                        8,                          // bits per component
                                        8 * cvMat.elemSize(),       // bits per pixel
                                        cvMat.step[0],              // bytesPerRow
                                        colorSpace,                 // colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   // CGDataProviderRef
                                        NULL,                       // decode
                                        false,                      // should interpolate
                                        kCGRenderingIntentDefault   // intent
                                        );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

void assertCropAndScaleValid(CVPixelBufferRef pixelBuffer, CGRect cropRect, CGSize scaleSize) {
    CGFloat originalWidth = (CGFloat)CVPixelBufferGetWidth(pixelBuffer);
    CGFloat originalHeight = (CGFloat)CVPixelBufferGetHeight(pixelBuffer);

    assert(CGRectContainsRect(CGRectMake(0, 0, originalWidth, originalHeight), cropRect));
    assert(scaleSize.width > 0 && scaleSize.height > 0);
}

void pixelBufferReleaseCallBack(void *releaseRefCon, const void *baseAddress) {
    if (baseAddress != NULL) {
        free((void *)baseAddress);
    }
}

// Returns a CVPixelBufferRef with +1 retain count
CVPixelBufferRef createCroppedPixelBuffer(CVPixelBufferRef sourcePixelBuffer, CGRect croppingRect, CGSize scaledSize) {

    OSType inputPixelFormat = CVPixelBufferGetPixelFormatType(sourcePixelBuffer);
    assert(inputPixelFormat == kCVPixelFormatType_32BGRA
           || inputPixelFormat == kCVPixelFormatType_32ABGR
           || inputPixelFormat == kCVPixelFormatType_32ARGB
           || inputPixelFormat == kCVPixelFormatType_32RGBA);

    assertCropAndScaleValid(sourcePixelBuffer, croppingRect, scaledSize);

    if (CVPixelBufferLockBaseAddress(sourcePixelBuffer, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess) {
        NSLog(@"Could not lock base address");
        return nil;
    }

    void *sourceData = CVPixelBufferGetBaseAddress(sourcePixelBuffer);
    if (sourceData == NULL) {
        NSLog(@"Error: could not get pixel buffer base address");
        CVPixelBufferUnlockBaseAddress(sourcePixelBuffer, kCVPixelBufferLock_ReadOnly);
        return nil;
    }

    size_t sourceBytesPerRow = CVPixelBufferGetBytesPerRow(sourcePixelBuffer);
    size_t offset = CGRectGetMinY(croppingRect) * sourceBytesPerRow + CGRectGetMinX(croppingRect) * 4;

    vImage_Buffer croppedvImageBuffer = {
        .data = ((char *)sourceData) + offset,
        .height = (vImagePixelCount)CGRectGetHeight(croppingRect),
        .width = (vImagePixelCount)CGRectGetWidth(croppingRect),
        .rowBytes = sourceBytesPerRow
    };

    size_t scaledBytesPerRow = scaledSize.width * 4;
    void *scaledData = malloc(scaledSize.height * scaledBytesPerRow);
    if (scaledData == NULL) {
        NSLog(@"Error: out of memory");
        CVPixelBufferUnlockBaseAddress(sourcePixelBuffer, kCVPixelBufferLock_ReadOnly);
        return nil;
    }

    vImage_Buffer scaledvImageBuffer = {
        .data = scaledData,
        .height = (vImagePixelCount)scaledSize.height,
        .width = (vImagePixelCount)scaledSize.width,
        .rowBytes = scaledBytesPerRow
    };

    /* The ARGB8888, ARGB16U, ARGB16S and ARGBFFFF functions work equally well on
     * other channel orderings of 4-channel images, such as RGBA or BGRA.*/
    vImage_Error error = vImageScale_ARGB8888(&croppedvImageBuffer, &scaledvImageBuffer, nil, 0);
    CVPixelBufferUnlockBaseAddress(sourcePixelBuffer, kCVPixelBufferLock_ReadOnly);

    if (error != kvImageNoError) {
        NSLog(@"Error: %ld", error);
        free(scaledData);
        return nil;
    }

    OSType pixelFormat = CVPixelBufferGetPixelFormatType(sourcePixelBuffer);
    CVPixelBufferRef outputPixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreateWithBytes(nil, scaledSize.width, scaledSize.height, pixelFormat, scaledData, scaledBytesPerRow, pixelBufferReleaseCallBack, nil, nil, &outputPixelBuffer);

    if (status != kCVReturnSuccess) {
        NSLog(@"Error: could not create new pixel buffer");
        free(scaledData);
        return nil;
    }

    return outputPixelBuffer;
}

CVPixelBufferRef createCroppedPixelBufferCoreImage(CVPixelBufferRef pixelBuffer,
                                                   CGRect cropRect,
                                                   CGSize scaleSize,
                                                   CIContext *context) {

    assertCropAndScaleValid(pixelBuffer, cropRect, scaleSize);

    CIImage *image = [CIImage imageWithCVImageBuffer:pixelBuffer];
    image = [image imageByCroppingToRect:cropRect];

    CGFloat scaleX = scaleSize.width / CGRectGetWidth(image.extent);
    CGFloat scaleY = scaleSize.height / CGRectGetHeight(image.extent);

    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];

    // Due to the way [CIContext:render:toCVPixelBuffer] works, we need to translate the image so the cropped section is at the origin
    image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(-image.extent.origin.x, -image.extent.origin.y)];

    CVPixelBufferRef output = NULL;

    CVPixelBufferCreate(nil,
                        CGRectGetWidth(image.extent),
                        CGRectGetHeight(image.extent),
                        CVPixelBufferGetPixelFormatType(pixelBuffer),
                        nil,
                        &output);

    if (output != NULL) {
        [context render:image toCVPixelBuffer:output];
    }

    return output;
}
- (CVPixelBufferRef) getImageBufferFromMat: (cv::Mat) mat {
    cv::cvtColor(mat, mat, cv::COLOR_BGR2BGRA);
    int width = mat.cols;
    int height = mat.rows;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             // [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             // [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             [NSNumber numberWithInt:width], kCVPixelBufferWidthKey,
                             [NSNumber numberWithInt:height], kCVPixelBufferHeightKey,
                             nil];
    CVPixelBufferRef imageBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorMalloc, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef) CFBridgingRetain(options), &imageBuffer) ;
    NSParameterAssert(status == kCVReturnSuccess && imageBuffer != NULL);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *base = CVPixelBufferGetBaseAddress(imageBuffer) ;
    memcpy(base, mat.data, mat.total()*4);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return imageBuffer;
}

- (void)predictHumanBBox:(CMSampleBufferRef)sampleBuffer {
//    CVPixelBufferRef pixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//    cv::Mat src = [self matFromImageBuffer:pixelBufferRef];
////    cv::Size srcSize = cv::Size(416, 416);
//    cv::Size srcSize = cv::Size(640, 640);
//    cv::Mat newSrc = cv::Mat(640,640,CV_8UC4);
//    cv::resize(src, newSrc, srcSize, 0, 0, INTER_LINEAR);
//    UIImage *iamge =[self UIImageFromCVMat:newSrc];
//    pixelBufferRef = [self getImageBufferFromMat:newSrc];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == NULL) { return; }

    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);

    CGRect videoRect = CGRectMake(0, 0, width, height);
    CGSize scaledSize = CGSizeMake(640, 640);
//    CGSize scaledSize = CGSizeMake(416, 416);

    // Create a rectangle that meets the output size's aspect ratio, centered in the original video frame
    CGRect centerCroppingRect = AVMakeRectWithAspectRatioInsideRect(scaledSize, videoRect);
    if(context == nil){
        context = [CIContext context];
    }

    pixelBuffer = createCroppedPixelBuffer(pixelBuffer, videoRect, scaledSize);
//    pixelBuffer = createCroppedPixelBufferCoreImage(pixelBuffer, centerCroppingRect, scaledSize, context);
    
//    YOLOv3Output *outPut = [GlobalVar.sharedInstance.yoloModel predictionFromImage:pixelBuffer iouThreshold:nil confidenceThreshold:@0.6 error:nil];
//    YOLOv3TinyOutput *outPut = [GlobalVar.sharedInstance.yoloModelTiny predictionFromImage:pixelBufferRef iouThreshold:nil confidenceThreshold:@0.6 error:nil];
//    yolov5sOutput *outPut = [GlobalVar.sharedInstance.yoloModelv predictionFromInput:pixelBufferRef iouThreshold:0.45 confidenceThreshold:0.6 error:nil];
//    yolov5mOutput *outPut = [GlobalVar.sharedInstance.yoloModelm predictionFromInput:pixelBufferRef iouThreshold:0.45 confidenceThreshold:0.6 error:nil];
    yolov8nOutput *outPut = [GlobalVar.sharedInstance.yoloModelv8n predictionFromImage:pixelBuffer iouThreshold:0.45 confidenceThreshold:0.6 error:nil];
//    yolov8xOutput *outPut = [GlobalVar.sharedInstance.yoloModelv8x predictionFromImage:pixelBufferRef iouThreshold:0.45 confidenceThreshold:0.6 error:nil];
//    bestOutput *outPut = [GlobalVar.sharedInstance.golfball predictionFromImage:pixelBuffer iouThreshold:0.45 confidenceThreshold:0.6 error:nil];
    
    CVPixelBufferRelease(pixelBuffer);
    // 打印输出结果
    MLMultiArray *confidence = outPut.confidence;
    MLMultiArray *coordinate = outPut.coordinates;
    
    CGRect rect = CGRectMake(0, 0, 0, 0);
    for (int i = 0; i < confidence.count/80 ; i++) {
        if (confidence[i*80].floatValue > 0.6) {
            CGRect rectTmp;
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
                rectTmp = [self convertWithX:1 - coordinate[i * 4 + 1].floatValue andY:coordinate[i * 4].floatValue andW:coordinate[i * 4 + 3].floatValue andH:coordinate[i * 4 + 2].floatValue];
            }
            else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
                rectTmp = [self convertWithX:coordinate[i * 4 + 1].floatValue andY:1 - coordinate[i * 4].floatValue andW:coordinate[i * 4 + 3].floatValue andH:coordinate[i * 4 + 2].floatValue];
            }
            else if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
                rectTmp = [self convertWithX:1 - coordinate[i * 4].floatValue andY:1 - coordinate[i * 4 + 1].floatValue andW:coordinate[i * 4 + 2].floatValue andH:coordinate[i * 4 + 3].floatValue];
            }
            else {
                rectTmp = [self convertWithX:coordinate[i * 4].floatValue andY:coordinate[i * 4 + 1].floatValue andW:coordinate[i * 4 + 2].floatValue andH:coordinate[i * 4 + 3].floatValue];
            }
            if (rectTmp.size.width * rectTmp.size.height > rect.size.width * rect.size.height) {
                rect = rectTmp;
            }
            else if (rectTmp.size.width * rectTmp.size.height > rect.size.width * rect.size.height * 0.6 &&
                     pow((rectTmp.origin.x + rectTmp.size.width / 2 - kScreenW / 2), 2) + pow((rectTmp.origin.y + rectTmp.size.height
                                                                                             / 2 - kScreenH / 2), 2) <
                     pow((rect.origin.x + rect.size.width / 2 - kScreenW / 2), 2) + pow((rect.origin.y + rect.size.height
                                                                                         / 2 - kScreenH / 2), 2)) {
                rect = rectTmp;
            }
        }
    }
    if(rect.size.height < kScreenH/3-30 || rect.size.height > kScreenH/3+30){
        [self changeFactor:self->cameraDevice.videoZoomFactor *  kScreenH/3/rect.size.height];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self-> _personView.layer.borderColor = UIColor.redColor.CGColor;
        });
//        NSLog(@"当前线程：%@",[NSThread currentThread]);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self-> _personView.layer.borderColor = UIColor.greenColor.CGColor;
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_personView setHidden:NO];
        if (abs(self->_personView.frame.origin.x - rect.origin.x) < 5 &&
            abs(self->_personView.frame.origin.y - rect.origin.y) < 5 &&
            abs(self->_personView.frame.size.width - rect.size.width) < 5 &&
            abs(self->_personView.frame.size.height - rect.size.height) < 5) {}
        else {
            self->_personView.frame = rect;
        }
    });
}

#pragma mark - HumanBodyPoseDetectorDelegate
/*
- (void)getPersonViewRect:(CGRect)rect{
    CGFloat height = (rect.size.height-rect.origin.y)*kScreenH;
    CGFloat midX = (rect.size.width+rect.origin.x)/2*kScreenW;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_personView setHidden:NO];
        self->_personView.frame = CGRectMake(midX-0.3*height, rect.origin.y*kScreenH, 0.6*height, height);
    });
    if (2.0*height>kScreenW){
        //太大
        [_delegate setRemindLabel:@"距离球手过近" andOrientation:[UIDevice currentDevice].orientation];
        return;
    }
    CGFloat midY = (rect.size.height+rect.origin.y)/2*kScreenH;
    if (midX-height < 0){
        [_delegate setRemindLabel:@"请向右平移镜头" andOrientation:[UIDevice currentDevice].orientation];
        return;
    }
    if (midX+height > kScreenW){
        [_delegate setRemindLabel:@"请向左平移镜头" andOrientation:[UIDevice currentDevice].orientation];
        return;
    }
    if (midY-2.2*height < 0){
        [_delegate setRemindLabel:@"请向下平移镜头" andOrientation:[UIDevice currentDevice].orientation];
        return;
    }
    if (midY+1.8*height > kScreenH){
        [_delegate setRemindLabel:@"请向上平移镜头" andOrientation:[UIDevice currentDevice].orientation];
        return;
    }
    [_delegate setRemindLabel:@"" andOrientation:[UIDevice currentDevice].orientation];
}*/

- (void)hidePersonView{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_personView setHidden:YES];
        [self->_delegate setRemindLabel:@"" andOrientation:[UIDevice currentDevice].orientation];
    });
}

@end
