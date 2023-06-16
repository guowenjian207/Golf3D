//
//  ZHScreenRecordManager.h
//  ZHScreenRecordManager
//
//  Created by 安子和 on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import "SharedInstance.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHScreenRecordManager : NSObject

//SingleH(Manager)

- (void)startRecord;
- (void)pauseRecord;
- (void)endReocrd:(void (^)(NSString *filePath))completion;

+ (void)startRecord:(void (^)(BOOL success, NSError *error))completionHandler;
+ (void)endRecord:(void (^)(NSString *filePath, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
