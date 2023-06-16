//
//  ZHScreenCapture.h
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHScreenCapture : NSObject

@property(nonatomic, assign) UInt8 frameRate;
@property(nonatomic, strong) NSString *videoPath;

- (void)startRecord;
- (void)pauseRecord;
- (void)endReocrd;

@end

NS_ASSUME_NONNULL_END
