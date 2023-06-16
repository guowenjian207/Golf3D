//
//  ZHAudioCapture.h
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHAudioCapture : NSObject<AVAudioRecorderDelegate>

@property(nonatomic, strong) NSString *audioPath;

- (void)startRecord;
- (void)pauseRecord;
- (void)endReocrd;

@end

NS_ASSUME_NONNULL_END
