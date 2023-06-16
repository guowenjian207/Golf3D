//
//  UIView+Frame.m
//  MatchItUp
//
//  Created by 安子和 on 2021/3/28.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size{
    return self.frame.size;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)headX{
    return self.x;
}

- (void)setHeadX:(CGFloat)headX{
    CGRect frame = self.frame;
    if (headX > self.tailX){
        frame.origin.x = self.tailX;
        frame.size.width = headX - self.tailX;
    }else{
        frame.origin.x = headX;
        frame.size.width += (self.x - headX);
    }
    self.frame = frame;
}

- (CGFloat)tailX{
    return self.x + self.width;
}

- (void)setTailX:(CGFloat)tailX{
    CGRect frame = self.frame;
    if (tailX < self.headX){
        frame.origin.x = tailX;
        frame.size.width = self.headX - tailX;
    }else{
        frame.size.width = tailX - self.headX;
    }
    self.frame = frame;
}

@end
