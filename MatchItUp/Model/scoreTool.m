//
//  scoreTool.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/16.
//

#import "scoreTool.h"
#import <objc/runtime.h>

@implementation scoreTool

+ (instancetype)scoreToolWithDic:(NSDictionary *)dic {
    id objc = [[self alloc] init];
    
    unsigned int count;
    
    // 获取类中的所有成员属性
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员属性名->字典中的key
        // 从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        
        // 根据成员属性名去字典中查找对应的value
        id value = dic[key];
        if (value) {
            [objc setValue:value forKey:key];
        }
    }
    
    return objc;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\r%@\r%@\r%@\r%@\r%@\r%@\r%d\r%d\r%d", _name, _type, _frame, _x1, _y1, _x2, _y2, _LRMovable, _UDMovable, _Rotatable];
}

- (void)updateWithContentSize:(CGSize)size andvideoH:(float) h andvideoW:(float)w{
    int frameIdx = [_frame intValue];
    float gap = 10 * size.width / [UIScreen mainScreen].bounds.size.width;
    float aveWidth = (size.width - gap) / 5;
    float aveHeight = size.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    
    if(h==0&&w==0){
        w=1280;
        h=720;
    }
    float newheight=aveWidth*(h/w);
    float newoffsetY=(aveHeight-newheight)/2;
    CGPoint point1, point2, point3, point4;
    if ([_type isEqual:@"Line"] || [_type isEqual:@"LineWithNode"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"ExternLineWithNode"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x / 3, offset.y / 3);
        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"SingleExternLineWithNode"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x, offset.y);
//        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"Angle"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(_x3.floatValue, _y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        [_toolPath addLineToPoint:point3];
        [_toolPath moveToPoint:point2];
        CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
        [_toolPath addLineToPoint:point4];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"Rect"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [_toolPath addLineToPoint:point2];
        [_toolPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"Quadrilateral"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(_x3.floatValue, _y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        point4 = CGPointMake(_x4.floatValue, _y4.floatValue);
        point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        [_toolPath addLineToPoint:point4];
        [_toolPath addLineToPoint:point3];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"Ruler"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [_toolPath moveToPoint:point2];
        [_toolPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }
    else if ([_type isEqual:@"RotateRect"]) {
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(_x3.floatValue, _y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        [_toolPath addLineToPoint:point3];
        [_toolPath addLineToPoint:point4];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }else if ([_type isEqual:@"Curve"]){
        [_toolPath removeAllPoints];
        point1 = CGPointFromString(_pointArray[0]);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * newheight + offsetY+newoffsetY);
        [_toolPath moveToPoint:point1];
        for (int i = 1; i < _pointArray.count; i++) {
            point2 = CGPointFromString(_pointArray[i]);
//            if(point2.x<0.001||point2.x>0.999||point2.y<0.001||point2.y>0.999)
            if(i+1<_pointArray.count)
            {
                point1 = CGPointFromString(_pointArray[i+1]);
                if((fabs(point1.y-point2.y)<0.01&&fabs(point1.x-point2.x)>0.1)||(fabs(point1.x-point2.x)<0.01&&fabs(point1.y-point2.y)>0.1)){
                    point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * newheight + offsetY+newoffsetY);
                    point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                    [_toolPath addLineToPoint:point2];
                    [_toolPath moveToPoint:point1];
                }else{
                    point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                    [_toolPath addLineToPoint:point2];
                }
            }else{
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                [_toolPath addLineToPoint:point2];
            }
        }
        _toolLayer.path = _toolPath.CGPath;
    }
    _label.frame = CGRectMake(point1.x, point1.y - 40, 80, 40);
    if ([_frame intValue] == 0 && ([_name isEqual:@"Shaft Line To Armpit"] || [_name isEqual:@"Elbow-Hosel Line"])) {
        _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 60, 30);
        _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
    }
    else if ([_frame intValue] == 2 && ([_name isEqual:@"Club Face Angle"] || [_name isEqual:@"Elbow-Hosel Line"])) {
        if ([_name isEqual:@"Club Face Angle"]) {
            _angleLabel1.frame = CGRectMake(point3.x + 5, point3.y - 10, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point3 andP3:CGPointMake(point3.x + 10, point3.y)];
        }
        else {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    else if ([_frame intValue] == 3 && ([_name isEqual:@"Shaft Line"])) {
        _angleLabel1.frame = CGRectMake(point1.x + 10, point1.y - 10, 60, 30);
        _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
    }
    else if ([_frame intValue] == 4 && ([_name isEqual:@"Shoulder Tilt"] || [_name isEqual:@"Shaft Line"])) {
        _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 60, 30);
        _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
    }
    else if ([_frame intValue] == 6 && ([_name isEqual:@"Shaft Line"] || [_name isEqual:@"Elbow Line"] || [_name isEqual:@"Shaft Line To Armpit"])) {
        if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.frame = CGRectMake(point1.x - 30, point1.y, 60, 30);
        }
        else if ([_name isEqual:@"Elbow Line"]) {
            _angleLabel1.frame = CGRectMake(point2.x - 40, point2.y, 60, 30);
        }
        else {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
        }
        if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
        }
        else if ([_name isEqual:@"Elbow Line"]) {
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x - 10, point2.y)];
        }
        else {
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    else if ([_frame intValue] == 7) {
        if ([_name isEqual:@"Club Face Angle"]) {
            _angleLabel1.frame = CGRectMake(point3.x + 5, point3.y - 10, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point3 andP3:CGPointMake(point3.x + 10, point3.y)];
        }
        else if ([_name isEqual:@"Elbow Angle"]) {
            CGFloat distance = size.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            [_angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            [_angleLabel2 setCenter:p3];
        }
        else {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    else if ([_frame intValue] == 8) {
        if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.frame = CGRectMake(point1.x - 30, point1.y, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
        }
    }
    else if ([_frame intValue] == 9) {
        if ([_name isEqual:@"Elbow Angle"]) {
            CGFloat distance = size.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            [_angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            [_angleLabel2 setCenter:p3];
        }
        else if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.frame = CGRectMake(point1.x - 30, point1.y, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
        }
        else if ([_name isEqual:@"Shoulder Tilt"]) {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    else if ([_frame intValue] == 10 && ([_name isEqual:@"Shaft Line"] || [_name isEqual:@"Elbow-Hosel Line"])) {
        if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.frame = CGRectMake(point1.x + 10, point1.y - 10, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
        }
        else {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    else if ([_frame intValue] == 11) {
        if ([_name isEqual:@"Elbow-Hosel Line"]) {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
        else if ([_name isEqual:@"Elbow Angle"]) {
            CGFloat distance = size.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            [_angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            _angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            [_angleLabel2 setCenter:p3];
        }
    }
    else if ([_frame intValue] == 12 && ([_name isEqual:@"Shoulder Tilt"])) {
        _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 60, 30);
        _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
    }
    else if ([_frame intValue] == 13 && ([_name isEqual:@"Shaft Line"] || [_name isEqual:@"Elbow-Hosel Line"])) {
        if ([_name isEqual:@"Shaft Line"]) {
            _angleLabel1.frame = CGRectMake(point1.x + 10, point1.y - 10, 60, 30);
            _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
        }
        else {
            _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 40, 30);
            _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        }
    }
    
    if ([_name isEqual:@"Spine Tilt"] || [_name isEqual:@"Leadarm Line"]) {
        _angleLabel1.frame = CGRectMake(point2.x, point2.y - 30, 60, 30);
        _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
    }
}

- (NSString *)computeAngleWithP1:(CGPoint)point1 andP2:(CGPoint)point2 andP3:(CGPoint)point3 {
    double o = sqrt(pow((point1.x-point3.x), 2)+pow((point1.y-point3.y), 2));
    double a = sqrt(pow((point2.x-point3.x), 2)+pow((point2.y-point3.y), 2));
    double b = sqrt(pow((point2.x-point1.x), 2)+pow((point2.y-point1.y), 2));
    double angle = acos((pow(a, 2)+pow(b, 2)-pow(o, 2))/(2*a*b))/M_PI*180;
    return [NSString stringWithFormat:@"%.1f°",angle];
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

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_frame forKey:@"frame"];
    [coder encodeObject:_x1 forKey:@"x1"];
    [coder encodeObject:_x2 forKey:@"x2"];
    [coder encodeObject:_x3 forKey:@"x3"];
    [coder encodeObject:_x4 forKey:@"x4"];
    [coder encodeObject:_y1 forKey:@"y1"];
    [coder encodeObject:_y2 forKey:@"y2"];
    [coder encodeObject:_y3 forKey:@"y3"];
    [coder encodeObject:_y4 forKey:@"y4"];
    [coder encodeObject:_pointArray forKey:@"pointArray"];
    [coder encodeBool:_LRMovable forKey:@"LRMovable"];
    [coder encodeBool:_UDMovable forKey:@"UDMovable"];
    [coder encodeBool:_Rotatable forKey:@"Rotatable"];
    [coder encodeBool:_hasAdjust forKey:@"hasAdjust"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _type = [coder decodeObjectForKey:@"type"];
        _frame = [coder decodeObjectForKey:@"frame"];
        _x1 = [coder decodeObjectForKey:@"x1"];
        _x2 = [coder decodeObjectForKey:@"x2"];
        _x3 = [coder decodeObjectForKey:@"x3"];
        _x4 = [coder decodeObjectForKey:@"x4"];
        _y1 = [coder decodeObjectForKey:@"y1"];
        _y2 = [coder decodeObjectForKey:@"y2"];
        _y3 = [coder decodeObjectForKey:@"y3"];
        _y4 = [coder decodeObjectForKey:@"y4"];
        _pointArray= [coder decodeObjectForKey:@"pointArray"];
        _LRMovable = [coder decodeBoolForKey:@"LRMovable"];
        _UDMovable = [coder decodeBoolForKey:@"UDMovable"];
        _Rotatable = [coder decodeBoolForKey:@"Rotatable"];
        _hasAdjust = [coder decodeBoolForKey:@"hasAdjust"];
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    scoreTool *tool = [[scoreTool allocWithZone:zone] init];
    tool.name = _name;
    tool.type = _type;
    tool.frame = [_frame copy];
    tool.x1 = [_x1 copy];
    tool.x2 = [_x2 copy];
    tool.x3 = [_x3 copy];
    tool.x4 = [_x4 copy];
    tool.y1 = [_y1 copy];
    tool.y2 = [_y2 copy];
    tool.y3 = [_y3 copy];
    tool.y4 = [_y4 copy];
    tool.pointArray=[_pointArray copy];
    tool.Rotatable = _Rotatable;
    tool.LRMovable = _LRMovable;
    tool.UDMovable = _UDMovable;
    tool.hasAdjust = _hasAdjust;
    return tool;
}

@end
