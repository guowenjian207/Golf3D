//
//  NotificationManager.m
//  MatchItUp
//
//  Created by 安子和 on 2021/6/10.
//

#import "NotificationManager.h"
#import <UserNotifications/UserNotifications.h>

@implementation NotificationManager

SingleM(Manager)

- (void)pushLocalNotification:(NSString *)swingId {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = swingId;
    content.body = @"";
    content.sound = [UNNotificationSound defaultSound];
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:1] timeIntervalSinceNow];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
    NSString *identifier = @"noticeId";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        if (error) {
            NSLog(@"添加推送失败:%@", error.localizedDescription);
        } else {
            NSLog(@"成功添加推送");
        }
    }];
}

@end
