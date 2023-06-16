//
//  protractorLayer.h
//  TinyYOLO-CoreML
//
//  Created by 文昊天 on 2018/12/23.
//  Copyright © 2018年 MachineThink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#define angle_to_radia(x)   ( M_PI / 180 * (x) )
#define radia_to_angle(x)   ( 180 / M_PI * (x) )

//@protocol angelDelegate
//
//-(CGFloat) sendAngle:(CGFloat) angle;
//
//@end

@interface myProtractorLayer : CALayer

@property (nonatomic, copy) void (^callback)(CGFloat from, CGFloat to, CGFloat angle);
@property (nonatomic, assign, readonly) CGFloat protractor_nop;
@property (nonatomic, assign) CGFloat startAngle;                       // 起始角度
@property (nonatomic, assign) CGFloat endAngle;                         // 终止角度
@property (nonatomic, assign) CGPoint end_angle_position;               //终止圆点的坐标
@property (nonatomic, assign) CGPoint protractor_center;                // 中心圆圆心
//@property (nonatomic, weak) id<angelDelegate> angleDelegate;            // 角度代理

+ (myProtractorLayer *)drawProtractorLayer;
- (void)redrawIncludedAngleLineFromAngle:(CGFloat)from toAngle:(CGFloat)to;
- (void)redrawProtractorWithNewPosition:(CGPoint)newPosition;
- (CGFloat)point_to_angle:(CGPoint)point;
- (NSString*)getAngleFromAngelLayer;

@end /* protractorLayer_h */
