//
//  SpeechRecognzier.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/13.
//

#import "SpeechRecognzier.h"

@implementation SpeechRecognzier{
    SFSpeechRecognizer *recognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
    AVAudioInputNode *audioInputNode;
    
    int startCount;
    int endCount;
}

- (void)setup{
    recognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    recognizer.delegate = self;
    audioEngine = [[AVAudioEngine alloc]init];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status){
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    NSLog(@"SpeechRecognizer authorized");
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    NSLog(@"SpeechRecognizer denied");
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    NSLog(@"SpeechRecognizer restricted");
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    NSLog(@"SpeechRecognizer not determined");
                default:
                    break;
            }
        }];
    });
    startCount = 0;
    endCount = 0;
}

- (void)startRecognize{
    NSError *err;
    
    //配置音频输入
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&err];
    if (err != nil){
        NSLog(@"AVAudioSession配置失败%@",err.localizedDescription);
        return;
    }
    [audioSession setActive:YES error:&err];
    if (err != nil){
        NSLog(@"AVAudioSession激活失败%@",err.localizedDescription);
        return;
    }
    audioInputNode = audioEngine.inputNode;
    //识别请求
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    if (recognitionRequest == nil){
        NSLog(@"Unable to create a SFSpeechAudioBufferRecognitionRequest object");
        return;
    }
    recognitionRequest.shouldReportPartialResults = YES;
    recognitionRequest.requiresOnDeviceRecognition = YES;

    recognitionTask = [recognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult *result,NSError *error){
        BOOL isFinal = NO;
        if (result != nil){
            isFinal = result.final;
            [self->_delegate checkResult:result.bestTranscription.formattedString];
        }
        if (error != nil || isFinal){
            if (error != nil){
                NSLog(@"语音识别error%@",error.localizedDescription);
            }else{
                NSLog(@"语音识别task结束");
            }
            
            [self endRecognize];
            
            [self startRecognize];
        }
    }];
    
    //配置麦克风输入
    AVAudioFormat *audioForamt = [audioInputNode outputFormatForBus:0];
    [audioInputNode installTapOnBus:0 bufferSize:1024 format:audioForamt block:^(AVAudioPCMBuffer *buffer, AVAudioTime* time){
        [self->recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [audioEngine prepare];
    [audioEngine startAndReturnError:&err];
    if (err != nil){
        NSLog(@"AVAudioEngine启动失败%@",err.localizedDescription);
    }
}

- (void)endRecognize{
    [audioEngine stop];
    [audioInputNode removeTapOnBus:0];
    
    [recognitionRequest endAudio];
    recognitionRequest = nil;
    
    [recognitionTask cancel];
    recognitionTask = nil;
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if (available){
        NSLog(@"Start recording");
    }else{
        NSLog(@"Recognition not available");
    }
}

@end
