//
//  NSString+StringPlus.h
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (StringPlus)

- (NSString *)deviceType;

- (NSString *)makeSHA256;

- (NSData *)dataUsingUTF8Encoding;

- (BOOL)isPassword;

- (BOOL)isUsername;

@end

NS_ASSUME_NONNULL_END
