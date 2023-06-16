//
//  Canvas.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/21.
//

#import "Canvas.h"
#import "ZHScreenRecordManager.h"
#import "ZHPopupViewManager.h"
#import "CoreDataManager.h"

@interface Canvas ()

@property(nonatomic,assign)UIColor *strokeColor;

@end

@implementation Canvas{
    //工具栏
    UIButton *closeBtn;
    UIButton *revokeBtn;
    UIButton *clearBtn;
    UIButton *lineBtn;
    UIButton *angleBtn;
    UIButton *rectBtn;
    UIButton *colorBtn;
    UIButton *recordBtn;
    
    CGPoint toolboxLastLocation;
    DrawTool currentTool;
    
    BOOL isRecording;
    
    //颜色栏
    UIView *colorView;
    UIButton *redBtn;
    UIButton *yellowBtn;
    UIButton *blueBtn;
    UIButton *greenBtn;
    UIButton *orangeBtn;
    UIButton *purpleBtn;
    
    //线和矩形用
    UIBezierPath *currentPath;
    CGPoint origin;
    CAShapeLayer *currentLayer;
    UIPanGestureRecognizer *addLinePanGestureRecognizer;
    UIPanGestureRecognizer *addRectanglePanGestureRecognizer;
    //
    NSMutableArray<NSNumber *> *toolArr;
    NSMutableDictionary<NSNumber *,CAShapeLayer *> *layerDic;
    NSMutableDictionary<NSNumber *,AngleTool *> *angleToolDic;
}


- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        _toolboxView = [[UIView alloc]initWithFrame:CGRectMake(kScreenW-55, [GlobalVar sharedInstance].kStatusBarH+150, 50, 400)];
        UIPanGestureRecognizer *toolboxLongPressRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(toolboxPan:)];
        [_toolboxView addGestureRecognizer:toolboxLongPressRecognizer];
//        [_toolboxView setHidden:YES];
        [_toolboxView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_toolboxView];
        
        closeBtn = [[UIButton alloc]init];
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [closeBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:closeBtn];
        
        revokeBtn = [[UIButton alloc]init];
        [revokeBtn setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
        [revokeBtn addTarget:self action:@selector(revokeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [revokeBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [revokeBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:revokeBtn];
        
        clearBtn = [[UIButton alloc]init];
        [clearBtn setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [clearBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [clearBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:clearBtn];
        
        lineBtn = [[UIButton alloc]init];
        [lineBtn setImage:[UIImage imageNamed:@"line"] forState:UIControlStateNormal];
        [lineBtn addTarget:self action:@selector(lineBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [lineBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [lineBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:lineBtn];
        
        angleBtn = [[UIButton alloc]init];
        [angleBtn setImage:[UIImage imageNamed:@"angle"] forState:UIControlStateNormal];
        [angleBtn addTarget:self action:@selector(angleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [angleBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [angleBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:angleBtn];
        
        rectBtn = [[UIButton alloc]init];
        [rectBtn setImage:[UIImage imageNamed:@"rectAngle"] forState:UIControlStateNormal];
        [rectBtn addTarget:self action:@selector(rectBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [rectBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [rectBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:rectBtn];
        
        colorBtn = [[UIButton alloc]init];
        [colorBtn setBackgroundColor:[UIColor systemRedColor]];
        [colorBtn setImage:[UIImage imageNamed:@"color"] forState:UIControlStateNormal];
        [colorBtn addTarget:self action:@selector(colorBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [colorBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [colorBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:colorBtn];
        
        recordBtn = [UIButton new];
        [recordBtn setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(recordBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [recordBtn.layer setBorderColor:[UIColor systemOrangeColor].CGColor];
        [recordBtn.layer setBorderWidth:1];
        [_toolboxView addSubview:recordBtn];
        
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.left.right.equalTo(_toolboxView);
            maker.height.mas_equalTo(50);
        }];
        
        [revokeBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(closeBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [clearBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(revokeBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [lineBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(clearBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [angleBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(lineBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [rectBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(angleBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [colorBtn mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.equalTo(rectBtn.mas_bottom);
            maker.left.height.width.equalTo(closeBtn);
        }];
        
        [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(colorBtn.mas_bottom);
            make.left.height.width.equalTo(closeBtn);
        }];
        
        //颜色栏
        colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW/2, kScreenW/3)];
        colorView.center = self.center;
        [self addSubview:colorView];
        
        CGFloat t = kScreenW/6;
        
        redBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, t, t)];
        [redBtn setBackgroundColor:[UIColor systemRedColor]];
        [redBtn addTarget:self action:@selector(redBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        yellowBtn = [[UIButton alloc] initWithFrame:CGRectMake(t, 0, t, t)];
        [yellowBtn setBackgroundColor:[UIColor systemYellowColor]];
        [yellowBtn addTarget:self action:@selector(yellowBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        blueBtn = [[UIButton alloc] initWithFrame:CGRectMake(t*2, 0, t, t)];
        [blueBtn setBackgroundColor:[UIColor systemBlueColor]];
        [blueBtn addTarget:self action:@selector(blueBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        greenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, t, t, t)];
        [greenBtn setBackgroundColor:[UIColor systemGreenColor]];
        [greenBtn addTarget:self action:@selector(greenBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        orangeBtn = [[UIButton alloc] initWithFrame:CGRectMake(t, t, t, t)];
        [orangeBtn setBackgroundColor:[UIColor systemOrangeColor]];
        [orangeBtn addTarget:self action:@selector(orangeBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        purpleBtn = [[UIButton alloc] initWithFrame:CGRectMake(t*2, t, t, t)];
        [purpleBtn setBackgroundColor:[UIColor systemPurpleColor]];
        [purpleBtn addTarget:self action:@selector(purpleBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [colorView addSubview:redBtn];
        [colorView addSubview:yellowBtn];
        [colorView addSubview:blueBtn];
        [colorView addSubview:greenBtn];
        [colorView addSubview:orangeBtn];
        [colorView addSubview:purpleBtn];
        [colorView setHidden:YES];
        
        toolArr = [[NSMutableArray alloc]init];
        layerDic = [[NSMutableDictionary alloc]init];
        angleToolDic = [[NSMutableDictionary alloc]init];
        addLinePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addLine:)];
        addRectanglePanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addRectangle:)];
        _strokeColor = [UIColor systemRedColor];
        
        isRecording = NO;
        
        [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self stopRecord];
}

- (UIView *)colorView {
    return  colorView;
}

- (void)setColorView:(UIView *)colorView {
    colorView = colorView;
}

- (void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor = strokeColor;
    [colorBtn setBackgroundColor:strokeColor];
    if (currentTool==Rectangle) {
        [rectBtn setBackgroundColor:strokeColor];
        return;
    }
    if (currentTool==Line){
        [lineBtn setBackgroundColor:strokeColor];
    }
}

- (void)undo{
    if (toolArr.count>0){
        NSNumber *number = toolArr.lastObject;
        [toolArr removeLastObject];
        if (layerDic[number] == nil) {
            AngleTool *angleTool = angleToolDic[number];
            [angleToolDic removeObjectForKey:number];
            angleTool = nil;
        }else{
            currentLayer = layerDic[number];
            [layerDic removeObjectForKey:number];
            [currentLayer removeFromSuperlayer];
            currentLayer = nil;
        }
    }
}

- (void)clear{
    while (toolArr.count>0) {
        [self undo];
    }
}

- (void)startAddLine{
    [self addGestureRecognizer:addLinePanGestureRecognizer];
    [lineBtn setBackgroundColor:_strokeColor];
}

- (void)endAddLine{
    [self removeGestureRecognizer:addLinePanGestureRecognizer];
    [lineBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)addLine:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.bounds];
            currentLayer.lineWidth = 3;
            currentLayer.strokeColor = _strokeColor.CGColor;
            [self.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            CGPoint translation = [recognizer translationInView:self];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSNumber *newNumber = [[NSNumber alloc]initWithUnsignedLong:toolArr.count];
            [toolArr addObject:newNumber];
            layerDic[newNumber] = currentLayer;
            break;
        }
        default:
            break;
    }
}

- (void)startAddRectangle{
    [self addGestureRecognizer:addRectanglePanGestureRecognizer];
    [rectBtn setBackgroundColor:_strokeColor];
}

- (void)endAddRectangle{
    [self removeGestureRecognizer:addRectanglePanGestureRecognizer];
    [rectBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)addRectangle:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            origin = [recognizer locationInView:self];
            currentLayer = [[CAShapeLayer alloc]init];
            [currentLayer setFrame:self.bounds];
            currentLayer.lineWidth = 2;
            currentLayer.strokeColor = _strokeColor.CGColor;
            currentLayer.fillColor = [UIColor clearColor].CGColor;
            [self.layer addSublayer:currentLayer];
            currentPath = [UIBezierPath bezierPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [currentPath removeAllPoints];
            [currentPath moveToPoint:origin];
            CGPoint translation = [recognizer translationInView:self];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x+translation.x, origin.y+translation.y)];
            [currentPath addLineToPoint:CGPointMake(origin.x, origin.y+translation.y)];
            [currentPath closePath];
            currentLayer.path = currentPath.CGPath;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSNumber *newNumber = [[NSNumber alloc]initWithUnsignedLong:toolArr.count];
            [toolArr addObject:newNumber];
            layerDic[newNumber] = currentLayer;
            break;
        }
        default:
            break;
    }
}

- (AngleTool *)addAngleTool{
    AngleTool *newAngleTool = [[AngleTool alloc]initWithSuperiew:self andColor:_strokeColor];
    NSNumber *newNumber = [[NSNumber alloc]initWithUnsignedLong:toolArr.count];
    [toolArr addObject:newNumber];
    angleToolDic[newNumber] = newAngleTool;
    return newAngleTool;
}

- (void)closeToolbox{
    currentTool = NoTool;
    [self endAddLine];
    [self endAddRectangle];
}

- (void)closeBtnTapped{
    if([_delegate respondsToSelector:@selector(closeCanvas)]){
        [_delegate closeCanvas];
    }
}

- (void)revokeBtnTapped{
    [self undo];
}

- (void)clearBtnTapped{
    [self clear];
}

- (void)lineBtnTapped{
    switch (currentTool) {
        case NoTool:{
            currentTool = Line;
            [self startAddLine];
            break;
        }
        case Line:
            currentTool = NoTool;
            [self endAddLine];
            break;
        case Rectangle:{
            currentTool = Line;
            [self endAddRectangle];
            [self startAddLine];
            break;
        }
        case Angle:{
            currentTool = Line;
            [self startAddLine];
            break;
        }
        default:
            break;
    }
}

- (void)angleBtnTapped{
    switch (currentTool) {
        case Line:
            [self endAddLine];
            break;
        case Rectangle:{
            [self endAddRectangle];
            break;
        }
        default:
            break;
    }
    currentTool = Angle;
    [self addAngleTool];
}

- (void)rectBtnTapped{
    switch (currentTool) {
        case NoTool:{
            currentTool = Rectangle;
            [self startAddRectangle];
            break;
        }
        case Line:
            currentTool = Rectangle;
            [self endAddLine];
            [self startAddRectangle];
            break;
        case Rectangle:{
            currentTool = NoTool;
            [self endAddRectangle];
            break;
        }
        case Angle:{
            currentTool = Rectangle;
            [self startAddRectangle];
            break;
        }
        default:
            break;
    }
}

- (void)toolboxPan:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            toolboxLastLocation = _toolboxView.center;
            break;
            
        case UIGestureRecognizerStateEnded:{
            CGFloat x = _toolboxView.center.x;
            CGFloat y = _toolboxView.center.y;
            if (x<40){
                x = 40;
            }else if (x>kScreenW-40){
                x = kScreenW-40;
            }
            if (y<[GlobalVar sharedInstance].kStatusBarH+195){
                y=[GlobalVar sharedInstance].kStatusBarH+195;
            }else if (y>kScreenH-300){
                y=kScreenH-300;
            }
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.toolboxView.center = CGPointMake(x, y);
            }];
            break;
        }
        default:{
            CGPoint translation = [recognizer translationInView:self.superview];
            _toolboxView.center = CGPointMake(toolboxLastLocation.x+translation.x, toolboxLastLocation.y+translation.y);
            break;
        }
    }
}

-(void)colorBtnTapped{
    [colorView setHidden:NO];
}

- (void)recordBtnTapped {
    if (isRecording) {
        [self stopRecord];
    } else {
        [self startRecord];
    }
}

- (void)startRecord {
    __weak typeof(self) weakSelf = self;
    [ZHScreenRecordManager startRecord:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!success) {
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:strongSelf mode:MBProgressHUDModeText title:error.localizedDescription icon:NULL autoHideAfterDelayIfNeed:@1];
        } else {
            strongSelf->isRecording = YES;
            [strongSelf->recordBtn setImage:[UIImage imageNamed:@"endRecord"] forState:UIControlStateNormal];
        }
    }];
}

- (void)stopRecord {
    if (!isRecording) return;
    __weak typeof(self) weakSelf = self;
    [ZHScreenRecordManager endRecord:^(NSString *filePath, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf->isRecording = NO;
            [strongSelf->recordBtn setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
            if (filePath) {
                [strongSelf->recordBtn setUserInteractionEnabled:NO];
                [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:strongSelf mode:MBProgressHUDModeIndeterminate title:@"保存录屏中\n请稍后...." icon:NULL autoHideAfterDelayIfNeed:NULL];
                //保存录屏
                [CoreDataManager.sharedManager newAddScreenRecord:filePath WithCompletionHandler:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf->recordBtn setUserInteractionEnabled:YES];
                        if (success) {
                            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:strongSelf mode:MBProgressHUDModeText title:@"保存录屏成功" icon:NULL autoHideAfterDelayIfNeed:@1];
                        } else {
                            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:strongSelf mode:MBProgressHUDModeIndeterminate title:error.localizedDescription icon:NULL autoHideAfterDelayIfNeed:@1];
                        }
                    });
                }];
            } else {
                [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:strongSelf mode:MBProgressHUDModeText title:error.localizedDescription icon:NULL autoHideAfterDelayIfNeed:@1];
            }
        });
    }];
}

-(void)redBtnTapped{
    self.strokeColor = [UIColor systemRedColor];
    [colorView setHidden:YES];
}

-(void)yellowBtnTapped{
    self.strokeColor = [UIColor systemYellowColor];
    [colorView setHidden:YES];
}

-(void)blueBtnTapped{
    self.strokeColor = [UIColor systemBlueColor];
    [colorView setHidden:YES];
}

-(void)greenBtnTapped{
    self.strokeColor = [UIColor systemGreenColor];
    [colorView setHidden:YES];
}

-(void)orangeBtnTapped{
    self.strokeColor = [UIColor systemOrangeColor];
    [colorView setHidden:YES];
}

-(void)purpleBtnTapped{
    self.strokeColor = [UIColor systemPurpleColor];
    [colorView setHidden:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"] && [change[@"new"]  isEqual:@YES]) {
        [self stopRecord];
    }
}

@end
