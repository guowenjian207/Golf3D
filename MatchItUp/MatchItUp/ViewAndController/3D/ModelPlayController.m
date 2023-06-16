//
//  ModelPlayController.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/1.
//

#import "ModelPlayController.h"
#import "GolferModel.h"
#import "ModelPlayView.h"
#import <Masonry/Masonry.h>

typedef struct {
    GLKVector3 positionCoord;   //顶点坐标
    GLKVector2 textureCoord;    //纹理坐标
    GLKVector3 normal;          //法线
} CCVertex;

// 顶点数
static NSInteger const kCoordCount = 36;

@interface ModelPlayController () <GLKViewDelegate,ModelPlayViewDelegate> {
    GLuint _bufferID;
    GLuint _exbufferID;
    GLuint _backbufferID;
    
    float ROC_X,ROC_Y,ROC_Z;
    float RX,RY,RZ;   //旋转
    float PX,PY;      //平移
    float S_XYZ;      //缩放

    long int count;
    
    GLKMatrix4 mvp;
    
    CGFloat aspect;
}
//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) ModelPlayView* mp;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) GLKBaseEffect *backhroundEffect;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
//@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign) NSInteger frame;
@property (nonatomic, assign) NSInteger player_num;
@property (nonatomic, copy)   NSString *player_name;
@property (nonatomic, assign) NSInteger backgroundID;
@property (nonatomic, assign) MyVertex *vetrexs;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) GolferModel* gl;

@property (assign, nonatomic, readwrite) GLKVector3 eyePosition;
@property (assign, nonatomic) GLKVector3 lookAtPosition;
@property (assign, nonatomic) GLKVector3 upVector;

@property (nonatomic, strong) UIPanGestureRecognizer *_panGesture;      //旋转
@property (nonatomic, strong) UIPinchGestureRecognizer *_pinchGesture;  //缩放
@property (nonatomic, strong) UIRotationGestureRecognizer *_rotationGesture; //旋转
@property (nonatomic, assign) BOOL IsPlay;


@property (nonatomic, assign) CCVertex *vertices;
@property (nonatomic, assign) GLuint vertexBuffer;

@end
@implementation ModelPlayController
- (void)dealloc{
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    if (self.vetrexs) {
        free(self.vetrexs);
        self.vetrexs = nil;
    }
    
    if (_bufferID) {
        glDeleteBuffers(1, &_bufferID);
        _bufferID = 0;
        
    }
    if (_backbufferID) {
        glDeleteBuffers(1, &_backbufferID);
        _backbufferID = 0;

    }
    [self.displayLink invalidate];
}
- (void)cleanup{
    
    if (_bufferID) {
        glDeleteBuffers(1, &_bufferID);
        _bufferID = 0;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.player_name == NULL){
        self.player_name =@"dustin_johnson1";
    }
    if(self.gl){
        for(int i=0;i<self.gl.frames;i++){
            if(self.gl.Isframes[i]){
                free(self.gl.allVertex[i].myVertex);
            }
            else{
                continue;
            }
        }
        free(self.gl.allVertex);
        free(self.gl.Isframes);
        free(self.gl.indices);
        self.gl=nil;
    }
    NSLog(@"viewDidLoad!");
    self.gl = [[GolferModel alloc] init:self.player_name];
    ROC_X = self.gl.allVertex[0].myVertex->positionCoodinate.x;
    ROC_Y = self.gl.allVertex[0].myVertex->positionCoodinate.y;
    ROC_Z = self.gl.allVertex[0].myVertex->positionCoodinate.z;
    //[self.gl initgolferModel];
    [self setupConfig];
    [self setupVertexData];
    [self setupTexture];
    [self setupGestures];
    [self addBK];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addDisplayLink];
}
- (void)viewDidAppear:(BOOL)animated{
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self.displayLink invalidate];
}
- (void)viewDidDisAppear:(BOOL)animated{

}
// 手势配置
- (void) setupGestures{
    RX = 0; RY = 0; RZ = 0;
    PX = 0; PY = 0;
    S_XYZ = 2.0;
    self.backgroundID=1;
    mvp=GLKMatrix4Identity;
    self.IsPlay = YES;
    self.view.backgroundColor = [UIColor orangeColor];
    
    self._panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewRotation:)];
    [self.view addGestureRecognizer:self._panGesture];
    
    self._pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(viewZoom:)];
    [self.view addGestureRecognizer:self._pinchGesture];
}
// 配置基本信息
- (void)setupConfig{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 判断是否创建成功
    if (!self.context) {
        NSLog(@"Create ES context failed");
        return;
    }
    
    // 设置当前上下文
    [EAGLContext setCurrentContext:self.context];
    self.view.backgroundColor = [UIColor blackColor];
    // GLKView
    CGRect frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, (self.view.frame.size.width / 4 * 3 + 30 + 40));
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0,[[UIApplication sharedApplication] statusBarFrame].size.height+30,self.view.frame.size.width,self.view.frame.size.width / 4 * 3) context:self.context];
    self.glkView.delegate = self;
    self.glkView.context = self.context;
    
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glDepthRangef(1, 0);
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [self.view addSubview:self.glkView];
    _mp =[[ModelPlayView alloc]initWithFrame:frame];
    _mp.glkView=_glkView;
    _mp.delegate=self;
    _mp.slider.maximumValue=self.gl.frames;
    [self.view addSubview:_mp];
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height+(self.view.frame.size.width / 4 * 3 + 30 + 40), self.view.frame.size.width, (self.view.frame.size.width / 4 * 3 + 30 + 40))];
    backgroundView.backgroundColor= [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"framePlayerBottomView"]];
    [self.view addSubview:backgroundView];
    glClearColor(1.0f, 1.0f,1.0f, 1);
}

// 配置顶点数据
- (void)setupVertexData{
    // 开辟空间
    [self cleanup];
    if(!self.gl.Isframes[self.frame]){
        const char* name = [self.player_name UTF8String];
        NSLog(@"player_name:%s",name);
        [self.gl modelRead4:self.player_name withFrame:self.frame];
        //[self.gl modelRead:self.player_name withFrame:self.frame];
    }
    NSLog(@"%ld",(long)_frame);
    glGenBuffers(1, &_bufferID); // 开辟1个顶点缓冲区，所以传入1
    //NSLog(@"bufferID:%d", _bufferID);
    // 绑定顶点缓冲区
    glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
    // 缓冲区大小
    GLsizeiptr bufferSizeBytes = sizeof(MyVertex) * _gl.pointCount;
    // 将顶点数组的数据copy到顶点缓冲区中(GPU显存中)
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.gl.allVertex[_frame].myVertex, GL_STREAM_DRAW);
     
    // 打开读取通道
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 顶点坐标数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex)/*由于是结构体，所以步长就是结构体大小*/, NULL + offsetof(MyVertex, positionCoodinate));
    
    //顶点颜色
//    glEnableVertexAttribArray(GLKVertexAttribColor);
//    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex)/*由于是结构体，所以步长就是结构体大小*/,NULL + offsetof(MyVertex, colorCoodinate));
    //    光照
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL+offsetof(MyVertex, normal));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex, texture));

}
// 配置纹理
- (void)setupTexture{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mengpi" ofType:@"jpg"];

     //初始化纹理
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(1)}; // 纹理坐标原点是左下角,但是图片显示原点应该是左上角
    _textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];

    NSLog(@"textureInfo.name: %d", _textureInfo.name);
    
    
//    self.exEffect =  [[GLKBaseEffect alloc] init];
//
//    self.exEffect.constantColor=GLKVector4Make(1, 1, 1, 1.0f);
//    self.exEffect.light0.enabled = YES;
//    self.exEffect.light0.ambientColor =GLKVector4Make(1, 1, 1, 1);
//    self.exEffect.light0.specularColor=GLKVector4Make(1, 1, 1, 1);
//    self.exEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);// 开启漫反射
//    self.exEffect.light0.position = GLKVector4Make(0.0f,-1.0f, 0.0f, 1);
    
    
    // 使用苹果`GLKit`提供的`GLKBaseEffect`完成着色器工作(顶点/片元)
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = _textureInfo.name;
    
    self.baseEffect.light0.enabled = YES; // 开启光照效果
    self.baseEffect.light0.ambientColor =GLKVector4Make(0.5f, 0.5f, 0.5f, 1);
    self.baseEffect.light0.specularColor=GLKVector4Make(0.5f, 0.5f, 0.5f, 1);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 1);// 开启漫反射
//    self.baseEffect.light0.position = GLKVector4Make(-0.5f,2.0f, -0.5f,1); // 光源位置
    self.baseEffect.light0.position = GLKVector4Make(ROC_X+100, ROC_Y, ROC_Z-100, 1);
    self.baseEffect.light1.enabled = YES; // 开启光照效果
    self.baseEffect.light1.ambientColor =GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);
    self.baseEffect.light1.specularColor=GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);
    self.baseEffect.light1.diffuseColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);// 开启漫反射
//    self.baseEffect.light1.position = GLKVector4Make(0.5f, -0.0f,0.5f, 1); // 光源位置
    self.baseEffect.light1.position = GLKVector4Make(ROC_X, ROC_Y, ROC_Z+100, 1);
    
    self.baseEffect.light2.enabled = YES; // 开启光照效果
    self.baseEffect.light2.ambientColor =GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);
    self.baseEffect.light2.specularColor=GLKVector4Make(0.5f, 0.5f, 0.5f, 0.5);
    self.baseEffect.light2.diffuseColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.5);// 开启漫反射
//    self.baseEffect.light1.position = GLKVector4Make(0.5f, -0.0f,0.5f, 1); // 光源位置
    self.baseEffect.light2.position = GLKVector4Make(ROC_X-100, ROC_Y, ROC_Z-100, 1);

//    //铜
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.212500, 0.127500, 0.054000, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.714000, 0.428400, 0.181440, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.393548, 0.271906, 0.166721, 1.000000);
//    self.baseEffect.material.shininess= 25.600000;
    //紫罗兰
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.110000, 0.060000, 0.090000, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.430000, 0.470000, 0.540000, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.330000, 0.330000, 0.520000, 1.000000);
//    self.baseEffect.material.shininess= 22.000000;
    //银色
    self.baseEffect.material.ambientColor=GLKVector4Make(0.192250, 0.192250, 0.192250, 1.000000);
    self.baseEffect.material.diffuseColor=GLKVector4Make(0.507540, 0.507540, 0.507540, 1.000000);
    self.baseEffect.material.specularColor=GLKVector4Make( 0.508273, 0.508273, 0.508273, 1.000000);
    self.baseEffect.material.shininess= 51.200001;
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.162250, 0.162250, 0.162250, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.307540, 0.307540, 0.307540, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.308273, 0.308273, 0.308273, 1.000000);
//    self.baseEffect.material.shininess= 51.200001;
    //珍珠
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.250000, 0.207250, 0.207250, 0.922000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(1.000000, 0.829000, 0.829000, 0.922000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.296648, 0.296648, 0.296648, 0.922000);
//    self.baseEffect.material.shininess= 11.264000;
    //黑塑料
//    self.baseEffect.material.ambientColor=GLKVector4Make(0.000000, 0.000000, 0.000000, 1.000000);
//    self.baseEffect.material.diffuseColor=GLKVector4Make( 0.010000, 0.010000, 0.010000, 1.000000);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.500000, 0.500000, 0.500000, 1.000000);
//    self.baseEffect.material.shininess= 32.000000;
    
    
//    self.baseEffect.material.ambientColor=GLKVector4Make( 0.1402, 0.1429 ,0.1429, 1);
//    self.baseEffect.material.diffuseColor=GLKVector4Make(0.5, 0.5, 0.5, 1);
//    self.baseEffect.material.specularColor=GLKVector4Make(0.1959, 0.1959, 0.1959, 1);
//    self.baseEffect.material.shininess= 60;
//
    // 透视投影矩阵
//    CGFloat aspect = fabs(self.glkView.bounds.size.width / self.glkView.bounds.size.height);
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0),aspect,0.2f, 0.5f);
//    self.baseEffect.transform.projectionMatrix = projectionMatrix;
    //正交投影矩阵
//    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-4.0f, 4.0f, -4.0f, 4.0f, -4.0f, 4.0f);
//    self.baseEffect.transform.projectionMatrix = orthoMatrix;
}
// 添加定时器
- (void)addDisplayLink{
    self.frame = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScene)];
    self.displayLink.preferredFramesPerSecond=15;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)addfooler{
    self.vetrexs = malloc(sizeof(MyVertex)* 100);

    float delta = 2.0*M_PI/100;
    float a = 0.5; //水平方向的半径
    float b = a * self.glkView.bounds.size.width / self.glkView.bounds.size.height;
    for (int i = 0; i < 101; i++) {
        GLfloat x = a * cos(delta * i);
        GLfloat y = 0;
        GLfloat z = b * sin(delta * i);
        self.vetrexs[i] = (MyVertex){{x, y, -z}, {0, -1, 0}};;

        printf("%f , %f\n", x, z);
    }
    self.gl.minfoot_y=1.0f;
    glGenBuffers(1, &_exbufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _exbufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(MyVertex)*100, self.vetrexs, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex,positionCoodinate));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex,normal));
}

-(void) addBK{

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
    
   NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"3D界面背景B01.jpg"];
   UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
   
   //6.设置纹理参数
   NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
   GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                              options:options
                                                                error:NULL];
 
   //7.使用baseEffect
   self.effect = [[GLKBaseEffect alloc] init];
   self.effect.texture2d0.name = textureInfo.name;
   self.effect.texture2d0.target = textureInfo.target;
}
// 更新
- (void)updateScene{
    // 切帧
    if(self.IsPlay){
        self.frame = (self.frame+1) % self.gl.frames;
    }
    _mp.slider.value=self.frame;
    NSLog(@"%@",self.player_name);
    [self setupVertexData];
    self.eyePosition = GLKVector3Make(0,0.3f,3.0f );

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
//    self.baseEffect.light0.transform.modelviewMatrix=modelViewMatrix;
//    self.baseEffect.light1.transform.modelviewMatrix=modelViewMatrix;
//    self.exEffect.transform.modelviewMatrix=GLKMatrix4Translate(modelViewMatrix,ROC_X,self.gl.minfoot_y,ROC_Z/2);
    

    
    aspect = fabs(self.glkView.bounds.size.width/self.glkView.bounds.size.height);
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),aspect,0.1f, 100.0f);
//    self.baseEffect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 orthoMatrix;
    if(self.glkView.bounds.size.width<self.glkView.bounds.size.height){
        orthoMatrix = GLKMatrix4MakeOrtho(-1, 1, -1/aspect, 1/aspect, 0, 5);
    }else{
        orthoMatrix = GLKMatrix4MakeOrtho(-aspect, aspect, -1, 1, 0, 5);
    }
    self.baseEffect.transform.projectionMatrix = orthoMatrix;

//    mvp=GLKMatrix4Multiply(orthoMatrix, modelViewMatrix);
    
    self.skyboxEffect.center = self.eyePosition;
    self.skyboxEffect.transform.projectionMatrix =GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f),aspect,0.1f, 20.0f);
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
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
    if(fabsf(RY)>fabsf(RX)){
        modelViewMatrix2 = GLKMatrix4RotateY(modelViewMatrix2, -RY);
    }
//    modelViewMatrix2 = GLKMatrix4Scale(modelViewMatrix2, S_XYZ, S_XYZ, S_XYZ);
//    modelViewMatrix2 = GLKMatrix4Translate(modelViewMatrix2, -ROC_X, -ROC_Y, -ROC_Z);
    self.effect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f),aspect,0.1f, 100.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix2;
    // 重新渲染
    [self.glkView display];
}

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    // 清除颜色缓冲区、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //背景绘制
//    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);//开启会覆盖模型
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, positionCoord));
    
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, textureCoord));
    [self.effect prepareToDraw];
        
        //4.绘图
    glDrawArrays(GL_TRIANGLES, 0,kCoordCount);
//    glBindVertexArrayOES(0);
    
    
    //(2).绑定顶点缓存区.(明确作用)
    glBindBuffer(GL_ARRAY_BUFFER, _backbufferID);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 0);

    //纹理坐标数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 3);
//    glClear(GL_COLOR_BUFFER_BIT);

    //2.准备绘制
//    [self.backhroundEffect prepareToDraw];

    //3.开始绘制
//    glDrawArrays(GL_TRIANGLES, 0, 6);


    //地板绘制

    

    //模型绘制
    
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferID);
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 顶点坐标数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex)/*由于是结构体，所以步长就是结构体大小*/, NULL + offsetof(MyVertex, positionCoodinate));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL+offsetof(MyVertex, normal));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL+offsetof(MyVertex, texture));
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
#pragma mark ModelPlayViewDelegate
-(void)preFrame{
    _frame--;
    _frame%=self.gl.frames;
}
-(void)nextFrame{
    _frame++;
    _frame%=self.gl.frames;
}
-(void)playOrPause{
    if(_IsPlay){
        _IsPlay = NO;
        _mp.playOrPauseBtn.selected = NO;
//        [self.play setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        _IsPlay=YES;
        _mp.playOrPauseBtn.selected = YES;
//        [self.play setTitle:@"暂停" forState:UIControlStateNormal];
    }
}
-(void)changeBackground{
    if(self.backgroundID==0){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3D界面背景B01" ofType:@"jpg"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
        _effect = [[GLKBaseEffect alloc] init];
        _effect.texture2d0.enabled = true;
        _effect.texture2d0.name = textureInfo.name;
        _backgroundID=1;
    }else if(self.backgroundID==1){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3D界面背景B02" ofType:@"jpg"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
        _effect = [[GLKBaseEffect alloc] init];
        _effect.texture2d0.enabled = true;
        _effect.texture2d0.name = textureInfo.name;
        _backgroundID=2;
    }else if(self.backgroundID==2){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3D界面背景B03" ofType:@"jpg"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
        _effect = [[GLKBaseEffect alloc] init];
        _effect.texture2d0.enabled = true;
        _effect.texture2d0.name = textureInfo.name;
        _backgroundID=3;
    }else if(self.backgroundID==3){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"3D界面背景B04" ofType:@"jpg"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
        _effect = [[GLKBaseEffect alloc] init];
        _effect.texture2d0.enabled = true;
        _effect.texture2d0.name = textureInfo.name;
        _backgroundID=0;
    }
}
-(void)rotationModel{
    if(RX!=0||RY!=0){
        RX=0;
        RY=0;
    }else if(RY==-90*M_PI/180&&RX==0){
        RY=0;
    }else if (RX==0&&RY==0){
        RY=-90*M_PI/180;
    }
        
}
-(void)sliderValueChanged:(UISlider *)slider{
    self.frame = (int)slider.value;
}
-(void)changeModel{
    NSString *str1 = @"oc/";
    NSString *str = [[NSBundle mainBundle] pathForResource:[str1 stringByAppendingString: @"all_player"] ofType:@"txt"];
    NSString *connect = [[NSString alloc] initWithContentsOfFile: str encoding:NSUTF8StringEncoding error:nil];
    NSCharacterSet *character = [NSCharacterSet whitespaceCharacterSet];
    NSArray *array = [connect componentsSeparatedByCharactersInSet:character];
    
    self.player_num = (self.player_num + 1) % (array.count - 1);
    
    NSInteger tmp1 = self.player_num - 1;
    if(tmp1 == -1) tmp1 = array.count - 2;
    
    NSString *tempString = (NSString *)array[self.player_num];
    self.player_name = tempString;
    
    self.frame = 0;
    RX = 0; RY = 0; RZ = 0;
    PX = 0; PY = 0;
    S_XYZ = 2;
    if(self.gl){
        for(int i=0;i<self.gl.frames;i++){
            if(self.gl.Isframes[i]){
                free(self.gl.allVertex[i].myVertex);
            }
            else{
                continue;
            }
        }
        free(self.gl.allVertex);
        free(self.gl.Isframes);
        free(self.gl.indices);
        self.gl=nil;
    }
    self.gl = [[GolferModel alloc] init:self.player_name];
    _mp.slider.maximumValue=self.gl.frames;
}
-(void) pushToSetting{
    SpecificationViewController *vc = [[SpecificationViewController alloc] initWithModel:self.gl andBackgroundID:(int)_backgroundID andPlayerName:_player_name];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark Touch
-(void)viewRotation:(UIPanGestureRecognizer *)panGesture{
    if(panGesture.numberOfTouches==1){
        CGPoint transPoint = [panGesture translationInView:self.view];
        float x = transPoint.x/80;
        float y = transPoint.y/80 ;
        RX -=y;
        RY -=x;
        RZ +=0.0;
    }else if(panGesture.numberOfTouches == 3){
        CGPoint transPoint = [panGesture translationInView:self.view];
        float x = transPoint.x/200;
        float y = transPoint.y/200 ;
        PX +=x;
        PY +=-y;
        ROC_X-=x; ROC_Y +=y;
    }
//    [self updateScene];
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
}
-(void)viewZoom:(UIPinchGestureRecognizer *)pinchGesture{
    float scale = pinchGesture.scale;
    
    S_XYZ *= scale;
//    [self updateScene];
    pinchGesture.scale = 1.0;
}

@end
