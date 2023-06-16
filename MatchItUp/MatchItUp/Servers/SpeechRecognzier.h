//
//  SpeechRecognzier.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/13.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

NS_ASSUME_NONNULL_BEGIN

//Speech语音识别协议
@protocol SpeechRecognizerDelegate;

@interface SpeechRecognzier : NSObject<SFSpeechRecognizerDelegate>

@property(nonatomic,weak) id<SpeechRecognizerDelegate> delegate;

- (void)setup;
- (void)startRecognize;
- (void)endRecognize;

@end

@protocol SpeechRecognizerDelegate <NSObject>

- (void)checkResult:(NSString *)result;

@end

NS_ASSUME_NONNULL_END
