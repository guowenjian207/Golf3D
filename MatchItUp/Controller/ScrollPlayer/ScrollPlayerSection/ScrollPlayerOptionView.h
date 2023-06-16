//
//  ScrollPlayerOptionView.h
//  MatchItUp
//
//  Created by 安子和 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollPlayerOptionButton : UIButton

@property(nonatomic, copy) void (^tapAction)(void);
@property(nonatomic, strong) NSString *title;

@end

@interface ScrollPlayerOptionView : UIView

@property(nonatomic, strong) NSArray<ScrollPlayerOptionButton *> *buttons;

@end

NS_ASSUME_NONNULL_END
