//
//  AngleTool.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AngleTool : NSObject

@property(nonatomic, readonly, strong) UIView *nodeA;
@property(nonatomic, readonly, strong) UIView *nodeB;
@property(nonatomic, readonly, strong) UIView *nodeO;

- (instancetype)initWithSuperiew:(UIView *)superview andColor:(UIColor *)color;

- (void)update;

@end

NS_ASSUME_NONNULL_END
