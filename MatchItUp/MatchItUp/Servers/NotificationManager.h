//
//  NotificationManager.h
//  MatchItUp
//
//  Created by 安子和 on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import "SharedInstance.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationManager : NSObject

SingleH(Manager)

- (void)pushLocalNotification:(NSString *)swingId;

@end

NS_ASSUME_NONNULL_END
