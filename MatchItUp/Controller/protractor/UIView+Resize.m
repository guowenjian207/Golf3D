//
//  UIView+Resize.m
//  TinyYOLO-CoreML
//
//  Created by 文昊天 on 2018/12/23.
//  Copyright © 2018年 MachineThink. All rights reserved.
//

#import "UIView+Resize.h"

@implementation UIView(Resize)

//x属性的get,set
-(void)setX:(CGFloat)x
{
    CGRect frame=[self frame];
    frame.origin.x=x;
    self.frame=frame;
}
-(CGFloat)x
{
    return self.frame.origin.x;
}
//centerX属性的get,set
-(void)setCenterX:(CGFloat)centerX
{
    CGPoint center=self.center;
    center.x=centerX;
    self.center=center;
}
-(CGFloat)centerX
{
    return self.center.x;
}
//centerY属性的get,set
-(void)setCenterY:(CGFloat)centerY
{
    CGPoint center=self.center;
    center.y=centerY;
    self.center=center;
}
-(CGFloat)centerY
{
    return self.center.y;
}
//y属性的get,set
-(void)setY:(CGFloat)y
{
    CGRect frame=self.frame;
    frame.origin.y=y;
    self.frame=frame;
}
-(CGFloat)y
{
    return self.frame.origin.y;
}
//width属性的get,set
-(void)setWidth:(CGFloat)width
{
    CGRect frame=self.frame;
    frame.size.width=width;
    self.frame=frame;
}
-(CGFloat)width
{
    return self.frame.size.width;
}
//height属性的get,set
-(void)setHeight:(CGFloat)height
{
    CGRect frame=self.frame;
    frame.size.height=height;
    self.frame=frame;
}
-(CGFloat)height
{
    return self.frame.size.height;
}
//size属性的get,set
-(void)setSize:(CGSize)size
{
    CGRect frame=self.frame;
    frame.size.width=size.width;
    frame.size.height=size.height;
    self.frame=frame;
}
-(CGSize)size
{
    return self.frame.size;
}
//origin属性的get,set,用于设置坐标
-(void)setOrigin:(CGPoint)origin
{
    CGRect frame=self.frame;
    frame.origin.x=origin.x;
    frame.origin.y=origin.y;
    self.frame=frame;
}
-(CGPoint)origin
{
    return self.frame.origin;
}

- (CGFloat)left{
    return self.x;
}

- (void)setLeft:(CGFloat)left {
    self.x = left;
}

- (CGFloat)right {
    return self.x + self.width;
}

- (void)setRight:(CGFloat)right {
    self.x = right - self.width;
}

- (CGFloat)top {
    return self.y;
}

- (void)setTop:(CGFloat)top {
    self.y = top;
}

- (CGFloat)bottom {
    return self.y + self.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}

@end
