//
//  specificationCanvasView.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/18.
//

#import "specificationCanvasView.h"
#import "SpecificationTool.h"
@interface specificationCanvasView()<UICollectionViewDelegate, UICollectionViewDataSource,UIGestureRecognizerDelegate>


@end
@implementation specificationCanvasView{
    CAShapeLayer *currentLayer;
    UIBezierPath *currentPath;
    CAShapeLayer *tmpLayer;
    UIBezierPath *tmpPath;
    SpecificationTool *currentTool;
    UIPanGestureRecognizer *panGestureRecognizer;
    NSMutableArray *originPoint;
    BOOL canPan;
    UITapGestureRecognizer *tapGestureRecognizer;
    UIImageView *rotateImgView;
    CGPoint origin;
    CGPoint originP1;
    CGPoint originP2;
    CGPoint originP3;
    CGFloat originDis;
    CGPoint centerP;
    CGFloat tmpDis;
    CGPoint originCenter;
    UIView *pointA, *pointB, *pointC, *pointD;
    BOOL isPan1;
    UILabel *angleLabel1, *angleLabel2;
    UITapGestureRecognizer *doubleTapGestureRecognizer;
    SpecificationTool *tempTool;
    UIColorPickerViewController *colorPickerVC;
    NSArray *colors;
    UICollectionView *collectionView;
    BOOL ischange;
}
- (NSString *)computeAngleWithP1:(CGPoint)point1 andP2:(CGPoint)point2 andP3:(CGPoint)point3 {
    double o = sqrt(pow((point1.x-point3.x), 2)+pow((point1.y-point3.y), 2));
    double a = sqrt(pow((point2.x-point3.x), 2)+pow((point2.y-point3.y), 2));
    double b = sqrt(pow((point2.x-point1.x), 2)+pow((point2.y-point1.y), 2));
    double angle = acos((pow(a, 2)+pow(b, 2)-pow(o, 2))/(2*a*b))/M_PI*180;
    return [NSString stringWithFormat:@"%.1f°",angle];
}
- (void)initializeWithScrollView:(UIScrollView *)scrollV andSuperView:(UIView *)superView
{
    self.superview = superView;
    _scrollView = scrollV;
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTool:)];
    [_scrollView addGestureRecognizer:tapGestureRecognizer];
}

-(void)initializeWithUIView:(UIView *)scrollV andSuperView:(UIView *)superView{
    self.superview = superView;
    _view = scrollV;
    ischange = NO;
    
    colors = @[
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor greenColor],
        [UIColor yellowColor],
        [UIColor orangeColor],
        [UIColor purpleColor],
        [UIColor brownColor],
        [UIColor blackColor],
        [UIColor whiteColor]
    ];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(30 ,30);
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(450,60,30, 40*colors.count) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_superview addSubview:collectionView];
    [collectionView setHidden:YES];
    [collectionView setCenter:CGPointMake(scrollV.frame.size.width-20, scrollV.frame.size.height/2)];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectToolInGlk:)];
    tapGestureRecognizer.delegate = self;
    [_view addGestureRecognizer:tapGestureRecognizer];
}

-(void)initializeChangeWithUIView:(UIView *)scrollV andSuperView:(UIView *)superView{
    self.superview = superView;
    _view = scrollV;
    ischange = YES;
    
    colors = @[
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor greenColor],
        [UIColor yellowColor],
        [UIColor orangeColor],
        [UIColor purpleColor],
        [UIColor brownColor],
        [UIColor blackColor],
        [UIColor whiteColor]
    ];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(30 ,30);
    layout.minimumLineSpacing = 10;
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(450,60,30, 40*colors.count) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_view addSubview:collectionView];
    [collectionView setHidden:YES];
    [collectionView setCenter:CGPointMake(scrollV.frame.size.width-20, scrollV.frame.size.height/2)];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectToolInGlk:)];
    tapGestureRecognizer.delegate = self;
    [_view addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    // 若为UICollectionViewCell（即点击了collectionViewCell）
    if ([touch.view isDescendantOfView:collectionView]) {
        // cell 不需要响应 父视图的手势，保证didselect 可以正常
        return NO;
    }
    //默认都需要响应
    return YES;
}

-(void)initializeWithColelctionView:(UICollectionView *)scrollV andSuperView:(UICollectionView *)superView{
    self.superview = superView;
    _view = scrollV;
}
#pragma mark collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = colors[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *selectedColor = colors[indexPath.item];
    
    currentTool.color = selectedColor;
    [self.delegate updateColorWithTool:(SpecificationTool*)currentTool];
    [self deselectCurrentTool];
    [tapGestureRecognizer setEnabled:YES];
    [collectionView setHidden:YES];
}
- (void)dealloc {
    [_scrollView removeGestureRecognizer:tapGestureRecognizer];
}
//单图绘制
- (void)drawCanvasWithToolInGlk:(SpecificationTool *)tool{
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    float aveWidth = self.superview.frame.size.width;
    float aveHeight = self.superview.frame.size.height;
    
    if (tool.color) {
        currentLayer.strokeColor = tool.color.CGColor;
    }
    else if (tool.isTemplate) {
        currentLayer.strokeColor = [UIColor whiteColor].CGColor;
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
    }
    else {
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    if (tool.isForDisplay && tool.isSubItem) {
        // 加的两个梯形
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    [self.view.layer addSublayer:currentLayer];
    CGPoint point1, point2, point3, point4;
    if ([tool.type isEqualToString:@"Line"] || [tool.type isEqualToString:@"LineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth , point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth , point2.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"broken Line"]){
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth , point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth , point2.y * aveHeight);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth , point3.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"Quadrilateral"]) {
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth, point3.y * aveHeight);
        point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
        point4 = CGPointMake(point4.x * aveWidth, point4.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        [currentPath addLineToPoint:point4];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Angle"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth, point3.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
//        [currentPath moveToPoint:point2];
//        CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
//        [currentPath addLineToPoint:point4];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"ExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x / 3, offset.y / 3);
        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"SingleExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x, offset.y);
//        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Rect"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Ruler"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
//        [currentPath moveToPoint:point2];
//        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        currentLayer.path = currentPath.CGPath;
        
        UIBezierPath *path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint:point2];
        [path2 addLineToPoint:CGPointMake(point2.x, point1.y)];
       
        CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
        shapeLayer2.path = [path2 CGPath];
        shapeLayer2.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer2.lineWidth = 3.0;

        tool.rulerToolPath = path2;
        // Add the second line to the view's layer
       [currentLayer addSublayer:shapeLayer2];
        tool.rulerLayer = shapeLayer2;
    }

    if ([tool.name isEqual:@"Shaft_Line_To_Armpit"] || [tool.name isEqual:@"Elbow_Hosel_Line"] || [tool.name isEqual:@"Shoulder_Tilt"] || [tool.name isEqual:@"Shaft_Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        if(point1.y>point2.y){
            if(point1.x>point2.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x-10, point1.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x+10, point1.y)];
            }
            
            angleLabel1.center = point1;
        }else{
            if(point2.x>point1.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x-10, point2.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x+10, point2.y)];
            }
            
            angleLabel1.center = point2;
        }
        if([tool.name isEqual:@"Shaft_Line"]){
            angleLabel1.center = point2;
        }
        tool.angleLabel1.textColor = tool.color;
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    
    tool.lastLayer = currentLayer;
    tool.toolPath = currentPath;
}
//无间隔绘制
- (void)drawCanvasSmallWithTool:(SpecificationTool *)tool{
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    float aveWidth = self.superview.frame.size.width/6;
    float aveHeight = self.superview.frame.size.height;
    int frameindx = [tool.index intValue];
    float offsetX = frameindx % 6 * aveWidth;
    float offsetY = 0;
    
    if (tool.color) {
        currentLayer.strokeColor = tool.color.CGColor;
    }
    else if (tool.isTemplate) {
        currentLayer.strokeColor = [UIColor whiteColor].CGColor;
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
    }
    else {
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    if (tool.isForDisplay && tool.isSubItem) {
        // 加的两个梯形
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    [self.view.layer addSublayer:currentLayer];
    CGPoint point1, point2, point3, point4;
    if ([tool.type isEqualToString:@"Line"] || [tool.type isEqualToString:@"LineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"broken Line"]){
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"Quadrilateral"]) {
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
        point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        [currentPath addLineToPoint:point4];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Angle"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
//        [currentPath moveToPoint:point2];
//        CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
//        [currentPath addLineToPoint:point4];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"ExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x / 3, offset.y / 3);
        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"SingleExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x, offset.y);
//        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Rect"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Ruler"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
//        [currentPath moveToPoint:point2];
//        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        currentLayer.path = currentPath.CGPath;
        
        UIBezierPath *path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint:point2];
        [path2 addLineToPoint:CGPointMake(point2.x, point1.y)];
       
        CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
        shapeLayer2.path = [path2 CGPath];
        shapeLayer2.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer2.lineWidth = 3.0;
        
        tool.rulerToolPath = path2;
        
        // Add the second line to the view's layer
       [currentLayer addSublayer:shapeLayer2];
        tool.rulerLayer = shapeLayer2;
    }
    
    if ([tool.name isEqual:@"Shaft_Line_To_Armpit"] || [tool.name isEqual:@"Elbow_Hosel_Line"] || [tool.name isEqual:@"Shoulder_Tilt"] || [tool.name isEqual:@"Shaft_Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        if(point1.y>point2.y){
            if(point1.x>point2.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x-10, point1.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x+10, point1.y)];
            }
            
            angleLabel1.center = point1;
        }else{
            if(point2.x>point1.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x-10, point2.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x+10, point2.y)];
            }
            
            angleLabel1.center = point2;
        }
        if([tool.name isEqual:@"Shaft_Line"]){
            angleLabel1.center = point2;
        }
        tool.angleLabel1.textColor = tool.color;
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }

    
    tool.toolLayer = currentLayer;
    tool.toolPath = currentPath;
}
//3D有间隔绘制
- (void)drawCanvasWithTool:(SpecificationTool *)tool{
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    CGFloat kItemWidth = UIScreen.mainScreen.bounds.size.width/13;
    CGFloat kItemHeight = kItemWidth/4*5;
    int frameIdx = [tool.index intValue];
    float gap = self.scrollView.zoomScale * 18;
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
    
    if (tool.color) {
        currentLayer.strokeColor = tool.color.CGColor;
    }
    else if (tool.isTemplate) {
        currentLayer.strokeColor = [UIColor whiteColor].CGColor;
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
    }
    else {
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    if (tool.isForDisplay && tool.isSubItem) {
        // 加的两个梯形
        currentLayer.strokeColor = [UIColor redColor].CGColor;
    }
    
    [self.scrollView.layer addSublayer:currentLayer];
    CGPoint point1, point2, point3, point4;
    if ([tool.type isEqualToString:@"Line"] || [tool.type isEqualToString:@"LineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"broken Line"]){
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        currentLayer.path = currentPath.CGPath;
    }else if ([tool.type isEqualToString:@"Quadrilateral"]) {
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
        point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        [currentPath addLineToPoint:point4];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Angle"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
//        [currentPath moveToPoint:point2];
//        CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
//        [currentPath addLineToPoint:point4];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"ExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x / 3, offset.y / 3);
        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"SingleExternLineWithNode"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        offset = CGPointMake(offset.x, offset.y);
//        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
        point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Rect"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Ruler"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:CGPointMake(point1.x, point2.y)];
//        [currentPath moveToPoint:point2];
//        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        currentLayer.path = currentPath.CGPath;
        
        UIBezierPath *path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint:point2];
        [path2 addLineToPoint:CGPointMake(point2.x, point1.y)];
       
        CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
        shapeLayer2.path = [path2 CGPath];
        shapeLayer2.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer2.lineWidth = 3.0;
        tool.rulerToolPath = path2;
        
        // Add the second line to the view's layer
        [currentLayer addSublayer:shapeLayer2];
        tool.rulerLayer = shapeLayer2;
    }
    
    if ([tool.name isEqual:@"Shaft_Line_To_Armpit"] || [tool.name isEqual:@"Elbow_Hosel_Line"] || [tool.name isEqual:@"Shoulder_Tilt"] || [tool.name isEqual:@"Shaft_Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        if(point1.y>point2.y){
            if(point1.x>point2.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x-10, point1.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x+10, point1.y)];
            }
            
            angleLabel1.center = point1;
        }else{
            if(point2.x>point1.x){
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x-10, point2.y)];
            }else{
                tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x+10, point2.y)];
            }
            
            angleLabel1.center = point2;
        }
        if([tool.name isEqual:@"Shaft_Line"]){
            angleLabel1.center = point2;
        }
        tool.angleLabel1.textColor = tool.color;
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }

    tool.toolLayer = currentLayer;
    tool.toolPath = currentPath;
}

- (void)deselectCurrentTool {
    [tmpLayer removeFromSuperlayer];
    tmpLayer = nil;
    tmpPath = nil;
    [pointA removeFromSuperview];
    pointA = nil;
    [pointB removeFromSuperview];
    pointB = nil;
    [pointC removeFromSuperview];
    pointC = nil;
    [pointD removeFromSuperview];
    pointD = nil;
    [rotateImgView removeFromSuperview];
    rotateImgView = nil;
    [currentTool.label setHidden:YES];
    [currentTool.toolLayer removeAllAnimations];
    [collectionView setHidden:YES];
    [self.scrollView.panGestureRecognizer setEnabled:YES];
    [self.scrollView.pinchGestureRecognizer setEnabled:YES];
}
- (void)selectToolInGlk:(UITapGestureRecognizer *)recognizer {
    CGPoint x0 = [recognizer locationInView:self.view];
    SpecificationTool *nearestTool = nil;
    nearestTool = [self.delegate chooseNearestSpecificationToolWithXInGlk:x0];
    currentTool = nearestTool;
    [self deselectCurrentTool];
    if (currentTool != nil) {
        [collectionView setHidden:NO];
        currentTool.hasAdjust = true;
        [currentTool.label setHidden:NO];
        if (currentTool.isForDisplay) {
            return;
        }
//        [tapGestureRecognizer setEnabled:NO];
        if(ischange){
            panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            [panGestureRecognizer addTarget:self action:@selector(panTool2:)];
            panGestureRecognizer.maximumNumberOfTouches = 1;
            [self.superview addGestureRecognizer:panGestureRecognizer];
        }
        
        CGPoint point1, point2, point3, point4;
        float aveWidth = _view.frame.size.width;
        float aveHeight = _view.frame.size.height;
        float offsetX = 0;
        float offsetY = 0;
        if([currentTool.type isEqual:@"Line"]){
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            [self.view addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            [self.view addSubview:pointB];
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            
        }else if([currentTool.type isEqual:@"broken Line"]){
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.view addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.view addSubview:pointB];
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            
        }
        else if ([currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"] || [currentTool.type isEqual:@"Rect"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.view addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.view addSubview:pointB];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
        }else if ([currentTool.type isEqual:@"Angle"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.view addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.view addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.color.CGColor];
            [pointC.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panC = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointC:)];
            [pointC addGestureRecognizer:panC];
            [self.view addSubview:pointC];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
        }else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point4 = CGPointMake(currentTool.x4.floatValue, currentTool.y4.floatValue);
            point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.view addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.view addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.color.CGColor];
            [pointC.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panC = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointC:)];
            [pointC addGestureRecognizer:panC];
            [self.view addSubview:pointC];
            
            pointD = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointD.layer setBackgroundColor:currentTool.color.CGColor];
            [pointD.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panD = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointD:)];
            [pointD addGestureRecognizer:panD];
            [self.view addSubview:pointD];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            [pointD setCenter:point4];
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            tmpLayer = [[CAShapeLayer alloc]init];
            [tmpLayer setFrame:self.superview.bounds];
            tmpLayer.lineWidth = 3;
            [self.view.layer addSublayer:tmpLayer];
            tmpPath = [UIBezierPath bezierPath];
            tmpLayer.fillColor = [UIColor clearColor].CGColor;
            tmpLayer.strokeColor = [UIColor redColor].CGColor;
            [tmpPath moveToPoint:CGPointMake(point1.x, (point1.y + point2.y) / 2)];
            [tmpPath addLineToPoint:CGPointMake(point2.x, (point1.y + point2.y) / 2)];
            tmpLayer.path = tmpPath.CGPath;
        }
    }
}

- (void)selectTool:(UITapGestureRecognizer *)recognizer {
    CGPoint x0 = [recognizer locationInView:self.scrollView];
    SpecificationTool *nearestTool = nil;
    nearestTool = [self.delegate chooseNearestSpecificationToolWithX:x0];
    [self deselectCurrentTool];
    tempTool = [nearestTool copy];
    currentTool = [nearestTool copy];
    [self drawCanvasWithTool:currentTool];
    [currentTool.toolLayer removeAllAnimations];
    
    if (currentTool != nil) {
        currentTool.hasAdjust = true;
        [currentTool.label setHidden:NO];
        if (currentTool.isForDisplay) {
            return;
        }
        [self.scrollView.panGestureRecognizer setEnabled:NO];
        [self.scrollView.pinchGestureRecognizer setEnabled:NO];
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [panGestureRecognizer addTarget:self action:@selector(panTool:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self.superview addGestureRecognizer:panGestureRecognizer];
        
        CGPoint point1, point2, point3, point4;
        CGFloat kItemWidth = UIScreen.mainScreen.bounds.size.width/13;
        CGFloat kItemHeight = kItemWidth/4*5;
        int frameIdx = [currentTool.index intValue];
        float gap = self.scrollView.zoomScale * 18;
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
        if([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"] || [currentTool.type isEqual:@"Rect"]){
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointB];
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            
        }else if([currentTool.type isEqual:@"broken Line"]){
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointB];
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            
        }else if ([currentTool.type isEqual:@"Angle"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.color.CGColor];
            [pointC.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointC];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
        }
        else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point4 = CGPointMake(currentTool.x4.floatValue, currentTool.y4.floatValue);
            point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.color.CGColor];
            [pointA.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.color.CGColor];
            [pointB.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.color.CGColor];
            [pointC.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointC];
            
            pointD = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointD.layer setBackgroundColor:currentTool.color.CGColor];
            [pointD.layer setCornerRadius:7.5];
            [self.scrollView addSubview:pointD];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            [pointD setCenter:point4];
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);

            tmpLayer = [[CAShapeLayer alloc]init];
            [tmpLayer setFrame:self.superview.bounds];
            tmpLayer.lineWidth = 3;
            [self.scrollView.layer addSublayer:tmpLayer];
            tmpPath = [UIBezierPath bezierPath];
            tmpLayer.fillColor = [UIColor clearColor].CGColor;
            tmpLayer.strokeColor = [UIColor redColor].CGColor;
            [tmpPath moveToPoint:CGPointMake(point1.x, (point1.y + point2.y) / 2)];
            [tmpPath addLineToPoint:CGPointMake(point2.x, (point1.y + point2.y) / 2)];
            tmpLayer.path = tmpPath.CGPath;
        }
//        if (currentTool.isTemplate) {
//            [pointA removeFromSuperview];
//            pointA = nil;
//            [pointB removeFromSuperview];
//            pointB = nil;
//            [pointC removeFromSuperview];
//            pointC = nil;
//            [pointD removeFromSuperview];
//            pointD = nil;
//        }
//
//        if (currentTool.isSubItem) {
//            doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
//            doubleTapGestureRecognizer.numberOfTapsRequired = 2;
//            doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
//            [doubleTapGestureRecognizer addTarget:self action:@selector(doubleTapped:)];
//            [self.superview addGestureRecognizer:doubleTapGestureRecognizer];
//        }
    }
}

- (CGFloat)getDisBetweenP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

- (CGPoint)getPointWithPoint:(CGPoint)point andK:(CGFloat)k andDis:(CGFloat)dis andOriginP:(CGPoint)originP andNewCenter:(CGPoint)newCenter {
    CGFloat bias = point.y - k * point.x;
    CGFloat a = 1 + k * k;
    CGFloat b = 2 * k * (bias - point.y) - 2 * point.x;
    CGFloat c = point.x * point.x + (bias - point.y) * (bias - point.y) - dis * dis;
    CGFloat x1 = (-b + sqrt(b * b - 4 * a * c)) / (2 * a);
    CGFloat x2 = (-b - sqrt(b * b - 4 * a * c)) / (2 * a);
    CGFloat y1 = k * x1 + bias;
    CGFloat y2 = k * x2 + bias;
    CGPoint ans;
    CGPoint ans1 = CGPointMake(x1, y1);
    CGPoint ans2 = CGPointMake(x2, y2);
    CGFloat length = [self getDisBetweenP1:centerP andP2:originP];
    CGFloat rate = [self getDisBetweenP1:newCenter andP2:originCenter] / [self getDisBetweenP1:centerP andP2:originCenter];
    if (fabs([self getDisBetweenP1:ans1 andP2:originP] / length - rate) <
        fabs([self getDisBetweenP1:ans2 andP2:originP] / length - rate)) {
        ans = ans1;
    }
    else {
        ans = ans2;
    }
    return ans;
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

- (CGFloat)computeDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    if(self.scrollView){
        p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
        p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
    }else{
        p1 = CGPointMake(p1.x * self.view.frame.size.width, p1.y * self.view.frame.size.height);
        p2 = CGPointMake(p2.x * self.view.frame.size.width, p2.y * self.view.frame.size.height);
    }
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

- (void)panTool:(UIPanGestureRecognizer *)recognizer {
    if (currentTool.isForDisplay) {
        return;
    }
    CGFloat kItemWidth = UIScreen.mainScreen.bounds.size.width/13;
    CGFloat kItemHeight = kItemWidth/4*5;
    int frameIdx = [currentTool.index intValue];
    float gap = self.scrollView.zoomScale * 18;
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
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originPoint = [[NSMutableArray alloc] init];
        CGPoint point1, point2, point3, point4;
        if ([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            if (rotateImgView) {
                originCenter = rotateImgView.center;
            }
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            if ([self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2] <= 20) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        } else if ([currentTool.type isEqual:@"broken Line"]){
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / _scrollView.contentSize.width, point1.y / _scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / _scrollView.contentSize.width, point2.y / _scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / _scrollView.contentSize.width, point3.y / _scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 =[self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point3];
            if ((dis1 <= 20 || dis2 <= 20 )) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Rect"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point2.x, point1.y)];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point4 = CGPointMake(currentTool.x4.floatValue, currentTool.y4.floatValue);
            point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / self.scrollView.contentSize.width, point3.y / self.scrollView.contentSize.height);
            point4 = CGPointMake(point4.x / self.scrollView.contentSize.width, point4.y / self.scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            [originPoint addObject:NSStringFromCGPoint(point4)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point3 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point4];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if ((dis1 <= 20 || dis2 <= 20)) {
                if (dis1 < dis2) {
                    isPan1 = true;
                }
                else {
                    isPan1 = false;
                }
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"RotateRect"]) {
            originCenter = rotateImgView.center;
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / self.scrollView.contentSize.width, point3.y / self.scrollView.contentSize.height);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point3 andP2:point4];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Angle"]) {
            originCenter = rotateImgView.center;
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            point3 = CGPointMake(point3.x / self.scrollView.contentSize.width, point3.y / self.scrollView.contentSize.height);
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point4];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point3];
            if ((dis1 <= 20 || dis2 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
            point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if ((dis1 <= 20 || dis2 <= 20)) {
                if (dis1 < dis2) {
                    isPan1 = true;
                }
                else {
                    isPan1 = false;
                }
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        if (!canPan) {
            return;
        }
        CGPoint offset = [recognizer translationInView:self.scrollView];
        if ([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"Rect"] || [currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
            point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            if (rotateImgView) {
                [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            }
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            
        }
        else if ([currentTool.type isEqual:@"broken Line"]){
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
            point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            point3 = CGPointMake(point3.x * self.scrollView.contentSize.width + realOffset.x, point3.y * self.scrollView.contentSize.height + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point3];
            if (rotateImgView) {
                [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            }
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint realOffset;
            if (isPan1 || !isPan1) {
                realOffset = offset;
                point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
                point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            }
            [tmpPath removeAllPoints];
            [tmpPath moveToPoint:CGPointMake(point1.x, (point1.y + point2.y) / 2)];
            [tmpPath addLineToPoint:CGPointMake(point2.x, (point1.y + point2.y) / 2)];
            tmpLayer.path = tmpPath.CGPath;
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
        }
        else if ([currentTool.type isEqual:@"RotateRect"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
            point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            point3 = CGPointMake(point3.x * self.scrollView.contentSize.width + realOffset.x, point3.y * self.scrollView.contentSize.height + realOffset.y);
            [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint point4 = CGPointFromString(originPoint[3]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
            point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            point3 = CGPointMake(point3.x * self.scrollView.contentSize.width + realOffset.x, point3.y * self.scrollView.contentSize.height + realOffset.y);
            point4 = CGPointMake(point4.x * self.scrollView.contentSize.width + realOffset.x, point4.y * self.scrollView.contentSize.height + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            [pointD setCenter:point4];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            point4 = CGPointMake(point4.x - offsetX, point4.y - offsetY);
            point4 = CGPointMake(point4.x / aveWidth, point4.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
            currentTool.x4 = @(point4.x);
            currentTool.y4 = @(point4.y);
        }
        else if ([currentTool.type isEqual:@"Angle"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
            point2 = CGPointMake(point2.x * self.scrollView.contentSize.width + realOffset.x, point2.y * self.scrollView.contentSize.height + realOffset.y);
            point3 = CGPointMake(point3.x * self.scrollView.contentSize.width + realOffset.x, point3.y * self.scrollView.contentSize.height + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        
        
        [currentTool updateInCopyWithContentSize:self.scrollView.contentSize];
        
    }
    else {
        CGPoint point = [recognizer locationInView:_scrollView];
        [currentTool.toolLayer removeFromSuperlayer];
        [self deselectCurrentTool];
        currentTool = nil;
        for(int i=0;i<6;i++){
            bool isContain = [self.delegate isContainPoint:point andIndex:i];
            if(isContain && tempTool){
                [self.delegate addSpectificationToolWithTool:tempTool andIndex:i];
                break;
            }
        }
        tempTool = nil;
    }
}

- (CGPoint)limitPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andOffset:(CGPoint)offset inFrameIdx:(int)frameIdx {
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    if (point1.x < point2.x) {
        if (offset.x < 0) {
            if (offset.x + point1.x < offsetX) {
                offset.x = offsetX - point1.x;
            }
        }
        else {
            if (offset.x + point2.x > offsetX + aveWidth) {
                offset.x = offsetX + aveWidth - point2.x;
            }
        }
    }
    else {
        if (offset.x < 0) {
            if (offset.x + point2.x < offsetX) {
                offset.x = offsetX - point2.x;
            }
        }
        else {
            if (offset.x + point1.x > offsetX + aveWidth) {
                offset.x = offsetX + aveWidth - point1.x;
            }
        }
    }
    
    if (point1.y < point2.y) {
        if (offset.y < 0) {
            if (offset.y + point1.y < offsetY) {
                offset.y = offsetY - point1.y;
            }
        }
        else {
            if (offset.y + point2.y > offsetY + aveHeight) {
                offset.y = offsetY + aveHeight - point2.y;
            }
        }
    }
    else {
        if (offset.y < 0) {
            if (offset.y + point2.y < offsetY) {
                offset.y = offsetY - point2.y;
            }
        }
        else {
            if (offset.y + point1.y > offsetY + aveHeight) {
                offset.y = offsetY + aveHeight - point1.y;
            }
        }
    }
    return offset;
}

- (CGPoint)limitRulerWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andOffset:(CGPoint)offset inFrameIdx:(int)frameIdx {
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    if (offset.x < 0) {
        if (offset.x + point1.x < offsetX) {
            offset.x = offsetX - point1.x;
        }
    }
    else {
        if (offset.x + point1.x > offsetX + aveWidth) {
            offset.x = offsetX + aveWidth - point1.x;
        }
    }
    
    if (point1.y < point2.y) {
        if (offset.y < 0) {
            if (offset.y + point1.y < offsetY) {
                offset.y = offsetY - point1.y;
            }
        }
        else {
            if (offset.y + point2.y > offsetY + aveHeight) {
                offset.y = offsetY + aveHeight - point2.y;
            }
        }
    }
    else {
        if (offset.y < 0) {
            if (offset.y + point2.y < offsetY) {
                offset.y = offsetY - point2.y;
            }
        }
        else {
            if (offset.y + point1.y > offsetY + aveHeight) {
                offset.y = offsetY + aveHeight - point1.y;
            }
        }
    }
    return offset;
}


- (void)panTool2:(UIPanGestureRecognizer *)recognizer {
    if (currentTool.isForDisplay) {
        return;
    }
//    int frameIdx = 0;
    float aveWidth = _view.frame.size.width;
    float aveHeight = _view.frame.size.height;
    float offsetX = 0;
    float offsetY = 0;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originPoint = [[NSMutableArray alloc] init];
        CGPoint point1, point2, point3, point4;
        if ([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            if (rotateImgView) {
                originCenter = rotateImgView.center;
            }
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            if ([self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point2] <= 20) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"broken Line"]) {
            originCenter = rotateImgView.center;
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
        
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
           
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
          

            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point3 andP2:point4];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Rect"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:CGPointMake(point2.x, point1.y)];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);

            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);

            point4 = CGPointMake(currentTool.x4.floatValue, currentTool.y4.floatValue);

            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            [originPoint addObject:NSStringFromCGPoint(point4)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point3 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point4];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            

            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if ((dis1 <= 20 || dis2 <= 20)) {
                if (dis1 < dis2) {
                    isPan1 = true;
                }
                else {
                    isPan1 = false;
                }
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"RotateRect"]) {
            originCenter = rotateImgView.center;
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
        
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
           
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
          

            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point3 andP2:point4];
            if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
        else if ([currentTool.type isEqual:@"Angle"]) {
            originCenter = rotateImgView.center;
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
           
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);

           
//            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            [originPoint addObject:NSStringFromCGPoint(point1)];
            [originPoint addObject:NSStringFromCGPoint(point2)];
            [originPoint addObject:NSStringFromCGPoint(point3)];
            CGFloat dis1 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.view] andP1:point2 andP2:point3];
            if ((dis1 <= 20 || dis2 <= 20)) {
                canPan = true;
            }
            else {
                canPan = false;
                return;
            }
        }
    }
    else {
        if (!canPan) {
            return;
        }
        CGPoint offset = [recognizer translationInView:self.view];
        if ([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"Rect"] || [currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
            point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            if (rotateImgView) {
                [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            }
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            
//            if ([currentTool.name isEqual:@"Head Height"] && [currentTool.frame isEqual:@0]) {
//                scoreTool *headPositionTool = [self.delegate getHeadPositionTool];
//                CGFloat offset = point1.y - [headPositionTool.y1 floatValue];
//                headPositionTool.y1 = @([headPositionTool.y1 floatValue] + offset);
//                headPositionTool.y2 = @([headPositionTool.y2 floatValue] + offset);
//                [headPositionTool updateWithContentSize:self.view.contentSize andvideoH:0 andvideoW:0];
//            }
        }else if ([currentTool.type isEqual:@"broken Line"]) {
//            if (!currentTool.LRMovable) {
//                offset.x = 0;
//            }
//            if (!currentTool.UDMovable) {
//                offset.y = 0;
//            }
            if(fabs(offset.x)>fabs(offset.y)){
                offset.y = 0;
            }else{
                offset.x = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
            point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            point3 = CGPointMake(point3.x * aveWidth + realOffset.x, point3.y * aveHeight + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point3];
            [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        else if ([currentTool.type isEqual:@"Ruler"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint realOffset;
            if (isPan1) {
                realOffset =offset;
                point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
                point2 = CGPointMake(point2.x * aveWidth, point2.y * aveHeight + realOffset.y);
            }
            else {
                realOffset = offset;
                point1 = CGPointMake(point1.x * aveWidth, point1.y * aveHeight + realOffset.y);
                point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            }
            [tmpPath removeAllPoints];
            [tmpPath moveToPoint:CGPointMake(point1.x, (point1.y + point2.y) / 2)];
            [tmpPath addLineToPoint:CGPointMake(point2.x, (point1.y + point2.y) / 2)];
            tmpLayer.path = tmpPath.CGPath;
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
        }
        else if ([currentTool.type isEqual:@"RotateRect"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
            point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            point3 = CGPointMake(point3.x * aveWidth + realOffset.x, point3.y * aveHeight + realOffset.y);
            [rotateImgView setCenter:CGPointMake(originCenter.x + realOffset.x, originCenter.y + realOffset.y)];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        else if ([currentTool.type isEqual:@"Quadrilateral"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint point4 = CGPointFromString(originPoint[3]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
            point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            point3 = CGPointMake(point3.x * aveWidth + realOffset.x, point3.y * aveHeight + realOffset.y);
            point4 = CGPointMake(point4.x * aveWidth + realOffset.x, point4.y * aveHeight + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            [pointD setCenter:point4];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            point4 = CGPointMake(point4.x - offsetX, point4.y - offsetY);
            point4 = CGPointMake(point4.x / aveWidth, point4.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
            currentTool.x4 = @(point4.x);
            currentTool.y4 = @(point4.y);
        }
        else if ([currentTool.type isEqual:@"Angle"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint point3 = CGPointFromString(originPoint[2]);
            CGPoint realOffset = offset;
            point1 = CGPointMake(point1.x * aveWidth + realOffset.x, point1.y * aveHeight + realOffset.y);
            point2 = CGPointMake(point2.x * aveWidth + realOffset.x, point2.y * aveHeight + realOffset.y);
            point3 = CGPointMake(point3.x * aveWidth + realOffset.x, point3.y * aveHeight + realOffset.y);
            [pointA setCenter:point1];
            [pointB setCenter:point2];
            [pointC setCenter:point3];
            
            point1 = CGPointMake(point1.x - offsetX, point1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(point2.x - offsetX, point2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(point3.x - offsetX, point3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
        }
        [currentTool updateWithContentSize:_view.frame.size];
    }
}

- (void)panPointA:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointA.center;
        originP1 = pointB.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.view];
        [pointA setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        float aveWidth = _view.frame.size.width;
        float aveHeight = _view.frame.size.height;
        float offsetX = 0;
        float offsetY = 0;
        CGPoint point = pointA.center;
        CGPoint point1;
        point1 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
        currentTool.x1 = @(point1.x);
        currentTool.y1 = @(point1.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            [pointB setCenter:CGPointMake(originP1.x-translation.x, originP1.y+translation.y)];
            CGPoint point = pointB.center;
            CGPoint point2;
            point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
//            [pointB setCenter:CGPointMake(pointB.center.x, pointA.center.y)];
        }else if ([currentTool.type isEqual:@"broken Line"]){
            currentTool.y2 = @(point1.y);
        }
        [currentTool updateWithContentSize:_view.frame.size];
    }
}

- (void)panPointB:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointB.center;
        originP1 = pointA.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.view];
        [pointB setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        float aveWidth = _view.frame.size.width;
        float aveHeight = _view.frame.size.height;
        float offsetX = 0;
        float offsetY = 0;
        CGPoint point = pointB.center;
        CGPoint point2;
        point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
        if ([currentTool.type isEqual:@"broken Line"]){
            currentTool.x3 = @(point2.x);
            currentTool.y3 = @(point2.y);
        }else{
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
        }
        
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            [pointA setCenter:CGPointMake(originP1.x-translation.x, originP1.y+translation.y)];
            CGPoint point = pointA.center;
            CGPoint point2;
            point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point2.x);
            currentTool.y1 = @(point2.y);
        }else if ([currentTool.type isEqual:@"broken Line"]){
            currentTool.x2 = @(point2.x);
        }
        [currentTool updateWithContentSize:_view.frame.size];
    }
}

- (void)panPointC:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointC.center;
        originP1 = pointD.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.view];
        [pointC setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        float aveWidth = _view.frame.size.width;
        float aveHeight = _view.frame.size.height;
        float offsetX = 0;
        float offsetY = 0;
        CGPoint point = pointC.center;
        CGPoint point3;
        point3 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
        currentTool.x3 = @(point3.x);
        currentTool.y3 = @(point3.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            [pointD setCenter:CGPointMake(originP1.x-translation.x, originP1.y+translation.y)];
            CGPoint point = pointD.center;
            CGPoint point2;
            point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x4 = @(point2.x);
            currentTool.y4 = @(point2.y);
        }
        [currentTool updateWithContentSize:_view.frame.size];
    }
}

- (void)panPointD:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointD.center;
        originP1 = pointC.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.view];
        [pointD setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        float aveWidth = _view.frame.size.width;
        float aveHeight = _view.frame.size.height;
        float offsetX = 0;
        float offsetY = 0;
        CGPoint point = pointD.center;
        CGPoint point4;
        point4 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point4 = CGPointMake(point4.x / aveWidth, point4.y / aveHeight);
        currentTool.x4 = @(point4.x);
        currentTool.y4 = @(point4.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            [pointC setCenter:CGPointMake(originP1.x-translation.x, originP1.y+translation.y)];
            CGPoint point = pointC.center;
            CGPoint point2;
            point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x3 = @(point2.x);
            currentTool.y3 = @(point2.y);
        }
        [currentTool updateWithContentSize:_view.frame.size];
    }
}
@end
