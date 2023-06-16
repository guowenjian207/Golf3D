//
//  ZHVideoModel.m
//  MatchItUp
//
//  Created by 安子和 on 2021/5/24.
//

#import "ZHVideoModel.h"

@implementation ZHVideoModel

- (instancetype)initWithPhotos:(NSArray<PHAsset *> *)videos{
    self = [super init];
    if (self){
        self.assets = [NSMutableArray array];
        for (PHAsset *video in videos) {
            [self.assets addObject: [[ZHVideoAsset alloc] initWithPHAsset:video]];
        }
    }
    return self;
}

- (instancetype)initWithVideos:(NSArray<Video *> *)videos{
    self = [super init];
    if (self){
        self.assets = [NSMutableArray array];
        for (Video *video in videos){
            [self.assets addObject:[[ZHVideoAsset alloc] initWithVideo:video]];
        }
    }
    return self;
}

- (instancetype)initWithScreenRecord:(NSArray<ScreenRecord *> *)srs {
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray array];
        for (ScreenRecord *sr in srs) {
            [self.assets addObject:[[ZHVideoAsset alloc] initWithScreenRecord:sr]];
        }
    }
    return self;
}
- (instancetype)initWithAnalysisVideos:(NSArray<AnalysisVideo*> *)videos{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray array];
        for (AnalysisVideo *video in videos) {
            [self.assets addObject:[[ZHVideoAsset alloc] initWithAnalysisVideo:video]];
        }
    }
    return self;
}
@end
