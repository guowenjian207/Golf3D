//
//  ZHVideoModel.h
//  MatchItUp
//
//  Created by 安子和 on 2021/5/24.
//

#import <Foundation/Foundation.h>
#import "ZHVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@class Video;
@interface ZHVideoModel : NSObject

@property(nonatomic, strong) NSMutableArray<ZHVideoAsset*> *assets;

- (instancetype)initWithVideos:(NSArray<Video*> *)videos;

///系统相册视频
- (instancetype)initWithPhotos:(NSArray<PHAsset*> *)videos;

///录屏
- (instancetype)initWithScreenRecord:(NSArray<ScreenRecord*> *)srs;

- (instancetype)initWithAnalysisVideos:(NSArray<AnalysisVideo*> *)videos;

@end

NS_ASSUME_NONNULL_END
