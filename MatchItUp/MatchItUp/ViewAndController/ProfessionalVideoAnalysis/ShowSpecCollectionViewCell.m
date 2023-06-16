//
//  ShowSpecCollectionViewCell.m
//  MatchItUp
//
//  Created by GWJ on 2023/4/13.
//

#import "ShowSpecCollectionViewCell.h"
#import "ShowSpecSmallCollectionViewCell.h"

@implementation ShowSpecCollectionViewCell{
    UICollectionView *specSmallCollectionView;
    UIImageView *bigView;
    NSMutableArray *bigViewCurrentTools;
    UIView *bigView2;
    UIView *bigView1;
    
    NSNumber *currentIndex;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat W = frame.size.height/35*24;
        CGFloat H = W/4*5;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat itemW = W/6;
        CGFloat itemH = itemW/4*5;
        layout.itemSize = CGSizeMake(itemW,itemH);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        specSmallCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake((frame.size.width-W)/2, 0, W, itemH) collectionViewLayout:layout];
        [self addSubview:specSmallCollectionView];
        specSmallCollectionView.backgroundColor = [UIColor blackColor];
        [specSmallCollectionView registerClass:[ShowSpecSmallCollectionViewCell class] forCellWithReuseIdentifier:@"small"];
        specSmallCollectionView.delegate = self;
        specSmallCollectionView.dataSource = self;
        
        
        
        bigView = [[UIImageView alloc]initWithFrame:CGRectMake((frame.size.width-W)/2, itemH, W, H)];
        bigView.backgroundColor = [UIColor redColor];
        [self addSubview:bigView];
        
        bigView1 = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-W)/2, itemH, W, H)];
        bigView1.backgroundColor = [UIColor clearColor];
//        bigView2.clipsToBounds = NO;
        [self addSubview:bigView1];
        
        bigView2 = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-W)/2, itemH, W, H)];
        bigView2.backgroundColor = [UIColor clearColor];
//        bigView2.clipsToBounds = NO;
        [self addSubview:bigView2];
        
    }
    return self;
}

#pragma mark collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _specTools.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_speCanvas == nil){
        _speCanvas = [[specificationCanvasView alloc]init];
        [_speCanvas initializeWithColelctionView:specSmallCollectionView andSuperView:specSmallCollectionView];
        for (NSMutableArray *array in _specTools) {
            for (SpecificationTool *tool in array) {
                [_speCanvas drawCanvasSmallWithTool:tool];
            }
        }
    }
    if(_bigViewCanvas == nil){
        bigViewCurrentTools = _specTools[0];
        _bigViewCanvas = [[specificationCanvasView alloc]init];
        [_bigViewCanvas initializeChangeWithUIView:bigView2 andSuperView:bigView2];
        _bigViewCanvas.delegate = self;
        for (SpecificationTool *tool in bigViewCurrentTools) {
            [_bigViewCanvas drawCanvasWithToolInGlk:tool];
        }
        currentIndex = [NSNumber numberWithInteger:0];
    }
    ShowSpecSmallCollectionViewCell *cell = [specSmallCollectionView dequeueReusableCellWithReuseIdentifier:@"small" forIndexPath:indexPath];
    cell.imageView.image = nil;
    [cell.layer setBorderWidth:0.0];
    if(((NSMutableArray*)_specTools[indexPath.row]).count>0 || indexPath.row == 0){
        if(((NSMutableArray*)_specTools[indexPath.row]).count>0){
            SpecificationTool *tool = _specTools[indexPath.row][0];
            NSData *imageData = _frameIndexArray[[tool.corresFrame intValue]];
            cell.imageView.image = [UIImage imageWithData:imageData];
            
            [cell.layer setBorderWidth:0.0];
            [cell.layer setBorderColor:[UIColor redColor].CGColor];
        }
    
        if((int)indexPath.row == 0){
            [cell setSelected:YES];
            NSData *imageData = _frameIndexArray[0];
            cell.imageView.image = [UIImage imageWithData:imageData];
            bigView.image = [UIImage imageWithData:imageData];
            [cell.layer setBorderWidth:2.0];
            [cell.layer setBorderColor:[UIColor redColor].CGColor];
        }
    }
    
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ShowSpecSmallCollectionViewCell *cell = (ShowSpecSmallCollectionViewCell*)[specSmallCollectionView  cellForItemAtIndexPath:indexPath];
    for(ShowSpecSmallCollectionViewCell *indexcell in specSmallCollectionView.visibleCells){
        [indexcell.layer setBorderWidth:0.0];
        if(indexPath.row == [specSmallCollectionView indexPathForCell:indexcell].row){
            [indexcell.layer setBorderWidth:2.0];
        }
    }
    if(((NSArray*)_specTools[indexPath.row]).count>0){
        
        
//        [cell.layer setBorderWidth:2.0];
        
        SpecificationTool *tool = _specTools[indexPath.row][0];
        NSData *imageData = _frameIndexArray[[tool.corresFrame intValue]];
        bigView.image = [UIImage imageWithData:imageData];
        
        [self removeBigeViewCurrentTools];
        bigViewCurrentTools = _specTools[indexPath.row];
        [self displayToolsWith:bigViewCurrentTools];
        
        currentIndex = [NSNumber numberWithInteger:indexPath.row];
    }
    if((int)indexPath.row == 0){
//        [cell.layer setBorderWidth:2.0];
        NSData *imageData = _frameIndexArray[0];
        bigView.image = [UIImage imageWithData:imageData];
        
        [self removeBigeViewCurrentTools];
        bigViewCurrentTools = _specTools[indexPath.row];
        [self displayToolsWith:bigViewCurrentTools];
        
        currentIndex = [NSNumber numberWithInteger:indexPath.row];
    }
}
#pragma mark -specificationCanvasDelegate

-(SpecificationTool *)chooseNearestSpecificationToolWithXInGlk:(CGPoint)x0{
    SpecificationTool *nearestTool = nil;
    CGFloat minDis = CGFLOAT_MAX;
    NSMutableArray *tmpScoreTools;
    tmpScoreTools = bigViewCurrentTools;
    for(SpecificationTool *tool in bigViewCurrentTools){

        CGPoint point1, point2, point3, point4;
        if ([tool.type isEqual:@"Line"] || [tool.type isEqual:@"LineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            CGFloat dis = [self computeDisInGlkWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"ExternLineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
            offset = CGPointMake(offset.x / 3, offset.y / 3);
            point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
            point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
            
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            CGFloat dis = [self computeDisInGlkWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"SingleExternLineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);

//            point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
            point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
            
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            CGFloat dis = [self computeDisInGlkWith:x0 andP1:point1 andP2:point2];
            if (dis < minDis && dis <= 20) {
                nearestTool = tool;
                minDis = dis;
            }
        }
        else if ([tool.type isEqual:@"broken Line"] || [tool.type isEqual:@"Angle"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            
            point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
           
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            point3 = CGPointMake(point3.x *  bigView.frame.size.width, point3.y * bigView.frame.size.height);
            CGFloat dis1 = [self computeDisInGlkWith:x0 andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisInGlkWith:x0 andP1:point2 andP2:point3];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
        }else if ([tool.type isEqual:@"Quadrilateral"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            
            point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
            
            point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
           
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            point3 = CGPointMake(point3.x *  bigView.frame.size.width, point3.y * bigView.frame.size.height);
            point4 = CGPointMake(point4.x *  bigView.frame.size.width, point4.y * bigView.frame.size.height);
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point2];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point3];
            CGFloat dis3 = [self computeDisWith:x0 andP1:point3 andP2:point4];
            CGFloat dis4 = [self computeDisWith:x0 andP1:point1 andP2:point4];
        
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
            if (dis3 < minDis && dis3 <= 20) {
                nearestTool = tool;
                minDis = dis3;
            }
            if (dis4 < minDis && dis4 <= 20) {
                nearestTool = tool;
                minDis = dis4;
            }
        }else if ([tool.type isEqual:@"Rect"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
          
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point2.x, point1.y)];
            CGFloat dis3 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis4 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
            if (dis3 < minDis && dis3 <= 20) {
                nearestTool = tool;
                minDis = dis3;
            }
            if (dis4 < minDis && dis4 <= 20) {
                nearestTool = tool;
                minDis = dis4;
            }
        }
        else if ([tool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
          
            point1 = CGPointMake(point1.x *  bigView.frame.size.width, point1.y * bigView.frame.size.height);
            point2 = CGPointMake(point2.x * bigView.frame.size.width, point2.y * bigView.frame.size.height);
            
            CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:CGPointMake(point1.x, point2.y)];
            CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:CGPointMake(point2.x, point1.y)];
            if (dis1 < minDis && dis1 <= 20) {
                nearestTool = tool;
                minDis = dis1;
            }
            if (dis2 < minDis && dis2 <= 20) {
                nearestTool = tool;
                minDis = dis2;
            }
        }
    }
    return nearestTool;
}
//xi
-(void) updateColorWithTool:(SpecificationTool*)currentTool{
    
    for (int i = 0; i < _specTools.count; i++) {//当前cell的Tools
        NSMutableArray *frameTools = _specTools[i];
        for (int j = 0; j < frameTools.count; j++) {
            SpecificationTool *tool = frameTools[j];//一张图中的tool
            if(currentTool.frame == tool.frame && currentTool.name == tool.name){
                tool.color = currentTool.color;
                tool.x1 = currentTool.x1;
                tool.x2 = currentTool.x2;
                tool.x3 = currentTool.x3;
                tool.x4 = currentTool.x4;
                tool.y1 = currentTool.y1;
                tool.y2 = currentTool.y2;
                tool.y3 = currentTool.y3;
                tool.y4 = currentTool.y4;
                [tool.toolLayer removeFromSuperlayer];
                [tool.angleLabel1 removeFromSuperview];
                [_speCanvas drawCanvasSmallWithTool:tool];
            }
        }
    }
    
    [currentTool.lastLayer removeFromSuperlayer];
    [currentTool.angleLabel1 removeFromSuperview];
    [_bigViewCanvas drawCanvasWithToolInGlk:currentTool];
    NSNotification *notification = [NSNotification notificationWithName:@"specToolColorChange" object: nil];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

//-(BOOL)isContainPoint:(CGPoint) point andIndex:(int) i{
//    bool isContain = CGRectContainsPoint(((UIImageView *)_frameViewArray[i]).frame, point);
//    return isContain;
//}
- (CGFloat)computeDisWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
//    p1 = CGPointMake(p1.x * self.scrollView.contentSize.width, p1.y * self.scrollView.contentSize.height);
//    p2 = CGPointMake(p2.x * self.scrollView.contentSize.width, p2.y * self.scrollView.contentSize.height);
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
- (CGFloat)computeDisInGlkWith:(CGPoint)x0 andP1:(CGPoint)p1 andP2:(CGPoint)p2 {
    
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


- (void)removeBigeViewCurrentTools {
    for (SpecificationTool *tmpTool in bigViewCurrentTools) {
        [tmpTool.lastLayer removeFromSuperlayer];
        [tmpTool.toolPath removeAllPoints];
        [tmpTool.angleLabel1 removeFromSuperview];
    }
}

- (void)removeTools {
    for (NSMutableArray *array in _specTools) {
        for (SpecificationTool *tool in array) {
            [tool.toolLayer removeFromSuperlayer];
            [tool.toolPath removeAllPoints];
            [tool.angleLabel1 removeFromSuperview];
        }
    }
}

- (void)reset{
    [self removeTools];
    [self removeBigeViewCurrentTools];
//    [specSmallCollectionView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//    if(specSmallCollectionView != nil){
//        NSArray *layers = specSmallCollectionView.layer.sublayers;
//        for (int i = 0; i < layers.count; i ++) {
//            CALayer *layer = layers[i];
//            [layer removeFromSuperlayer];
//        }
//    }
    _speCanvas = nil;
    _bigViewCanvas = nil;
    _specTools = nil;
    _frameIndexArray = nil;
}

- (void)reloadData{
    [specSmallCollectionView reloadData];
}

- (void)displayToolsWith:(NSArray *) tools{
    for (SpecificationTool *tool in tools) {
        [_bigViewCanvas drawCanvasWithToolInGlk:tool];
    }
}
@end
