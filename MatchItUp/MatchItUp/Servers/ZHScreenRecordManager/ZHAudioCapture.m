//
//  ZHAudioCapture.m
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import "ZHAudioCapture.h"

#define AVSampleRate 8000

@interface ZHAudioCapture ()

@property(nonatomic, strong) NSMutableDictionary *audioSettings;

@end

@implementation ZHAudioCapture{
    BOOL isRecord;
    BOOL isPause;
    AVAudioRecorder *audioRecorder;
}

- (NSMutableDictionary *)audioSettings{
    if (_audioSettings == nil){
        _audioSettings = [NSMutableDictionary dictionary];
        _audioSettings[AVFormatIDKey] = @(kAudioFormatLinearPCM);
        //#define AVSampleRate 8000
        _audioSettings[AVSampleRateKey] = @(AVSampleRate);
        //由于需要压缩为MP3格式，所以此处必须为双声道
        _audioSettings[AVNumberOfChannelsKey] = @(2);
        _audioSettings[AVLinearPCMBitDepthKey] = @(16);
        _audioSettings[AVEncoderAudioQualityKey] = @(AVAudioQualityMin);
    }
    return _audioSettings;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isRecord = NO;
        isPause = NO;
        _audioPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audio.wav"];
    }
    return self;
}

#pragma mark - public method
- (void)startRecord{
    if (isRecord){
        if (isPause){
            isPause = NO;
            [audioRecorder record];
        }
    }else{
        isRecord = YES;
        isPause = NO;
        NSError *err;
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_audioPath] settings:self.audioSettings error:&err];
        if (err) {
            NSLog(@"创建audio recorder失败%@", err.localizedDescription);
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err.code userInfo:nil];
            NSLog(@"%@", error.description);
            return;
        }
        audioRecorder.delegate = self;
        [audioRecorder setMeteringEnabled:YES];
        [audioRecorder prepareToRecord];
        
        [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
        if (err){
            NSLog(@"%@", err.localizedDescription);
            return;
        }
        [AVAudioSession.sharedInstance setActive:YES error:&err];
        if (err){
            NSLog(@"%@", err.localizedDescription);
            return;
        }
        
        [audioRecorder record];
    }
}

- (void)pauseRecord{
    if (isRecord && !isPause){
        isPause = YES;
        [audioRecorder pause];
    }
}

- (void)endReocrd{
    if (isRecord){
        [audioRecorder stop];
        audioRecorder = nil;
    }
}

@end
