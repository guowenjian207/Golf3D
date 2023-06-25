//
//  SpecificationTool.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/10.
//

#import "SpecificationTool.h"
#import <objc/runtime.h>

@implementation SpecificationTool
+ (instancetype)specificationToolWithDic:(NSDictionary *)dic {
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
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_type forKey:@"type"];
    [coder encodeObject:_frame forKey:@"frame"];
    [coder encodeObject:_index forKey:@"index"];
    [coder encodeObject:_corresFrame forKey:@"corresFrame"];
    [coder encodeObject:_x1 forKey:@"x1"];
    [coder encodeObject:_x2 forKey:@"x2"];
    [coder encodeObject:_x3 forKey:@"x3"];
    [coder encodeObject:_x4 forKey:@"x4"];
    [coder encodeObject:_y1 forKey:@"y1"];
    [coder encodeObject:_y2 forKey:@"y2"];
    [coder encodeObject:_y3 forKey:@"y3"];
    [coder encodeObject:_y4 forKey:@"y4"];
    [coder encodeObject:_color forKey:@"color"];
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
        _index = [coder decodeObjectForKey:@"index"];
        _corresFrame= [coder decodeObjectForKey:@"corresFrame"];
        _x1 = [coder decodeObjectForKey:@"x1"];
        _x2 = [coder decodeObjectForKey:@"x2"];
        _x3 = [coder decodeObjectForKey:@"x3"];
        _x4 = [coder decodeObjectForKey:@"x4"];
        _y1 = [coder decodeObjectForKey:@"y1"];
        _y2 = [coder decodeObjectForKey:@"y2"];
        _y3 = [coder decodeObjectForKey:@"y3"];
        _y4 = [coder decodeObjectForKey:@"y4"];
        _color = [coder decodeObjectForKey:@"color"];
        _pointArray= [coder decodeObjectForKey:@"pointArray"];
        _LRMovable = [coder decodeBoolForKey:@"LRMovable"];
        _UDMovable = [coder decodeBoolForKey:@"UDMovable"];
        _Rotatable = [coder decodeBoolForKey:@"Rotatable"];
        _hasAdjust = [coder decodeBoolForKey:@"hasAdjust"];
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    SpecificationTool *tool = [[SpecificationTool allocWithZone:zone] init];
    tool.name = _name;
    tool.index=[_index copy];
    tool.type = _type;
    tool.frame = [_frame copy];
    tool.corresFrame = [_corresFrame copy];
    tool.x1 = [_x1 copy];
    tool.x2 = [_x2 copy];
    tool.x3 = [_x3 copy];
    tool.x4 = [_x4 copy];
    tool.y1 = [_y1 copy];
    tool.y2 = [_y2 copy];
    tool.y3 = [_y3 copy];
    tool.y4 = [_y4 copy];
    tool.color = [_color copy];
    tool.pointArray=[_pointArray copy];
    tool.Rotatable = _Rotatable;
    tool.LRMovable = _LRMovable;
    tool.UDMovable = _UDMovable;
    tool.hasAdjust = _hasAdjust;
    return tool;
}
-(instancetype)intiLineWithPointA:(CGPoint)point{
    if(self){
        self.name = @"Head_Height";
        self.type = @"Line";
        self.LRMovable = NO;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = @0;
        self.y1 = [NSNumber numberWithFloat:point.y];
        self.x2 = @1;
        self.y2 = [NSNumber numberWithFloat:point.y];
    }
    return  self;
}

-(instancetype)intiHipDepthWithPointA:(CGPoint)point{
    if(self){
        self.name = @"Hip_Depth";
        self.type = @"Line";
        self.LRMovable = YES;
        self.UDMovable = NO;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:point.x];
        self.y1 = [NSNumber numberWithFloat:point.y+0.2];
        self.x2 = [NSNumber numberWithFloat:point.x];
        self.y2 = [NSNumber numberWithFloat:point.y-0.2];
    }
    return  self;
}
//肩线
-(instancetype)intiShoulderTiltWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Shoulder_Tilt";
        self.type = @"ExternLineWithNode";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}

//小臂
-(instancetype)intiLeadForearmLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Lead_Forearm_Line";
        self.type = @"SingleExternLineWithNode";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}

//球杆
-(instancetype)intiShaftLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Shaft_Line";
        self.type = @"LineWithNode";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}

-(instancetype)intiShaftLineToArmpitWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Shaft_Line_To_Armpit";
        self.type = @"LineWithNode";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = YES;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}

-(instancetype)intiElbowHoselLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Elbow_Hosel_Line";
        self.type = @"LineWithNode";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = YES;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}
//头位置
-(instancetype)intiHeadPositionWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC{
    if(self){
        self.name = @"Head_Position";
        self.type = @"broken Line";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
    }
    return  self;
}
//头框
-(instancetype)intiHeadFrameWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    if(self){
        self.name = @"Head_Frame";
        self.type = @"Rect";
        self.LRMovable = NO;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}
//下肢梯形
-(instancetype)intiLowBodyPositionWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andPointC:(CGPoint)pointC andPointD:(CGPoint)pointD {
    if(self){
        self.name = @"Lower_Body_Position";
        self.type = @"Quadrilateral";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
        self.x4 = [NSNumber numberWithFloat:pointD.x];
        self.y4 = [NSNumber numberWithFloat:pointD.y];
    }
    return  self;
}
//手肘
-(instancetype)intiLeadElbowAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC{
    if(self){
        self.name = @"Lead_Elbow_Angle";
        self.type = @"Angle";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
    }
    return  self;
}

-(instancetype)intiTrailElbowAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC{
    if(self){
        self.name = @"Trail_Elbow_Angle";
        self.type = @"Angle";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
    }
    return  self;
}

//腿部
-(instancetype)intiTrailLegAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC{
    if(self){
        self.name = @"Trail_Leg_Angle";
        self.type = @"Angle";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
    }
    return  self;
}
-(instancetype)intiLeadLegAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC{
    if(self){
        self.name = @"Lead_Leg_Angle";
        self.type = @"Angle";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
        self.x3 = [NSNumber numberWithFloat:pointC.x];
        self.y3 = [NSNumber numberWithFloat:pointC.y];
    }
    return  self;
}

-(instancetype)intiKneeGapsWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB{
    if(self){
        self.name = @"Knees_Gaps";
        self.type = @"Ruler";
        self.LRMovable = YES;
        self.UDMovable = YES;
        self.Rotatable = NO;
        self.color = [UIColor redColor];
        self.x1 = [NSNumber numberWithFloat:pointA.x];
        self.y1 = [NSNumber numberWithFloat:pointA.y];
        self.x2 = [NSNumber numberWithFloat:pointB.x];
        self.y2 = [NSNumber numberWithFloat:pointB.y];
    }
    return  self;
}

- (void)updateWithContentSize:(CGSize)size andIndex:(int) index{
    
    int frameIdx = index;
    float gap = 10 * size.width / [UIScreen mainScreen].bounds.size.width;
    float aveWidth = (size.width - gap) / 5;
    float aveHeight = size.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    
    CGPoint point1, point2, point3, point4;
    if ([_type isEqual:@"Line"] || [_type isEqual:@"LineWithNode"]) {
//        [_toolLayer removeFromSuperlayer];
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        
    }else if ([_type isEqual:@"broken Line"]){
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
        
    }else if ([_type isEqual:@"ExternLineWithNode"]) {
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

    }else if ([_type isEqual:@"SingleExternLineWithNode"]) {
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

    }else if ([_type isEqual:@"Angle"]) {
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
    }else if ([_type isEqual:@"Ruler"]) {
        [_toolPath removeAllPoints];
        [_rulerToolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [_rulerToolPath moveToPoint:point2];
        [_rulerToolPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [_toolPath closePath];
        _rulerLayer.path = _rulerToolPath.CGPath;
    }
    if(index == 5 || index == 10){
        _lastLayer.path = _toolPath.CGPath;
    }else{
        _toolLayer.path = _toolPath.CGPath;
    }
}

- (void)updateInCopyWithContentSize:(CGSize)size{
    CGFloat kItemWidth = UIScreen.mainScreen.bounds.size.width/13;
    CGFloat kItemHeight = kItemWidth/4*5;
    int frameIdx = [_index intValue];
    float gap = size.width * 18/[UIScreen mainScreen].bounds.size.width;
    float aveWidth = (UIScreen.mainScreen.bounds.size.width - gap) / 6;
    float aveHeight = aveWidth/ 4 * 5;
    float offsetX = frameIdx % 6 * aveWidth;
    if(frameIdx>0){
        offsetX=offsetX+10;
        if(frameIdx>1){
            offsetX = offsetX + (2*(frameIdx-1));
        }
    }
    float offsetY = kItemHeight;
    
    CGPoint point1, point2, point3, point4;
    if ([_type isEqual:@"Line"] || [_type isEqual:@"LineWithNode"]) {
//        [_toolLayer removeFromSuperlayer];
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
        _toolLayer.path = _toolPath.CGPath;
    }else if ([_type isEqual:@"broken Line"] || [_type isEqual:@"Angle"]){
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
        _toolLayer.path = _toolPath.CGPath;
    }else if ([_type isEqual:@"ExternLineWithNode"]) {
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
    }else if ([_type isEqual:@"SingleExternLineWithNode"]) {
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

    }else if ([_type isEqual:@"Rect"]) {
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
        [_toolPath addLineToPoint:point3];
        [_toolPath addLineToPoint:point4];
        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
    }else if ([_type isEqual:@"Ruler"]) {
        [_toolPath removeAllPoints];
        [_rulerToolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [_rulerToolPath moveToPoint:point2];
        [_rulerToolPath addLineToPoint:CGPointMake(point2.x, point1.y)];
//        [_toolPath closePath];
        _toolLayer.path = _toolPath.CGPath;
        _rulerLayer.path = _rulerToolPath.CGPath;
    }
}
//updata BigView
- (void)updateWithContentSize:(CGSize)size{
    
//    int frameIdx = 0;
    float aveWidth = size.width;
    float aveHeight = size.height;
    float offsetX = 0;
    float offsetY = 0;
    
    CGPoint point1, point2, point3, point4;
    if ([_type isEqual:@"Line"] || [_type isEqual:@"LineWithNode"]) {
//        [_toolLayer removeFromSuperlayer];
        [_toolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:point2];
    }else if ([_type isEqual:@"broken Line"] || [_type isEqual:@"Angle"]){
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
    }else if ([_type isEqual:@"ExternLineWithNode"]) {
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
    }else if ([_type isEqual:@"SingleExternLineWithNode"]) {
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

    }else if ([_type isEqual:@"Rect"]) {
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
        [_toolPath addLineToPoint:point3];
        [_toolPath addLineToPoint:point4];
        [_toolPath closePath];
    }else if ([_type isEqual:@"Ruler"]) {
        [_toolPath removeAllPoints];
        [_rulerToolPath removeAllPoints];
        point1 = CGPointMake(_x1.floatValue, _y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(_x2.floatValue, _y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [_toolPath moveToPoint:point1];
        [_toolPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [_rulerToolPath moveToPoint:point2];
        [_rulerToolPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [_toolPath closePath];
        _rulerLayer.path = _rulerToolPath.CGPath;
    }
    
    if ([_name isEqual:@"Shaft_Line_To_Armpit"] || [_name isEqual:@"Elbow_Hosel_Line"] || [_name isEqual:@"Shoulder_Tilt"] || [_name isEqual:@"Shaft_Line"]) {
        if(point1.y>point2.y){
            if(point1.x>point2.x){
                _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x-10, point1.y)];
            }else{
                _angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x+10, point1.y)];
            }
            
            _angleLabel1.center = point1;
        }else{
            if(point2.x>point1.x){
                _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x-10, point2.y)];
            }else{
                _angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x+10, point2.y)];
            }
            
            _angleLabel1.center = point2;
        }
        if([_name isEqual:@"Shaft_Line"]){
            _angleLabel1.center = point2;
        }
        _angleLabel1.textColor = _color;
//        [_angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    
    _lastLayer.path = _toolPath.CGPath;
}

- (NSString *)computeAngleWithP1:(CGPoint)point1 andP2:(CGPoint)point2 andP3:(CGPoint)point3 {
    double o = sqrt(pow((point1.x-point3.x), 2)+pow((point1.y-point3.y), 2));
    double a = sqrt(pow((point2.x-point3.x), 2)+pow((point2.y-point3.y), 2));
    double b = sqrt(pow((point2.x-point1.x), 2)+pow((point2.y-point1.y), 2));
    double angle = acos((pow(a, 2)+pow(b, 2)-pow(o, 2))/(2*a*b))/M_PI*180;
    return [NSString stringWithFormat:@"%.1f°",angle];
}
@end
