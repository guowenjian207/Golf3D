//
//  PoseView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/10/21.
//

#import "PoseView.h"

@implementation PoseView {
    NSMutableArray *dots;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setDots:(NSMutableArray *)dots1
{
    dots = dots1;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    if (!dots) {
        return;
    }
    [self drawLineWithIdx1:5 andIdx2:6];
    [self drawLineWithIdx1:5 andIdx2:7];
    [self drawLineWithIdx1:6 andIdx2:8];
    [self drawLineWithIdx1:7 andIdx2:9];
    [self drawLineWithIdx1:8 andIdx2:10];
    [self drawLineWithIdx1:5 andIdx2:11];
    [self drawLineWithIdx1:6 andIdx2:12];
    [self drawLineWithIdx1:11 andIdx2:12];
    [self drawLineWithIdx1:11 andIdx2:13];
    [self drawLineWithIdx1:12 andIdx2:14];
    [self drawLineWithIdx1:13 andIdx2:15];
    [self drawLineWithIdx1:14 andIdx2:16];
    [self drawDotWithIdx:0];
    for (int i = 5; i < 17; i++) {
        [self drawDotWithIdx:i];
    }
}

- (void)drawLineWithIdx1:(int)idx1 andIdx2:(int)idx2 {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置绘制的颜色
    [[UIColor redColor] setStroke];
    // 设置线条的宽度
    CGContextSetLineWidth(context, 2.0);
    // 设置线条绘制的起始点
    CGContextMoveToPoint(context, [dots[idx1] CGPointValue].x, [dots[idx1] CGPointValue].y);
    // 添加线条路径
    CGContextAddLineToPoint(context, [dots[idx2] CGPointValue].x, [dots[idx2] CGPointValue].y);
    // 执行绘制路径操作
    CGContextStrokePath(context);
}

- (void)drawDotWithIdx:(int)idx {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor redColor] setFill];
    CGContextSetLineWidth(context, 2.0);
    CGContextAddArc(context, [dots[idx] CGPointValue].x, [dots[idx] CGPointValue].y, 2, 0, M_PI*2, 0);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
