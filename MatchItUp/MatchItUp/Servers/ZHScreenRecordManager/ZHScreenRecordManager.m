//
//  ZHScreenRecordManager.m
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import "ZHScreenRecordManager.h"
#import "ZHScreenCapture.h"
#import "ZHAudioCapture.h"
#import <ReplayKit/ReplayKit.h>

@interface ZHScreenRecordManager ()

@property(nonatomic, strong) ZHScreenCapture *screenCapture;
@property(nonatomic, strong) ZHAudioCapture *audioCapture;

@end

@implementation ZHScreenRecordManager{
    BOOL isRecord;
    BOOL isPause;
}

//SingleM(Manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        isRecord = NO;
        isPause = NO;
    }
    return self;
}

- (void)startRecord{
    if (isRecord){
        if (isPause){
            isPause = NO;
            [_screenCapture startRecord];
            [_audioCapture startRecord];
        }
    }else{
        isRecord = YES;
        isPause = NO;
        _screenCapture = [[ZHScreenCapture alloc] init];
        _audioCapture = [[ZHAudioCapture alloc] init];
        [_screenCapture startRecord];
        [_audioCapture startRecord];
    }
}

- (void)pauseRecord{
    if (isRecord && !isPause){
        isPause = YES;
        [_screenCapture pauseRecord];
        [_audioCapture pauseRecord];
    }
}

- (void)endReocrd:(void (^)(NSString *filePath))completion{
    if (isRecord){
        [_screenCapture endReocrd];
        [_audioCapture endReocrd];
        [self mergeVideoAndVideo:completion];
    }
}

- (void)mergeVideoAndVideo:(void (^)(NSString *filePath))completion{
    NSURL *audioUrl=[NSURL fileURLWithPath: _audioCapture.audioPath];
    NSURL *videoUrl=[NSURL fileURLWithPath: _screenCapture.videoPath];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    //混合音乐
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:nil];
    
    
    //混合视频
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    
    //保存混合后的文件的过程
    NSString* videoName = @"export2.mov";
    NSString *exportPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:videoName];
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    //_assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputFileType = AVFileTypeMPEG4;
    NSLog(@"file type %@",_assetExport.outputFileType);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^{
        completion(exportPath);
    }];
}

//MARK: - replaykit
+ (void)startRecord:(void (^)(BOOL success, NSError *error))completionHandler{
    RPScreenRecorder.sharedRecorder.microphoneEnabled = YES;
    [RPScreenRecorder.sharedRecorder startRecordingWithHandler:^(NSError * _Nullable error) {
        if (error) {
            completionHandler(NO, error);
        } else {
            completionHandler(YES, NULL);
        }
    }];
}
+ (void)endRecord:(void (^)(NSString *filePath, NSError *error))completionHandler{
    
    NSString* videoName = @"exportNew.mp4";
    NSString *exportPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    [RPScreenRecorder.sharedRecorder stopRecordingWithOutputURL:exportUrl completionHandler:^(NSError * _Nullable error) {
        if (error) {
            completionHandler(NULL, error);
        } else {
            completionHandler(exportPath, NULL);
        }
    }];
}

@end
