//
//  ZHSpeechManager.h
//  Sport
//
//  Created by 安子和 on 2021/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZHSpeechManagerDelegate <NSObject>

- (void)check:(NSString *)result;
- (void)reset;

@end

@interface ZHSpeechManager : NSObject

@property(nonatomic, weak) id<ZHSpeechManagerDelegate> delegate;

- (void)startRecognize;
- (void)endRecognize;

@end

NS_ASSUME_NONNULL_END
