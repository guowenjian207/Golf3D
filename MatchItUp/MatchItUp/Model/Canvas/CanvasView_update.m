//
//  CanvasView_update.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/8.
//

#import "CanvasView_update.h"
#import "Tool.h"
#import "FramePlayerView.h"
#import "ComposedView.h"

static NSDictionary *colorDic;

@interface CanvasView_update ()

@property (nonatomic, strong) UIButton *pencilBtn;
@property (nonatomic, strong) UIButton *eraseBtn;
@property (nonatomic, strong) UIButton *lineBtn;
@property (nonatomic, strong) UIButton *rectBtn;
@property (nonatomic, strong) UIButton *angleBtn;
@property (nonatomic, strong) UIButton *circleBtn;
@property (nonatomic, strong) UIButton *curveBtn;
@property (nonatomic, strong) UIButton *deleteAllBtn;
@property (nonatomic, strong) UIButton *redBtn;
@property (nonatomic, strong) UIButton *yellowBtn;
@property (nonatomic, strong) UIButton *greenBtn;
@property (nonatomic, strong) UIButton *blueBtn;
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *rectColor;
@property (nonatomic, strong) UIColor *angleColor;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *curveColor;

@end

@implementation CanvasView_update {
    BOOL isSettingColor;
    UIPanGestureRecognizer *addLinePanGestureRecognizer;
    UIPanGestureRecognizer *addRectPanGestureRecognizer;
    UIPanGestureRecognizer *addCurvePanGestureRecognizer;
    UIPanGestureRecognizer *addCirclePanGestureRecognizer;
    UIPanGestureRecognizer *addAnglePanGestureRecognizer;
    CGPoint origin;
    CAShapeLayer *currentLayer;
    UIBezierPath *currentPath;
    UILabel *angleLabel;
    UIView *pointA;
    UIView *pointB;
    UIView *pointC;
    Tool *currentTool;
    CAShapeLayer *tmpLayer;
    UIBezierPath *tmpPath;
    UIPanGestureRecognizer *panGestureRecognizer;
    CAShapeLayer *buttonLayer;
    UIButton *currentSettingColorBtn;
    NSMutableArray *curvePoint;
    UITapGestureRecognizer *tapGestureRecognizer;
    NSMutableArray *originPoint;
    BOOL canPan;
    CGPoint originA;
    CGPoint originB;
    CGPoint originC;
    NSString *superViewName;
}

+ (void)initialize {
    colorDic = @{[UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1] : @"0",
                 [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1] : @"1",
                 [UIColor blackColor] : @"2",
                 [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1] : @"3",
                 [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1] : @"4"
    };
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    NSString *imageName = [NSString stringWithFormat:@"line%@", colorDic[lineColor]];
    [self.lineBtn setImage:[self getImageWithImage:[UIImage imageNamed:imageName]] forState:UIControlStateNormal];
}

- (void)setRectColor:(UIColor *)rectColor {
    _rectColor = rectColor;
    NSString *imageName = [NSString stringWithFormat:@"rect%@", colorDic[rectColor]];
    [self.rectBtn setImage:[self getImageWithImage:[UIImage imageNamed:imageName]] forState:UIControlStateNormal];
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    NSString *imageName = [NSString stringWithFormat:@"circle%@", colorDic[circleColor]];
    [self.circleBtn setImage:[self getImageWithImage:[UIImage imageNamed:imageName]] forState:UIControlStateNormal];
}

- (void)setCurveColor:(UIColor *)curveColor {
    _curveColor = curveColor;
    NSString *imageName = [NSString stringWithFormat:@"curve%@", colorDic[curveColor]];
    [self.curveBtn setImage:[self getImageWithImage:[UIImage imageNamed:imageName]] forState:UIControlStateNormal];
}

- (void)setAngleColor:(UIColor *)angleColor {
    _angleColor = angleColor;
    NSString *imageName = [NSString stringWithFormat:@"angle%@", colorDic[angleColor]];
    [self.angleBtn setImage:[self getImageWithImage:[UIImage imageNamed:imageName]] forState:UIControlStateNormal];
}

- (UIImage *)getImageWithImage:(UIImage *)image2 {
    CGSize size = CGSizeMake(120, 120);
    UIGraphicsBeginImageContext(size);
    UIImage *image1 = [UIImage imageNamed:@"backImage"];
    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image2 drawInRect:CGRectMake(image1.size.width / 2 - image2.size.width / 2, image1.size.height / 2 - image2.size.height / 2, image2.size.width, image2.size.height)];
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return togetherImage;
}

- (void)initializeWithScrollView:(UIScrollView *)scrollV andSuperView:(UIView *)superView
{
    self.superview = superView;
    if ([superView isKindOfClass:[FramePlayerView class]]) {
        superViewName = @"framePlayer";
    }
    else if ([superView isKindOfClass:[FramePlayerView class]]) {
        superViewName = @"composedView";
    }
    else {
        superViewName = @"";
    }
    _scrollView = scrollV;
    self.pencilBtn = [[UIButton alloc] init];
    [self.pencilBtn addTarget:self action:@selector(draw) forControlEvents:UIControlEventTouchUpInside];
    [self.pencilBtn setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
    [self.pencilBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"canvasCancel"]] forState:UIControlStateSelected];
    [self.superview addSubview:self.pencilBtn];
    
    self.eraseBtn = [[UIButton alloc] init];
    [self.eraseBtn addTarget:self action:@selector(eraseBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.eraseBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"erase"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.eraseBtn];
    [self.eraseBtn setHidden:YES];
    
    self.deleteAllBtn = [[UIButton alloc] init];
    [self.deleteAllBtn addTarget:self action:@selector(deteleAllBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.deleteAllBtn.backgroundColor = [UIColor blackColor];
    [self.deleteAllBtn setTitle:@"Delete All" forState:UIControlStateNormal];
    [self.deleteAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.superview addSubview:self.deleteAllBtn];
    [self.deleteAllBtn setHidden:YES];
    
    self.lineBtn = [[UIButton alloc] init];
    [self.lineBtn addTarget:self action:@selector(lineBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.lineBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"line"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.lineBtn];
    [self.lineBtn setHidden:YES];
    
    self.redBtn = [[UIButton alloc] init];
    [self.redBtn addTarget:self action:@selector(redBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.redBtn.backgroundColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    [self.superview addSubview:self.redBtn];
    [self.redBtn setHidden:YES];
    
    self.rectBtn = [[UIButton alloc] init];
    [self.rectBtn addTarget:self action:@selector(rectBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.rectBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"rectangle"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.rectBtn];
    [self.rectBtn setHidden:YES];
    
    self.yellowBtn = [[UIButton alloc] init];
    [self.yellowBtn addTarget:self action:@selector(yellowBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.yellowBtn.backgroundColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
    [self.superview addSubview:self.yellowBtn];
    [self.yellowBtn setHidden:YES];
    
    self.angleBtn = [[UIButton alloc] init];
    [self.angleBtn addTarget:self action:@selector(angleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.angleBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"angle"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.angleBtn];
    [self.angleBtn setHidden:YES];
    
    self.greenBtn = [[UIButton alloc] init];
    [self.greenBtn addTarget:self action:@selector(greenBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.greenBtn.backgroundColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
    [self.superview addSubview:self.greenBtn];
    [self.greenBtn setHidden:YES];
    
    self.circleBtn = [[UIButton alloc] init];
    [self.circleBtn addTarget:self action:@selector(circleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.circleBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"circle"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.circleBtn];
    [self.circleBtn setHidden:YES];
    
    self.blueBtn = [[UIButton alloc] init];
    [self.blueBtn addTarget:self action:@selector(blueBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.blueBtn.backgroundColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
    [self.superview addSubview:self.blueBtn];
    [self.blueBtn setHidden:YES];
    
    self.curveBtn = [[UIButton alloc] init];
    [self.curveBtn addTarget:self action:@selector(curveBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.curveBtn setImage:[self getImageWithImage:[UIImage imageNamed:@"curve"]] forState:UIControlStateNormal];
    [self.superview addSubview:self.curveBtn];
    [self.curveBtn setHidden:YES];
    
    self.blackBtn = [[UIButton alloc] init];
    [self.blackBtn addTarget:self action:@selector(blackBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.blackBtn.backgroundColor = [UIColor blackColor];
    [self.superview addSubview:self.blackBtn];
    [self.blackBtn setHidden:YES];
    
    [self.delegate mas_makeConstraintsFor:self.pencilBtn
                                      and:self.eraseBtn
                                      and:self.deleteAllBtn
                                      and:self.lineBtn
                                      and:self.redBtn
                                      and:self.rectBtn
                                      and:self.yellowBtn
                                      and:self.angleBtn
                                      and:self.greenBtn
                                      and:self.circleBtn
                                      and:self.blueBtn
                                      and:self.curveBtn
                                      and:self.blackBtn];
    
    addLinePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addLine:)];
    addRectPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addRect:)];
    addCurvePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addCurve:)];
    addCirclePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addCircle:)];
    addAnglePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addAngle:)];
    
    // 从userdefaults中读取，如果有的话
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableString *tmpString = [@"lineColor" mutableCopy];
    [tmpString appendString:superViewName];
    if ([def valueForKey:tmpString]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:tmpString];
        self.lineColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    else {
        self.lineColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    }
    tmpString = [@"rectColor" mutableCopy];
    [tmpString appendString:superViewName];
    if ([def valueForKey:tmpString]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:tmpString];
        self.rectColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    else {
        self.rectColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    }
    tmpString = [@"circleColor" mutableCopy];
    [tmpString appendString:superViewName];
    if ([def valueForKey:tmpString]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:tmpString];
        self.circleColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    else {
        self.circleColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    }
    tmpString = [@"angleColor" mutableCopy];
    [tmpString appendString:superViewName];
    if ([def valueForKey:tmpString]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:tmpString];
        self.angleColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    else {
        self.angleColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    }
    tmpString = [@"curveColor" mutableCopy];
    [tmpString appendString:superViewName];
    if ([def valueForKey:tmpString]) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:tmpString];
        self.curveColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    else {
        self.curveColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
    }
    
    isSettingColor = false;
}

- (void)endAddTool {
    if (self.lineBtn.isSelected) {
        [self endAddLine];
    }
    else if (self.rectBtn.isSelected) {
        [self endAddRect];
    }
    else if (self.angleBtn.isSelected) {
        [self endAddAngle];
    }
    else if (self.circleBtn.isSelected) {
        [self endAddCircle];
    }
    else {
        [self endAddCurve];
    }
    [self hideColorPalette];
    isSettingColor = NO;
    [self.deleteAllBtn setHidden:YES];
}

- (void)enableBtns {
    [self.lineBtn setEnabled:YES];
    [self.rectBtn setEnabled:YES];
    [self.curveBtn setEnabled:YES];
    [self.circleBtn setEnabled:YES];
    [self.angleBtn setEnabled:YES];
}

- (void)disableBtns {
    [self.lineBtn setEnabled:NO];
    [self.rectBtn setEnabled:NO];
    [self.curveBtn setEnabled:NO];
    [self.circleBtn setEnabled:NO];
    [self.angleBtn setEnabled:NO];
}

- (void)startAddLine {
    [self.superview addGestureRecognizer:addLinePanGestureRecognizer];
}

- (void)endAddLine {
    [self.superview removeGestureRecognizer:addLinePanGestureRecognizer];
    [self.lineBtn.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.lineBtn setSelected:NO];
}

- (void)startAddRect {
    [self.superview addGestureRecognizer:addRectPanGestureRecognizer];
}

- (void)endAddRect {
    [self.superview removeGestureRecognizer:addRectPanGestureRecognizer];
    [self.rectBtn.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.rectBtn setSelected:NO];
}

- (void)startAddCurve {
    [self.superview addGestureRecognizer:addCurvePanGestureRecognizer];
}

- (void)endAddCurve {
    [self.superview removeGestureRecognizer:addCurvePanGestureRecognizer];
    [self.curveBtn.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.curveBtn setSelected:NO];
}

- (void)startAddCircle {
    [self.superview addGestureRecognizer:addCirclePanGestureRecognizer];
}

- (void)endAddCircle {
    [self.superview removeGestureRecognizer:addCirclePanGestureRecognizer];
    [self.circleBtn.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.circleBtn setSelected:NO];
}

- (void)startAddAngle {
    [self.superview addGestureRecognizer:addAnglePanGestureRecognizer];
}

- (void)endAddAngle {
    [self.superview removeGestureRecognizer:addAnglePanGestureRecognizer];
    [self.angleBtn.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.angleBtn setSelected:NO];
}

- (void)draw {
    self.pencilBtn.selected = !self.pencilBtn.selected;
    if (self.pencilBtn.selected) {
        [self.lineBtn setHidden:NO];
        [self.eraseBtn setHidden:NO];
        [self.rectBtn setHidden:NO];
        [self.curveBtn setHidden:NO];
        [self.circleBtn setHidden:NO];
        [self.angleBtn setHidden:NO];
        
        if (isSettingColor) {
            [self unhideColorPalette];
        }
        
        if ([self.delegate respondsToSelector:@selector(startDraw)]) {
            [self.delegate startDraw];
        }
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTool:)];
        [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    }
    else {
        [self.lineBtn setHidden:YES];
        [self.eraseBtn setHidden:YES];
        [self.rectBtn setHidden:YES];
        [self.curveBtn setHidden:YES];
        [self.circleBtn setHidden:YES];
        [self.angleBtn setHidden:YES];
        [self.deleteAllBtn setHidden:YES];
        [self hideColorPalette];
        [self deselectCurrentTool];
        if ([self.delegate respondsToSelector:@selector(endDraw)]) {
            [self.delegate endDraw];
        }
        [self.scrollView removeGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)hideColorPalette {
    [self.redBtn setHidden:YES];
    [self.greenBtn setHidden:YES];
    [self.blueBtn setHidden:YES];
    [self.yellowBtn setHidden:YES];
    [self.blackBtn setHidden:YES];
}

- (void)unhideColorPalette {
    [self.redBtn setHidden:NO];
    [self.greenBtn setHidden:NO];
    [self.blueBtn setHidden:NO];
    [self.yellowBtn setHidden:NO];
    [self.blackBtn setHidden:NO];
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

- (void)drawCanvasWithTool:(Tool *)tool {
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentLayer.strokeColor = tool.color.CGColor;
    [self.scrollView.layer addSublayer:currentLayer];
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    if (tool.tool == Line) {
        CGPoint point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height);
        CGPoint point2 = CGPointFromString(tool.pointArray[1]);
        point2 = CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if (tool.tool == Rectangle) {
        CGPoint point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height);
        CGPoint point2 = CGPointFromString(tool.pointArray[1]);
        point2 = CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if (tool.tool == Curve) {
        CGPoint point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height);
        [currentPath moveToPoint:point1];
        for (int i = 1; i < tool.pointArray.count; i++) {
            CGPoint point = CGPointFromString(tool.pointArray[i]);
            point = CGPointMake(point.x * self.scrollView.contentSize.width, point.y * self.scrollView.contentSize.height);
            [currentPath addLineToPoint:point];
        }
        currentLayer.path = currentPath.CGPath;
    }
    else if (tool.tool == Circle) {
        CGPoint point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height);
        CGPoint point2 = CGPointFromString(tool.pointArray[1]);
        point2 = CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height);
        CGFloat x = fmin(point1.x, point2.x);
        CGFloat y = fmin(point1.y, point2.y);
        CGFloat w = fabs(point1.x - point2.x);
        CGFloat h = fabs(point1.y - point2.y);
        currentPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, w, h)];
        currentLayer.path = currentPath.CGPath;
    }
    else if (tool.tool == Angle) {
        CGPoint point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height);
        CGPoint point2 = CGPointFromString(tool.pointArray[1]);
        point2 = CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height);
        CGPoint point3 = CGPointFromString(tool.pointArray[2]);
        point3 = CGPointMake(point3.x * self.scrollView.contentSize.width, point3.y * self.scrollView.contentSize.height);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        currentLayer.path = currentPath.CGPath;
        angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y, self.scrollView.contentSize.width / 5.5, self.scrollView.contentSize.width / 5.5 / 3)];
        [angleLabel setTextAlignment:NSTextAlignmentCenter];
        float labelFontSize = self.scrollView.contentSize.width / 19.5;
        labelFontSize = labelFontSize > 20 ? 20 : labelFontSize;
        [angleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize]];
        [angleLabel setTextColor:tool.color];
        [self.scrollView addSubview:angleLabel];
        CGFloat distance = self.scrollView.contentSize.width / 9.75;
        distance = distance > 40 ? 40 : distance;
        CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
        CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
        CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
        [angleLabel setText:[self computeAngleWithP1:point1 andP2:point2 andP3:point3]];
        [angleLabel setCenter:p3];
        tool.angleLabel = angleLabel;
        angleLabel = nil;
    }
    tool.toolLayer = currentLayer;
    tool.toolPath = currentPath;
}

- (void)deteleAllBtnTapped {
    [self.delegate deleteAllTools];
    [self.deleteAllBtn setHidden:YES];
}

- (void)eraseBtnTapped {
    if (currentTool) {
        switch (currentTool.tool) {
            case Line:
            case Rectangle:
            case Curve:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                pointA = nil;
                pointB = nil;
            }
                break;
            case Circle:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                pointA = nil;
                pointB = nil;
                [tmpLayer removeFromSuperlayer];
                [tmpPath removeAllPoints];
                tmpPath = nil;
                tmpLayer = nil;
            }
                break;
            case Angle:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                [pointC removeFromSuperview];
                [currentTool.angleLabel removeFromSuperview];
                pointA = nil;
                pointB = nil;
                pointC = nil;
            }
                break;
            default:
                break;
        }
        [self.delegate toolArrayRemoveObj:currentTool];
        [currentTool.toolLayer removeFromSuperlayer];
        [currentTool.toolPath removeAllPoints];
        currentTool = nil;
    }
    else {
        [self.deleteAllBtn setHidden:NO];
    }
    if (panGestureRecognizer) {
        [self.superview removeGestureRecognizer:panGestureRecognizer];
    }
    panGestureRecognizer = nil;
}

- (void)selectColorForButton:(UIButton *)button {
    isSettingColor = YES;
    [self unhideColorPalette];
    [button.layer setBorderColor:[UIColor clearColor].CGColor];
    buttonLayer   = [[CAShapeLayer alloc] init];
    buttonLayer.frame           = self.lineBtn.bounds;
    buttonLayer.backgroundColor = [UIColor clearColor].CGColor;
    UIBezierPath *path    = [UIBezierPath bezierPathWithRect:self.lineBtn.bounds];
    buttonLayer.path            = path.CGPath;
    buttonLayer.lineWidth       = 2.0f;
    buttonLayer.lineDashPattern = @[@4, @4];
    buttonLayer.fillColor       = [UIColor clearColor].CGColor;
    buttonLayer.strokeColor     = [UIColor whiteColor].CGColor;
    [button.layer addSublayer:buttonLayer];
}

- (void)deselectCurrentTool {
    if (currentTool) {
        switch (currentTool.tool) {
            case Line:
            case Rectangle:
            case Curve:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                pointA = nil;
                pointB = nil;
            }
                break;
            case Circle:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                pointA = nil;
                pointB = nil;
                [tmpLayer removeFromSuperlayer];
                [tmpPath removeAllPoints];
                tmpPath = nil;
                tmpLayer = nil;
            }
                break;
            case Angle:
            {
                [pointA removeFromSuperview];
                [pointB removeFromSuperview];
                [pointC removeFromSuperview];
                pointA = nil;
                pointB = nil;
                pointC = nil;
            }
                break;
            default:
                break;
        }
    }
    currentTool = nil;
    if (panGestureRecognizer) {
        [self.superview removeGestureRecognizer:panGestureRecognizer];
    }
    panGestureRecognizer = nil;
    [self endAddTool];
    [buttonLayer removeFromSuperlayer];
}

- (void)lineBtnTapped {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    
    if (self.lineBtn.isSelected) {
        [self endAddLine];
        [self selectColorForButton:self.lineBtn];
        currentSettingColorBtn = self.lineBtn;
    }
    else {
        [self deselectCurrentTool];
        [self startAddLine];
        [self.lineBtn setSelected:YES];
        [self.lineBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.lineBtn.layer setBorderWidth:2];
    }
}

- (void)rectBtnTapped {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    
    if (self.rectBtn.isSelected) {
        [self endAddRect];
        [self selectColorForButton:self.rectBtn];
        currentSettingColorBtn = self.rectBtn;
    }
    else {
        [self deselectCurrentTool];
        [self startAddRect];
        [self.rectBtn setSelected:YES];
        [self.rectBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.rectBtn.layer setBorderWidth:2];
    }
}

- (void)curveBtnTapped {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    
    if (self.curveBtn.selected) {
        [self endAddCurve];
        [self selectColorForButton:self.curveBtn];
        currentSettingColorBtn = self.curveBtn;
    }
    else {
        [self deselectCurrentTool];
        [self startAddCurve];
        [self.curveBtn setSelected:YES];
        [self.curveBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.curveBtn.layer setBorderWidth:2];
    }
}

- (void)circleBtnTapped {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    
    if (self.circleBtn.selected) {
        [self endAddCircle];
        [self selectColorForButton:self.circleBtn];
        currentSettingColorBtn = self.circleBtn;
    }
    else {
        [self deselectCurrentTool];
        [self startAddCircle];
        [self.circleBtn setSelected:YES];
        [self.circleBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.circleBtn.layer setBorderWidth:2];
    }
}

- (void)angleBtnTapped {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    
    if (self.angleBtn.selected) {
        [self endAddAngle];
        [self selectColorForButton:self.angleBtn];
        currentSettingColorBtn = self.angleBtn;
    }
    else {
        [self deselectCurrentTool];
        [self startAddAngle];
        [self.angleBtn setSelected:YES];
        [self.angleBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.angleBtn.layer setBorderWidth:2];
    }
}

- (void)redBtnTapped {
    NSString *tmpString;
    if (currentSettingColorBtn == self.lineBtn) {
        self.lineColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
        tmpString = @"lineColor";
        [self lineBtnTapped];
    }
    else if (currentSettingColorBtn == self.rectBtn) {
        self.rectColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
        tmpString = @"rectColor";
        [self rectBtnTapped];
    }
    else if (currentSettingColorBtn == self.angleBtn) {
        self.angleColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
        tmpString = @"angleColor";
        [self angleBtnTapped];
    }
    else if (currentSettingColorBtn == self.circleBtn) {
        self.circleColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
        tmpString = @"circleColor";
        [self circleBtnTapped];
    }
    else {
        self.curveColor = [UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1];
        tmpString = @"curveColor";
        [self curveBtnTapped];
    }
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@"%@%@", tmpString, superViewName];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.996 green:0.011 blue:0 alpha:1]] forKey:tmpStr];
    [def synchronize];
    [buttonLayer removeFromSuperlayer];
    [self hideColorPalette];
    isSettingColor = NO;
}

- (void)yellowBtnTapped {
    NSString *tmpString;
    if (currentSettingColorBtn == self.lineBtn) {
        self.lineColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
        tmpString = @"lineColor";
        [self lineBtnTapped];
    }
    else if (currentSettingColorBtn == self.rectBtn) {
        self.rectColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
        tmpString = @"rectColor";
        [self rectBtnTapped];
    }
    else if (currentSettingColorBtn == self.angleBtn) {
        self.angleColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
        tmpString = @"angleColor";
        [self angleBtnTapped];
    }
    else if (currentSettingColorBtn == self.circleBtn) {
        self.circleColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
        tmpString = @"circleColor";
        [self circleBtnTapped];
    }
    else {
        self.curveColor = [UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1];
        tmpString = @"curveColor";
        [self curveBtnTapped];
    }
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@"%@%@", tmpString, superViewName];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.937 green:0.718 blue:0.001 alpha:1]] forKey:tmpStr];
    [def synchronize];
    [buttonLayer removeFromSuperlayer];
    [self hideColorPalette];
    isSettingColor = NO;
}

- (void)greenBtnTapped {
    NSString *tmpString;
    if (currentSettingColorBtn == self.lineBtn) {
        self.lineColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
        tmpString = @"lineColor";
        [self lineBtnTapped];
    }
    else if (currentSettingColorBtn == self.rectBtn) {
        self.rectColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
        tmpString = @"rectColor";
        [self rectBtnTapped];
    }
    else if (currentSettingColorBtn == self.angleBtn) {
        self.angleColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
        tmpString = @"angleColor";
        [self angleBtnTapped];
    }
    else if (currentSettingColorBtn == self.circleBtn) {
        self.circleColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
        tmpString = @"circleColor";
        [self circleBtnTapped];
    }
    else {
        self.curveColor = [UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1];
        tmpString = @"curveColor";
        [self curveBtnTapped];
    }
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@"%@%@", tmpString, superViewName];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.366 green:0.706 blue:0.321 alpha:1]] forKey:tmpStr];
    [def synchronize];
    [buttonLayer removeFromSuperlayer];
    [self hideColorPalette];
    isSettingColor = NO;
}

- (void)blueBtnTapped {
    NSString *tmpString;
    if (currentSettingColorBtn == self.lineBtn) {
        self.lineColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
        tmpString = @"lineColor";
        [self lineBtnTapped];
    }
    else if (currentSettingColorBtn == self.rectBtn) {
        self.rectColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
        tmpString = @"rectColor";
        [self rectBtnTapped];
    }
    else if (currentSettingColorBtn == self.angleBtn) {
        self.angleColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
        tmpString = @"angleColor";
        [self angleBtnTapped];
    }
    else if (currentSettingColorBtn == self.circleBtn) {
        self.circleColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
        tmpString = @"circleColor";
        [self circleBtnTapped];
    }
    else {
        self.curveColor = [UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1];
        tmpString = @"curveColor";
        [self curveBtnTapped];
    }
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@"%@%@", tmpString, superViewName];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.095 green:0.531 blue:1 alpha:1]] forKey:tmpStr];
    [def synchronize];
    [buttonLayer removeFromSuperlayer];
    [self hideColorPalette];
    isSettingColor = NO;
}

- (void)blackBtnTapped {
    NSString *tmpString;
    if (currentSettingColorBtn == self.lineBtn) {
        self.lineColor = [UIColor blackColor];
        tmpString = @"lineColor";
        [self lineBtnTapped];
    }
    else if (currentSettingColorBtn == self.rectBtn) {
        self.rectColor = [UIColor blackColor];
        tmpString = @"rectColor";
        [self rectBtnTapped];
    }
    else if (currentSettingColorBtn == self.angleBtn) {
        self.angleColor = [UIColor blackColor];
        tmpString = @"angleColor";
        [self angleBtnTapped];
    }
    else if (currentSettingColorBtn == self.circleBtn) {
        self.circleColor = [UIColor blackColor];
        tmpString = @"circleColor";
        [self circleBtnTapped];
    }
    else {
        self.curveColor = [UIColor blackColor];
        tmpString = @"curveColor";
        [self curveBtnTapped];
    }
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@"%@%@", tmpString, superViewName];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:[NSKeyedArchiver archivedDataWithRootObject:[UIColor blackColor]] forKey:tmpStr];
    [def synchronize];
    [buttonLayer removeFromSuperlayer];
    [self hideColorPalette];
    isSettingColor = NO;
}

- (void)addLine:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self.scrollView];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.superview.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = self.lineColor.CGColor;
            [self.scrollView.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            CGPoint translation = [recognizer translationInView:self.superview];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            [currentPath addLineToPoint:[recognizer locationInView:self.scrollView]];
            currentLayer.path = currentPath.CGPath;
            [self endAddLine];
            
            CGPoint point1 = CGPointMake(origin.x / self.scrollView.contentSize.width, origin.y / self.scrollView.contentSize.height);
            CGPoint point2 = CGPointMake([recognizer locationInView:self.scrollView].x / self.scrollView.contentSize.width, [recognizer locationInView:self.scrollView].y / self.scrollView.contentSize.height);
            
            Tool *newLineTool = [[Tool alloc] initWithLinePoint1:point1 andPoint2:point2 andColor:self.lineColor];
            newLineTool.toolLayer = currentLayer;
            newLineTool.toolPath = currentPath;
            [self.delegate toolArrayAddObj:newLineTool];
            break;
        }
        default:
            break;
    }
}

- (void)addRect:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self.scrollView];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.superview.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = self.rectColor.CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.scrollView.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            CGPoint translation = [recognizer translationInView:self.superview];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x, origin.y+translation.y)];
            [currentPath closePath];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            [currentPath addLineToPoint:CGPointMake(origin.x, [recognizer locationInView:self.scrollView].y)];
            [currentPath addLineToPoint:[recognizer locationInView:self.scrollView]];
            [currentPath addLineToPoint:CGPointMake([recognizer locationInView:self.scrollView].x, origin.y)];
            [currentPath closePath];
            currentLayer.path = currentPath.CGPath;
            [self endAddRect];
            
            CGPoint point1 = CGPointMake(origin.x / self.scrollView.contentSize.width, origin.y / self.scrollView.contentSize.height);
            CGPoint point2 = CGPointMake([recognizer locationInView:self.scrollView].x / self.scrollView.contentSize.width, [recognizer locationInView:self.scrollView].y / self.scrollView.contentSize.height);
            
            Tool *newRectTool = [[Tool alloc] initWithRectPoint1:point1 andPoint2:point2 andColor:self.rectColor];
            newRectTool.toolLayer = currentLayer;
            newRectTool.toolPath = currentPath;
            [self.delegate toolArrayAddObj:newRectTool];
            
            break;
        }
        default:
            break;
    }
}

- (void)addCurve:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.superview.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = self.curveColor.CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.scrollView.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            curvePoint = [[NSMutableArray alloc] init];
            [curvePoint addObject:NSStringFromCGPoint([recognizer locationInView:self.scrollView])];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [curvePoint addObject:NSStringFromCGPoint([recognizer locationInView:self.scrollView])];
            [currentPath moveToPoint:CGPointFromString(curvePoint[0])];
            for (int i = 1; i < curvePoint.count; i++) {
                [currentPath addLineToPoint:CGPointFromString(curvePoint[i])];
            }
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [currentPath removeAllPoints];
            [curvePoint addObject:NSStringFromCGPoint([recognizer locationInView:self.scrollView])];
            [currentPath moveToPoint:CGPointFromString(curvePoint[0])];
            for (int i = 1; i < curvePoint.count; i++) {
                [currentPath addLineToPoint:CGPointFromString(curvePoint[i])];
            }
            currentLayer.path = currentPath.CGPath;
            [self endAddCurve];
            
            for (int i = 0; i < curvePoint.count; i++) {
                CGPoint point = CGPointFromString(curvePoint[i]);
                point = CGPointMake(point.x / self.scrollView.contentSize.width, point.y / self.scrollView.contentSize.height);
                curvePoint[i] = NSStringFromCGPoint(point);
            }
            
            Tool *newCurveTool = [[Tool alloc] initWithPoints:curvePoint andColor:self.curveColor];
            curvePoint = nil;
            newCurveTool.toolLayer = currentLayer;
            newCurveTool.toolPath = currentPath;
            [self.delegate toolArrayAddObj:newCurveTool];
            
            break;
        }
        default:
            break;
    }
}

- (void)addCircle:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self.scrollView];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.superview.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = self.circleColor.CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.scrollView.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            CGPoint translation = [recognizer translationInView:self.superview];
            CGFloat x = fmin(origin.x, origin.x+translation.x);
            CGFloat y = fmin(origin.y, origin.y+translation.y);
            CGFloat w = fabs(translation.x);
            CGFloat h = fabs(translation.y);
            currentPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, w, h)];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [currentPath removeAllPoints];
            CGPoint p = [recognizer locationInView:self.scrollView];
            CGFloat x = fmin(origin.x, p.x);
            CGFloat y = fmin(origin.y, p.y);
            CGFloat w = fabs(origin.x - p.x);
            CGFloat h = fabs(origin.y - p.y);
            currentPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, w, h)];
            currentLayer.path = currentPath.CGPath;
            [self endAddCircle];
            
            CGPoint point1 = CGPointMake(origin.x / self.scrollView.contentSize.width, origin.y / self.scrollView.contentSize.height);
            CGPoint point2 = CGPointMake([recognizer locationInView:self.scrollView].x / self.scrollView.contentSize.width, [recognizer locationInView:self.scrollView].y / self.scrollView.contentSize.height);
            
            Tool *newCircleTool = [[Tool alloc] initWithCirclePoint1:point1 andPoint2:point2 andColor:self.circleColor];
            newCircleTool.toolLayer = currentLayer;
            newCircleTool.toolPath = currentPath;
            [self.delegate toolArrayAddObj:newCircleTool];
            
            break;
        }
        default:
            break;
    }
}

- (void)addAngle:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self.scrollView];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.superview.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = self.angleColor.CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.scrollView.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, self.scrollView.contentSize.width / 5.5, self.scrollView.contentSize.width / 5.5 / 3)];
            [angleLabel setTextAlignment:NSTextAlignmentCenter];
            float labelFontSize = self.scrollView.contentSize.width / 19.5;
            labelFontSize = labelFontSize > 20 ? 20 : labelFontSize;
            [angleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize]];
            [angleLabel setTextColor:self.angleColor];
            [self.scrollView addSubview:angleLabel];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            CGPoint tmpP;
            if (origin.y - 110 > self.scrollView.contentOffset.y) {
                tmpP = CGPointMake(origin.x, origin.y - 100);
            }
            else {
                tmpP = CGPointMake(origin.x, origin.y + 100);
            }
            [currentPath moveToPoint:tmpP];
            [currentPath addLineToPoint:origin];
            CGPoint translation = [recognizer translationInView:self.superview];
            
            if (tmpP.x == origin.x+translation.x) {
                [angleLabel setCenter:origin];
            }
            else {
                CGFloat distance = self.scrollView.contentSize.width / 9.75;
                distance = distance > 40 ? 40 : distance;
                CGPoint p1 = [self getPointWithPoint1:origin andPoint2:tmpP andDistance:distance];
                CGPoint p2 = [self getPointWithPoint1:origin andPoint2:CGPointMake(origin.x+translation.x, origin.y+translation.y) andDistance:distance];
                CGPoint p3 = [self getPointWithPoint1:origin andPoint2:CGPointMake(p1.x + p2.x - origin.x, p1.y + p2.y - origin.y) andDistance:distance];
                [angleLabel setCenter:p3];
            }
            
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            currentLayer.path = currentPath.CGPath;
            [angleLabel setText:[self computeAngleWithP1:tmpP andP2:origin andP3:CGPointMake(origin.x+translation.x, origin.y+translation.y)]];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [currentPath removeAllPoints];
            CGPoint tmpP;
            if (origin.y - 110 > self.scrollView.contentOffset.y) {
                tmpP = CGPointMake(origin.x, origin.y - 100);
            }
            else {
                tmpP = CGPointMake(origin.x, origin.y + 100);
            }
            
            if (tmpP.x == [recognizer locationInView:self.scrollView].x) {
                [angleLabel setCenter:origin];
            }
            else {
                CGFloat distance = self.scrollView.contentSize.width / 9.75;
                distance = distance > 40 ? 40 : distance;
                CGPoint p1 = [self getPointWithPoint1:origin andPoint2:tmpP andDistance:distance];
                CGPoint p2 = [self getPointWithPoint1:origin andPoint2:[recognizer locationInView:self.scrollView] andDistance:distance];
                CGPoint p3 = [self getPointWithPoint1:origin andPoint2:CGPointMake(p1.x + p2.x - origin.x, p1.y + p2.y - origin.y) andDistance:distance];
                [angleLabel setCenter:p3];
            }
            
            [currentPath moveToPoint:tmpP];
            [currentPath addLineToPoint:origin];
            [currentPath addLineToPoint:[recognizer locationInView:self.scrollView]];
            currentLayer.path = currentPath.CGPath;
            [angleLabel setText:[self computeAngleWithP1:tmpP andP2:origin andP3:[recognizer locationInView:self.scrollView]]];
            [self endAddAngle];
            
            CGPoint point1 = CGPointMake(tmpP.x / self.scrollView.contentSize.width, tmpP.y / self.scrollView.contentSize.height);
            CGPoint point2 = CGPointMake(origin.x / self.scrollView.contentSize.width, origin.y / self.scrollView.contentSize.height);
            CGPoint point3 = CGPointMake([recognizer locationInView:self.scrollView].x / self.scrollView.contentSize.width, [recognizer locationInView:self.scrollView].y / self.scrollView.contentSize.height);

            Tool *newAngleTool = [[Tool alloc] initWithAnglePoint1:point1 andPoint2:point2 andPoint3:point3 andColor:self.angleColor];
            newAngleTool.toolLayer = currentLayer;
            newAngleTool.toolPath = currentPath;
            newAngleTool.angleLabel = angleLabel;
            angleLabel = nil;
            [self.delegate toolArrayAddObj:newAngleTool];
            
            break;
        }
        default:
            break;
    }
}

- (CGPoint)convertPoint:(CGPoint)point {
    return CGPointMake(point.x * self.scrollView.contentSize.width, point.y * self.scrollView.contentSize.height);
}

- (void)selectTool:(UITapGestureRecognizer *)recognizer {
    if (![self.delegate viewIsLocked]) {
        return;
    }
    CGPoint x0 = [recognizer locationInView:self.scrollView];
    Tool *nearestTool = nil;
    nearestTool = [self.delegate chooseNearestToolWithX:x0];
    [self deselectCurrentTool];
    currentTool = nearestTool;
    if (currentTool != nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [panGestureRecognizer addTarget:self action:@selector(panTool:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self.superview addGestureRecognizer:panGestureRecognizer];
        switch (currentTool.tool) {
            case Line:
            {
                pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointA.layer setBackgroundColor:currentTool.color.CGColor];
                [pointA.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
                [pointA addGestureRecognizer:panA];
                [self.scrollView addSubview:pointA];
                
                pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointB.layer setBackgroundColor:currentTool.color.CGColor];
                [pointB.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
                [pointB addGestureRecognizer:panB];
                [self.scrollView addSubview:pointB];
                
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                point1 = [self convertPoint:point1];
                point2 = [self convertPoint:point2];
                [pointA setCenter:point1];
                [pointB setCenter:point2];
            }
                break;
            case Rectangle:
            {
                pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointA.layer setBackgroundColor:currentTool.color.CGColor];
                [pointA.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
                [pointA addGestureRecognizer:panA];
                [self.scrollView addSubview:pointA];
                
                pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointB.layer setBackgroundColor:currentTool.color.CGColor];
                [pointB.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
                [pointB addGestureRecognizer:panB];
                [self.scrollView addSubview:pointB];
                
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                point1 = [self convertPoint:point1];
                point2 = [self convertPoint:point2];
                [pointA setCenter:point1];
                [pointB setCenter:point2];
            }
                break;
            case Circle:
            {
                pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
                [pointA.layer setBackgroundColor:[UIColor whiteColor].CGColor];
                [pointA.layer setCornerRadius:10];
                UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
                [pointA addGestureRecognizer:panA];
                [self.scrollView addSubview:pointA];
                
                pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
                [pointB.layer setBackgroundColor:[UIColor whiteColor].CGColor];
                [pointB.layer setCornerRadius:10];
                UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
                [pointB addGestureRecognizer:panB];
                [self.scrollView addSubview:pointB];
                
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                point1 = [self convertPoint:point1];
                point2 = [self convertPoint:point2];
                [pointA setCenter:point1];
                [pointB setCenter:point2];
                tmpLayer = [[CAShapeLayer alloc]init];
                [tmpLayer setFrame:self.superview.bounds];
                tmpLayer.lineWidth = 3;
                tmpLayer.strokeColor = [UIColor whiteColor].CGColor;
                tmpLayer.fillColor = [UIColor clearColor].CGColor;
                tmpLayer.lineDashPattern = @[@5, @5];
                [self.scrollView.layer addSublayer:tmpLayer];
                CGFloat x = fmin(pointA.center.x, pointB.center.x);
                CGFloat y = fmin(pointA.center.y, pointB.center.y);
                CGFloat w = fabs(pointA.center.x - pointB.center.x);
                CGFloat h = fabs(pointA.center.y - pointB.center.y);
                tmpPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
                tmpLayer.path = tmpPath.CGPath;
            }
                break;
            case Angle:
            {
                pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointA.layer setBackgroundColor:currentTool.color.CGColor];
                [pointA.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
                [pointA addGestureRecognizer:panA];
                [self.scrollView addSubview:pointA];
                
                pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointB.layer setBackgroundColor:currentTool.color.CGColor];
                [pointB.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
                [pointB addGestureRecognizer:panB];
                [self.scrollView addSubview:pointB];
                
                pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointC.layer setBackgroundColor:currentTool.color.CGColor];
                [pointC.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panC = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointC:)];
                [pointC addGestureRecognizer:panC];
                [self.scrollView addSubview:pointC];
                
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                CGPoint point3 = CGPointFromString(currentTool.pointArray[2]);
                point1 = [self convertPoint:point1];
                point2 = [self convertPoint:point2];
                point3 = [self convertPoint:point3];
                [pointA setCenter:point1];
                [pointB setCenter:point2];
                [pointC setCenter:point3];
            }
                break;
            case Curve:
            {
                pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointA.layer setBackgroundColor:currentTool.color.CGColor];
                [pointA.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
                [pointA addGestureRecognizer:panA];
                [self.scrollView addSubview:pointA];
                
                pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                [pointB.layer setBackgroundColor:currentTool.color.CGColor];
                [pointB.layer setCornerRadius:7.5];
                UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
                [pointB addGestureRecognizer:panB];
                [self.scrollView addSubview:pointB];
                
                CGPoint point1 = CGPointFromString([currentTool.pointArray firstObject]);
                CGPoint point2 = CGPointFromString([currentTool.pointArray lastObject]);
                point1 = [self convertPoint:point1];
                point2 = [self convertPoint:point2];
                [pointA setCenter:point1];
                [pointB setCenter:point2];
            }
                break;
            default:
                break;
        }
    }
}

- (void)panPointA:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            origin = pointA.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:self.scrollView];
            [pointA setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            switch (currentTool.tool) {
                case Line:
                case Rectangle:
                case Angle:
                {
                    CGPoint point = CGPointMake(pointA.center.x / self.scrollView.contentSize.width, pointA.center.y / self.scrollView.contentSize.height);
                    currentTool.pointArray[0] = NSStringFromCGPoint(point);
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                }
                    break;
                case Circle:
                {
                    CGPoint point = CGPointMake(pointA.center.x / self.scrollView.contentSize.width, pointA.center.y / self.scrollView.contentSize.height);
                    currentTool.pointArray[0] = NSStringFromCGPoint(point);
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                    CGFloat x = fmin(pointA.center.x, pointB.center.x);
                    CGFloat y = fmin(pointA.center.y, pointB.center.y);
                    CGFloat w = fabs(pointA.center.x - pointB.center.x);
                    CGFloat h = fabs(pointA.center.y - pointB.center.y);
                    [tmpPath removeAllPoints];
                    tmpPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
                    tmpLayer.path = tmpPath.CGPath;
                }
                    break;
                case Curve:
                {
                    CGPoint point1 = CGPointFromString([currentTool.pointArray firstObject]);
                    CGPoint point2 = CGPointFromString([currentTool.pointArray lastObject]);
                    CGPoint point = CGPointMake(pointA.center.x / self.scrollView.contentSize.width, pointA.center.y / self.scrollView.contentSize.height);
                    for (int i = 0; i < currentTool.pointArray.count; i++) {
                        CGPoint tmpPoint = CGPointFromString(currentTool.pointArray[i]);
                        CGFloat xRate = (tmpPoint.x - point2.x) / (point1.x - point2.x);
                        CGFloat yRate = (tmpPoint.y - point2.y) / (point1.y - point2.y);
                        currentTool.pointArray[i] = NSStringFromCGPoint(CGPointMake(xRate * (point.x - point2.x) + point2.x,
                                                                                    yRate * (point.y - point2.y) + point2.y));
                    }
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                }
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (void)panPointB:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            origin = pointB.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:self.scrollView];
            [pointB setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            switch (currentTool.tool) {
                case Line:
                case Rectangle:
                case Angle:
                {
                    CGPoint point = CGPointMake(pointB.center.x / self.scrollView.contentSize.width, pointB.center.y / self.scrollView.contentSize.height);
                    currentTool.pointArray[1] = NSStringFromCGPoint(point);
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                }
                    break;
                case Circle:
                {
                    CGPoint point = CGPointMake(pointB.center.x / self.scrollView.contentSize.width, pointB.center.y / self.scrollView.contentSize.height);
                    currentTool.pointArray[1] = NSStringFromCGPoint(point);
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                    CGFloat x = fmin(pointA.center.x, pointB.center.x);
                    CGFloat y = fmin(pointA.center.y, pointB.center.y);
                    CGFloat w = fabs(pointA.center.x - pointB.center.x);
                    CGFloat h = fabs(pointA.center.y - pointB.center.y);
                    [tmpPath removeAllPoints];
                    tmpPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
                    tmpLayer.path = tmpPath.CGPath;
                }
                    break;
                case Curve:
                {
                    CGPoint point1 = CGPointFromString([currentTool.pointArray firstObject]);
                    CGPoint point2 = CGPointFromString([currentTool.pointArray lastObject]);
                    CGPoint point = CGPointMake(pointB.center.x / self.scrollView.contentSize.width, pointB.center.y / self.scrollView.contentSize.height);
                    for (int i = 0; i < currentTool.pointArray.count; i++) {
                        CGPoint tmpPoint = CGPointFromString(currentTool.pointArray[i]);
                        CGFloat xRate = (tmpPoint.x - point1.x) / (point2.x - point1.x);
                        CGFloat yRate = (tmpPoint.y - point1.y) / (point2.y - point1.y);
                        currentTool.pointArray[i] = NSStringFromCGPoint(CGPointMake(xRate * (point.x - point1.x) + point1.x,
                                                                                    yRate * (point.y - point1.y) + point1.y));
                    }
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                }
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (void)panPointC:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            origin = pointC.center;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:self.scrollView];
            [pointC setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            switch (currentTool.tool) {
                case Angle:
                {
                    CGPoint point = CGPointMake(pointC.center.x / self.scrollView.contentSize.width, pointC.center.y / self.scrollView.contentSize.height);
                    currentTool.pointArray[2] = NSStringFromCGPoint(point);
                    [currentTool updateWithContentSize:self.scrollView.contentSize];
                }
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

- (CGFloat)computeDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
    CGFloat a = p2.y - p1.y;
    CGFloat b = p1.x - p2.x;
    CGFloat c = p2.x * p1.y - p1.x * p2.y;

//    CGFloat x = (b * b * x0.x - a * b * x0.y - a * c) / (a * a + b * b);
//    CGFloat y = (-a * b * x0.x + a * a * x0.y - b * c) / (a * a + b * b);

    CGFloat d = (a * x0.x + b * x0.y + c) / sqrt(pow(a, 2) + pow(b, 2));
    if (d < 0) {
        d = -d;
    }
    if (((x0.x >= p1.x && x0.x <= p2.x) || (x0.x >= p2.x && x0.x <= p1.x)) || ((x0.y >= p1.y && x0.y <= p2.y ) || (x0.y >= p2.y && x0.y <= p1.y))) {
        if (d <= 20) {
            return d;
        }
    }
    return CGFLOAT_MAX;
}

- (CGFloat)computeCircleDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
    p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
    CGFloat xMin = fmin(p1.x, p2.x);
    CGFloat xMax = fmax(p1.x, p2.x);
    CGFloat m = (p1.x + p2.x) / 2;
    CGFloat n = (p1.y + p2.y) / 2;
    CGFloat a = fabs(p1.x - p2.x) / 2;
    CGFloat b = fabs(p1.y - p2.y) / 2;
    CGFloat d = CGFLOAT_MAX;
    for (CGFloat i = xMin; i <= xMax; i += 1) {
        CGFloat tmp = sqrt((1 - (i - m) * (i - m) / (a * a)) * (b * b));
        CGFloat y1 = tmp + n;
        CGFloat y2 = -tmp + n;
        CGFloat dis = sqrt((x0.x - i) * (x0.x - i) + (x0.y - y1) * (x0.y - y1));
        d = fmin(d, dis);
        dis = sqrt((x0.x - i) * (x0.x - i) + (x0.y - y2) * (x0.y - y2));
        d = fmin(d, dis);
    }
    if (d <= 20) {
        return d;
    }
    return CGFLOAT_MAX;
}

- (BOOL)canPanWith:(CGPoint)x0 andP1:(CGPoint)p1 {
    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
    if (sqrt((x0.x - p1.x) * (x0.x - p1.x) + (x0.y - p1.y) * (x0.y - p1.y)) > 20) {
        return true;
    }
    return false;
}

- (void)panTool:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originPoint = [currentTool.pointArray copy];
        switch (currentTool.tool) {
            case Line:
            {
                if ([self computeDisWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[0]) andP2:CGPointFromString(currentTool.pointArray[1])] <= 20
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[0])]
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[1])]) {
                    canPan = true;
                }
                else {
                    canPan = false;
                    return;
                }
                originA = pointA.center;
                originB = pointB.center;
            }
                break;
            case Rectangle:
            {
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
                CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point2.x, point1.y)];
                CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point1.x, point2.y)];
                CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
                if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:point1]
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:point2]) {
                    canPan = true;
                }
                else {
                    canPan = false;
                    return;
                }
                originA = pointA.center;
                originB = pointB.center;
            }
                break;
            case Curve:
            {
                canPan = false;
                for (int i = 0; i < currentTool.pointArray.count - 1; i++) {
                    CGPoint point1 = CGPointFromString(currentTool.pointArray[i]);
                    CGPoint point2 = CGPointFromString(currentTool.pointArray[i + 1]);
                    CGFloat dis = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2];
                    if (dis <= 20
                        && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString([currentTool.pointArray firstObject])]
                        && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString([currentTool.pointArray lastObject])]) {
                        originA = pointA.center;
                        originB = pointB.center;
                        canPan = true;
                        break;
                    }
                }
                if (!canPan) {
                    return;
                }
            }
                break;
            case Circle:
            {
                CGPoint point1 = CGPointFromString(currentTool.pointArray[0]);
                CGPoint point2 = CGPointFromString(currentTool.pointArray[1]);
                CGFloat dis = [self computeCircleDisWith:[recognizer locationInView:self.scrollView] andP1:point1
                                                   andP2:point2];
                if (dis <= 20) {
                    canPan = true;
                }
                else {
                    canPan = false;
                    return;
                }
                originA = pointA.center;
                originB = pointB.center;
            }
                break;
            case Angle:
            {
                if (([self computeDisWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[0]) andP2:CGPointFromString(currentTool.pointArray[1])] <= 20
                     || [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[1]) andP2:CGPointFromString(currentTool.pointArray[2])] <= 20)
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[0])]
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[1])]
                    && [self canPanWith:[recognizer locationInView:self.scrollView] andP1:CGPointFromString(currentTool.pointArray[2])]) {
                    canPan = true;
                }
                else {
                    canPan = false;
                    return;
                }
                originA = pointA.center;
                originB = pointB.center;
                originC = pointC.center;
            }
                break;
            default:
                break;
        }
    }
    else {
        if (!canPan) {
            return;
        }
        CGPoint offset = [recognizer translationInView:self.scrollView];
        for (int i = 0; i < currentTool.pointArray.count; i++) {
            CGPoint point = CGPointFromString(originPoint[i]);
            point = CGPointMake(point.x * self.scrollView.contentSize.width + offset.x, point.y * self.scrollView.contentSize.height + offset.y);
            point = CGPointMake(point.x / self.scrollView.contentSize.width, point.y / self.scrollView.contentSize.height);
            currentTool.pointArray[i] = NSStringFromCGPoint(point);
        }
        switch (currentTool.tool) {
            case Line:
            case Rectangle:
            case Curve:
            {
                [pointA setCenter:CGPointMake(originA.x + offset.x, originA.y + offset.y)];
                [pointB setCenter:CGPointMake(originB.x + offset.x, originB.y + offset.y)];
            }
                break;
            case Circle:
            {
                [pointA setCenter:CGPointMake(originA.x + offset.x, originA.y + offset.y)];
                [pointB setCenter:CGPointMake(originB.x + offset.x, originB.y + offset.y)];
                CGFloat x = fmin(pointA.center.x, pointB.center.x);
                CGFloat y = fmin(pointA.center.y, pointB.center.y);
                CGFloat w = fabs(pointA.center.x - pointB.center.x);
                CGFloat h = fabs(pointA.center.y - pointB.center.y);
                [tmpPath removeAllPoints];
                tmpPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, w, h)];
                tmpLayer.path = tmpPath.CGPath;
            }
                break;
            case Angle:
            {
                [pointA setCenter:CGPointMake(originA.x + offset.x, originA.y + offset.y)];
                [pointB setCenter:CGPointMake(originB.x + offset.x, originB.y + offset.y)];
                [pointC setCenter:CGPointMake(originC.x + offset.x, originC.y + offset.y)];
            }
                break;
            default:
                break;
        }
        [currentTool updateWithContentSize:self.scrollView.contentSize];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
