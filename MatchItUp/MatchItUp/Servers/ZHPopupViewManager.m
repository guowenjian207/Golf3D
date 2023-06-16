//
//  ZHPopupViewManager.m
//  MatchItUp
//
//  Created by 安子和 on 2021/7/1.
//

#import "ZHPopupViewManager.h"

@implementation ZHPopupViewManager {
    MBProgressHUD *promptView;
}

SingleM(Manager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        promptView = [[MBProgressHUD alloc] init];
        promptView.removeFromSuperViewOnHide = YES;
        promptView.label.numberOfLines = 0;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:promptView action:@selector(hideAnimated:)];
        [promptView.backgroundView addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)showPromptViewWithSuperview:(nonnull UIView *)superview mode:(MBProgressHUDMode)mode title:(nullable NSString *)title icon:(nullable UIImage *)icon autoHideAfterDelayIfNeed:(nullable NSNumber *)delay{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->promptView removeFromSuperview];
        self->promptView.mode = mode;
        self->promptView.label.text = title;
        self->promptView.customView = icon ? [[UIImageView alloc] initWithImage:icon] : NULL;
        [superview addSubview:self->promptView];
        [self->promptView showAnimated:YES];
        if (delay) {
            [self->promptView hideAnimated:YES afterDelay:[delay floatValue]];
        }
    });
}

- (void)removePromptView {
    [self->promptView removeFromSuperview];
}

@end
