//
//  PhotosVideo.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/17.
//

#import "PhotosVideo.h"

@implementation PhotosVideo

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    self = [super init];
    if (self){
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *aset,AVAudioMix *audioMix,NSDictionary *info){
            self->_secs = [[GlobalVar sharedInstance]durationGetSecs:aset.duration];
            AVURLAsset *urlAsset = (AVURLAsset *)aset;
            self->_url = urlAsset.URL;
        }];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(kScreenW, kScreenH) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *img,NSDictionary *info){
            self->_img = img;
        }];
        _isSelected = NO;
    }
    return self;
}

@end
