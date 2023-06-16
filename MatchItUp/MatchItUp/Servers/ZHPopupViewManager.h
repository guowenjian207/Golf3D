//
//  ZHPopupViewManager.h
//  MatchItUp
//
//  Created by 安子和 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SharedInstance.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHPopupViewManager : NSObject

SingleH(Manager)

- (void)showPromptViewWithSuperview:(nonnull UIView *)superview mode:(MBProgressHUDMode)mode title:(nullable NSString *)title icon:(nullable UIImage *)icon autoHideAfterDelayIfNeed:(nullable NSNumber *)delay;

- (void)removePromptView;

@end

NS_ASSUME_NONNULL_END
