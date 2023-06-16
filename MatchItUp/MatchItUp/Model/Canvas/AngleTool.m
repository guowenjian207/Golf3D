//
//  AngleTool.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/21.
//

#import "AngleTool.h"

@implementation AngleTool
{
    UIView *superview;
    UIView *nodeA;
    CGPoint originPointA;
    UIView *nodeB;
    CGPoint originPointB;
    UIView *nodeO;
    CGPoint originPointO;
    UILabel *angleLabel;
    UIBezierPath *fillPath;
    CAShapeLayer *fillLayer;
    UIBezierPath *linePath;
    CAShapeLayer *lineLayer;
}

- (instancetype)initWithSuperiew:(UIView *)superview andColor:(UIColor *)color{
    self = [super init];
    if (self){
        self->superview = superview;
        
        nodeA = [[UIView alloc]initWithFrame:CGRectMake(superview.frame.size.width / 3, superview.frame.size.height / 2, 30, 30)];
        [nodeA.layer setBorderColor:color.CGColor];
        [nodeA.layer setBorderWidth:2];
        [nodeA.layer setCornerRadius:15];
        UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panNodeA:)];
        [nodeA addGestureRecognizer:panA];
        [superview addSubview:nodeA];
        
        nodeB = [[UIView alloc]initWithFrame:CGRectMake(superview.frame.size.width / 2, superview.frame.size.height / 2, 30, 30)];
        [nodeB.layer setBorderColor:color.CGColor];
        [nodeB.layer setBorderWidth:2];
        [nodeB.layer setCornerRadius:15];
        UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panNodeB:)];
        [nodeB addGestureRecognizer:panB];
        [superview addSubview:nodeB];
        
        nodeO = [[UIView alloc]initWithFrame:CGRectMake(superview.frame.size.width * 2 / 3, superview.frame.size.height / 2, 30, 30)];
        [nodeO.layer setBorderColor:color.CGColor];
        [nodeO.layer setBorderWidth:2];
        [nodeO.layer setCornerRadius:15];
        UIPanGestureRecognizer *panO = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panNodeO:)];
        [nodeO addGestureRecognizer:panO];
        [superview addSubview:nodeO];
        
        angleLabel = [[UILabel alloc]initWithFrame:CGRectMake(22, 22, 60, 20)];
        [angleLabel setTextColor:color];
        [angleLabel setText:@"45°"];
        [nodeO addSubview:angleLabel];

        fillPath = [[UIBezierPath alloc]init];
        [fillPath moveToPoint:nodeA.center];
        [fillPath addLineToPoint:nodeO.center];
        [fillPath addLineToPoint:nodeB.center];
        [fillPath closePath];
        
        fillLayer = [[CAShapeLayer alloc]init];
        [fillLayer setFrame:superview.bounds];
        [fillLayer setFillColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.25].CGColor];
        [fillLayer setPath:fillPath.CGPath];
        [superview.layer addSublayer:fillLayer];
        
        linePath = [[UIBezierPath alloc]init];
        linePath.lineWidth = 2.0;
        [linePath moveToPoint:nodeA.center];
        [linePath addLineToPoint:nodeO.center];
        [linePath addLineToPoint:nodeB.center];
        
        lineLayer = [[CAShapeLayer alloc]init];
        [lineLayer setFrame:superview.bounds];
        [lineLayer setStrokeColor:color.CGColor];
        [lineLayer setFillColor:[UIColor clearColor].CGColor];
        [lineLayer setPath:linePath.CGPath];
        [superview.layer addSublayer:lineLayer];
    }
    return self;
}

- (void)dealloc
{
    [nodeA removeFromSuperview];
    [nodeB removeFromSuperview];
    [nodeO removeFromSuperview];
    [fillLayer removeFromSuperlayer];
    [lineLayer removeFromSuperlayer];
}

- (UIView *)nodeA {
    return nodeA;
}

- (UIView *)nodeB {
    return nodeB;
}

- (UIView *)nodeO {
    return nodeO;
}

- (void)update{
    [fillPath removeAllPoints];
    [fillPath moveToPoint:nodeA.center];
    [fillPath addLineToPoint:nodeO.center];
    [fillPath addLineToPoint:nodeB.center];
    [fillPath closePath];
    [fillLayer setPath:fillPath.CGPath];
    
    [linePath removeAllPoints];
    linePath = [[UIBezierPath alloc]init];
    [linePath moveToPoint:nodeA.center];
    [linePath addLineToPoint:nodeO.center];
    [linePath addLineToPoint:nodeB.center];
    [lineLayer setPath:linePath.CGPath];
    
    
    double o = sqrt(pow((nodeA.center.x-nodeB.center.x), 2)+pow((nodeA.center.y-nodeB.center.y), 2));
    double a = sqrt(pow((nodeO.center.x-nodeB.center.x), 2)+pow((nodeO.center.y-nodeB.center.y), 2));
    double b = sqrt(pow((nodeO.center.x-nodeA.center.x), 2)+pow((nodeO.center.y-nodeA.center.y), 2));
    double angle = acos((pow(a, 2)+pow(b, 2)-pow(o, 2))/(2*a*b))/M_PI*180;
    [angleLabel setText:[NSString stringWithFormat:@"%.1f°",angle]];
}

- (void)panNodeA:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            originPointA = nodeA.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:superview];
            [nodeA setCenter:CGPointMake(originPointA.x+translation.x, originPointA.y+translation.y)];
            [self update];
        }
        default:
            break;
    }
}

- (void)panNodeB:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            originPointB = nodeB.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:superview];
            [nodeB setCenter:CGPointMake(originPointB.x+translation.x, originPointB.y+translation.y)];
            [self update];
        }
        default:
            break;
    }
}

- (void)panNodeO:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            originPointO = nodeO.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:superview];
            [nodeO setCenter:CGPointMake(originPointO.x+translation.x, originPointO.y+translation.y)];
            [self update];
        }
        default:
            break;
    }
}

@end
