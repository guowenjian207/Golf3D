//
//  NSDate+String.m
//  MatchItUp
//
//  Created by 安子和 on 2021/4/6.
//

#import "NSDate+String.h"

@implementation NSDate (String)

- (NSString *)time2String{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    return [formatter stringFromDate:self];
}

- (NSString *)date2String{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [formatter stringFromDate:self];
}

- (NSString *)dateToString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:self];
}
@end
