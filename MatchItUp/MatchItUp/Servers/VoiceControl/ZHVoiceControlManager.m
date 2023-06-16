//
//  ZHVoiceControlManager.m
//  Sport
//
//  Created by 安子和 on 2021/5/3.
//

#import "ZHVoiceControlManager.h"
#import "ZHSpeechManager.h"

@interface ZHVoiceControlManager () <ZHSpeechManagerDelegate>{
    NSUInteger startCount;
    NSUInteger endCount;
    ZHSpeechManager *speechManager;
}

@end

@implementation ZHVoiceControlManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        startCount = 0;
        endCount = 0;
        speechManager = [[ZHSpeechManager alloc] init];
        speechManager.delegate = self;
    }
    return self;
}

- (void)run{
    [speechManager startRecognize];
}

- (void)cancel{
    [speechManager endRecognize];
}

- (void)check:(nonnull NSString *)result {
    NSLog(@"%@", result);
    NSUInteger len = result.length;
    if (len >= 2){
        if ([result containsString:@"返回"]){
            [_delegate back];
            return;
        }
        NSString *sub;
        NSUInteger startC = 0;
        NSUInteger endC = 0;
        for (NSUInteger i=0; i<=len-2; ++i) {
            sub = [result substringWithRange:NSMakeRange(i, 2)];
            if ([sub  isEqual: @"开始"]){
                ++startC;
            }else if ([sub  isEqual: @"结束"] || [sub  isEqual: @"完成"]){
                ++endC;
            }
        }
        if (startC > startCount){
            startCount = startC;
            [_delegate startRecord];
            return;
        }
        if (endC > endCount){
            endCount = endC;
            [_delegate endRecord];
            return;
        }
    }
}

- (void)reset{
    startCount = 0;
    endCount = 0;
}

@end
