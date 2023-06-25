//
//  SpecificationViewController.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/8.
//

#import "SpecificationViewController.h"
#import "FrameCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "PhotosVideo.h"
#import "SpecificationAlbumViewController.h"
#import "SpecificationTool.h"
#import "CanvasView_update.h"
#import "scoreCanvasView.h"
#import "specificationCanvasView.h"
#import "SpecificationAsset.h"
#import "SpecificationFrameCell.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ZHPopupViewManager.h"
typedef struct {
    GLKVector3 positionCoord;   //顶点坐标
    GLKVector2 textureCoord;    //纹理坐标
    GLKVector3 normal;          //法线
} CCVertex;
// 顶点数
static NSInteger const kCoordCount = 36;

@interface SpecificationViewController () <GLKViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource,SpecificationAlbumViewControllerDelegate,specificationCanvasDelegate,UITextFieldDelegate> {
    GLuint _bufferID;
    GLuint _exbufferID;
    GLuint _specbackbufferID;
    
    float ROC_X,ROC_Y,ROC_Z;
    float RX,RY,RZ;   //旋转
    float PX,PY;      //平移
    float S_XYZ;      //缩放

    long int count;
    
    GLKMatrix4 mvp;
    
    CGFloat aspect;
    
    UILongPressGestureRecognizer *longPress;
    UIImageView *tmpImgView;
    SpecificationAlbumViewController *album;
    int currentSelectIndex;
    SpecificationTool *currentTool;
}
//opengl
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKBaseEffect *exEffect;
@property (nonatomic, strong) GLKBaseEffect *backgroundEffect;
@property (nonatomic, assign) NSInteger frame;
@property (nonatomic, copy)   NSString *player_name;
@property (nonatomic, assign) NSInteger backgroundID;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;
//
@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UICollectionView *frameCollectionView;
@property (nonatomic, strong) NSArray *thirteenFrames;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *specView;
@property (nonatomic, strong) UIView *albumSizeView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, assign) NSInteger currentFrameOf13;

@property (nonatomic, strong) NSMutableArray *jsonArray;
@property (nonatomic, strong) NSMutableArray *canvasToolArray;
@property (nonatomic, strong) NSMutableArray *canvasToolArrayInGlk;
@property (nonatomic, strong) specificationCanvasView *canvas;
@property (nonatomic, strong) specificationCanvasView *glkcanvas;
@property (nonatomic, assign) bool isfront;
@property (nonatomic, strong) SpecificationAsset *cuurrentAsset;

@property (nonatomic, assign) CCVertex *vertices;
@property (nonatomic, assign) GLuint vertexBuffer;

@end
@implementation SpecificationViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [self initView];
}
- (void)viewWillDisappear:(BOOL)animated{
    self.backgroundEffect = nil;
    self.baseEffect = nil;
}
- (instancetype)initWithModel:(GolferModel*) gm andBackgroundID:(int) backgroundID andPlayerName:(nonnull NSString *)player_name{
    self = [super init];
    if(self){
        self.player_name = player_name;
        self.gl=gm;
//        NSArray *array = @[@0, @25, @44, @59, @91,@110,@118,@121,@123,@126,@129,@138,@198];
        self.thirteenFrames= gm.keyFrames;
        _backgroundID = backgroundID;
    }
    return self;
}
- (void) initView{
    //模型展示
    [self setupConfig];
    [self setupVertexData];
    [self setupTexture];
    [self addBackground];
    [self updateScene];
    
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, 30)];
    [_topView setImage:[UIImage imageNamed:@"topView"]];
    _topView.userInteractionEnabled = YES;
    [self.view addSubview:_topView];
    //13帧定位
    // 创建collectionView的布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 行列间距
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    // 设置item大小
    CGFloat kItemWidth = self.view.frame.size.width/13;
    CGFloat kItemHeight = kItemWidth/354*399;
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    // 设置滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.frameCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.frameCollectionView.backgroundColor = [UIColor blackColor];
    self.frameCollectionView.showsHorizontalScrollIndicator = NO;
    self.frameCollectionView.scrollEnabled = YES;
    [self.view addSubview:_frameCollectionView];
    self.frameCollectionView.delegate = self;
    self.frameCollectionView.dataSource = self;
    [self.frameCollectionView registerClass:[FrameCollectionViewCell class] forCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID"];
    [self.frameCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.glkView.mas_bottom);
        make.height.mas_equalTo(kItemHeight+1);
    }];
    [_frameCollectionView setHidden:NO];
    UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longPress13Frame)];
    twoTap.numberOfTapsRequired=2;
    twoTap.numberOfTouchesRequired=1;
    [_frameCollectionView addGestureRecognizer:twoTap];
    self.isfront = YES;
    //模版窗口
    self.specView = [[UIView alloc] init];
    _specView.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"framePlayerBottomView"]];
    [self.view addSubview:_specView];
    [self.specView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.frameCollectionView.mas_bottom);
    }];
    _frameViewArray = [[NSMutableArray alloc] init];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = self.view.frame.size.width / ((self.view.frame.size.width - 10) / 5);
    self.scrollView.bouncesZoom = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor= [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"framePlayerBottomView"]];
    _frameNumArray = [NSMutableArray arrayWithCapacity:6];
    for (int i = 1; i <= 6; i++) {
        SpecificationFrameCell *tmpView;
        if(i == 1){
            tmpView = [[SpecificationFrameCell alloc]init];
            tmpView.image = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", i]];
            [tmpView.deleteButton addTarget:self action:@selector(deleteFrame) forControlEvents:UIControlEventTouchUpInside];
//            [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", i]]];
        }else{
            tmpView = [[SpecificationFrameCell alloc]init];
            [tmpView.deleteButton addTarget:self action:@selector(deleteFrame) forControlEvents:UIControlEventTouchUpInside];
//            tmpView = [[UIImageView alloc] init];
//            tmpView.backgroundColor = [UIColor blackColor];
        }
        [_frameViewArray addObject:tmpView];
        [_frameNumArray addObject:@-1];
        [_scrollView addSubview:tmpView];
    }
    [self.specView addSubview:_scrollView];
    _scrollView.scrollEnabled = NO;
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, ((self.view.frame.size.width - 10) / 4) * 3);
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, ((self.view.frame.size.width - 10) / 4) * 6);
    
    for (int i = 0; i < 6; i++) {
        CGFloat width = ((self.view.frame.size.width - 10-8) / 6);
        CGFloat height = width/4*5;
        CGFloat x, y;
        if (i == 0) {
            x = 0;
        }
        else {
            x = 10 + i * width+2*(i-1);
        }
        y = kItemWidth/4*5;
        ((UIImageView *)_frameViewArray[i]).frame = CGRectMake(x, y, width, height);
        [((UIImageView *)_frameViewArray[i]) setHidden:NO];
        //        [((UIImageView *)_frameViewArray[i]) addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }
    [_scrollView setHidden:YES];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(getDeleteButtn:)];
    longPressGesture.minimumPressDuration =0.5;
    longPressGesture.delegate = self;
    longPressGesture.delaysTouchesBegan=YES;
    [_scrollView addGestureRecognizer: longPressGesture];
    _saveButton = [[UIButton alloc]init];
    [_saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_saveButton];
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.view.mas_height).multipliedBy(0.04);
        make.right.equalTo(((UIImageView *)_frameViewArray[4]).mas_right).offset(-30);
        make.top.equalTo(((UIImageView *)_frameViewArray[0]).mas_bottom).offset(40);
    }];
    
    _cancelButton = [[UIButton alloc]init];
    [_cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_cancelButton];
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.view.mas_height).multipliedBy(0.04);
        make.left.equalTo(((UIImageView *)_frameViewArray[1]).mas_left).offset(30);
        make.top.equalTo(((UIImageView *)_frameViewArray[0]).mas_bottom).offset(40);
    }];
    _textField = [[UITextField alloc]init];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.delegate = self;
    [_scrollView addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.view.mas_height).multipliedBy(0.03);
        make.left.equalTo(_cancelButton.mas_right).offset(30);
        make.right.equalTo(_saveButton.mas_left).offset(-30);
        make.top.equalTo(((UIImageView *)_frameViewArray[0]).mas_bottom).offset(45);
    }];
    //指标相册
    _albumSizeView = [[UIView alloc]init];
    _albumSizeView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_albumSizeView];
    [self.albumSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.glkView.mas_left);
        make.bottom.equalTo(self.frameCollectionView.mas_top);
        make.top.equalTo(self.glkView.mas_top);
    }];
    album = [[SpecificationAlbumViewController alloc]init];
    [self addChildViewController:album];
    album.view.frame = _albumSizeView.frame;
    [_albumSizeView addSubview:album.view];
    album.delegate=self;

    //glk画布
    _canvasToolArray = [[NSMutableArray alloc]init];//模版画线结果
    _canvas = [[specificationCanvasView alloc]init];
    _canvas.delegate=self;
    [_canvas initializeWithScrollView:_scrollView andSuperView:_specView];
    
    _canvasToolArrayInGlk = [[NSMutableArray alloc]init];//glk画线数组
    _glkcanvas = [[specificationCanvasView alloc]init];
    _glkcanvas.delegate=self;
    [_glkcanvas initializeWithUIView:_glkView andSuperView:_glkView];
    
    _jsonArray = [[NSMutableArray alloc]init];
    for (int i=0; i<6; i++) {
        NSMutableDictionary *temdic = [[NSMutableDictionary alloc]init];;
        [_jsonArray addObject:temdic];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:)
       name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _scrollView.scrollEnabled = YES;
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    CGFloat distance = _textField.frame.size.height +_textField.frame.origin.y + _specView.frame.origin.y - keyboardFrame.origin.y;
    if (distance > 0) {
        CGPoint offset = self.scrollView.contentOffset;
        offset.y += distance+5;
        [self.scrollView setContentOffset:offset animated:YES];
    }
}

-(void)keyboardDidHidden:(NSNotification *)notification
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    _scrollView.scrollEnabled = NO;
}

-(void) cancel{
    [self rmakeData];
    [self viewHidden];
    _cuurrentAsset = nil;
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
-(void) save{
    
    NSString *toolsSavePath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"toolsData"];
    if ([NSKeyedArchiver archiveRootObject:self.canvasToolArray toFile:toolsSavePath]) {
        NSLog(@"tool写入成功");
    }
    else {
        NSLog(@"tool写入失败");
    }
    
    NSString *frameIdxSavePath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"frameIndex"];
    if ([_frameIndexArray writeToFile:frameIdxSavePath atomically:NO]) {
        NSLog(@"指标模型图片写入成功");
    }
    else {
        NSLog(@"指标模型图片写入失败");
    }
    
    [CoreDataManager.sharedManager setISFrontForSpecification:_cuurrentAsset.model andISFront:&(_isfront)];
    
    NSString *jsonPath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"jsonData.json"];
    if ([NSJSONSerialization isValidJSONObject:_jsonArray]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToFile:jsonPath atomically:YES];
        NSLog(@"%@",_jsonArray);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:@"http://219.238.233.6:37577/progolf/upload_spec" parameters:@{@"uid":_cuurrentAsset.uuid} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:jsonData name:@"file" fileName:@"jsonData.json" mimeType:@"json"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
               
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [CoreDataManager.sharedManager updataSpecificationIsEdite:YES andIsFront:self->_isfront andName:self->_textField.text  withUuid:self->album.currentSpecification.uuid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"123\r\n%@", responseObject);
                    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"上传成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
                });
                [self->album getData];
                [self rmakeData];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [CoreDataManager.sharedManager updataSpecificationIsEdite:NO andIsFront:self->_isfront andName:self->_textField.text  withUuid:self->album.currentSpecification.uuid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", error);
                    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"上传失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                    
                });
                [self->album getData];
                [self rmakeData];
            }
        ];
        
        
    }
    [self viewHidden];
    _cuurrentAsset = nil;
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(void) viewHidden{
    [_scrollView setHidden:YES];
    [album.toolView setHidden:YES];
}
-(void) rmakeData{
    [_frameNumArray removeAllObjects];
    [self deleteAllTools];
    [self deleteAllToolsInGlk];
    for (int i = 0; i < 6; i++) {
        if(i == 0){
            ((UIImageView *)_frameViewArray[i]).image =_isfront == YES ? [UIImage imageNamed:@"frontFrame1"] : [UIImage imageNamed:@"sideFrame1"];
        }else{
            ((UIImageView *)_frameViewArray[i]).image = nil;
        }
        [_frameNumArray addObject:@-1];
    }
    _textField.text = nil;
    [_jsonArray removeAllObjects];
    for (int i=0; i<6; i++) {
        NSMutableDictionary *temdic = [[NSMutableDictionary alloc]init];;
        [_jsonArray addObject:temdic];
    }
}
//删除glktool
- (void)deleteAllToolsInGlk {
    for (SpecificationTool *tmpTool in self.canvasToolArrayInGlk) {
        [tmpTool.lastLayer removeFromSuperlayer];
        [tmpTool.toolPath removeAllPoints];
        [tmpTool.angleLabel1 removeFromSuperview];
    }
    [self.canvasToolArrayInGlk removeAllObjects];
}
- (void)deleteAllTools {
    for(int i=0;i<6;i++){
        [self deleteToolsWithIndex:i];
    }
    [self.canvasToolArray removeAllObjects];
    for (int i=0; i<6; i++) {
        NSMutableArray *temArray = [[NSMutableArray alloc]init];;
        [_canvasToolArray addObject:temArray];
    }
}
- (void) deleteToolsWithIndex:(int)i{
    for (SpecificationTool *tmpTool in self.canvasToolArray[i]) {
        [tmpTool.toolLayer removeFromSuperlayer];
        [tmpTool.toolPath removeAllPoints];
        [tmpTool.angleLabel1 removeFromSuperview];
    }
    [self.canvasToolArray[i] removeAllObjects];
}
-(void) longPress13Frame{
    if(![_scrollView isHidden]){
        if(_isfront){
            for(FrameCollectionViewCell *indexcell in _frameCollectionView.visibleCells){
                [indexcell setFrameImg: [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", indexcell.index]] withRate:0];
            }
            RY=-95*M_PI/180;
            [self updateScene];
        }else{
            for(FrameCollectionViewCell *indexcell in _frameCollectionView.visibleCells){
                [indexcell setFrameImg: [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", indexcell.index]] withRate:0];
            }
            RY=0;
            [self updateScene];
        }
        _isfront = !_isfront;
        [self rmakeData];
    }
}
-(void) getDeleteButtn:(UILongPressGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state ==UIGestureRecognizerStateBegan){
        if (@available(iOS 10.0, *)) {
               UIImpactFeedbackGenerator *r = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
               [r prepare];
               [r impactOccurred];
            } else {
                // Fallback on earlier versions
            }
        
        CGPoint p=[gestureRecognizer locationInView:_scrollView];
        
        for (int i=0; i<6; i++) {
            if(CGRectContainsPoint(((SpecificationFrameCell *)_frameViewArray[i]).frame, p)){
                [((SpecificationFrameCell *)_frameViewArray[i]).contentsView setHidden:NO];
                currentSelectIndex = i;
                break;
            }
        }
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
          
    }
}

-(void) deleteFrame{
    [self deleteToolsWithIndex:currentSelectIndex];
    _frameNumArray[currentSelectIndex] = @-1;
    NSMutableDictionary *temdic = [[NSMutableDictionary alloc]init];;
    _jsonArray[currentSelectIndex] = temdic;
    ((SpecificationFrameCell *)_frameViewArray[currentSelectIndex]).image = nil;
    _frameIndexArray[currentSelectIndex]= [[NSData alloc]init];
    if(currentSelectIndex == 0){
        if(_isfront){
            ((SpecificationFrameCell *)_frameViewArray[currentSelectIndex]).image = [UIImage imageNamed:@"frontFrame1"];
            _frameIndexArray[currentSelectIndex] = UIImageJPEGRepresentation([UIImage imageNamed:@"frontFrame1"] , 1.0);
        }else{
            ((SpecificationFrameCell *)_frameViewArray[currentSelectIndex]).image = [UIImage imageNamed:@"sideFrame1"];
            _frameIndexArray[currentSelectIndex] = UIImageJPEGRepresentation([UIImage imageNamed:@"sideFrame1"] , 1.0);
        }
       
    }
    [((SpecificationFrameCell *)_frameViewArray[currentSelectIndex]).contentsView setHidden:YES];
}
-(void) headLine{
    GLKVector4 v=self.gl.headtop[_frame];
    CGPoint point = [self worldToScreen:v];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiLineWithPointA:point];
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.type == glktool.type){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];

}

- (void) headposition{
    GLKVector4 v1, v2, v3;
    CGPoint pointA, pointB, pointC;
    if(_isfront){
        v1 =self.gl.headposition[0][_frame];
        pointA = [self worldToScreen:v1];
        v2=self.gl.headposition[1][_frame];
        pointB = [self worldToScreen:v2];
        v3=self.gl.headposition[2][_frame];
        pointC = [self worldToScreen:v3];
    }else{
        v1 =self.gl.headPositionBeside[0][_frame];
        pointA = [self worldToScreen:v1];
        v2=self.gl.headPositionBeside[1][_frame];
        pointB = [self worldToScreen:v2];
        v3=self.gl.headPositionBeside[2][_frame];
        pointC = [self worldToScreen:v3];
    }
    
    SpecificationTool *glktool = [[SpecificationTool alloc]intiHeadPositionWithPointA:pointA andPointB:pointB andandPointC:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.type == glktool.type){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) headFrame{
    GLKVector4 v1, v2, v3;
    CGPoint pointA, pointB, pointC;
    if(_isfront){
        v1=self.gl.headposition[0][_frame];
        pointA = [self worldToScreen:v1];
        v3=self.gl.headposition[2][_frame];
        pointC = [self worldToScreen:v3];
    }else{
        v1=self.gl.headPositionBeside[0][_frame];
        pointA = [self worldToScreen:v1];
        v3=self.gl.headPositionBeside[2][_frame];
        pointC = [self worldToScreen:v3];
    }
    
    SpecificationTool *glktool = [[SpecificationTool alloc]intiHeadFrameWithPointA:pointA andPointB:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.type == glktool.type){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) kneeGaps{
    GLKVector4 v1,v3;
    CGPoint pointA,pointC;
    if(_isfront){
        v1=self.gl.kneeWidth[0][_frame];
        pointA = [self worldToScreen:v1];
        v3=self.gl.kneeWidth[2][_frame];
        pointC = [self worldToScreen:v3];
    }else{
        v1=self.gl.kneeWidthBeside[0][_frame];
        pointA = [self worldToScreen:v1];
        v3=self.gl.kneeWidthBeside[2][_frame];
        pointC = [self worldToScreen:v3];
    }
    
    SpecificationTool *glktool = [[SpecificationTool alloc]intiKneeGapsWithPointA:pointA andPointB:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name  == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) leadForearmLine{
    GLKVector4 v1=self.gl.leadForearmLine[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.leadForearmLine[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiLeadForearmLineWithPointA:pointA andPointB:pointB];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) shaftLine{
    GLKVector4 v1=self.gl.shaftLine[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.shaftLine[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiShaftLineWithPointA:pointA andPointB:pointB];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) elbowHosel{
    if(!_isfront){
        GLKVector4 v1=self.gl.elbowHosel[0][_frame];
        CGPoint pointA = [self worldToScreen:v1];
        GLKVector4 v2=self.gl.elbowHosel[1][_frame];
        CGPoint pointB = [self worldToScreen:v2];
        SpecificationTool *glktool = [[SpecificationTool alloc]intiElbowHoselLineWithPointA:pointA andPointB:pointB];
        
        for (SpecificationTool *tool in _canvasToolArrayInGlk) {
            if(tool.name == glktool.name){
                return;
            }
        }
        [_canvasToolArrayInGlk addObject:glktool];
        [_glkcanvas drawCanvasWithToolInGlk:glktool];
    }
}

- (void) shaftLineToArmpit{
    if(!_isfront){
        GLKVector4 v1=self.gl.shaftLineToArmpit[0][_frame];
        CGPoint pointA = [self worldToScreen:v1];
        GLKVector4 v2=self.gl.shaftLineToArmpit[1][_frame];
        CGPoint pointB = [self worldToScreen:v2];
        SpecificationTool *glktool = [[SpecificationTool alloc]intiShaftLineToArmpitWithPointA:pointA andPointB:pointB];
        
        for (SpecificationTool *tool in _canvasToolArrayInGlk) {
            if(tool.name == glktool.name){
                return;
            }
        }
        [_canvasToolArrayInGlk addObject:glktool];
        [_glkcanvas drawCanvasWithToolInGlk:glktool];
    }
}

- (void) lowBodyPosition{
    GLKVector4 v1=self.gl.lowBodyPosition[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.lowBodyPosition[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    GLKVector4 v3=self.gl.lowBodyPosition[2][_frame];
    CGPoint pointC = [self worldToScreen:v3];
    GLKVector4 v4=self.gl.lowBodyPosition[3][_frame];
    CGPoint pointD = [self worldToScreen:v4];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiLowBodyPositionWithPointA:pointA andPointB:pointB andPointC:pointC andPointD:pointD];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.type == glktool.type){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) leadElbowAngle{
    GLKVector4 v1, v2, v3;
    CGPoint pointA, pointB, pointC;
    v1=self.gl.leadElbowAngle[0][_frame];
    pointA = [self worldToScreen:v1];
    v2=self.gl.leadElbowAngle[1][_frame];
    pointB = [self worldToScreen:v2];
    v3=self.gl.leadElbowAngle[2][_frame];
    pointC = [self worldToScreen:v3];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiLeadElbowAngleWithPointA:pointA andPointB:pointB andandPointC:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name  == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) trailElbowAngle{
    GLKVector4 v1, v2, v3;
    CGPoint pointA, pointB, pointC;
    v1=self.gl.trailElbowAngle[0][_frame];
    pointA = [self worldToScreen:v1];
    v2=self.gl.trailElbowAngle[1][_frame];
    pointB = [self worldToScreen:v2];
    v3=self.gl.trailElbowAngle[2][_frame];
    pointC = [self worldToScreen:v3];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiTrailElbowAngleWithPointA:pointA andPointB:pointB andandPointC:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name  == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) shoulderTilt{
    GLKVector4 v1=self.gl.shoulderAngle[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.shoulderAngle[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiShoulderTiltWithPointA:pointA andPointB:pointB];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) trailLegAngle{
    GLKVector4 v1=self.gl.trailLegAngle[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.trailLegAngle[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    GLKVector4 v3=self.gl.trailLegAngle[2][_frame];
    CGPoint pointC = [self worldToScreen:v3];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiTrailLegAngleWithPointA:pointA andPointB:pointB andandPointC:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) leadLegAngle{
    GLKVector4 v1=self.gl.leadLegAngle[0][_frame];
    CGPoint pointA = [self worldToScreen:v1];
    GLKVector4 v2=self.gl.leadLegAngle[1][_frame];
    CGPoint pointB = [self worldToScreen:v2];
    GLKVector4 v3=self.gl.leadLegAngle[2][_frame];
    CGPoint pointC = [self worldToScreen:v3];
    SpecificationTool *glktool = [[SpecificationTool alloc]intiLeadLegAngleWithPointA:pointA andPointB:pointB andandPointC:pointC];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

-(void) hipDepth{
    GLKVector4 v1=self.gl.hipDepth[_frame];
    CGPoint pointA = [self worldToScreen:v1];
    
    SpecificationTool *glktool = [[SpecificationTool alloc]intiHipDepthWithPointA:pointA];
    
    for (SpecificationTool *tool in _canvasToolArrayInGlk) {
        if(tool.name == glktool.name){
            return;
        }
    }
    [_canvasToolArrayInGlk addObject:glktool];
    [_glkcanvas drawCanvasWithToolInGlk:glktool];
}

- (void) removeCurrentLine{
    if(currentTool){
        [currentTool.lastLayer removeFromSuperlayer];
        [currentTool.toolPath removeAllPoints];
        [currentTool.angleLabel1 removeFromSuperview];
        [self.canvasToolArrayInGlk removeObject:currentTool];
        [_glkcanvas deselectCurrentTool];
    }
}
- (CGPoint)worldToScreen:(GLKVector4)vector
{
//    GLKMatrix4 mvp = GLKMatrix4Multiply(GLKMatrix4Multiply(_projectionMatrix, _cameraMatrix), _modelViewMatrix) ;
    GLKVector4 ndc = GLKMatrix4MultiplyVector4(mvp, vector);
    
    float x = ndc.x / ndc.w;
    float y = ndc.y / ndc.w;
    x = (x+1)/2;
    y = (-y+1)/2;
    CGPoint p = CGPointMake(x, y);
    
    return p;
}
//
- (void)selectFrame:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!tmpImgView) {
            tmpImgView = [[UIImageView alloc] init];
            tmpImgView.frame = CGRectMake(0, 0, (self.view.frame.size.width - 18) / 6, (self.view.frame.size.width - 18) / 24*5);
            
            
            UIGraphicsBeginImageContextWithOptions(self.glkView.bounds.size, NO, 0.0f);
            NSLog(@"%f,%f",self.glkView.bounds.size.width,self.glkView.bounds.size.height);
//            [self.glkView.layer renderInContext:UIGraphicsGetCurrentContext()];
            [self.glkView drawViewHierarchyInRect:self.glkView.bounds afterScreenUpdates:YES];
            UIImage * resultImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
//            UIImage* resultImg = self.glkView.snapshot;
            tmpImgView.image = resultImg;
            CGPoint point = [recognizer locationInView:self.view];
            tmpImgView.center = point;
            [self.view.superview addSubview:tmpImgView];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.view];
        tmpImgView.frame = CGRectMake(0, 0, (self.view.frame.size.width - 18) / 6, (self.view.frame.size.width - 18) / 24*5);
        tmpImgView.center = point;
//        [self.delegate choosingFrame:point];

    }
    else {
        CGPoint point = [recognizer locationInView:_scrollView];
        [self finishSelect:tmpImgView.image andframeindex:0 andPoint:point];
        [tmpImgView removeFromSuperview];
        tmpImgView = nil;
    }
}
- (void)finishSelect:(UIImage *)image andframeindex:(int) fameindex andPoint:(CGPoint)point {
    if (point.y < ((UIImageView *)_frameViewArray[0]).frame.origin.y) {
        return;
    }
    int idx = 0;
    CGFloat distance = CGFLOAT_MAX;
//    for (int i = 0; i < 6; i++) {
//        UIImageView *tmpView = _frameViewArray[i];
//        CGFloat tmpDis = (tmpView.center.x - point.x) * (tmpView.center.x - point.x) + (tmpView.center.y + _scrollView.frame.origin.y - point.y) * (tmpView.center.y + _scrollView.frame.origin.y - point.y);
//        if (distance > tmpDis) {
//            distance = tmpDis;
//            idx = i;
//        }
//    }
    
    for (int i=0; i<6; i++) {
        if(CGRectContainsPoint(((SpecificationFrameCell *)_frameViewArray[i]).frame, point)){
            idx = i;
            break;
        }
    }
    UIImageView *tmpView = _frameViewArray[idx];
    tmpView.image = image;
    _frameNumArray[idx]=[NSNumber numberWithInt:(int)_currentFrameOf13];
    NSData *imgData = UIImageJPEGRepresentation(image , 1.0);
    _frameIndexArray[idx] = imgData;
    NSString *frameIdxSavePath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"frameIndex"];
    if ([_frameIndexArray writeToFile:frameIdxSavePath atomically:NO]) {
        NSLog(@"指标模型图片写入成功");
    }
    else {
        NSLog(@"指标模型图片写入失败");
    }
    [self addSpecificationToolWithIndex:idx];
//    _frameListArray[idx]=[NSNumber numberWithInt:fameindex];
}

-(void)addSpecificationToolWithIndex:(int)ind{
    [self deleteToolsWithIndex:ind];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:_frameNumArray[ind] forKey:@"frame_id"];
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    for(SpecificationTool *tool in _canvasToolArrayInGlk){
        SpecificationTool *newtool = [tool copy];
        newtool.index= [NSNumber numberWithInt:ind];
        newtool.frame = _frameNumArray[ind];
        newtool.corresFrame = _frameNumArray[ind];
        [_canvasToolArray[ind] addObject:newtool];
        [_canvas drawCanvasWithTool:newtool];
        NSMutableDictionary *line = [[NSMutableDictionary alloc]init];
        [line setObject:newtool.name forKey:@"line_name"];
        [lines addObject:line];
    }
    [dic setObject:lines forKey:@"lines"];
    _jsonArray[ind] = dic;
    NSLog(@"%@",_jsonArray);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect frame = [textField convertRect:textField.bounds toView:_scrollView];
    [_scrollView scrollRectToVisible:frame animated:YES];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    NSLog(@"%@", textField.text);
//    return YES;
//}
#pragma mark -specificationCanvasDelegate
-(SpecificationTool *)chooseNearestSpecificationToolWithX:(CGPoint)x0{
    SpecificationTool *nearestTool = nil;
    CGFloat minDis = CGFLOAT_MAX;
    NSMutableArray *tmpScoreTools;
    tmpScoreTools = _canvasToolArray;
    for (int i=0; i<6; i++) {
        for(SpecificationTool *tool in tmpScoreTools[i]){
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
            CGPoint point1, point2, point3, point4;
            if ([tool.type isEqual:@"Line"] || [tool.type isEqual:@"LineWithNode"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / _scrollView.contentSize.width, point1.y / _scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / _scrollView.contentSize.width, point2.y / _scrollView.contentSize.height);
                CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
                if (dis < minDis && dis <= 20) {
                    nearestTool = tool;
                    minDis = dis;
                }
            }
            else if ([tool.type isEqual:@"broken Line"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
                point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
                point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / _scrollView.contentSize.width, point1.y / _scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / _scrollView.contentSize.width, point2.y / _scrollView.contentSize.height);
//                point3 = CGPointMake(point3.x / _scrollView.contentSize.width, point3.y / _scrollView.contentSize.height);
                CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point2];
                CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point3];
                if (dis1 < minDis && dis1 <= 20) {
                    nearestTool = tool;
                    minDis = dis1;
                }
                if (dis2 < minDis && dis2 <= 20) {
                    nearestTool = tool;
                    minDis = dis2;
                }
            }else if ([tool.type isEqual:@"ExternLineWithNode"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
                CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
                offset = CGPointMake(offset.x / 3, offset.y / 3);
                point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
                point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
                CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
                if (dis < minDis && dis <= 20) {
                    nearestTool = tool;
                    minDis = dis;
                }
            }
            else if ([tool.type isEqual:@"SingleExternLineWithNode"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
                CGPoint offset = CGPointMake(point1.x - point2.x, point1.y - point2.y);
                offset = CGPointMake(offset.x, offset.y);
        //        point1 = CGPointMake(point1.x + offset.x, point1.y + offset.y);
                point2 = CGPointMake(point2.x - offset.x, point2.y - offset.y);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
                CGFloat dis = [self computeDisWith:x0 andP1:point1 andP2:point2];
                if (dis < minDis && dis <= 20) {
                    nearestTool = tool;
                    minDis = dis;
                }
            }
            else if ([tool.type isEqual:@"Rect"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
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
            }else if ([tool.type isEqual:@"Quadrilateral"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
                point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
                point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
                point4 = CGPointMake(tool.x4.floatValue, tool.y4.floatValue);
                point4 = CGPointMake(point4.x * aveWidth + offsetX, point4.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
//                point3 = CGPointMake(point3.x / scrollView.contentSize.width, point3.y / scrollView.contentSize.height);
//                point4 = CGPointMake(point4.x / scrollView.contentSize.width, point4.y / scrollView.contentSize.height);
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
            }
            else if ([tool.type isEqual:@"Angle"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
                point3 = CGPointMake(tool.x3.floatValue, tool.y3.floatValue);
                point3 = CGPointMake(point3.x * aveWidth + offsetX, point3.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
//                point3 = CGPointMake(point3.x / scrollView.contentSize.width, point3.y / scrollView.contentSize.height);
                CGPoint point4 = CGPointMake(point2.x + point2.x - point1.x, point2.y + point2.y - point1.y);
                CGFloat dis1 = [self computeDisWith:x0 andP1:point1 andP2:point2];
                CGFloat dis2 = [self computeDisWith:x0 andP1:point2 andP2:point3];
                if (dis1 < minDis && dis1 <= 20) {
                    nearestTool = tool;
                    minDis = dis1;
                }
                if (dis2 < minDis && dis2 <= 20) {
                    nearestTool = tool;
                    minDis = dis2;
                }
            }
            else if ([tool.type isEqual:@"Ruler"]) {
                point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
                point1 = CGPointMake(point1.x * aveWidth + offsetX, point1.y * aveHeight + offsetY);
                point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
                point2 = CGPointMake(point2.x * aveWidth + offsetX, point2.y * aveHeight + offsetY);
//                point1 = CGPointMake(point1.x / scrollView.contentSize.width, point1.y / scrollView.contentSize.height);
//                point2 = CGPointMake(point2.x / scrollView.contentSize.width, point2.y / scrollView.contentSize.height);
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
    }
    return nearestTool;
}

-(SpecificationTool *)chooseNearestSpecificationToolWithXInGlk:(CGPoint)x0{
    SpecificationTool *nearestTool = nil;
    CGFloat minDis = CGFLOAT_MAX;
    NSMutableArray *tmpScoreTools;
    tmpScoreTools = _canvasToolArrayInGlk;
    for(SpecificationTool *tool in _canvasToolArrayInGlk){
        
        CGPoint point1, point2, point3, point4;
        if ([tool.type isEqual:@"Line"] || [tool.type isEqual:@"LineWithNode"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
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
            
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
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
            
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
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
           
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
            point3 = CGPointMake(point3.x *  _glkView.frame.size.width, point3.y * _glkView.frame.size.height);
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
           
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
            point3 = CGPointMake(point3.x *  _glkView.frame.size.width, point3.y * _glkView.frame.size.height);
            point4 = CGPointMake(point4.x *  _glkView.frame.size.width, point4.y * _glkView.frame.size.height);
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
          
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
            
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
        }else if ([tool.type isEqual:@"Ruler"]) {
            point1 = CGPointMake(tool.x1.floatValue, tool.y1.floatValue);
            
            point2 = CGPointMake(tool.x2.floatValue, tool.y2.floatValue);
          
            point1 = CGPointMake(point1.x *  _glkView.frame.size.width, point1.y * _glkView.frame.size.height);
            point2 = CGPointMake(point2.x * _glkView.frame.size.width, point2.y * _glkView.frame.size.height);
            
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
    currentTool = nearestTool;
    return nearestTool;
}

-(void) updateColorWithTool:(SpecificationTool*)currentTool{
    [currentTool.lastLayer removeFromSuperlayer];
    [currentTool.angleLabel1 removeFromSuperview];
    [_glkcanvas drawCanvasWithToolInGlk:currentTool];
}

-(BOOL)isContainPoint:(CGPoint) point andIndex:(int) i{
    bool isContain = CGRectContainsPoint(((UIImageView *)_frameViewArray[i]).frame, point);
    return isContain;
}
//copy tool
-(void) addSpectificationToolWithTool:(SpecificationTool*) tool andIndex:(int)i{
    for (SpecificationTool* comparetool in _canvasToolArray[i]) {
        if(comparetool.name == tool.name && comparetool.frame == tool.frame){
            NSLog(@"存在相同线");
            return;
        }
    }
    SpecificationTool* newTool = [tool copy];
    if([newTool.index intValue] !=i){
        newTool.index = [NSNumber numberWithInt:i];
        newTool.corresFrame = _frameNumArray[i];
        [_canvasToolArray[i] addObject:newTool];
        [_canvas drawCanvasWithTool:newTool];
    }
    
}

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
#pragma mark -SpecificationAlbumViewControllerDelegate
-(void) hiddenViewAppearWithAsset:(SpecificationAsset*)asset{
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    _cuurrentAsset = asset;
    _textField.text = asset.name;
    _isfront = asset.isFront;
    
    [_frameCollectionView setHidden:NO];
    [_frameCollectionView reloadData];
    [_scrollView setHidden:NO];
    
    if(!_isfront){
        RY=-95*M_PI/180;
        [self updateScene];
    }else{
        RY=0;
        [self updateScene];
    }
    NSString *toolsSavePath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"toolsData"];
    NSMutableArray *tmpToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
    if(tmpToolsArray){
        _canvasToolArray = tmpToolsArray;
        for (int i=0; i<6; i++) {
            for (SpecificationTool*tool in _canvasToolArray[i]) {
                [_canvas drawCanvasWithTool:tool];
                NSLog(@"corresframe:%@",tool.corresFrame);
            }
        }     
    }else{
        for (int i=0; i<6; i++) {
            NSMutableArray *temArray = [[NSMutableArray alloc]init];;
            [_canvasToolArray addObject:temArray];
        }
    }
    
    NSString *frameIdxSavePath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"frameIndex"];
    _frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
    if (!_frameIndexArray) {
        _frameIndexArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 6; i++) {
            [_frameIndexArray addObject:@-1];
        }
    }
    else {
        for (int i = 0; i < 6; i++) {
            if ([_frameIndexArray[i] isKindOfClass:[NSData class]]) {
                UIImageView *tmpView = _frameViewArray[i];
                tmpView.image = [UIImage imageWithData:_frameIndexArray[i]];
            }
        }
    }
    
    NSString *jsonPath = [_cuurrentAsset.modelFile stringByAppendingPathComponent:@"jsonData.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    if(jsonData){
        _jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
}
#pragma mark -collectionview
- (void)showFrameAtIndex:(int)index{
    self.frame = [_thirteenFrames[index] intValue];
    [self updateScene];
}
#pragma mark -collectionview 数据源方法 13帧定位
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 13;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    UIImage *cellImg;
    
    if(_isfront){
        cellImg = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
    }else{
        cellImg = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
    }
    
    
    [cell setFrameImg:cellImg withRate:0];
    cell.index = (int)indexPath.row+1;
    UIView *tmpView = [[UIView alloc] initWithFrame:cell.frame];
    tmpView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = tmpView;
    if((int)indexPath.row==0){
        [cell setSelected:YES];
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    for(FrameCollectionViewCell *indexcell in _frameCollectionView.visibleCells){
        if(indexcell==cell){
            [indexcell setSelected:YES];
            indexcell.backgroundColor = [UIColor redColor];
        }else{
            [indexcell setSelected:NO];
            indexcell.backgroundColor = [UIColor blackColor];
        }
    }
    _currentFrameOf13 = indexPath.row;
    [self showFrameAtIndex:(int)indexPath.row];
    [self deleteAllToolsInGlk];
}
#pragma mark -GLKitView
- (void)setupConfig{
    RX = 0; RY = 0; RZ = 0;
    PX = 0; PY = 0;
    S_XYZ = 3.0;
    ROC_X = self.gl.allVertex[0].myVertex->positionCoodinate.x;
    ROC_Y = self.gl.allVertex[0].myVertex->positionCoodinate.y;
    ROC_Z = self.gl.allVertex[0].myVertex->positionCoodinate.z - 0.15;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    // 判断是否创建成功
    if (!self.context) {
        NSLog(@"Create ES context failed");
        return;
    }
    // 设置当前上下文
    [EAGLContext setCurrentContext:self.context];
    // GLKView
    CGRect frame = CGRectMake(self.view.frame.size.width/5*2,[[UIApplication sharedApplication] statusBarFrame].size.height+30,self.view.frame.size.width/5*3,self.view.frame.size.width / 4 * 3);
    NSLog(@"%f",frame.size.width/frame.size.height);
    self.glkView = [[GLKView alloc] initWithFrame:frame context:self.context];
    self.glkView.delegate = self;
    self.glkView.context = self.context;
    
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glDepthRangef(1, 0);
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [self.view addSubview:self.glkView];
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectFrame:)];
    longPress.minimumPressDuration = 0.5f;
    [self.glkView addGestureRecognizer:longPress];
    glClearColor(1.0f, 1.0f,1.0f, 1);
}
- (void)setupVertexData{
    // 开辟空间
    [self cleanup];
    NSLog(@"%ld",self.frame);
    if(!self.gl.Isframes[self.frame]){
        [self.gl modelRead4:self.player_name withFrame:self.frame];
    }
    NSLog(@"%ld",(long)_frame);
    glGenBuffers(1, &_bufferID); // 开辟1个顶点缓冲区，所以传入1
    // 绑定顶点缓冲区
    glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
    // 缓冲区大小
    GLsizeiptr bufferSizeBytes = sizeof(MyVertex) * _gl.pointCount;
    // 将顶点数组的数据copy到顶点缓冲区中(GPU显存中)
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.gl.allVertex[_frame].myVertex, GL_STREAM_DRAW);
     
    // 打开读取通道
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 顶点坐标数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex)/*由于是结构体，所以步长就是结构体大小*/, NULL + offsetof(MyVertex, positionCoodinate));
    
    //    光照
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL+offsetof(MyVertex, normal));

}
- (void)setupTexture{
    self.exEffect =  [[GLKBaseEffect alloc] init];
    
    self.exEffect.constantColor=GLKVector4Make(1, 1, 1, 1.0f);
    self.exEffect.light0.enabled = YES;
    self.exEffect.light0.ambientColor =GLKVector4Make(1, 1, 1, 1);
    self.exEffect.light0.specularColor=GLKVector4Make(1, 1, 1, 1);
    self.exEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);// 开启漫反射
    self.exEffect.light0.position = GLKVector4Make(0.0f,-1.0f, 0.0f, 1);
    
//    // 使用苹果`GLKit`提供的`GLKBaseEffect`完成着色器工作(顶点/片元)
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mengpi" ofType:@"jpg"];
//
//     //初始化纹理
//    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(1)}; // 纹理坐标原点是左下角,但是图片显示原点应该是左上角
//    _textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//
//    NSLog(@"textureInfo.name: %d", _textureInfo.name);
    
    // 使用苹果`GLKit`提供的`GLKBaseEffect`完成着色器工作(顶点/片元)
    self.baseEffect = [[GLKBaseEffect alloc] init];
//    self.baseEffect.texture2d0.enabled = GL_TRUE;
//    self.baseEffect.texture2d0.name = _textureInfo.name;
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
//    self.baseEffect.texture2d0.enabled = GL_TRUE;
//    self.baseEffect.texture2d0.name = _textureInfo.name;
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
//    self.baseEffect.texture2d0.enabled = GL_TRUE;
//    self.baseEffect.texture2d0.name = _textureInfo.name;
    
    self.baseEffect.light0.enabled = YES; // 开启光照效果
//    self.baseEffect.light0.ambientColor =GLKVector4Make(0.5f, 0.5f, 0.5f, 1);
//    self.baseEffect.light0.specularColor=GLKVector4Make(1.0f, 1.0f, 1.0f, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0);// 开启漫反射
//    self.baseEffect.light0.position = GLKVector4Make(-0.5f,2.0f, -0.5f,1); // 光源位置
    self.baseEffect.light0.position = GLKVector4Make(ROC_X-2000, ROC_Y+2000, ROC_Z+1000, 1);
    
    self.baseEffect.light1.enabled = YES; // 开启光照效果
//    self.baseEffect.light1.ambientColor =GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);
    self.baseEffect.light1.specularColor=GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0);
    self.baseEffect.light1.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0);// 开启漫反射
    self.baseEffect.light1.spotDirection=GLKVector3Make(-1,0,0);
////    self.baseEffect.light1.position = GLKVector4Make(0.5f, -0.0f,0.5f, 1); // 光源位置
    self.baseEffect.light1.position = GLKVector4Make(ROC_X+2000, ROC_Y, ROC_Z-1000, 1);
    
    self.baseEffect.light2.enabled = YES; // 开启光照效果
    self.baseEffect.light2.ambientColor =GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0);
//    self.baseEffect.light2.specularColor=GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0);
//    self.baseEffect.light2.spotDirection=GLKVector3Make(1,0,0);
    self.baseEffect.light2.diffuseColor = GLKVector4Make(1.2f, 1.2f, 1.2f, 1.0);// 开启漫反射
//    self.baseEffect.light1.position = GLKVector4Make(0.5f, -0.0f,0.5f, 1); // 光源位置
    self.baseEffect.light2.position = GLKVector4Make(ROC_X, ROC_Y+1000, ROC_Z+1000, 1);

    //铜
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.212500, 0.127500, 0.054000, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.714000, 0.428400, 0.181440, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.393548, 0.271906, 0.166721, 1.000000);
//    self.baseEffect.material.shininess= 25.600000;
//    银色
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.192250, 0.192250, 0.192250, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.507540, 0.507540, 0.507540, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make( 0.508273, 0.508273, 0.508273, 1.000000);
//    self.baseEffect.material.shininess= 51.200001;
    
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.502250, 0.502250, 0.502250, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.307540, 0.307540, 0.307540, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.308273, 0.308273, 0.308273, 1.000000);
//    self.baseEffect.material.shininess= 51.200001;
    self.baseEffect.material.ambientColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0f);
    self.baseEffect.material.diffuseColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    self.baseEffect.material.specularColor = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);

    // 设置反射强度
    self.baseEffect.material.shininess = 0.5f;

}
-(void)addBackground{
    self.vertices = malloc(sizeof(CCVertex) * kCoordCount);
       
    float width = 12.0;
   // 前面
   self.vertices[0] = (CCVertex){{-width, width, width},  {0, 1}};//前面左上角
   self.vertices[1] = (CCVertex){{-width, -width, width}, {0, 0}};//前面左下角
   self.vertices[2] = (CCVertex){{width, width, width},   {1, 1}};//前面右上角
   
   self.vertices[3] = (CCVertex){{-width, -width, width}, {0, 0}};//前面左下角
   self.vertices[4] = (CCVertex){{width, width, width},   {1, 1}};//前面右上角
   self.vertices[5] = (CCVertex){{width, -width, width},  {1, 0}};//前面右下角
   
   // 上面
   self.vertices[6] = (CCVertex){{width, width, width},    {1, 1}};
   self.vertices[7] = (CCVertex){{-width, width, width},   {0, 1}};
   self.vertices[8] = (CCVertex){{width, width, -width},   {1, 0}};
   self.vertices[9] = (CCVertex){{-width, width, width},   {0, 1}};
   self.vertices[10] = (CCVertex){{width, width, -width},  {1, 0}};
   self.vertices[11] = (CCVertex){{-width, width, -width}, {0, 0}};
   
   // 下面
   self.vertices[12] = (CCVertex){{width, -width, width},    {1, 1}};
   self.vertices[13] = (CCVertex){{-width, -width, width},   {0, 1}};
   self.vertices[14] = (CCVertex){{width, -width, -width},   {1, 0}};
   self.vertices[15] = (CCVertex){{-width, -width, width},   {0, 1}};
   self.vertices[16] = (CCVertex){{width, -width, -width},   {1, 0}};
   self.vertices[17] = (CCVertex){{-width, -width, -width},  {0, 0}};
   
   // 左面
   self.vertices[18] = (CCVertex){{-width, width, width},    {1, 1}};
   self.vertices[19] = (CCVertex){{-width, -width, width},   {0, 1}};
   self.vertices[20] = (CCVertex){{-width, width, -width},   {1, 0}};
   self.vertices[21] = (CCVertex){{-width, -width, width},   {0, 1}};
   self.vertices[22] = (CCVertex){{-width, width, -width},   {1, 0}};
   self.vertices[23] = (CCVertex){{-width, -width, -width},  {0, 0}};
   
   // 右面
   self.vertices[24] = (CCVertex){{width, width, width},    {1, 1}};
   self.vertices[25] = (CCVertex){{width, -width, width},   {0, 1}};
   self.vertices[26] = (CCVertex){{width, width, -width},   {1, 0}};
   self.vertices[27] = (CCVertex){{width, -width, width},   {0, 1}};
   self.vertices[28] = (CCVertex){{width, width, -width},   {1, 0}};
   self.vertices[29] = (CCVertex){{width, -width, -width},  {0, 0}};
   
   // 后面
   self.vertices[30] = (CCVertex){{-width, width, -width},   {0, 1}};
   self.vertices[31] = (CCVertex){{-width, -width, -width},  {0, 0}};
   self.vertices[32] = (CCVertex){{width, width, -width},    {1, 1}};
   self.vertices[33] = (CCVertex){{-width, -width, -width},  {0, 0}};
   self.vertices[34] = (CCVertex){{width, width, -width},    {1, 1}};
   self.vertices[35] = (CCVertex){{width, -width, -width},   {1, 0}};
   
   //开辟缓存区 VBO 顶点缓冲对象(Vertex Buffer Objects)
   //生成一个VBO对象
   glGenBuffers(1, &_vertexBuffer);
   //设置顶点缓冲对象的缓冲类型是GL_ARRAY_BUFFER，将创建的VBO对象绑定到当前的执行程序上，也可以理解为激活
   glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
   GLsizeiptr bufferSizeBytes = sizeof(CCVertex) * kCoordCount;
   //将准备好的顶点数据复制到缓冲的内存中，vertices为顶点数据，GL_STATIC_DRAW表示数据不会改变和几乎不会改变。第三个参数一共有三个选择：GL_STATIC_DRAW 表示数据不会或几乎不会改变、GL_DYNAMIC_DRAW表示数据会被改变很多、GL_STREAM_DRAW 表示数据每次绘制时都会改变。
   glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
   
   //顶点数据
   glEnableVertexAttribArray(GLKVertexAttribPosition);
   glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, positionCoord));
   
   //纹理数据
   glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
   glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, textureCoord));
   
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"3D界面背景B0%ld.jpg",_backgroundID%4 == 0 ? 4 : _backgroundID%4]];
   UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
   
   //6.设置纹理参数
   NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
   GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                              options:options
                                                                error:NULL];
    
    
    //3.使用苹果GLKit 提供GLKBaseEffect 完成着色器工作(顶点/片元)
    _backgroundEffect = [[GLKBaseEffect alloc] init];
    _backgroundEffect.texture2d0.enabled = true;
    _backgroundEffect.texture2d0.name = textureInfo.name;
}
- (void)updateScene{
    // 切帧
    NSLog(@"%@",self.player_name);
    [self setupVertexData];
    self.eyePosition = GLKVector3Make(0,0.3f,4.0f);

    // 调整观察的位置
    self.lookAtPosition = GLKVector3Make(0,
                                         ROC_Y ,
                                         ROC_Z);
    self.upVector = GLKVector3Make(0.0, 1.0, 0.0);
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeLookAt(
                         self.eyePosition.x,
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         self.upVector.x,
                         self.upVector.y,
                         self.upVector.z);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, ROC_X, ROC_Y, ROC_Z);//旋转点0.23f, 0.38f, -0.29f 先平移 再旋转 再平移
    //    //旋转
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, RX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, RY);
    
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, S_XYZ, S_XYZ, S_XYZ);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, -ROC_X, -ROC_Y, -ROC_Z);
    self.baseEffect.transform.modelviewMatrix =modelViewMatrix;
    self.exEffect.transform.modelviewMatrix=GLKMatrix4Translate(modelViewMatrix,ROC_X,self.gl.minfoot_y,ROC_Z/2);
    
    aspect = fabs(self.glkView.bounds.size.width/self.glkView.bounds.size.height);
    GLKMatrix4 orthoMatrix;
    if(self.glkView.bounds.size.width<self.glkView.bounds.size.height){
        orthoMatrix = GLKMatrix4MakeOrtho(-1, 1, -1/aspect, 1/aspect, 0, 5);
    }else{
        orthoMatrix = GLKMatrix4MakeOrtho(-aspect, aspect, -1, 1, 0, 5);
    }
    self.baseEffect.transform.projectionMatrix = orthoMatrix;
    self.exEffect.transform.projectionMatrix = orthoMatrix;
    mvp=GLKMatrix4Multiply(orthoMatrix, modelViewMatrix);
    
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4MakeLookAt(
                         self.eyePosition.x,
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         self.upVector.x,
                         self.upVector.y,
                         self.upVector.z);

    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, 0.0f, 10.0f, 3.0f);
//    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, ROC_X, ROC_Y, ROC_Z);//旋转点0.23f, 0.38f, -0.29f 先平移 再旋转 再平移
    //    //旋转
//    modelViewMatrix2 = GLKMatrix4RotateX(modelViewMatrix2, -RX);
//    modelViewMatrix2 = GLKMatrix4RotateY(modelViewMatrix2, -RY);
//    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, S_XYZ, S_XYZ, S_XYZ);
//    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, -ROC_X, -ROC_Y, -ROC_Z);
    self.backgroundEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),aspect,0.1f, 100.0f);
    self.backgroundEffect.transform.modelviewMatrix = modelViewMatrix2;
    // 重新渲染
    [self.glkView display];
}
#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    // 清除颜色缓冲区、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //背景绘制
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);//开启会覆盖模型
    //(2).绑定顶点缓存区.(明确作用)
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, positionCoord));
    
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, textureCoord));
    [self.backgroundEffect prepareToDraw];

    //3.开始绘制
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);

    glEnable(GL_DEPTH_TEST);
//    glEnable(GL_CULL_FACE);
//    glCullFace(GL_FRONT);
    
    //模型绘制
    glDisable(GL_CULL_FACE);
    glDepthMask(GL_TRUE);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 顶点坐标数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex)/*由于是结构体，所以步长就是结构体大小*/, NULL + offsetof(MyVertex, positionCoodinate));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL+offsetof(MyVertex, normal));
    // 准备绘制
    [self.baseEffect prepareToDraw];

    // 开始绘制
    int start = 0;
    for(int i=0;i<self.gl.faceCount;i++){
        //glDrawArrays(GL_LINE_LOOP, start, [count_array[i] intValue]);
        glDrawArrays(GL_TRIANGLE_FAN, start, self.gl.indices[i]);
        start += self.gl.indices[i];
    }
}
- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
//    if (_bufferID) {
//        glDeleteBuffers(1, &_bufferID);
//        _bufferID = 0;
//
//    }
//    if (_specbackbufferID) {
//        glDeleteBuffers(1, &_specbackbufferID);
//        _specbackbufferID = 0;
//
//    }
}
- (void)cleanup{
   
    if (_bufferID) {
        glDeleteBuffers(1, &_bufferID);
        _bufferID = 0;
    }
}
@end
