//
//  NSFileManager+Category.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/4.
//

#import "NSFileManager+Category.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSFileManager (Category)

/**
 * @brief 自动录制结束保存最后五秒
 */
- (void)cutTmpVideoWith:(void (^)(void))completion{
    @autoreleasepool {
        NSError *err;
        NSString *newPath = [GlobalVar sharedInstance].tmpNewVideoPath;
        
        if ([self fileExistsAtPath:newPath]){
            [self removeItemAtPath:newPath error:&err];
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
            [layerInstruction setOpacity:0.0 atTime:kCMTimeZero];
            
            AVMutableVideoCompositionInstruction *instruction = [[AVMutableVideoCompositionInstruction alloc]init];
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            instruction.layerInstructions = @[layerInstruction];
            
            AVMutableVideoComposition *mainComposition = [[AVMutableVideoComposition alloc]init];
            mainComposition.instructions = @[instruction];
            mainComposition.frameDuration = CMTimeMake(1, videoTrack.nominalFrameRate);
            mainComposition.renderSize = renderSize;
            
            
            CMTime start = CMTimeMake(asset.duration.value-5*asset.duration.timescale, asset.duration.timescale);
            CMTime duration = CMTimeMake(5*asset.duration.timescale, asset.duration.timescale);
            
            AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
            session.videoComposition = mainComposition;
            session.outputURL = [NSURL fileURLWithPath:newPath];
            session.shouldOptimizeForNetworkUse = YES;
            session.outputFileType = AVFileTypeMPEG4;
            session.timeRange = CMTimeRangeMake(start, duration);
            [session exportAsynchronouslyWithCompletionHandler:^(void){
                if (session.status == AVAssetExportSessionStatusCompleted){
                    NSLog(@"五秒视频剪裁成功");
                    completion();
                }else{
                    NSLog(@"五秒视频剪裁失败:%@",session.error.localizedDescription);
                }
            }];
        }
    }
}

/**
 * @brief 首次安装app时新建各种需要的文件夹
 */
- (void)checkDirectory{
    NSError *err = nil;
    
    //存储2dLocal视频
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].video2dLocalDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].video2dLocalDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //存储2dServer视频
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].video2dServerDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].video2dServerDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //存储3d视频
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].video3dDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].video3dDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //存储flow视频
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].videoFlowDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].videoFlowDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //存储原视频
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].videoOriDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].videoOriDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //存储关键帧
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].keyFrameDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].keyFrameDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    
    //存储原视频截图
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].shotPicDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].shotPicDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //应用相册
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].albumDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].albumDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //录屏相册
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].screenRecordDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].screenRecordDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //分析相册
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].analysisVideoDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].analysisVideoDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //技术指标相册
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].specificationAlbumDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].specificationAlbumDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //技术指标数据
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].specificationDocDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].specificationDocDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //mri文件夹
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].mriDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].mriDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
    
    //缓存球手头像
    if (![self fileExistsAtPath:[GlobalVar sharedInstance].golferIconDir]){
        [self createDirectoryAtPath:[GlobalVar sharedInstance].golferIconDir withIntermediateDirectories:NO attributes:nil error:&err];
    }
    if (err != nil){
        NSLog(@"%@",[err localizedDescription]);
        err = nil;
    }
}

#define FileHashDefaultChunkSizeForReadingData 1024*8
+(NSString *)md5HashOfPath:(NSString *)path
{
    
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
    
}



CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

@end
