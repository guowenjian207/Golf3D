//
//  ZHScreenCapture.m
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import "ZHScreenCapture.h"
#import <UIKit/UIKit.h>

@interface ZHScreenCapture ()

@property(nonatomic, weak) UIWindow *keyWindow;

@end

@implementation ZHScreenCapture{
    AVAssetWriter *videoWriter;
    AVAssetWriterInput *videoWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
    
    BOOL           _writing;       //正在将帧写入文件
    NSDate         *startedAt;     //录制的开始时间
    CGContextRef   context;        //绘制layer的context
    NSTimer        *timer;         //按帧率写屏的定时器
    
    //Capture Layer
    CALayer *_captureLayer;              //要绘制的目标layer
    
    BOOL isRecord;
    BOOL isPause;
    int spaceDuration;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"screen.mp4"];
        _frameRate = 10;
    }
    return self;
}

- (UIWindow *)keyWindow{
    if (_keyWindow == nil){
        NSArray *arr = UIApplication.sharedApplication.windows;
        for (UIWindow *window in arr) {
            if (window.isKeyWindow){
                _keyWindow = window;
                break;
            }
        }
    }
    return _keyWindow;
}

#pragma mark - public method
- (void)startRecord{
    if (isRecord){
        if (isPause) isPause = NO;
    }else{
        //开始录制
        isPause = NO;
        isRecord = YES;
        spaceDuration = 0;
        [self setupWriter];
        startedAt = [NSDate date];
        spaceDuration = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.frameRate target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)pauseRecord{
    if (isRecord){
        isPause = !isPause;
    }
}

- (void)endReocrd{
    isRecord = NO;
     isPause = NO;
    [timer invalidate];
    timer = nil;
    [self finishWriter];
    NSLog(@"****************%@", _videoPath);
}

#pragma mark - private method
- (void)setupWriter{
    //[self is64bit];

    CGSize tmpsize = [UIScreen mainScreen].bounds.size;
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGSize size = CGSizeMake(tmpsize.width*scaleFactor, tmpsize.height*scaleFactor);
    NSLog(@"%f %f", size.width, size.height);
    NSError *error = nil;
    
    //如果文件已经存在，则删去
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_videoPath]) {
        if ([fileManager removeItemAtPath:_videoPath error:&error] == NO) {
            NSLog(@"Could not delete old recording file at path:  %@", _videoPath);
            return;
        }
    }
    
    //configure videoWriter
    NSURL *fileUrl = [NSURL fileURLWithPath:_videoPath];
    videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    NSParameterAssert(videoWriter);
    
    //Configure videoWriterInput
    NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:size.width*size.height], AVVideoAverageBitRateKey,//视频尺寸*比率，10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细
                                           nil ];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecTypeH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   nil];
    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(videoWriterInput);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    
    //PixelBufferAdaptor
    NSMutableDictionary* bufferAttributes = [[NSMutableDictionary alloc] init];
    [bufferAttributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [bufferAttributes setObject:[NSNumber numberWithUnsignedInt:size.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [bufferAttributes setObject:[NSNumber numberWithUnsignedInt:size.height] forKey:(NSString*)kCVPixelBufferHeightKey];
     [bufferAttributes setObject:@YES forKey:(NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey];
    avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    //add input
    [videoWriter addInput:videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];

    //create context
    if (context == NULL)
    {
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        context = CGBitmapContextCreate (NULL,
//                                         size.width,
//                                         size.height,
//                                         8,//bits per component
//                                         size.width * 4,
//                                         colorSpace,
//                                         kCGImageAlphaNoneSkipFirst);
//        CGColorSpaceRelease(colorSpace);
//        CGContextSetAllowsAntialiasing(context,NO);
//        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0,-1, 0, size.height);
//        CGContextConcatCTM(context, flipVertical);
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen.bounds.size, YES, 0);
        context = UIGraphicsGetCurrentContext();
        
    }
    if (context== NULL)
    {
        fprintf (stderr, "Context not created!");
        return;
    }
}

- (void)finishWriter{
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        self->avAdaptor = nil;
        
        self->videoWriterInput = nil;
        
        self->videoWriter = nil;
        
        CGContextRelease(self->context);
        self->context=NULL;
    }];
}

- (void)drawFrame{
    if (isPause){
        spaceDuration += 1.0 / _frameRate;
        return;
    }
    if (!videoWriterInput.isReadyForMoreMediaData || !isRecord) return;
    
    size_t width = CGBitmapContextGetWidth(context);
    size_t height = CGBitmapContextGetHeight(context);
    
    NSLog(@"%d%d", width, height);
    
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    [self.keyWindow.layer renderInContext:context];
    self.keyWindow.layer.contents = nil;
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    CVPixelBufferRef pixelBuffer = NULL;
    int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
    if(status != 0){
        //could not get a buffer from the pool
        NSLog(@"Error creating pixel buffer:  status=%d", status);
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t* destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
    CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);
    if(status == 0) {
        float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0-spaceDuration*1000.0;
        BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake((int)millisElapsed, 1000)];
        if (!success)
            NSLog(@"Warning:  Unable to write buffer to video");
    }
    
    //clean up
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CVPixelBufferRelease( pixelBuffer );
    CFRelease(image);
    CGImageRelease(cgImage);
}

@end
