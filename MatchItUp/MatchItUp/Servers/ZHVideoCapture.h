//
//  ZHVideoCapture.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NSFileManager+Category.h"
#import "ZHFileManager.h"
#import "HumanBodyPoseDetector.h"
#import "GlobalVar.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZHVideoCaptureDelegate;

@interface ZHVideoCapture : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate,HumanBodyPoseDetectorDelegate>

@property(nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic,strong) UIView *personView;
@property(nonatomic,weak) id<ZHVideoCaptureDelegate> delegate;
@property(nonatomic,assign) BOOL isAuto;

@property(nonatomic,weak) NSTimer *detectTimer;
///30 60 120 240
@property(nonatomic,assign) int32_t frameRate;
///720 || 1280
@property(nonatomic,assign) int32_t videoResolution;
//2||3 s
@property(nonatomic,assign) int32_t videoDuration;

@property(nonatomic,assign) CGFloat minZoomFactor;
@property(nonatomic,assign) CGFloat maxZoomFactor;
@property(nonatomic,strong) AVCaptureDeviceInput *cameraInput;
- (instancetype)initWithDelegate:(id<ZHVideoCaptureDelegate>)delegate;
- (void)startRecord;
- (void)endRecord;
/**
 * @brief 侧面0度挥杆自动录制
 */
- (void)switchToFront;
/**
 * @brief 正面90度挥杆自动录制
 */
- (void)switchToRigth;
- (void)autoRecordCancel;

-(void) changeFactor:(CGFloat)currentZoomFactor;
@end

@protocol ZHVideoCaptureDelegate<NSObject>

- (void)goToPlayWithIsCutted:(BOOL)isCutted;
- (void)setAutoRecordLabel:(NSString *)str;
- (void)addAmation;
- (void)setRemindLabel:(NSString *)str andOrientation:(UIDeviceOrientation)orientation;
- (void)autoRecordEnd;

@optional
- (void)videoCaptureFrameRateChanged;
- (void)videoCaptureVideoResolutionChanged;
- (void)viderCaptureVideoDurationChanged;
@end

NS_ASSUME_NONNULL_END
