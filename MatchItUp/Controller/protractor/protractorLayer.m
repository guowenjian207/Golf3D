//
//  protractorLayer.m
//  TinyYOLO-CoreML
//
//  Created by 文昊天 on 2018/12/23.
//  Copyright © 2018年 MachineThink. All rights reserved.
//
#import "protractorLayer.h"

#define Point(x, y)         CGPointMake(x, y)
// 获取矩形中心点坐标
#define CenterForRect(r)    Point((r).origin.x + (r).size.width / 2, (r).origin.y + (r).size.height / 2)


#define kSingleLineWidth           (1 / [UIScreen mainScreen].scale)
#define kScreenHightorigin    (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
#define kScreenWidth    (MIN([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width))
#define kScreenHight    (kScreenHightorigin*0.25)

//#define kScreenHight 179.2
//#define kScreenWidth 375
#define arrowLineWidth 20



//颜色
#define kcpnt(c)        ((c) / 255.0f)
#define kColorRGBA(r, g, b, a)  [UIColor colorWithRed:kcpnt(r) green:kcpnt(g) blue:kcpnt(b) alpha:kcpnt(a)]

//#define Color_BK  kColorRGBA(10, 10, 10, 100)       // 整体背景色
#define Color_BK  [UIColor clearColor]
#define Color_CN  kColorRGBA(220, 244, 244, 100)    // 中心部分常规颜色
#define Color_CI  kColorRGBA(242, 171, 228, 100)    // 中心部分夹角颜色
#define Color_GI  kColorRGBA(0, 171, 0, 100)    // 中心部分夹角颜色

#define Color_AC  [UIColor greenColor]              // 角度值字体色
//#define Color_GL  kColorRGBA(193, 195, 207, 255)    // 刻度线颜色
#define Color_GL  kColorRGBA(35, 35, 35, 255)
#define Color_GV  kColorRGBA(255, 255, 255, 255)    // 刻度值字体色
#define Color_IA  kColorRGBA(238, 80, 72, 255)     // 夹角线颜色

#define Color_BK_Key  @"bk"
#define Color_GL_Key  @"gl"
#define Color_GV_Key  @"gv"
#define Color_CN_Key  @"cn"
#define Color_CI_Key  @"ci"
#define Color_IA_Key  @"ia"

#define angle_to_radia(x)   ( M_PI / 180 * (x) )
#define radia_to_angle(x)   ( 180 / M_PI * (x) )

@interface myProtractorLayer()

@property (nonatomic, strong) CATextLayer *angle_layer;             // 角度值
@property (nonatomic, strong) UIColor *angle_color;                  // 角度字体色

@property (nonatomic, strong) UIColor *background_color;            // 背景色
@property (nonatomic, strong) UIColor *graduation_line_color;       // 刻度线颜色
@property (nonatomic, strong) UIColor *graduation_value_color;      // 刻度值颜色
@property (nonatomic, strong) UIColor *center_normal_color;         // 中心颜色
@property (nonatomic, strong) UIColor *center_included_angle_color; // 中心夹角颜色
@property (nonatomic, strong) UIColor *included_angle_line_color;   // 加角线颜色

@property (nonatomic, strong) CAShapeLayer *background_layer;           // 背景层
@property (nonatomic, strong) CAShapeLayer *graduation_line_layer;      // 刻度线
@property (nonatomic, strong) CAShapeLayer *graduation_value_layer;     // 刻度值
@property (nonatomic, strong) CAShapeLayer *center_normal_layer;        // 中心常规
@property (nonatomic, strong) CAShapeLayer *center_included_angle_layer;// 中心夹角
@property (nonatomic, strong) CAShapeLayer *included_angle_line_layer;  // 加角线
@property (nonatomic, strong) CAShapeLayer *corner_radius_layer;        // 中心圆点
@property (nonatomic, strong) CAShapeLayer *start_angle_layer;          // 起始圆点
@property (nonatomic, strong) CAShapeLayer *end_angle_layer;            // 终止圆点


@property (nonatomic, assign, readonly) CGFloat protractor_radius;      // 中心圆半径

@property (nonatomic, assign, readonly) CGFloat protractor_inner_radius;// 内半径

// 刻度线半径
@property (nonatomic, assign, readonly) CGFloat kedur_r0;               // 长线内半径
@property (nonatomic, assign, readonly) CGFloat kedur_r1;               // 中线内半径
@property (nonatomic, assign, readonly) CGFloat kedur_r2;               // 短线内半径
@property (nonatomic, assign, readonly) CGFloat kedur_r3;               // 外半径
@property (nonatomic, assign, readonly) CGFloat kedur_val;              // 刻度值半径

@end


@implementation myProtractorLayer

+ (myProtractorLayer *)drawProtractorLayer
{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHight);
    myProtractorLayer *layer = [[myProtractorLayer alloc] init];
    layer.bounds = rect;
    layer.anchorPoint = CGPointMake(0.5, (kScreenHight - layer.protractor_nop) / kScreenHight);
    layer.position = CGPointMake(kScreenWidth/2, kScreenHight - layer.protractor_nop);
    //layer.protractor_center = CGPointMake(kScreenWidth / 2 , kScreenHight - layer.protractor_nop);
    //layer.position = CenterForRect(rect);
    //[layer setColors:colors];
    [layer setColors];
    layer.startAngle = angle_to_radia(90);
    layer.endAngle = angle_to_radia(135);
    [layer addGraduationContentLayers];
    return layer;
}

-(void)addGraduationContentLayers {
    
    NSLog(@"屏幕的宽度:%f", kScreenWidth);
    NSLog(@"屏幕的长度:%f", kScreenHight);
    
    [self addSublayer:self.background_layer];
    [self addSublayer:self.graduation_line_layer];
    [self addSublayer:self.graduation_value_layer];
    [self addSublayer:self.center_normal_layer];
    [self addSublayer:self.center_included_angle_layer];
    [self addSublayer:self.included_angle_line_layer];
    [self addSublayer:self.corner_radius_layer];
    [self addSublayer:self.start_angle_layer];
    [self addSublayer:self.end_angle_layer];
    [self addSublayer:self.angle_layer];
}

// 更新夹角
- (void)redrawIncludedAngleLineFromAngle:(CGFloat)from toAngle:(CGFloat)to
{
    /*    from = MIN(MAX(0, from), self.endAngle);
     to = MIN(MAX(to, self.startAngle), M_PI);*/
    
    self.startAngle = from;
    self.endAngle = to;
    
    // 角度值更新
    float angle = radia_to_angle(self.endAngle - M_PI_2);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendAngle" object:[NSString stringWithFormat:@"%.2f",angle]];
    self.angle_layer.string = [NSString stringWithFormat:@" %.2f°", angle];
    if ((angle >= -5 && angle <= 5) || (angle >= 85 && angle <= 95)) {
        self.included_angle_line_color = Color_AC;
        self.center_included_angle_color = Color_GI;
    }
    else {
        self.included_angle_line_color = Color_IA;
        self.center_included_angle_color = Color_CI;
    }
    _corner_radius_layer.fillColor = self.included_angle_line_color.CGColor;
    _included_angle_line_layer.strokeColor = self.included_angle_line_color.CGColor;
    _start_angle_layer.backgroundColor = self.included_angle_line_color.CGColor;
    _start_angle_layer.borderColor = self.included_angle_line_color.CGColor;
    _end_angle_layer.backgroundColor = self.included_angle_line_color.CGColor;
    _end_angle_layer.borderColor = self.included_angle_line_color.CGColor;
    _angle_layer.foregroundColor = self.included_angle_line_color.CGColor;
    _center_included_angle_layer.fillColor = self.center_included_angle_color.CGColor;
    
    if (self.callback)
    {
        self.callback(radia_to_angle(from), radia_to_angle(to), radia_to_angle(fabs(from - to)));
    }
    
    // 按钮位置更新
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CGFloat startAngle = radia_to_angle(self.startAngle) + 90;
        CGFloat startAngle2 = angle_to_radia(startAngle);
        CGFloat endAngle = radia_to_angle(self.endAngle) + 90;
        CGFloat endAngle2 = angle_to_radia(endAngle);
        
        self.start_angle_layer.position = [self inner_point_at_angle:self.startAngle r:self.protractor_inner_radius geometryFlipped:YES];
        self.start_angle_layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, startAngle2);
        
        self.end_angle_layer.position = [self inner_point_at_angle:self.endAngle r:self.protractor_inner_radius geometryFlipped:YES];
        self.end_angle_layer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, endAngle2);
        [CATransaction commit];
    }
    
    // 夹角线更新
    self.included_angle_line_layer.path = [self path_included_line].CGPath;
    
    // 夹角层更新
    self.center_included_angle_layer.path = [self path_included_angle].CGPath;
}

//背景
- (CAShapeLayer *)background_layer
{
    if (!_background_layer)
    {
        _background_layer = [self shapeLayerPath:[UIBezierPath bezierPathWithRect:self.bounds] strokeColor:nil fillColor:self.background_color lineWidth:kSingleLineWidth geometryFlipped:YES];
    }
    return _background_layer;
}

//刻度线
- (CAShapeLayer *)graduation_line_layer
{
    if (!_graduation_line_layer)
    {
        _graduation_line_layer = [self shapeLayerPath:[self path_graduation_lines] strokeColor:self.graduation_line_color fillColor:nil lineWidth:kSingleLineWidth geometryFlipped:YES];
    }
    return _graduation_line_layer;
}

//圆心
- (CAShapeLayer *)corner_radius_layer
{
    if (!_corner_radius_layer)
    {
        CGFloat w = self.protractor_nop;
        _corner_radius_layer = [CAShapeLayer layer];
        _corner_radius_layer.backgroundColor = [UIColor clearColor].CGColor;
        _corner_radius_layer.fillColor = self.included_angle_line_color.CGColor;
        _corner_radius_layer.position = self.protractor_center;
        _corner_radius_layer.bounds = CGRectMake(0, 0, w, w);
        _corner_radius_layer.path = [UIBezierPath bezierPathWithRoundedRect:_corner_radius_layer.bounds cornerRadius:w / 2].CGPath;
    }
    return _corner_radius_layer;
}

//中心常规圆
- (CAShapeLayer *)center_normal_layer
{
    if (!_center_normal_layer)
    {
        _center_normal_layer = [self shapeLayerPath:[self path_inner_background] strokeColor:nil fillColor:self.center_normal_color lineWidth:kSingleLineWidth geometryFlipped:YES];
    }
    return _center_normal_layer;
}

//刻度值
- (CAShapeLayer *)graduation_value_layer
{
    if (!_graduation_value_layer)
    {
        _graduation_value_layer = [self shapeLayerPath:[UIBezierPath bezierPathWithRect:self.bounds] strokeColor:nil fillColor:nil lineWidth:kSingleLineWidth geometryFlipped:YES];
        for (NSInteger i = 0; i <= 180; i ++)
        {
            if (i % 10 == 0) // 长线
            {
                CGFloat angle = angle_to_radia(i);
                CGFloat transformAngle = angle_to_radia(90 - i);
                NSString *text = [NSString stringWithFormat:@"%zd", i];
                CGRect rect = CGRectMake(0, 0, 20, 12);
                CGPoint point = [self point_at_angle:angle r:self.kedur_val geometryFlipped:YES];
                CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, transformAngle);  //不能在一开始初始化为angle = angle_to_radia(90 - i)
                CATextLayer *layer = [self textLayerAtPosition:point bounds:rect color:self.graduation_value_color fontSize:11 transform:transform];
                layer.string = text;
                [_graduation_value_layer addSublayer:layer];
            }
        }
    }
    return _graduation_value_layer;
}

//两条夹角线
- (CAShapeLayer *)included_angle_line_layer
{
    if (!_included_angle_line_layer)
    {
        _included_angle_line_layer = [self shapeLayerPath:[self path_included_line] strokeColor:self.included_angle_line_color fillColor:nil lineWidth:kSingleLineWidth*3 geometryFlipped:YES];
    }
    return _included_angle_line_layer;
}

//夹角填充
- (CAShapeLayer *)center_included_angle_layer
{
    if (!_center_included_angle_layer)
    {
        _center_included_angle_layer = [self shapeLayerPath:[self path_included_angle] strokeColor:nil fillColor:self.center_included_angle_color lineWidth:kSingleLineWidth geometryFlipped:YES];
    }
    return _center_included_angle_layer;
}

//起始角度圆点
- (CAShapeLayer *)start_angle_layer
{
    if (!_start_angle_layer)
    {
        CGFloat angle = self.startAngle ; //startAngle已经经过angle_to_radia的变化了
        CGFloat adjustAngle = angle_to_radia(90);
        _start_angle_layer = [self create_touch_item_layer];
        _start_angle_layer.position = [self inner_point_at_angle:self.startAngle r:self.protractor_inner_radius geometryFlipped:YES];
        CGAffineTransform transformAdjust = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
        _start_angle_layer.affineTransform = CGAffineTransformRotate(transformAdjust, adjustAngle);
    }
    return _start_angle_layer;
}

//结束角度圆点
- (CAShapeLayer *)end_angle_layer
{
    if (!_end_angle_layer)
    {
        CGFloat angle = self.endAngle;
        CGFloat adjustAngle = angle_to_radia(90);
        _end_angle_layer = [self create_touch_item_layer];
        _end_angle_layer.position = [self inner_point_at_angle:self.endAngle r:self.protractor_inner_radius geometryFlipped:YES];
        CGAffineTransform transformAdjust = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
        _end_angle_layer.affineTransform = CGAffineTransformRotate(transformAdjust, adjustAngle);
    }
    return _end_angle_layer;
}


- (CAShapeLayer *)create_touch_item_layer
{
    CGFloat nop = 2;
    CGFloat nop_l = 3;
    CGFloat w = self.protractor_nop + 2;
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.bounds = CGRectMake(0, 0, w, w);
    layer.backgroundColor = self.included_angle_line_color.CGColor;
    layer.borderColor = self.included_angle_line_color.CGColor;
    layer.borderWidth = 1;
    layer.cornerRadius = w / 2;
    layer.masksToBounds = YES;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(w / 2, nop_l)];
    [path addLineToPoint:CGPointMake(w / 2, w - nop_l)];
    [path moveToPoint:CGPointMake(w / 2 - nop, nop_l)];
    [path addLineToPoint:CGPointMake(w / 2 - nop, w - nop_l)];
    [path moveToPoint:CGPointMake(w / 2 + nop, nop_l)];
    [path addLineToPoint:CGPointMake(w / 2 + nop, w - nop_l)];
    
    layer.strokeColor = self.background_color.CGColor;
    layer.path = path.CGPath;
    layer.lineWidth = kSingleLineWidth;
    layer.lineJoin = kCALineJoinBevel;
    return layer;
}

//夹角值
- (CATextLayer *)angle_layer
{
    if (!_angle_layer)
    {
        CGRect rect = CGRectMake(0, 0, 120, 30);
        CGPoint point = CGPointMake(kScreenWidth - 40, kScreenHight / 2);
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI / 2);
        CATextLayer *layer = [self textLayerAtPosition:point bounds:rect color:self.angle_color fontSize:20 transform:CGAffineTransformIdentity];
        layer.string = [NSString stringWithFormat:@" %.2f°", radia_to_angle(fabs(self.endAngle - self.startAngle))];
        _angle_layer = layer;
    }
    
    return _angle_layer;
}

//传出夹角值
- (NSString*)getAngleFromAngelLayer
{
    NSString* angle;
    angle = self.angle_layer.string;
    return angle;
}

- (CATextLayer *)textLayerAtPosition:(CGPoint)position bounds:(CGRect)rect color:(UIColor *)color fontSize:(CGFloat)size transform:(CGAffineTransform)transform
{
    CATextLayer *layer = [CATextLayer layer];
    layer.position = position;
    layer.bounds = rect;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.foregroundColor = color.CGColor;
    layer.alignmentMode = @"center";
    layer.fontSize = size;
    layer.affineTransform = transform;
    return layer;
}


#pragma mark - 计算path
// 内层半圆常规path
- (UIBezierPath *)path_inner_background
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(self.protractor_center.x, self.protractor_nop) radius:self.protractor_inner_radius startAngle:M_PI endAngle: 0 clockwise:NO];
    
    //    [path moveToPoint:CGPointMake(0, self.protractor_center.y - self.protractor_inner_radius)];
    //    [path addLineToPoint:CGPointMake(self.protractor_center.x, self.protractor_center.y - self.protractor_inner_radius)];
    //    [path addLineToPoint:CGPointMake(self.protractor_center.x, self.protractor_center.y + self.protractor_inner_radius)];
    //    [path addLineToPoint:CGPointMake(0, self.protractor_center.y + self.protractor_inner_radius)];
    NSLog(@"protractor_center的坐标为：%@",NSStringFromCGPoint(self.protractor_center));
    [path moveToPoint:CGPointMake(self.protractor_center.x - self.protractor_inner_radius, 0)]; //不知道为什么以左下角为原点……
    [path addLineToPoint:CGPointMake(self.protractor_center.x - self.protractor_inner_radius, self.protractor_nop) ];
    [path addLineToPoint:CGPointMake(self.protractor_center.x + self.protractor_inner_radius, self.protractor_nop)];
    [path addLineToPoint:CGPointMake(self.protractor_center.x + self.protractor_inner_radius, 0)];
    return path;
}

// 刻度线path
- (UIBezierPath *)path_graduation_lines
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i <= 180; i ++)
    {
        CGFloat angle = angle_to_radia(i);
        CGPoint start = [self point_r3_at_angle:angle];
        CGPoint end = CGPointZero;
        if (i % 10 == 0) // 长线
        {
            end = [self point_r0_at_angle:angle];
        }
        else if (i % 5 == 0) // 中线
        {
            end = [self point_r1_at_angle:angle];
        }
        else // 短线
        {
            end = [self point_r2_at_angle:angle];
        }
        [path moveToPoint:start];
        [path addLineToPoint:end];
        //NSLog(@"%d度对应的坐标为：(%f,%f),(%f,%f)",i,start.x,start.y,end.x,end.y);
    }
    return path;
}

// 夹角线path
- (UIBezierPath *)path_included_line
{
    //    CGFloat angle_start = MIN(self.startAngle, self.endAngle);
    //    CGFloat angle_end = MAX(self.startAngle, self.endAngle);
    CGFloat angle_start = self.startAngle;
    CGFloat angle_end = self.endAngle;
    UIBezierPath *path = [UIBezierPath bezierPath];
    //添加起始线
    [path moveToPoint: CGPointMake(self.protractor_center.x, self.protractor_nop)];
    [path addLineToPoint:[self edge_point_at_angle:angle_start]];
    //添加起始线箭头
    CGFloat start_arrow_x1 = [self edge_point_at_angle:angle_start].x - arrowLineWidth * sin(self.startAngle + M_PI / 6 - M_PI_2);
    CGFloat start_arrow_y1 = [self edge_point_at_angle:angle_start].y - arrowLineWidth * cos(self.startAngle + M_PI / 6 - M_PI_2);
    [path addLineToPoint:CGPointMake(start_arrow_x1, start_arrow_y1)];
    
    [path moveToPoint:[self edge_point_at_angle:angle_start]];
    CGFloat start_arrow_x2 = [self edge_point_at_angle:angle_start].x + arrowLineWidth * cos(self.startAngle - M_PI / 6);
    CGFloat start_arrow_y2 = [self edge_point_at_angle:angle_start].y - arrowLineWidth * sin(self.startAngle - M_PI / 6);
    [path addLineToPoint:CGPointMake(start_arrow_x2, start_arrow_y2)];
    
    //添加结束线
    [path moveToPoint: CGPointMake(self.protractor_center.x, self.protractor_nop)];
    [path addLineToPoint:[self edge_point_at_angle:angle_end]];
    //添加结束线箭头
    CGFloat end_arrow_x1 = [self edge_point_at_angle:angle_end].x - arrowLineWidth * sin(self.endAngle + M_PI / 6 - M_PI_2);
    CGFloat end_arrow_y1 = [self edge_point_at_angle:angle_end].y - arrowLineWidth * cos(self.endAngle + M_PI / 6 - M_PI_2);
    [path addLineToPoint:CGPointMake(end_arrow_x1, end_arrow_y1)];
    
    [path moveToPoint:[self edge_point_at_angle:angle_end]];
    CGFloat end_arrow_x2 = [self edge_point_at_angle:angle_end].x + arrowLineWidth * cos(self.endAngle - M_PI / 6);
    CGFloat end_arrow_y2 = [self edge_point_at_angle:angle_end].y - arrowLineWidth * sin(self.endAngle - M_PI / 6);
    [path addLineToPoint:CGPointMake(end_arrow_x2, end_arrow_y2)];
    
    return path;
}

//内层夹角path
- (UIBezierPath *)path_included_angle
{
    CGFloat angle_start = M_PI  - MIN(self.startAngle, self.endAngle);
    CGFloat angle_end = M_PI - MAX(self.startAngle, self.endAngle) ;
    //CGPoint center = CGPointMake(self.protractor_center.x, kScreenHight - self.protractor_nop);
    CGPoint center = CGPointMake(self.protractor_center.x, self.protractor_nop);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:self.protractor_inner_radius startAngle:angle_start endAngle:angle_end clockwise:NO]; //画圆的坐标系和量角器自己定义的坐标系不同
    [path moveToPoint:center];
    [path addLineToPoint:[self point_at_angle:self.startAngle r:self.protractor_inner_radius geometryFlipped:YES]];
    [path addLineToPoint:[self point_at_angle:self.endAngle r:self.protractor_inner_radius geometryFlipped:YES]];
    [path addLineToPoint:center];
    return path;
}

- (CAShapeLayer *)shapeLayerPath:(UIBezierPath *)path strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor lineWidth:(CGFloat)lineWidth geometryFlipped:(BOOL)geometryFlipped
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.bounds = layer.frame;
    layer.geometryFlipped = geometryFlipped; // 子图层是否被垂直翻转
    layer.path = path.CGPath;
    layer.strokeColor = strokeColor.CGColor;
    layer.fillColor = fillColor.CGColor;
    layer.lineWidth = lineWidth;
    layer.lineJoin = kCALineJoinBevel;
    return layer;
}

#pragma mark - Colors
- (void)setColors:(NSDictionary *)dict
{
    UIColor *gl = dict[Color_GL_Key];
    UIColor *gv = dict[Color_GV_Key];
    UIColor *bk = dict[Color_BK_Key];
    UIColor *cn = dict[Color_CN_Key];
    UIColor *ci = dict[Color_CI_Key];
    UIColor *ia = dict[Color_IA_Key];
    if (gl) self.graduation_line_color = gl;
    if (gv) self.graduation_value_color = gv;
    if (bk) self.background_color = bk;
    if (cn) self.center_normal_color = cn;
    if (ci) self.center_included_angle_color = ci;
    if (ia) self.included_angle_line_color = ia;
}

-(void)setColors {
    self.graduation_line_color = Color_GL;
    self.graduation_value_color = Color_GV;
    self.background_color = Color_BK;
    self.center_normal_color = Color_CN;
    self.center_included_angle_color = Color_CI;
    self.included_angle_line_color = Color_IA;
}

- (UIColor *)angle_color
{
    if (!_angle_color)
    {
        _angle_color = Color_IA;
    }
    return _angle_color;
}

- (UIColor *)graduation_line_color
{
    if (!_graduation_line_color)
    {
        _graduation_line_color = Color_GL;
    }
    return _graduation_line_color;
}

- (UIColor *)graduation_value_color
{
    if (!_graduation_value_color)
    {
        _graduation_value_color = Color_GV;
    }
    return _graduation_value_color;
}

- (UIColor *)background_color
{
    if (!_background_color)
    {
        _background_color = Color_BK;
    }
    return _background_color;
}

- (UIColor *)center_normal_color
{
    if (!_center_normal_color)
    {
        _center_normal_color = Color_CN;
    }
    return _center_normal_color;
}

- (UIColor *)center_included_angle_color
{
    if (!_center_included_angle_color)
    {
        _center_included_angle_color = Color_CI;
    }
    return _center_included_angle_color;
}

- (UIColor *)included_angle_line_color
{
    if (!_included_angle_line_color)
    {
        _included_angle_line_color = Color_IA;
    }
    return _included_angle_line_color;
}


#pragma mark - CGFloat
- (CGFloat)protractor_nop
{
    return 12;
}

- (CGPoint)protractor_center
{
    return CGPointMake(kScreenWidth / 2 , kScreenHight - self.protractor_nop); //坐标为（187.5，198）
}

- (CGFloat)protractor_radius
{
    return 10;
}

- (CGFloat)kedur_r0 //长线内半径
{
    return self.kedur_r3 - 16;
}

- (CGFloat)kedur_r1 //中线内半径
{
    return self.kedur_r3 - 12;
}

- (CGFloat)kedur_r2 //短线内半径
{
    return self.kedur_r3 - 8;
}

- (CGFloat)kedur_r3 //外半径
{
    return (kScreenHight - self.protractor_nop) * 0.75;
}

- (CGFloat)kedur_val //刻度值半径
{
    return self.kedur_r3 - 23;
}

- (CGFloat)protractor_inner_radius
{
    return self.kedur_r3 * 0.55;
}


#pragma mark - 辅助方法
- (CGPoint)end_angle_position {
    return self.end_angle_layer.position;
}

- (CGPoint)point_r3_at_angle:(CGFloat)angle
{
    return [self point_at_angle:angle r:self.kedur_r3 geometryFlipped:YES];
}

- (CGPoint)point_r2_at_angle:(CGFloat)angle
{
    return [self point_at_angle:angle r:self.kedur_r2 geometryFlipped:YES];
}

- (CGPoint)point_r1_at_angle:(CGFloat)angle
{
    return [self point_at_angle:angle r:self.kedur_r1 geometryFlipped:YES];
}

- (CGPoint)point_r0_at_angle:(CGFloat)angle
{
    return [self point_at_angle:angle r:self.kedur_r0 geometryFlipped:YES];
}

- (CGPoint)point_at_angle:(CGFloat)angle r:(CGFloat)r geometryFlipped:(BOOL)geometryFlipped
{
    CGFloat sin = sinf(angle);
    CGFloat cos = cosf(angle) * (geometryFlipped ? 1 : -1);
    //    CGFloat x = self.protractor_center.x + sin * r;
    //    CGFloat y = self.protractor_center.y + cos * r;
    CGFloat x = self.protractor_center.x - cos * r;
    CGFloat y = self.protractor_nop + sin * r; //用center.y不行，因为center的坐标系是以左上角为原点的坐标系
    return CGPointMake(x, y);
}

- (CGPoint)inner_point_at_angle:(CGFloat)angle r:(CGFloat)r geometryFlipped:(BOOL)geometryFlipped {
    CGFloat sin = sinf(angle);
    CGFloat cos = cosf(angle) * (geometryFlipped ? 1 : -1);
    CGFloat x = self.protractor_center.x - cos * r;
    CGFloat y = kScreenHight - self.protractor_nop - sin * r;
    return CGPointMake(x, y);
}

- (CGPoint)edge_point_at_angle:(CGFloat)angle
{
    
    CGFloat angle_min = atan((kScreenHight - self.protractor_nop) / (kScreenWidth / 2));
    //    CGFloat angle_min = atan((600.5 - self.protractor_nop) / (kScreenWidth / 2));
    CGFloat angle_max = M_PI - angle_min;
    CGFloat x = 0, y = self.protractor_nop;
    
    if (angle <= angle_min) {
        y += tan(angle) * (kScreenWidth / 2);
    } else if (angle <= angle_max) {
        CGFloat ang = M_PI / 2 - angle;
        //y = kScreenHight;
        y = 600.5;
        x = self.protractor_center.x - (y - self.protractor_nop) * tan(ang);
        //x = self.protractor_center.x - (kScreenHight - self.protractor_nop) * tan(ang);
    } else {
        CGFloat ang = M_PI - angle;
        x = kScreenWidth;
        y += tan(ang) * (kScreenWidth / 2);
    }
    
    //    CGFloat angle_min = atan((590 - self.protractor_nop) / (kScreenWidth / 2));
    //    CGFloat angle_max = M_PI - angle_min;
    //    CGFloat x = 0, y = self.protractor_nop;
    //    if (angle <=angle_min) {
    //        y+=tan(angle) * (kScreenWidth / 2);
    //    } else if (angle <= angle_max) {
    //        CGFloat ang = M_PI / 2 - angle;
    //        x = self.protractor_center.x - (kScreenHight - self.protractor_nop) * tan(ang);
    //        y = 590;
    //    } else {
    //        CGFloat ang = M_PI - angle;
    //        x = kScreenWidth;
    //        y = 590;
    //    }
    return CGPointMake(x, y);
    
}

// point转夹角 0~180
- (CGFloat)point_to_angle:(CGPoint)point
{
    if (point.y >= kScreenHight - self.protractor_nop)
    {
        point.y = kScreenHight - self.protractor_nop;
    }
    CGFloat w = kScreenHight - self.protractor_nop - point.y;
    CGFloat h = self.protractor_center.x - point.x;
    CGFloat radia = atan(w / h);
    CGFloat angle = radia_to_angle(radia);
    if (angle < 0)
    {
        angle = 180 + angle;
    }
    angle = fabs(angle);
    if (angle == 0 && point.x > (kScreenWidth / 2))
    {
        angle = 180;
    }
    return angle;
}

@end
