//
//  ZHFileManager.m
//  MatchItUp
//
//  Created by 安子和 on 2021/4/6.
//

#import "ZHFileManager.h"
#import "GlobalVar.h"

@interface ZHFileManager ()

@property(nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ZHFileManager{
    NSFileManager *fileManager;
    GlobalVar *globalVar;
    CoreDataManager *coreDataManager;
}

SingleM(Manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("www.filemanager.BYGolf", DISPATCH_QUEUE_CONCURRENT);
        fileManager = [NSFileManager defaultManager];
        globalVar = [GlobalVar sharedInstance];
        coreDataManager = [CoreDataManager sharedManager];
    }
    return self;
}

- (NSString *)getNewVideoName{
    NSString *currentDate = [[[NSDate alloc] init] date2String];
    __block NSInteger videoNum = 0;
    dispatch_sync(_queue, ^{
        NSString *lastDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastDate"];
        NSLog(@"@%", lastDate);
        if (lastDate == currentDate){
            videoNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"videoNum"] + 1;
            [[NSUserDefaults standardUserDefaults] setInteger:videoNum forKey:@"videoNum"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"lastDate"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"screenReocrdNum"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"videoNum"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    return [NSString stringWithFormat:@"%@%04d_%@", currentDate, (int)videoNum, NSUUID.UUID.UUIDString];
}

- (void)cutVideo:(NSURL *)sourceFile withStartTime:(Float32)startTime endTime:(Float32)endTime remindView:(MBProgressHUD *)hudView angle:(Float32)angle completion: (nullable void (^)(NSURL * _Nonnull))completionBlock{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewVideoName];
        AVAsset *asset = [AVAsset assetWithURL:sourceFile];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (assetVideoTrack == nil) return;
        NSLog(@"原视频%@信息---%f---%f---%d", sourceFile, assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width, assetVideoTrack.naturalTimeScale);
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *err = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&err];
        if (err){
            NSLog(@"原视频%@制作视频轨失败：%@", sourceFile, err.localizedDescription);
            return;
        }
        //剪裁视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGSize renderSize;
        if (assetVideoTrack.preferredTransform.b == 0){
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        }else{
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        [videoCompositionLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime: kCMTimeZero];
        [videoCompositionLayerInstruction setOpacity:0.0 atTime:asset.duration];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [videoCompositionInstruction setLayerInstructions:@[videoCompositionLayerInstruction]];
        
        AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
        [videoComposition setInstructions:@[videoCompositionInstruction]];
        [videoComposition setFrameDuration:CMTimeMake(1, assetVideoTrack.nominalFrameRate)];
        [videoComposition setRenderSize:renderSize];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        [session setVideoComposition:videoComposition];
        NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.albumDir, newFileName];
        [session setOutputURL:[NSURL fileURLWithPath:videoPath]];
        [session setShouldOptimizeForNetworkUse:YES];
        [session setOutputFileType:AVFileTypeMPEG4];
        [session setTimeRange:CMTimeRangeMake(CMTimeMake(startTime*100000, 100000), CMTimeMake((endTime-startTime)*100000, 100000))];
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"%@剪裁成功",sourceFile);
                //保存封面
                [self createShotPicWithVideo:videoPath named:newFileName];
                [self->coreDataManager addVideo:newFileName withAngle:angle];
                completionBlock(session.outputURL);
            }else{
                NSLog(@"%@剪裁失败%@", sourceFile, session.error.localizedDescription);
                NSLog(@"%@", newFileName);
            }
        }];
    });
}

- (void)copyVideo:(NSURL *)sourceFile withAngle:(Float32)angle completion:(nullable void (^)(NSURL *))completionBlock{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewVideoName];
        AVAsset *asset = [AVAsset assetWithURL:sourceFile];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (assetVideoTrack == nil) return;
        NSLog(@"原视频%@信息---%f---%f---%f", sourceFile, assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width, assetVideoTrack.nominalFrameRate);
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *err = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&err];
        if (err){
            NSLog(@"原视频%@制作视频轨失败：%@", sourceFile, err.localizedDescription);
            return;
        }
        //剪裁视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGSize renderSize;
        if (assetVideoTrack.preferredTransform.b == 0){
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        }else{
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        [videoCompositionLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime: kCMTimeZero];
        [videoCompositionLayerInstruction setOpacity:0.0 atTime:asset.duration];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [videoCompositionInstruction setLayerInstructions:@[videoCompositionLayerInstruction]];
        
        AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
        [videoComposition setInstructions:@[videoCompositionInstruction]];
        [videoComposition setFrameDuration:CMTimeMake(1, assetVideoTrack.nominalFrameRate)];
        [videoComposition setRenderSize:renderSize];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        [session setVideoComposition:videoComposition];
        NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.albumDir, newFileName];
        [session setOutputURL:[NSURL fileURLWithPath:videoPath]];
        [session setShouldOptimizeForNetworkUse:YES];
        [session setOutputFileType:AVFileTypeMPEG4];
        [session setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"%@剪裁成功",sourceFile);
                //保存封面
                [self createShotPicWithVideo:videoPath named:newFileName];
                [self->coreDataManager addVideo:newFileName withAngle:angle];
                completionBlock(session.outputURL);
            }else{
                NSLog(@"%@剪裁失败%@", sourceFile, session.error.localizedDescription);
                NSLog(@"%@", newFileName);
            }
        }];
    });
}

- (void)copyVideo:(NSURL *)sourceFile completion:(void (^)(NSString * nullable))completionBlock{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewVideoName];
        
        AVAsset *asset = [AVAsset assetWithURL:sourceFile];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (assetVideoTrack == nil) {
            completionBlock(NULL);
            return;
        }
        
        NSLog(@"原视频%@信息---%f---%f---%f", sourceFile, assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width, assetVideoTrack.nominalFrameRate);
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *err = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&err];
        if (err){
            NSLog(@"原视频%@制作视频轨失败：%@", sourceFile, err.localizedDescription);
            completionBlock(NULL);
            return;
        }
        
        //剪裁视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGSize renderSize;
        if (assetVideoTrack.preferredTransform.b == 0){
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        }else{
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        [videoCompositionLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime: kCMTimeZero];
        [videoCompositionLayerInstruction setOpacity:0.0 atTime:asset.duration];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [videoCompositionInstruction setLayerInstructions:@[videoCompositionLayerInstruction]];
        
        AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
        [videoComposition setInstructions:@[videoCompositionInstruction]];
        [videoComposition setFrameDuration:CMTimeMake(1, assetVideoTrack.nominalFrameRate)];
        [videoComposition setRenderSize:renderSize];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        [session setVideoComposition:videoComposition];
        NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.albumDir, newFileName];
        [session setOutputURL:[NSURL fileURLWithPath:videoPath]];
        [session setShouldOptimizeForNetworkUse:YES];
        [session setOutputFileType:AVFileTypeMPEG4];
        [session setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"%@剪裁成功",sourceFile);
                //保存封面
                [self createShotPicWithVideo:videoPath named:newFileName];
                completionBlock(newFileName);
            }else{
                NSLog(@"%@剪裁失败%@", sourceFile, session.error.localizedDescription);
                completionBlock(NULL);
            }
        }];
    });
}

- (void)cutVideo:(NSURL *)sourceFile startTime:(CMTime)start endTime:(CMTime)end completion:(void (^)(NSString * nullable))completionBlock{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewVideoName];
        
        AVAsset *asset = [AVAsset assetWithURL:sourceFile];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (assetVideoTrack == nil) {
            completionBlock(NULL);
            return;
        }
        
        NSLog(@"原视频%@信息---%f---%f---%f", sourceFile, assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width, assetVideoTrack.nominalFrameRate);
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *err = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&err];
        if (err){
            NSLog(@"原视频%@制作视频轨失败：%@", sourceFile, err.localizedDescription);
            completionBlock(NULL);
            return;
        }
        
        //剪裁视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGSize renderSize;
        if (assetVideoTrack.preferredTransform.b == 0){
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        }else{
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        [videoCompositionLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime: kCMTimeZero];
        [videoCompositionLayerInstruction setOpacity:0.0 atTime:asset.duration];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [videoCompositionInstruction setLayerInstructions:@[videoCompositionLayerInstruction]];
        
        AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
        [videoComposition setInstructions:@[videoCompositionInstruction]];
        [videoComposition setFrameDuration:CMTimeMake(1, assetVideoTrack.nominalFrameRate)];
        [videoComposition setRenderSize:renderSize];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        [session setVideoComposition:videoComposition];
        NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.albumDir, newFileName];
        [session setOutputURL:[NSURL fileURLWithPath:videoPath]];
        [session setShouldOptimizeForNetworkUse:YES];
        [session setOutputFileType:AVFileTypeMPEG4];
        [session setTimeRange:CMTimeRangeMake(start, CMTimeMake(end.value - start.value, start.timescale))];
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"%@剪裁成功",sourceFile);
                //保存封面
                [self createShotPicWithVideo:videoPath named:newFileName];
                completionBlock(newFileName);
            }else{
                NSLog(@"%@剪裁失败%@", sourceFile, session.error.localizedDescription);
                completionBlock(NULL);
            }
        }];
    });
}

- (NSString *)getNewScreenRecordName{
    NSString *currentDate = [[[NSDate alloc] init] date2String];
    __block NSInteger videoNum = 0;
    dispatch_sync(_queue, ^{
        NSString *lastDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastDate"];
        NSLog(@"@%", lastDate);
        if (lastDate == currentDate){
            videoNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"screenReocrdNum"] + 1;
            [[NSUserDefaults standardUserDefaults] setInteger:videoNum forKey:@"screenReocrdNum"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"lastDate"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"screenReocrdNum"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"videoNum"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    return [NSString stringWithFormat:@"sr_%@%04d", currentDate, (int)videoNum];
}

- (void)copyScreenRecord:(NSURL *)sourceFile{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewVideoName];
        NSString *destFile = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.screenRecordDir, newFileName];
        NSError *err;
        [self->fileManager copyItemAtURL:sourceFile toURL:[NSURL fileURLWithPath:destFile] error:&err];
        if (err){
            NSLog(@"复制录屏失败:%@",err.localizedDescription);
            return;
        }
        [self createShotPicWithVideo:destFile named:newFileName];
        [self->coreDataManager addScreenRecord:newFileName];
    });
}

- (void)newCopyScreenRecord:(NSURL *)fileURL withCompletionHandler:(void (^)(BOOL success, NSError *error, NSString *fileName))completionHandler{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewScreenRecordName];
        NSString *destPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.screenRecordDir, newFileName];
        NSError *err;
        [self->fileManager copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destPath] error:&err];
        if (err) {
            completionHandler(NO, err, NULL);
        } else {
            completionHandler(YES, NULL, newFileName);
            [self createShotPicWithVideo:destPath named:newFileName];
        }
    });
}
-(void)copyAnalysisVideo:(NSURL *)fileURL withCompletionHandler:(void (^)(BOOL success, NSError *error, NSString *fileName))completionHandler{
    dispatch_async(_queue, ^{
        NSString *newFileName = [self getNewScreenRecordName];
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (assetVideoTrack == nil) {
            completionHandler(NULL,NULL,NULL);
            return;
        }
        
        NSLog(@"原视频%@信息---%f---%f---%f", fileURL, assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width, assetVideoTrack.nominalFrameRate);
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *err = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&err];
        if (err){
            NSLog(@"原视频%@制作视频轨失败：%@", fileURL, err.localizedDescription);
            completionHandler(NULL,NULL,NULL);
            return;
        }
        
        //剪裁视频
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGSize renderSize;
        if (assetVideoTrack.preferredTransform.b == 0){
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        }else{
            renderSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        [videoCompositionLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime: kCMTimeZero];
        [videoCompositionLayerInstruction setOpacity:0.0 atTime:asset.duration];
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [[AVMutableVideoCompositionInstruction alloc] init];
        [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [videoCompositionInstruction setLayerInstructions:@[videoCompositionLayerInstruction]];
        
        AVMutableVideoComposition *videoComposition = [[AVMutableVideoComposition alloc] init];
        [videoComposition setInstructions:@[videoCompositionInstruction]];
        [videoComposition setFrameDuration:CMTimeMake(1, assetVideoTrack.nominalFrameRate)];
        [videoComposition setRenderSize:renderSize];
        
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        [session setVideoComposition:videoComposition];
        NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", self->globalVar.analysisVideoDir, newFileName];
        [session setOutputURL:[NSURL fileURLWithPath:videoPath]];
        [session setShouldOptimizeForNetworkUse:YES];
        [session setOutputFileType:AVFileTypeMPEG4];
        [session setTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"%@剪裁成功",fileURL);
                //保存封面
                [self createShotPicWithVideo:videoPath named:newFileName];
                completionHandler(YES, NULL, newFileName);
            }else{
                NSLog(@"%@剪裁失败%@", fileURL, session.error.localizedDescription);
                completionHandler(NO, err, NULL);
            }
        }];
    });
}
- (void)mergeVideosToOne:(NSArray*)array{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
//    AVMutableCompositionTrack *a_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    Float64 tmpDuration =0.0f;
    
    for (NSURL *videoUrl in array)
    {
        
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
        
        AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//        AVAssetTrack *audioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,asset.duration);
        
        [a_compositionVideoTrack setPreferredTransform:videoAssetTrack.preferredTransform];
//        [a_compositionAudioTrack setPreferredTransform:audioAssetTrack.preferredTransform];

        /**
         依次加入每个asset
        
         param TimeRange 加入的asset持续时间
         param Track     加入的asset类型,这里都是video
         param Time      从哪个时间点加入asset,这里用了CMTime下面的CMTimeMakeWithSeconds(tmpDuration, 0),timesacle为0
         */
        NSError *error;
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:videoAssetTrack atTime:CMTimeMakeWithSeconds(tmpDuration, 0) error:&error];
        
        
//        [a_compositionAudioTrack insertTimeRange:video_timeRange ofTrack:audioAssetTrack atTime:CMTimeMakeWithSeconds(tmpDuration, 0) error:&error];
        tmpDuration += CMTimeGetSeconds(asset.duration);
    }
    NSError *err;
    if ([[NSFileManager defaultManager]fileExistsAtPath:[GlobalVar sharedInstance].tmpmergeVideoPath]){
        [[NSFileManager defaultManager] removeItemAtPath:[GlobalVar sharedInstance].tmpmergeVideoPath error:&err];
        if (err != nil){
            NSLog(@"删除原临时视频文件失败:%@",err.localizedDescription);
            return;
        }
    }
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    session.outputURL = [NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpmergeVideoPath];
    session.shouldOptimizeForNetworkUse = YES;
    session.outputFileType = AVFileTypeMPEG4;
    [session exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
        switch ([session status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"failed: %@", [[session error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"canceled");
                break;
            default:
                NSLog(@"success");
                break;
        }
    }];
    [NSThread sleepForTimeInterval:0.5]; 
    [CoreDataManager.sharedManager addAnalysisVideo:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpmergeVideoPath] withisFront:YES completion:^(AnalysisVideo * _Nonnull) {
    }];
}
- (void)createShotPicWithVideo:(NSString *)sourceFile named:(NSString *)fileName{
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:sourceFile]];
    NSError *err;
    UIImage *img;
    AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imgGenerator.appliesPreferredTrackTransform = YES;
    imgGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef cgImg = [imgGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:&err];
    if (err){
        NSLog(@"缩略图截取失败:%@",err.localizedDescription);
        img = [UIImage imageNamed:@"icon1.png"];
    }else{
        img = [UIImage imageWithCGImage:cgImg];
    }
    NSString *name = [NSString stringWithFormat:@"%@.jpg",fileName];
    NSData *imgData = UIImagePNGRepresentation(img);
    [self->fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@",self->globalVar.shotPicDir,name] contents:imgData attributes:nil];
}

- (void)deleteTmpVideo{
    dispatch_barrier_sync(_queue, ^{
        if ([fileManager fileExistsAtPath:[GlobalVar sharedInstance].tmpVideoPath]){
            NSError *err = NULL;
            [fileManager removeItemAtPath:[GlobalVar sharedInstance].tmpVideoPath error:&err];
            if (err) NSLog(@"录制视频删除失败:%@", err.localizedDescription);
        }
    });
}

- (void)cutTmpVideo:(NSTimeInterval)interval With:(nullable void (^)(void))completion{
    @autoreleasepool {
        NSError *err;
        NSString *newPath = [GlobalVar sharedInstance].tmpNewVideoPath;
        
        if ([fileManager fileExistsAtPath:newPath]){
            [fileManager removeItemAtPath:newPath error:&err];
            if (err != nil){
                NSLog(@"移除tmpNewVideo失败:%@",err.localizedDescription);
                return;
            }
        }
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:[GlobalVar sharedInstance].tmpVideoPath]];
        if (asset == nil){
            return;
        }
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (videoTrack != nil){
            //素材插入视频轨道
            AVMutableComposition *composition = [[AVMutableComposition alloc]init];
            AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:&err];
            if (err != nil){
                NSLog(@"插入视频轨道失败:%@",err.localizedDescription);
                asset = nil;
                videoTrack = nil;
                composition = nil;
                compositionTrack = nil;
                return;
            }
            //剪裁视频
            AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionTrack];
            
            CGSize renderSize;
            if (videoTrack.preferredTransform.b == 0){
                renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            }else{
                renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            }
            
            [layerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
            [layerInstruction setOpacity:0.0 atTime:asset.duration];
            
            AVMutableVideoCompositionInstruction *instruction = [[AVMutableVideoCompositionInstruction alloc]init];
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            instruction.layerInstructions = @[layerInstruction];
            
            AVMutableVideoComposition *mainComposition = [[AVMutableVideoComposition alloc]init];
            mainComposition.instructions = @[instruction];
            mainComposition.frameDuration = CMTimeMake(1, videoTrack.nominalFrameRate);
            mainComposition.renderSize = renderSize;
            
            
            CMTime start = CMTimeMake(asset.duration.value-interval*asset.duration.timescale, asset.duration.timescale);
            CMTime duration = CMTimeMake(interval*asset.duration.timescale, asset.duration.timescale);
            
            AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
            session.videoComposition = mainComposition;
            session.outputURL = [NSURL fileURLWithPath:newPath];
            session.shouldOptimizeForNetworkUse = YES;
            session.outputFileType = AVFileTypeMPEG4;
            session.timeRange = CMTimeRangeMake(start, duration);
            [session exportAsynchronouslyWithCompletionHandler:^(void){
                if (session.status == AVAssetExportSessionStatusCompleted){
                    NSLog(@"自适应剪裁成功");
                    completion();
                }else{
                    NSLog(@"自适应剪裁失败:%@",session.error.localizedDescription);
                }
            }];
        }
    }
}

- (void)clearVideo:(Video *)video{
    NSString *videoFile = video.videoFile;
    NSString *coverFile = video.shotPicFile;
    dispatch_async(_queue, ^{
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.albumDir, videoFile] error:nil];
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.shotPicDir, coverFile] error:nil];
    });
}

- (void)clearScreenRecord:(ScreenRecord *)sr{
    NSString *videoFile = sr.videoFile;
    NSString *coverFile = sr.shotPicFile;
    dispatch_async(_queue, ^{
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.screenRecordDir, videoFile] error:nil];
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.shotPicDir, coverFile] error:nil];
    });
}

- (void)clearAnalysisVideo:(AnalysisVideo *)sr{
    NSString *videoFile = sr.videoFile;
    NSString *coverFile = sr.shotPicFile;
    dispatch_async(_queue, ^{
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.analysisVideoDir, videoFile] error:nil];
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.shotPicDir, coverFile] error:nil];
    });
}

#pragma mark - 技术指标模版
- (NSString *)getNewSpecificationName{
    NSString *currentDate = [[[NSDate alloc] init] date2String];
    __block NSInteger specificationNum = 0;
    dispatch_sync(_queue, ^{
        NSString *lastDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastDate"];
        NSLog(@"%@", lastDate);
        if (lastDate == currentDate){
            specificationNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"specificationNum"] + 1;
            [[NSUserDefaults standardUserDefaults] setInteger:specificationNum forKey:@"specificationNum"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"lastDate"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"screenReocrdNum"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"videoNum"];
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"specificationNum"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    return [NSString stringWithFormat:@"%@%04d_%@", currentDate, (int)specificationNum, NSUUID.UUID.UUIDString];
}
-(void)copySpecification:(NSURL*)sourceURL completion:(nullable void (^)(BOOL success, NSError *error,NSString *fileName))completionBlock{
    dispatch_async(_queue,^{
        
        NSString *newFileName = [NSString stringWithFormat:@"%@.%@",[self getNewSpecificationName],[[[sourceURL absoluteString] lastPathComponent] pathExtension]];
        NSError *copyerror = nil;
        NSURL* newurl = [NSURL fileURLWithPath:[GlobalVar.sharedInstance.specificationAlbumDir stringByAppendingString:newFileName]];
        [self->fileManager createDirectoryAtPath:[GlobalVar.sharedInstance.specificationDocDir stringByAppendingString:[[newFileName lastPathComponent] stringByDeletingPathExtension]] withIntermediateDirectories:YES attributes:nil error:nil];
        if([self->fileManager copyItemAtURL:sourceURL toURL:newurl error:&copyerror]){
            NSLog(@"copy yes %@",newurl);
            completionBlock(YES,copyerror,newFileName);
        }
    });
}

- (void)clearSpecification:(SpecificationModel *)model{
    NSString *modelFile = model.modelFile;
    NSString *coverFile = model.shotPicFile;
    dispatch_async(_queue, ^{
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.specificationAlbumDir, coverFile] error:nil];
        [self->fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", self->globalVar.specificationDocDir, modelFile] error:nil];
    });
}

- (void)firstInitSpecifications{
    for(int i=1;i<13;i++){
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"zhibiaomoban%d",i]];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"zhibiaomoban%d.png",i]];
        BOOL isSuccess = [imageData writeToFile:filePath atomically:YES];
        if(isSuccess){
            NSLog(@"%@",[NSString stringWithFormat:@"zhibiaomoban%d",i]);
            [coreDataManager addSpecification:[NSURL fileURLWithPath:filePath] withCanDelete:NO andISFront:i<6 completion:^(SpecificationModel * _Nonnull newModel) {
                NSLog(@"%@",[NSString stringWithFormat:@"zhibiaomoban%d 成功",i]);
                NSString *toolPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/specificationDocDir/zhibiaomoban%d/toolsData",i];
                NSMutableArray *tmpToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolPath];
                NSString *modlePath = [GlobalVar.sharedInstance.specificationDocDir stringByAppendingString:newModel.modelFile];
                NSString *toolsSavePath = [modlePath stringByAppendingPathComponent:@"toolsData"];
                if ([NSKeyedArchiver archiveRootObject:tmpToolsArray toFile:toolsSavePath]) {
                    NSLog(@"tool写入成功");
                }
                else {
                    NSLog(@"tool写入失败");
                }
                NSString *frameIndexPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/specificationDocDir/zhibiaomoban%d/frameIndex",i];
                NSMutableArray *frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIndexPath];
                NSString *frameIdxSavePath = [modlePath stringByAppendingPathComponent:@"frameIndex"];
                if ([frameIndexArray writeToFile:frameIdxSavePath atomically:NO]) {
                    NSLog(@"指标模型图片写入成功");
                }
                else {
                    NSLog(@"指标模型图片写入失败");
                }
                NSString *jsonPath =  [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/specificationDocDir/zhibiaomoban%d/jsonData.json",i];
                NSString *jsonSavePath = [modlePath stringByAppendingPathComponent:@"jsonData.json"];
                NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
                if( [jsonData writeToFile:jsonSavePath atomically:YES]){
                    NSLog(@"json写入成功");
                }else{
                    NSLog(@"json写入失败");
                }
            }];
        }
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"example1.mp4"] withExtension:nil];
    [CoreDataManager.sharedManager addVideo:url withAngle:0 completion:^(Video * newVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newVideo == NULL) {
                NSLog(@"保存失败");
                return;
            }
            NSLog(@"save asset 成功 %@", newVideo.videoFile);
        });
    }];
}
+ (BOOL)resultExistsWithId:(NSString*)videoId option:(NSUInteger)option {
    NSString *path;
    switch (option) {
        case 0:
            path = [NSString stringWithFormat:@"%@%@.mp4", GlobalVar.sharedInstance.videoOriDir, videoId];
            break;
        case 1:
            path = [NSString stringWithFormat:@"%@%@.mp4", GlobalVar.sharedInstance.video2dServerDir, videoId];
            break;
        case 2:
            path = [NSString stringWithFormat:@"%@%@.mp4", GlobalVar.sharedInstance.video3dDir, videoId];
            break;
        case 3:
            path = [NSString stringWithFormat:@"%@%@", GlobalVar.sharedInstance.keyFrameDir, videoId];
            break;
        default:
            path = [NSString stringWithFormat:@"%@%@.mp4", GlobalVar.sharedInstance.video2dLocalDir, videoId];
            break;
    }
    return [NSFileManager.defaultManager fileExistsAtPath:path];
}

@end
