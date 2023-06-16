//
//  ZHVideoAsset.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ZHVideoAsset.h"
#import <UIKit/UIKit.h>
#import "GlobalVar.h"
#import "Video+CoreDataClass.h"

@implementation ZHVideoAsset

- (instancetype)initWithLocalURL:(NSURL *)videoURL andIsFront:(BOOL)isFront{
    self = [super init];
    if (self){
        self.videoURL = videoURL;
        self.cover = [UIImage imageNamed:@"placeholder"];
        //获取视频尺寸
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        NSArray *array = asset.tracks;
        CGSize videoSize = CGSizeZero;
        
        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoSize = track.naturalSize;
                self.video.videoHeight = videoSize.height;
                self.video.videoWidth = videoSize.width;
            }
        }
        
        _isFillScreen = videoSize.height / videoSize.width > kScreenH / kScreenW;
        _isFront = isFront;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)phAsset{
    self = [super init];
    if (self){
        _phAsset = phAsset;
        
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
        videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        videoRequestOptions.networkAccessAllowed = YES;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:videoRequestOptions resultHandler:^(AVAsset *aset,AVAudioMix *audioMix,NSDictionary *info){
            self->_secs = [[GlobalVar sharedInstance]durationGetSecs:aset.duration];
            AVURLAsset *urlAsset = (AVURLAsset *)aset;
            self->_videoURL = urlAsset.URL;
        }];
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc]init];
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(kScreenW, kScreenH) contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage *img,NSDictionary *info){
            self->_cover = img;
        }];
        _isSelected = NO;
        _isFillScreen = phAsset.pixelHeight / phAsset.pixelWidth > kScreenH / kScreenW;
    }
    return self;
}

- (instancetype)initWithVideo:(Video *)video{
    self = [super init];
    if (self){
        _video = video;
        _videoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",GlobalVar.sharedInstance.albumDir,video.videoFile]];
        _cover = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",GlobalVar.sharedInstance.shotPicDir,video.shotPicFile]];
        _secs = video.secs;
        _isSelected = NO;
        _isFillScreen = video.videoHeight / video.videoWidth > kScreenH / kScreenW;
        _isFront = video.isFront;
    }
    return self;
}

- (instancetype)initWithScreenRecord:(ScreenRecord *)screenRecord{
    self = [super init];
    if (self){
        _screenRecord = screenRecord;
        _videoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",GlobalVar.sharedInstance.screenRecordDir, screenRecord.videoFile]];
        _cover = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", GlobalVar.sharedInstance.shotPicDir,screenRecord.shotPicFile]];
        _secs = screenRecord.secs;
        _isSelected = NO;
        _isFillScreen = YES;
    }
    return self;
}
- (instancetype)initWithAnalysisVideo:(AnalysisVideo *)analysisVideo{
    self = [super init];
    if (self){
        _analysisVideo= analysisVideo;
        _videoURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",GlobalVar.sharedInstance.analysisVideoDir, analysisVideo.videoFile]];
        _cover = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", GlobalVar.sharedInstance.shotPicDir,analysisVideo.shotPicFile]];
        _secs = analysisVideo.secs;
        _isSelected = NO;
        _isFillScreen = NO;
    }
    return self;
}
@end
