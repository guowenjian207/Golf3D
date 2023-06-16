//
//  ZHVideoAsset.h
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "Video+CoreDataClass.h"
#import "ScreenRecord+CoreDataClass.h"
#import "AnalysisVideo+CoreDataClass.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZHVideoAsset : NSObject

@property(nonatomic, strong) NSURL *videoURL;

@property(nonatomic, strong) UIImage *cover;

@property(nonatomic, strong) NSString *secs;

@property(nonatomic, assign) BOOL isSelected;

@property(nonatomic, assign) PHAsset *phAsset;

@property(nonatomic, strong) Video *video;

@property(nonatomic, strong) ScreenRecord *screenRecord;

@property(nonatomic, strong) AnalysisVideo *analysisVideo;

@property(nonatomic, assign) BOOL isFillScreen;

@property(nonatomic, assign) BOOL isFront;

- (instancetype)initWithLocalURL:(NSURL *)videoURL andIsFront:(BOOL)isFront;

- (instancetype)initWithPHAsset:(PHAsset *)phAsset;

- (instancetype)initWithVideo:(Video *)video;

- (instancetype)initWithScreenRecord:(ScreenRecord *)screenRecord;

- (instancetype)initWithAnalysisVideo:(AnalysisVideo *)analysisVideo;

@end

NS_ASSUME_NONNULL_END
