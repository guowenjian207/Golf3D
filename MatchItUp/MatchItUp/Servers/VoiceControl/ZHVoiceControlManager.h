//
//  ZHVoiceControlManager.h
//  Sport
//
//  Created by 安子和 on 2021/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZHVoiceControlManagerDelegate <NSObject>

- (void)startRecord;
- (void)endRecord;
- (void)back;

@end

@interface ZHVoiceControlManager : NSObject

@property(nonatomic, weak) id<ZHVoiceControlManagerDelegate> delegate;

- (void)run;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
