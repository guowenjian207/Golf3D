//
//  scoreCanvasView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/16.
//

#import "scoreCanvasView.h"
#import "SpecificationTool.h"
@interface scoreCanvasView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation scoreCanvasView {
    CAShapeLayer *currentLayer;
    UIBezierPath *currentPath;
    CAShapeLayer *tmpLayer;
    UIBezierPath *tmpPath;
    scoreTool *currentTool;
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

- (void)dealloc {
    [_scrollView removeGestureRecognizer:tapGestureRecognizer];
}

- (UIColor *)getColorWithFrameIdx:(int)frameIdx andName:(NSString *)name {
    if (frameIdx == 0) {
        if ([name isEqual:@"Head Height"]) {
            return [UIColor colorWithRed:0.710 green:0.043 blue:0.663 alpha:1];
        }
        else if ([name isEqual:@"Head Position"]) {
            return [UIColor colorWithRed:0.776 green:0.851 blue:0.945 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line To Armpit"]) {
            return [UIColor colorWithRed:0.584 green:0.216 blue:0.208 alpha:1];
        }
        else if ([name isEqual:@"Elbow-Hosel Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.314 alpha:1];
        }
        else if ([name isEqual:@"Hip Depth"]) {
            return [UIColor colorWithRed:0.769 green:0.741 blue:0.592 alpha:1];
        }
        else if ([name isEqual:@"Spine Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Lower Body Position"]) {
            return [UIColor yellowColor];
        }
    }
    else if (frameIdx == 2) {
        if ([name isEqual:@"Hands Position"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Club Face Angle"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Leadarm Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 3) {
        if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
    }
    else if (frameIdx == 4) {
        if ([name isEqual:@"Hands Position"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Shoulder Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        if ([name isEqual:@"Grip End Height"]) {
            return [UIColor colorWithRed:0.576 green:0.804 blue:0.867 alpha:1];
        }
    }
    else if (frameIdx == 5) {
        if ([name isEqual:@"Head Height"]) {
            return [UIColor colorWithRed:0.980 green:0.753 blue:0.565 alpha:1];
        }
        else if ([name isEqual:@"Knees Gaps"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Spine Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 6) {
        if ([name isEqual:@"Head Height"]) {
            return [UIColor colorWithRed:0.576 green:0.804 blue:0.867 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Elbow Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Knees Gaps"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Feet Gaps"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Lead Forearm Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 7) {
        if ([name isEqual:@"Hands Position"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Club Face Angle"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Elbow Angle"]) {
            return [UIColor colorWithRed:0.851 green:0.588 blue:0.580 alpha:1];
        }
        else if ([name isEqual:@"Lead Forearm Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
    }
    else if (frameIdx == 8) {
        if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Lead Forearm Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 9) {
        if ([name isEqual:@"Knees Gaps"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Elbow Angle"]) {
            return [UIColor colorWithRed:0.851 green:0.588 blue:0.580 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Lead Forearm Line"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Shoulder Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 10) {
        if ([name isEqual:@"Knees Gaps"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Shoulder Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
        else if ([name isEqual:@"Spine Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 11) {
        if ([name isEqual:@"Hands Position"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"Elbow Angle"]) {
            return [UIColor colorWithRed:0.851 green:0.588 blue:0.580 alpha:1];
        }
    }
    else if (frameIdx == 12) {
        if ([name isEqual:@"Shoulder Tilt"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
    }
    else if (frameIdx == 13) {
        if ([name isEqual:@"Shaft Line"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
    }
    else if (frameIdx == 14) {
        if ([name isEqual:@"up"]) {
            return [UIColor colorWithRed:0 green:0.690 blue:0.941 alpha:1];
        }
        else if ([name isEqual:@"down"]) {
            return [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1];
        }
//        return [UIColor colorWithRed:0 green:0.424 blue:0.039 alpha:1];
    }

    return nil;
}
- (void)drawCanvasWithTool:(SpecificationTool *)tool andIndex:(int) index{
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    int frameIdx = index;
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    
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
    if(index == 5 || index == 10){
        tool.lastLayer = currentLayer;
    }else{
        tool.toolLayer = currentLayer;
    }
    tool.toolPath = currentPath;
    
}

- (void)drawCanvasWithTool:(scoreTool *)tool andvideoH:(float) h andvideoW:(float)w{
    currentLayer = [[CAShapeLayer alloc]init];
    [currentLayer setFrame:self.superview.bounds];
    currentLayer.lineWidth = 3;
    currentPath = [UIBezierPath bezierPath];
    currentLayer.fillColor = [UIColor clearColor].CGColor;
    int frameIdx = [tool.frame intValue];
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    
    if(h==0&&w==0){
        w=1280;
        h=720;
    }
    float newheight=aveWidth*(h/w);
    float newoffsetY=(aveHeight-newheight)/2;
    if (tool.isSubItem) {
        currentLayer.strokeColor = tool.adjustColor.CGColor;
    }
    else if (tool.isTemplate) {
        currentLayer.strokeColor = [UIColor whiteColor].CGColor;
        [currentLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:1], nil]];
    }
    else if (tool.isForDisplay) {
        currentLayer.strokeColor = [self getColorWithFrameIdx:[tool.fatherFrame intValue] andName:tool.name].CGColor;
    }
//    else if ([tool.name isEqual:@"up"]) {
//        currentLayer.strokeColor= [UIColor colorWithRed:0.5 green:0.690 blue:0.941 alpha:1].CGColor;
//    }else if ([tool.name isEqual:@"down"]) {
//        currentLayer.strokeColor= [UIColor colorWithRed:0.894 green:0.424 blue:0.039 alpha:1].CGColor;
//    }
    else {
        currentLayer.strokeColor = [self getColorWithFrameIdx:frameIdx andName:tool.name].CGColor;
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
    }
    else if ([tool.type isEqualToString:@"Quadrilateral"]) {
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
        [currentPath addLineToPoint:point4];
        [currentPath addLineToPoint:point3];
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
        [currentPath moveToPoint:point2];
        CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
        [currentPath addLineToPoint:point4];
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
        [currentPath moveToPoint:point2];
        [currentPath addLineToPoint:CGPointMake(point2.x, point1.y)];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"RotateRect"]) {
        point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
        CGPoint point4 = CGPointMake(point3.x + offset.x, point3.y + offset.y);
        [currentPath moveToPoint:point1];
        [currentPath addLineToPoint:point2];
        [currentPath addLineToPoint:point3];
        [currentPath addLineToPoint:point4];
        [currentPath closePath];
        currentLayer.path = currentPath.CGPath;
    }
    else if ([tool.type isEqualToString:@"Curve"]&&tool.pointArray!=nil){
        point1 = CGPointFromString(tool.pointArray[0]);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * newheight + offsetY+newoffsetY);
        [currentPath moveToPoint:point1];
        for (int i = 1; i < tool.pointArray.count; i++) {
            point2 = CGPointFromString(tool.pointArray[i]);
            if(i+1<tool.pointArray.count)
            {
                point1 = CGPointFromString(tool.pointArray[i+1]);
                if((fabs(point1.y-point2.y)<0.01&&fabs(point1.x-point2.x)>0.1)||(fabs(point1.x-point2.x)<0.01&&fabs(point1.y-point2.y)>0.1)){
                    point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * newheight + offsetY+newoffsetY);
                    point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                    [currentPath addLineToPoint:point2];
                    [currentPath moveToPoint:point1];
                }else{
                    point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                    [currentPath addLineToPoint:point2];
                }
            }
        else{
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * newheight + offsetY+newoffsetY);
                [currentPath addLineToPoint:point2];
            }
        }
        currentLayer.path = currentPath.CGPath;
    }
    if(![tool.type isEqualToString:@"Curve"]){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(point1.x, point1.y - 40, 80, 40)];
        [self.scrollView addSubview:label];
        tool.label = label;
        tool.label.text = tool.name;
        tool.label.textColor = [UIColor whiteColor];
        [tool.label setFont:[UIFont systemFontOfSize:15.0]];
        tool.label.numberOfLines = 2;
        [tool.label setHidden:YES];
    }

    NSNumber *frameNumber;
    if (tool.isForDisplay) {
        frameNumber = tool.fatherFrame;
    }
    else {
        frameNumber = tool.frame;
    }
    if ([frameNumber intValue] == 0 && ([tool.name isEqual:@"Shaft Line To Armpit"] || [tool.name isEqual:@"Elbow-Hosel Line"])) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        if (tool.isForDisplay) {
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:[tool.fatherFrame intValue] andName:tool.name];
        }
        else {
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        }
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 2 && ([tool.name isEqual:@"Club Face Angle"])) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point3.x + 5, point3.y - 10, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point3 andP3:CGPointMake(point3.x + 10, point3.y)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 3 && ([tool.name isEqual:@"Shaft Line"])) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x + 10, point1.y - 10, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 4 && ([tool.name isEqual:@"Shoulder Tilt"] || [tool.name isEqual:@"Shaft Line"])) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 6 && ([tool.name isEqual:@"Shaft Line"] || [tool.name isEqual:@"Elbow Line"])) {
        if ([tool.name isEqual:@"Shaft Line"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y, 60, 30)];
        }
        else {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x - 40, point2.y, 60, 30)];
        }
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        if ([tool.name isEqual:@"Shaft Line"]) {
            tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
        }
        else {
            tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x - 10, point2.y)];
        }
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 7) {
        if ([tool.name isEqual:@"Club Face Angle"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point3.x + 5, point3.y - 10, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentLeft;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point3 andP3:CGPointMake(point3.x + 10, point3.y)];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
        }
        else if ([tool.name isEqual:@"Shaft Line"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentLeft;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
        }
        else if ([tool.name isEqual:@"Elbow Angle"]) {
            CGFloat distance = self.scrollView.contentSize.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel2.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel2];
            tool.angleLabel2 = angleLabel2;
            tool.angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            tool.angleLabel2.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel2 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel2 setCenter:p3];
        }
    }
    else if ([frameNumber intValue] == 8) {
        if ([tool.name isEqual:@"Shaft Line"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentLeft;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
        }
    }
    else if ([frameNumber intValue] == 9) {
        if ([tool.name isEqual:@"Elbow Angle"]) {
            CGFloat distance = self.scrollView.contentSize.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel2.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel2];
            tool.angleLabel2 = angleLabel2;
            tool.angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            tool.angleLabel2.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel2 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel2 setCenter:p3];
        }
        else if ([tool.name isEqual:@"Shaft Line"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentLeft;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x, point1.y + 10)];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
        }
        else if ([tool.name isEqual:@"Shoulder Tilt"]) {
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentLeft;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
        }
    }
    else if ([frameNumber intValue] == 10 && [tool.name isEqual:@"Shaft Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x + 10, point1.y - 10, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 11) {
        if ([tool.name isEqual:@"Elbow Angle"]) {
            CGFloat distance = self.scrollView.contentSize.width / 9.75;
            distance = distance > 30 ? 30 : distance;
            CGPoint p1 = [self getPointWithPoint1:point2 andPoint2:point1 andDistance:distance];
            CGPoint p2 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            CGPoint p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel1.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel1];
            tool.angleLabel1 = angleLabel1;
            tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:point3];
            tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel1 setCenter:p3];
            
            CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
            p1 = [self getPointWithPoint1:point2 andPoint2:point3 andDistance:distance];
            p2 = [self getPointWithPoint1:point2 andPoint2:point4 andDistance:distance];
            p3 = [self getPointWithPoint1:point2 andPoint2:CGPointMake(p1.x + p2.x - point2.x, p1.y + p2.y - point2.y) andDistance:distance];
            angleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            angleLabel2.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:angleLabel2];
            tool.angleLabel2 = angleLabel2;
            tool.angleLabel2.text = [self computeAngleWithP1:point3 andP2:point2 andP3:point4];
            tool.angleLabel2.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
            [tool.angleLabel2 setFont:[UIFont systemFontOfSize:15.0]];
            [angleLabel2 setCenter:p3];
        }
    }
    else if ([frameNumber intValue] == 12 && ([tool.name isEqual:@"Shoulder Tilt"])) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    else if ([frameNumber intValue] == 13 && [tool.name isEqual:@"Shaft Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point1.x + 10, point1.y - 10, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point2 andP2:point1 andP3:CGPointMake(point1.x + 10, point1.y)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    
    if ([tool.name isEqual:@"Spine Tilt"] || [tool.name isEqual:@"Leadarm Line"]) {
        angleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(point2.x, point2.y - 30, 60, 30)];
        angleLabel1.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:angleLabel1];
        tool.angleLabel1 = angleLabel1;
        tool.angleLabel1.text = [self computeAngleWithP1:point1 andP2:point2 andP3:CGPointMake(point2.x, point2.y - 10)];
        tool.angleLabel1.textColor = [self getColorWithFrameIdx:frameIdx andName:tool.name];
        [tool.angleLabel1 setFont:[UIFont systemFontOfSize:15.0]];
    }
    
    tool.toolLayer = currentLayer;
    tool.toolPath = currentPath;
    
    // 李总又不要闪动效果了，这段先注释掉
//    if (!tool.hasAdjust) {
//        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        alphaAnimation.duration = 0.5;
//        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
//        alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        // 倒转动画
//        alphaAnimation.autoreverses = YES;
//        // 设置重复次数为无限大
//        alphaAnimation.repeatCount = FLT_MAX;
//        // 添加动画到layer
//        [currentLayer addAnimation:alphaAnimation forKey:@"opacity"];
//    }
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
    [self.scrollView.panGestureRecognizer setEnabled:YES];
    [self.scrollView.pinchGestureRecognizer setEnabled:YES];
}

- (void)selectTool:(UITapGestureRecognizer *)recognizer {
    CGPoint x0 = [recognizer locationInView:self.scrollView];
    scoreTool *nearestTool = nil;
    nearestTool = [self.delegate chooseNearestScoreToolWithX:x0];
    [self deselectCurrentTool];
    currentTool = nearestTool;
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
        int frameIdx = [currentTool.frame intValue];
        float gap = self.scrollView.zoomScale * 10;
        float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
        float aveHeight = self.scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
        float offsetY = frameIdx / 5 * aveHeight;
        if ([currentTool.type isEqual:@"RotateRect"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            centerP = CGPointMake((point1.x + point3.x) / 2, (point1.y + point3.y) / 2);
            CGPoint point = CGPointMake((point3.x + point2.x) / 2, (point3.y + point2.y) / 2);
            tmpDis = sqrt((centerP.x - point.x) * (centerP.x - point.x) + (centerP.y - point.y) * (centerP.y - point.y));
            CGPoint imgCenter = [self getPointWithPoint1:centerP andPoint2:point andDistance:2 * tmpDis];
            rotateImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tmpDis, tmpDis)];
            rotateImgView.image = [UIImage imageNamed:@"rotate"];
            [rotateImgView setCenter:imgCenter];
            UIPanGestureRecognizer *panRotateView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRotateView:)];
            [self.scrollView addSubview:rotateImgView];
            rotateImgView.userInteractionEnabled = YES;
            [rotateImgView addGestureRecognizer:panRotateView];
        }
        else if ([currentTool.frame intValue] == 0 && ([currentTool.name isEqual:@"Shaft Line To Armpit"] || [currentTool.name isEqual:@"Elbow-Hosel Line"])) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            centerP = CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
            tmpDis = 10 * self.scrollView.zoomScale;
            CGFloat k = (point1.x - point2.x) / (point2.y - point1.y);
            CGFloat bias = centerP.y - k * centerP.x;
            CGPoint imgCenter = [self getPointWithPoint1:centerP andPoint2:CGPointMake(0, bias) andDistance:tmpDis];
            rotateImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tmpDis, tmpDis)];
            rotateImgView.image = [UIImage imageNamed:@"rotate"];
            [rotateImgView setCenter:imgCenter];
            UIPanGestureRecognizer *panRotateView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRotateView:)];
            [self.scrollView addSubview:rotateImgView];
            rotateImgView.userInteractionEnabled = YES;
            [rotateImgView addGestureRecognizer:panRotateView];
        }
        else if ([currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.scrollView addSubview:pointB];

            [pointA setCenter:point1];
            [pointB setCenter:point2];
        }
        else if ([currentTool.type isEqual:@"Angle"]) {
            point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
            point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
            point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
            point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
            point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
            point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
            pointA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointA.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.scrollView addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointC.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panC = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointC:)];
            [pointC addGestureRecognizer:panC];
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
            [pointA.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointA.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panA = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointA:)];
            [pointA addGestureRecognizer:panA];
            [self.scrollView addSubview:pointA];
            
            pointB = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointB.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointB.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panB = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointB:)];
            [pointB addGestureRecognizer:panB];
            [self.scrollView addSubview:pointB];
            
            pointC = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointC.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointC.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panC = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointC:)];
            [pointC addGestureRecognizer:panC];
            [self.scrollView addSubview:pointC];
            
            pointD = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            [pointD.layer setBackgroundColor:currentTool.toolLayer.strokeColor];
            [pointD.layer setCornerRadius:7.5];
            UIPanGestureRecognizer *panD = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPointD:)];
            [pointD addGestureRecognizer:panD];
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
        
        if (currentTool.isTemplate) {
            [pointA removeFromSuperview];
            pointA = nil;
            [pointB removeFromSuperview];
            pointB = nil;
            [pointC removeFromSuperview];
            pointC = nil;
            [pointD removeFromSuperview];
            pointD = nil;
        }
        
        if (currentTool.isSubItem) {
            doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
            doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
            [doubleTapGestureRecognizer addTarget:self action:@selector(doubleTapped:)];
            [self.superview addGestureRecognizer:doubleTapGestureRecognizer];
        }
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer {
    int frameIdx = [currentTool.frame intValue];
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    CGPoint point1, point2, point3, point4;
    if ([currentTool.type isEqual:@"Line"]) {
        point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point1 = CGPointMake(point1.x / self.scrollView.contentSize.width, point1.y / self.scrollView.contentSize.height);
        point2 = CGPointMake(point2.x / self.scrollView.contentSize.width, point2.y / self.scrollView.contentSize.height);
        if ([self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point2] <= 20) {
            if ([currentTool.adjustColor isEqual:[UIColor yellowColor]]) {
                currentTool.adjustColor = [UIColor greenColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
            else if ([currentTool.adjustColor isEqual:[UIColor greenColor]]) {
                currentTool.adjustColor = [UIColor redColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
            else if ([currentTool.adjustColor isEqual:[UIColor redColor]]) {
                currentTool.adjustColor = [UIColor yellowColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
        }
        else {
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
        CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point3];
        CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point4];
        CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point3 andP2:point4];
        if ((dis1 <= 20 || dis2 <= 20 || dis3 <= 20 || dis4 <= 20)) {
            if ([currentTool.adjustColor isEqual:[UIColor yellowColor]]) {
                currentTool.adjustColor = [UIColor greenColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
            else if ([currentTool.adjustColor isEqual:[UIColor greenColor]]) {
                currentTool.adjustColor = [UIColor redColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
            else if ([currentTool.adjustColor isEqual:[UIColor redColor]]) {
                currentTool.adjustColor = [UIColor yellowColor];
                currentTool.toolLayer.strokeColor = currentTool.adjustColor.CGColor;
            }
            [pointA.layer setBackgroundColor:currentTool.adjustColor.CGColor];
            [pointB.layer setBackgroundColor:currentTool.adjustColor.CGColor];
            [pointC.layer setBackgroundColor:currentTool.adjustColor.CGColor];
            [pointD.layer setBackgroundColor:currentTool.adjustColor.CGColor];
        }
        else {
            return;
        }
    }
}

- (void)panPointA:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointA.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.scrollView];
        [pointA setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        int frameIdx = [currentTool.frame intValue];
        float gap = self.scrollView.zoomScale * 10;
        float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
        float aveHeight = self.scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
        float offsetY = frameIdx / 5 * aveHeight;
        CGPoint point = pointA.center;
        CGPoint point1;
        point1 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
        currentTool.x1 = @(point1.x);
        currentTool.y1 = @(point1.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            currentTool.y2 = @(point1.y);
            [pointB setCenter:CGPointMake(pointB.center.x, pointA.center.y)];
        }
        [currentTool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)panPointB:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointB.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.scrollView];
        [pointB setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        int frameIdx = [currentTool.frame intValue];
        float gap = self.scrollView.zoomScale * 10;
        float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
        float aveHeight = self.scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
        float offsetY = frameIdx / 5 * aveHeight;
        CGPoint point = pointB.center;
        CGPoint point2;
        point2 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
        currentTool.x2 = @(point2.x);
        currentTool.y2 = @(point2.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            currentTool.y1 = @(point2.y);
            [pointA setCenter:CGPointMake(pointA.center.x, pointB.center.y)];
        }
        [currentTool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)panPointC:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointC.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.scrollView];
        [pointC setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        int frameIdx = [currentTool.frame intValue];
        float gap = self.scrollView.zoomScale * 10;
        float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
        float aveHeight = self.scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
        float offsetY = frameIdx / 5 * aveHeight;
        CGPoint point = pointC.center;
        CGPoint point3;
        point3 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
        currentTool.x3 = @(point3.x);
        currentTool.y3 = @(point3.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            currentTool.y4 = @(point3.y);
            [pointD setCenter:CGPointMake(pointD.center.x, pointC.center.y)];
        }
        [currentTool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)panPointD:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        origin = pointD.center;
    }
    else {
        CGPoint translation = [recognizer translationInView:self.scrollView];
        [pointD setCenter:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
        int frameIdx = [currentTool.frame intValue];
        float gap = self.scrollView.zoomScale * 10;
        float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
        float aveHeight = self.scrollView.contentSize.height / 3;
        float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
        float offsetY = frameIdx / 5 * aveHeight;
        CGPoint point = pointD.center;
        CGPoint point4;
        point4 = CGPointMake(point.x - offsetX, point.y - offsetY);
        point4 = CGPointMake(point4.x / aveWidth, point4.y / aveHeight);
        currentTool.x4 = @(point4.x);
        currentTool.y4 = @(point4.y);
        if ([currentTool.type isEqual:@"Quadrilateral"]) {
            currentTool.y3 = @(point4.y);
            [pointC setCenter:CGPointMake(pointC.center.x, pointD.center.y)];
        }
        [currentTool updateWithContentSize:self.scrollView.contentSize];
    }
}

- (void)panRotateView:(UIPanGestureRecognizer *)recognizer {
    CGPoint point1, point2, point3;
    int frameIdx = [currentTool.frame intValue];
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
    if ([currentTool.type isEqual:@"RotateRect"]) {
        point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        point3 = CGPointMake(currentTool.x3.floatValue, currentTool.y3.floatValue);
        point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            centerP = CGPointMake((point1.x + point3.x) / 2, (point1.y + point3.y) / 2);
            origin = [recognizer locationInView:self.scrollView];
            originCenter = rotateImgView.center;
            originDis = sqrt((centerP.x - originCenter.x) * (centerP.x - originCenter.x) + (centerP.y - originCenter.y) * (centerP.y - originCenter.y));
            originP2 = point2;
            originP3 = point3;
        }
        else {
            CGPoint offset = [recognizer translationInView:self.scrollView];
            CGPoint tmpP = CGPointMake(offset.x + origin.x, offset.y + origin.y);
            CGPoint newCenter = [self getPointWithPoint1:centerP andPoint2:tmpP andDistance:originDis];
            [rotateImgView setCenter:newCenter];
            
            CGPoint point = [self getPointWithPoint1:centerP andPoint2:newCenter andDistance:tmpDis]; // point2和point3的中点
            CGFloat k;
            if (fabs(centerP.y - newCenter.y) < 0.1) {
                k = -10000;
            }
            else {
                k = -(centerP.x - newCenter.x) / (centerP.y - newCenter.y);
            }
            CGFloat tmpDisP2andP3 = sqrt((point2.x - point3.x) * (point2.x - point3.x) + (point2.y - point3.y) * (point2.y - point3.y));
            CGPoint newPoint2 = [self getPointWithPoint:point andK:k andDis:tmpDisP2andP3/2 andOriginP:originP2 andNewCenter:newCenter];
            CGPoint newPoint3 = [self getPointWithPoint:point andK:k andDis:tmpDisP2andP3/2 andOriginP:originP3 andNewCenter:newCenter];
            CGPoint offsetTmp = CGPointMake(centerP.x - point.x, centerP.y - point.y);
            offsetTmp = CGPointMake(2 * offsetTmp.x, 2 * offsetTmp.y);
            CGPoint newPoint1 = CGPointMake(newPoint2.x + offsetTmp.x, newPoint2.y + offsetTmp.y);
            
            point1 = CGPointMake(newPoint1.x - offsetX, newPoint1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(newPoint2.x - offsetX, newPoint2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            point3 = CGPointMake(newPoint3.x - offsetX, newPoint3.y - offsetY);
            point3 = CGPointMake(point3.x / aveWidth, point3.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);
            currentTool.x3 = @(point3.x);
            currentTool.y3 = @(point3.y);
            
            [currentTool updateWithContentSize:self.scrollView.contentSize];
        }
    }
    else {
        point1 = CGPointMake(currentTool.x1.floatValue, currentTool.y1.floatValue);
        point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
        point2 = CGPointMake(currentTool.x2.floatValue, currentTool.y2.floatValue);
        point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            centerP = CGPointMake((point1.x + point2.x) / 2, (point1.y + point2.y) / 2);
            origin = [recognizer locationInView:self.scrollView];
            originCenter = rotateImgView.center;
            originDis = sqrt((centerP.x - originCenter.x) * (centerP.x - originCenter.x) + (centerP.y - originCenter.y) * (centerP.y - originCenter.y));
            originP1 = point1;
            originP2 = point2;
        }
        else {
            CGPoint offset = [recognizer translationInView:self.scrollView];
            CGPoint tmpP = CGPointMake(offset.x + origin.x, offset.y + origin.y);
            CGPoint newCenter = [self getPointWithPoint1:centerP andPoint2:tmpP andDistance:originDis];
            [rotateImgView setCenter:newCenter];
            
            CGPoint point = centerP;
            CGFloat k;
            if (fabs(centerP.y - newCenter.y) < 0.1) {
                k = -10000;
            }
            else {
                k = -(centerP.x - newCenter.x) / (centerP.y - newCenter.y);
            }
            CGFloat tmpDisP1andP2 = sqrt((point2.x - point1.x) * (point2.x - point1.x) + (point2.y - point1.y) * (point2.y - point1.y));
            CGPoint newPoint1 = [self getPointWithPoint:point andK:k andDis:tmpDisP1andP2/2 andOriginP:originP1 andNewCenter:newCenter];
            CGPoint newPoint2 = [self getPointWithPoint:point andK:k andDis:tmpDisP1andP2/2 andOriginP:originP2 andNewCenter:newCenter];

            point1 = CGPointMake(newPoint1.x - offsetX, newPoint1.y - offsetY);
            point1 = CGPointMake(point1.x / aveWidth, point1.y / aveHeight);
            point2 = CGPointMake(newPoint2.x - offsetX, newPoint2.y - offsetY);
            point2 = CGPointMake(point2.x / aveWidth, point2.y / aveHeight);
            currentTool.x1 = @(point1.x);
            currentTool.y1 = @(point1.y);
            currentTool.x2 = @(point2.x);
            currentTool.y2 = @(point2.y);

            [currentTool updateWithContentSize:self.scrollView.contentSize];
        }
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

- (void)panTool:(UIPanGestureRecognizer *)recognizer {
    if (currentTool.isForDisplay) {
        return;
    }
    int frameIdx = [currentTool.frame intValue];
    float gap = self.scrollView.zoomScale * 10;
    float aveWidth = (self.scrollView.contentSize.width - gap) / 5;
    float aveHeight = self.scrollView.contentSize.height / 3;
    float offsetX = frameIdx % 5 * aveWidth + (frameIdx % 5 > 0) * gap;
    float offsetY = frameIdx / 5 * aveHeight;
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
            CGFloat dis2 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point1 andP2:point3];
            CGFloat dis3 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point2 andP2:point4];
            CGFloat dis4 = [self computeDisWith:[recognizer locationInView:self.scrollView] andP1:point3 andP2:point4];
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
    }
    else {
        if (!canPan) {
            return;
        }
        CGPoint offset = [recognizer translationInView:self.scrollView];
        if ([currentTool.type isEqual:@"Line"] || [currentTool.type isEqual:@"Rect"] || [currentTool.type isEqual:@"LineWithNode"] || [currentTool.type isEqual:@"ExternLineWithNode"] || [currentTool.type isEqual:@"SingleExternLineWithNode"]) {
            if (!currentTool.LRMovable) {
                offset.x = 0;
            }
            if (!currentTool.UDMovable) {
                offset.y = 0;
            }
            CGPoint point1 = CGPointFromString(originPoint[0]);
            CGPoint point2 = CGPointFromString(originPoint[1]);
            CGPoint realOffset = [self limitPoint1:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                         andPoint2:CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height)
                                         andOffset:offset
                                        inFrameIdx:[currentTool.frame intValue]];
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
            
            if ([currentTool.name isEqual:@"Head Height"] && [currentTool.frame isEqual:@0]) {
                scoreTool *headPositionTool = [self.delegate getHeadPositionTool];
                CGFloat offset = point1.y - [headPositionTool.y1 floatValue];
                headPositionTool.y1 = @([headPositionTool.y1 floatValue] + offset);
                headPositionTool.y2 = @([headPositionTool.y2 floatValue] + offset);
                [headPositionTool updateWithContentSize:self.scrollView.contentSize];
            }
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
                realOffset = [self limitRulerWithPoint1:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                             andPoint2:CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height)
                                             andOffset:offset
                                            inFrameIdx:[currentTool.frame intValue]];
                point1 = CGPointMake(point1.x * self.scrollView.contentSize.width + realOffset.x, point1.y * self.scrollView.contentSize.height + realOffset.y);
                point2 = CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height + realOffset.y);
            }
            else {
                realOffset = [self limitRulerWithPoint1:CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height)
                                             andPoint2:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                             andOffset:offset
                                            inFrameIdx:[currentTool.frame intValue]];
                point1 = CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height + realOffset.y);
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
            CGPoint realOffset = [self limitPoint1:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                         andPoint2:CGPointMake(point3.x * self.scrollView.contentSize.width, point3.y * self.scrollView.contentSize.height)
                                         andOffset:offset
                                        inFrameIdx:[currentTool.frame intValue]];
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
            CGPoint realOffset = [self limitPoint1:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                         andPoint2:CGPointMake(point3.x * self.scrollView.contentSize.width, point3.y * self.scrollView.contentSize.height)
                                         andOffset:offset
                                        inFrameIdx:[currentTool.frame intValue]];
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
            CGPoint realOffset = [self limitPoint1:CGPointMake(point1.x * self.scrollView.contentSize.width, point1.y * self.scrollView.contentSize.height)
                                         andPoint2:CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height)
                                         andOffset:offset
                                        inFrameIdx:[currentTool.frame intValue]];
            realOffset = [self limitPoint1:CGPointMake(point2.x * self.scrollView.contentSize.width, point2.y * self.scrollView.contentSize.height)
                                         andPoint2:CGPointMake(point3.x * self.scrollView.contentSize.width, point3.y * self.scrollView.contentSize.height)
                                         andOffset:realOffset
                                        inFrameIdx:[currentTool.frame intValue]];
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
        [currentTool updateWithContentSize:self.scrollView.contentSize];
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

@end
