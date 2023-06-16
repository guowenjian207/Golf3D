//
//  CountDownView.m
//  timerTest
//
//  Created by ios2chen on 2017/8/22.
//  Copyright © 2017年 Lfy. All rights reserved.
//

#import "CountDownView.h"

@implementation CountDownView{
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.frame.size.height/2 startAngle:-M_PI_2 endAngle:M_PI*3/2 clockwise:1];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5.0f;
    
    if ([self.flag isEqualToString:@"track"]) {
        shapeLayer.strokeColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1].CGColor;
    }else{
        shapeLayer.strokeColor = [UIColor colorWithRed:191/255.0f green:0/255.0f blue:0/255.0f alpha:1].CGColor;
    }
    
    //每个虚线长度为2，间隔为3
    shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil];
    [self.layer addSublayer:shapeLayer];
    _shapeLayer=shapeLayer;
    
}
-(void)addAmation{
    if ([self.flag isEqualToString:@"process"]) {
        CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnima.duration = self.time;
        pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
//        pathAnima.fillMode = kCAFillModeForwards;
        pathAnima.removedOnCompletion = NO;
//        pathAnima.autoreverses=YES;
        pathAnima.repeatCount=HUGE_VAL;
        [_shapeLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
        _pathAnima=pathAnima;
    }
}

@end
