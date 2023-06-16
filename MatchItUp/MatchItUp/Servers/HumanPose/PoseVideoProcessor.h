//
//  PoseVideoProcessor.h
//  MatchItUp
//
//  Created by 安子和 on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SharedInstance.h"
#import "Video+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface PoseVideoProcessor : NSObject

SingleH(Processor)

- (void)processVideo:(NSString *)videoFile withSwingId:(NSString *)swingId;

@end

@interface AssetReader : NSObject

- (instancetype)initWithURL:(NSURL *)videoURL;
- (nullable CMSampleBufferRef)nextBuffer;

@end

NS_ASSUME_NONNULL_END
