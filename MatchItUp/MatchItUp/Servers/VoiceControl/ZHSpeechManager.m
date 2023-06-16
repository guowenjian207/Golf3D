//
//  ZHSpeechManager.m
//  Sport
//
//  Created by 安子和 on 2021/5/3.
//

#import "ZHSpeechManager.h"
#import <Speech/Speech.h>

@interface ZHSpeechManager () <SFSpeechRecognizerDelegate>

@end

@implementation ZHSpeechManager{
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
    AVAudioNode *inputNode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
        self->speechRecognizer.delegate = self;
        self->audioEngine = [[AVAudioEngine alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusAuthorized:{
                        NSLog(@"可以的");
//                        self->speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
//                        self->speechRecognizer.delegate = self;
//                        self->audioEngine = [[AVAudioEngine alloc] init];
                    }
                        break;
                    case SFSpeechRecognizerAuthorizationStatusDenied:
                        NSLog(@"拒绝了");
                        break;
                    case SFSpeechRecognizerAuthorizationStatusRestricted:
                        NSLog(@"受限");
                        break;
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                        NSLog(@"出错了");
                        break;
                    default:
                        NSLog(@"不知道怎么了");
                        break;
                }
            }];
        });
    }
    return self;
}

- (void)dealloc
{
    [self endRecognize];
}

- (void)startRecognize{
    [_delegate reset];
    
    if (recognitionTask){
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    NSError *err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&err];
    if (err){
        NSLog(@"%@", err.localizedDescription);
        return;
    }
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    if (err){
        NSLog(@"%@", err.localizedDescription);
        return;
    }
    
    inputNode = audioEngine.inputNode;
    
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    if (recognitionRequest == nil) {
        NSLog(@"Unable to create a SFSpeechAudioBufferRecognitionRequest object");
        return;
    }
    recognitionRequest.requiresOnDeviceRecognition = YES;
    if (@available(iOS 13, *)){
        recognitionRequest.requiresOnDeviceRecognition = YES;
    }
    
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result){
            isFinal = result.isFinal;
            [self.delegate check:result.bestTranscription.formattedString];
        }
        
        if (err || isFinal){
            if (err){
                NSLog(@"%@", err.localizedDescription);
            }else{
                NSLog(@"一轮语音识别结束");
            }
            
            [self->audioEngine stop];
            [self->inputNode removeTapOnBus:0];
            
            [self->recognitionRequest endAudio];
            self->recognitionRequest = nil;
            
            [self->recognitionTask cancel];
            self->recognitionTask = nil;
            
            if (err == nil){
                [self startRecognize];
            }
        }
    }];
    
    AVAudioFormat *format = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self->recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:&err];
    if (err){
        NSLog(@"%@", err);
    }
}

- (void)endRecognize{
    [audioEngine stop];
    
    [inputNode removeTapOnBus:0];
    
    [recognitionRequest endAudio];
    recognitionRequest = nil;
    
    [recognitionTask cancel];
    recognitionTask = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if (available){
        NSLog(@"start recording");
    }else{
        NSLog(@"recognition not available");
    }
}

@end
