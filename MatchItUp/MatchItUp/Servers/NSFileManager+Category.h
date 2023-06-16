//
//  NSFileManager+Category.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GlobalVar.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Category)

- (void)checkDirectory;

- (void)cutTmpVideoWith:(void (^)(void))completion;

+(NSString *)md5HashOfPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
