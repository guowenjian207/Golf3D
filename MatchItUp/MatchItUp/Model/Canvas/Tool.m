//
//  Tool.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/1/4.
//

#import "Tool.h"

@implementation Tool

- (instancetype)initWithLinePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.tool = Line;
        self.pointArray = [[NSMutableArray alloc] init];
        [self.pointArray addObject:NSStringFromCGPoint(point1)];
        [self.pointArray addObject:NSStringFromCGPoint(point2)];
        self.color = color;
    }
    return self;
}

- (instancetype)initWithRectPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.tool = Rectangle;
        self.pointArray = [[NSMutableArray alloc] init];
        [self.pointArray addObject:NSStringFromCGPoint(point1)];
        [self.pointArray addObject:NSStringFromCGPoint(point2)];
        self.color = color;
    }
    return self;
}

- (instancetype)initWithCirclePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.tool = Circle;
        self.pointArray = [[NSMutableArray alloc] init];
        [self.pointArray addObject:NSStringFromCGPoint(point1)];
        [self.pointArray addObject:NSStringFromCGPoint(point2)];
        self.color = color;
    }
    return self;
}

- (instancetype)initWithPoints:(NSMutableArray *)pointArray andColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.tool = Curve;
        self.pointArray = [pointArray mutableCopy];
        self.color = color;
    }
    return self;
}

- (instancetype)initWithAnglePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.tool = Angle;
        self.pointArray = [[NSMutableArray alloc] init];
        [self.pointArray addObject:NSStringFromCGPoint(point1)];
        [self.pointArray addObject:NSStringFromCGPoint(point2)];
        [self.pointArray addObject:NSStringFromCGPoint(point3)];
        self.color = color;
    }
    return self;
}

- (void)updateWithContentSize:(CGSize)size {
    if (_tool == Line) {
        [_toolPath removeAllPoints];
        CGPoint p1 = CGPointFromString(_pointArray[0]);
        CGPoint p2 = CGPointFromString(_pointArray[1]);
        [_toolPath moveToPoint:CGPointMake(size.width * p1.x, size.height * p1.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p2.x, size.height * p2.y)];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if (_tool == Curve) {
        [_toolPath removeAllPoints];
        CGPoint p1 = CGPointFromString(_pointArray[0]);
        [_toolPath moveToPoint:CGPointMake(size.width * p1.x, size.height * p1.y)];
        for (int i = 1; i < _pointArray.count; i++) {
            CGPoint tmpPoint = CGPointFromString(_pointArray[i]);
            [_toolPath addLineToPoint:CGPointMake(size.width * tmpPoint.x, size.height * tmpPoint.y)];
        }
        _toolLayer.path = _toolPath.CGPath;
    }
    else if (_tool == Rectangle) {
        [_toolPath removeAllPoints];
        CGPoint p1 = CGPointFromString(_pointArray[0]);
        CGPoint p2 = CGPointFromString(_pointArray[1]);
        [_toolPath moveToPoint:CGPointMake(size.width * p1.x, size.height * p1.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p1.x, size.height * p2.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p2.x, size.height * p2.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p2.x, size.height * p1.y)];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if (_tool == Curve) {
        [_toolPath removeAllPoints];
        CGPoint p = CGPointFromString(_pointArray[0]);
        [_toolPath moveToPoint:CGPointMake(size.width * p.x, size.height * p.y)];
        for (int i = 1; i < _pointArray.count; i++) {
            CGPoint pointTmp = CGPointFromString(_pointArray[i]);
            [_toolPath addLineToPoint:CGPointMake(size.width * pointTmp.x, size.height * pointTmp.y)];
        }
        _toolLayer.path = _toolPath.CGPath;
    }
    else if (_tool == Circle) {
        [_toolPath removeAllPoints];
        CGPoint p1 = CGPointFromString(_pointArray[0]);
        CGPoint p2 = CGPointFromString(_pointArray[1]);
        p1 = CGPointMake(p1.x * size.width, p1.y * size.height);
        p2 = CGPointMake(p2.x * size.width, p2.y * size.height);
        CGFloat x = fmin(p1.x, p2.x);
        CGFloat y = fmin(p1.y, p2.y);
        CGFloat w = fabs(p1.x - p2.x);
        CGFloat h = fabs(p1.y - p2.y);
        _toolPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, w, h)];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if (_tool == Angle) {
        [_toolPath removeAllPoints];
        CGPoint p1 = CGPointFromString(_pointArray[0]);
        CGPoint p2 = CGPointFromString(_pointArray[1]);
        CGPoint p3 = CGPointFromString(_pointArray[2]);
        [_toolPath moveToPoint:CGPointMake(size.width * p1.x, size.height * p1.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p2.x, size.height * p2.y)];
        [_toolPath addLineToPoint:CGPointMake(size.width * p3.x, size.height * p3.y)];
        _toolLayer.path = _toolPath.CGPath;
        
        CGPoint p11 = CGPointMake(size.width * p1.x, size.height * p1.y);
        CGPoint p22 = CGPointMake(size.width * p2.x, size.height * p2.y);
        CGPoint p33 = CGPointMake(size.width * p3.x, size.height * p3.y);
        _angleLabel.frame = CGRectMake(p2.x * size.width, p2.y * size.height, size.width / 5.5, size.width / 5.5 / 3);
        if (p11.x == p33.x) {
            [_angleLabel setCenter:p22];
        }
        else {
            float labelFontSize = size.width / 19.5;
            labelFontSize = labelFontSize > 20 ? 20 : labelFontSize;
            [_angleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize]];
            CGFloat distance = size.width / 9.75;
            distance = distance > 40 ? 40 : distance;
            CGPoint p1 = [self getPointWithPoint1:p22 andPoint2:p11 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:p22 andPoint2:p33 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:p22 andPoint2:CGPointMake(p1.x + p2.x - p22.x, p1.y + p2.y - p22.y) andDistance:distance];
            [_angleLabel setCenter:p3];
        }
        [_angleLabel setText:[self computeAngleWithP1:CGPointMake(size.width * p1.x, size.height * p1.y)
                                                andP2:CGPointMake(size.width * p2.x, size.height * p2.y)
                                                andP3:CGPointMake(size.width * p3.x, size.height * p3.y)]];
    }
}

- (CGPoint)getPointWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andDistance:(CGFloat)distance {
    CGFloat k;
    if (fabs(point2.x - point1.x) < 0.1) {
        k = 10000;
    }
    else {
        k = (point2.y - point1.y) / (point2.x - point1.x);
    }
    CGFloat bias = point2.y - k * point2.x;
    CGFloat a = (1 + k * k);
    CGFloat b = -2 * point1.x + 2 * (bias - point1.y) * k;
    CGFloat c = point1.x * point1.x + (bias - point1.y) * (bias - point1.y) - distance * distance;
    CGFloat x1 = (-b + sqrt(b * b - 4 * a * c)) / (2 * a), y1 = k * x1 + bias;
    CGFloat x2 = (-b - sqrt(b * b - 4 * a * c)) / (2 * a), y2 = k * x2 + bias;
    CGFloat x, y;
    if ((x1 - point2.x) * (x1 - point2.x) + (y1 - point2.y) * (y1 - point2.y) <
        (x2 - point2.x) * (x2 - point2.x) + (y2 - point2.y) * (y2 - point2.y)) {
        x = x1;
        y = y1;
    }
    else {
        x = x2;
        y = y2;
    }
    return CGPointMake(x, y);
}

- (NSString *)computeAngleWithP1:(CGPoint)point1 andP2:(CGPoint)point2 andP3:(CGPoint)point3 {
    double o = sqrt(pow((point1.x-point3.x), 2)+pow((point1.y-point3.y), 2));
    double a = sqrt(pow((point2.x-point3.x), 2)+pow((point2.y-point3.y), 2));
    double b = sqrt(pow((point2.x-point1.x), 2)+pow((point2.y-point1.y), 2));
    double angle = acos((pow(a, 2)+pow(b, 2)-pow(o, 2))/(2*a*b))/M_PI*180;
    return [NSString stringWithFormat:@"%.1f°",angle];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.tool = [coder decodeIntegerForKey:@"tool"];
        self.pointArray = [coder decodeObjectForKey:@"pointArray"];
        NSNumber *colorTmp = [coder decodeObjectForKey:@"color"];
        NSArray *colorArr = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor blackColor]];
        self.color = colorArr[[colorTmp intValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.tool forKey:@"tool"];
    [coder encodeObject:self.pointArray forKey:@"pointArray"];
    NSDictionary *colorDic = @{[UIColor redColor] : @0, [UIColor yellowColor] : @1, [UIColor greenColor] : @2, [UIColor blueColor] : @3, [UIColor blackColor] : @4};
    [coder encodeObject:colorDic[self.color] forKey:@"color"];
}

@end
