//
//  GolferModel.m
//  Opengl-test
//
//  Created by GWJ on 2022/5/16.
//

#import "GolferModel.h"
#import "../../oc/samples/oc.hpp"
#import "../../oc/samples/oc.hpp"
#include <vector>
#include <iostream>
using namespace std;

@interface GolferModel(){
    
}
@end
@implementation GolferModel
-(instancetype) init:(NSString*) modelPath{
    //读入面
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    const char* destDir = [bundlePath UTF8String];
    const char* player_name = [modelPath UTF8String];
    
    self.frames = getFrameCount(destDir, player_name);
    vector<int> count_array = getBodyCount();

    self.indices = static_cast<GLuint *>(malloc(sizeof(GLuint) * count_array.size()));
    self.faceCount =count_array.size();
    for(int i=0;i<count_array.size();i++){
        self.indices[i] = count_array[i];
    }
    self.linesAngle = [NSMutableArray arrayWithCapacity:self.frames];
    for(int i=0;i<self.frames;i++){
        [self.linesAngle addObject:@""];
    }
    NSLog(@"kaishi");
    //读入顶点

    
    self.allVertex = (AllVertex*)malloc(sizeof(AllVertex)*self.frames);
    self.newVertex = (NewVertex*)malloc(sizeof(LineVertex)*self.frames);
    self.Isframes = static_cast<bool *>(malloc(sizeof(bool)*_frames));
    for(int i=0;i<_frames;i++){
        self.Isframes[i]=NO;
    }
    
    [self initLineDataSpace];
    
    _minfoot_y=10;
    
    vector<int> key_frames = test_key_frames(player_name);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < key_frames.size(); ++i) {
        [result addObject:@(key_frames[i])];
    }
    self.keyFrames = result;

    [self modelRead4:modelPath withFrame:0];
    return self;
}

-(void) initLineDataSpace{
    self.headtop=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
    self.headposition = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.lowBodyPosition = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.shaftLine = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.spineTilt = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.leadarmLine = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.shoulderAngle = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.gripEndHeight = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.leadForearmLine = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.feetWidth = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.trailElbowAngle = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*3);
    self.leadElbowAngle = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*3);
    self.trailLegAngle = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*3);
    self.leadLegAngle = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*3);
    self.kneeWidth = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    
    self.elbowHosel = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.hipDepth = (GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
    self.headPositionBeside = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.shaftLineToArmpit = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    self.handPosition = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.kneeWidthBeside = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*4);
    self.elbowLine = (GLKVector4**)malloc(sizeof(GLKVector4)*_frames*2);
    
    for(int i=0;i<4;i++){
        self.headposition[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.lowBodyPosition[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.feetWidth[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.kneeWidth[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.headPositionBeside[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.handPosition[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.kneeWidthBeside[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
    }
    
    for(int i=0;i<3;i++){
        self.leadElbowAngle[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.trailElbowAngle[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.leadLegAngle[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.trailLegAngle[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
    }
    for(int i=0;i<2;i++){
        self.shaftLine[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.spineTilt[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.leadarmLine[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.shoulderAngle[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.leadForearmLine[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.gripEndHeight[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.elbowHosel[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.shaftLineToArmpit[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        self.elbowLine[i]=(GLKVector4*)malloc(sizeof(GLKVector4)*_frames);
        
    }
    
}

-(void) modelRead:(NSString*) modelPath withFrame:(NSInteger) frame{
    NSString *str1 = [@"player/" stringByAppendingString: modelPath];
    NSString *str2 = [str1 stringByAppendingString:@"/output/"];
    NSString *str = [[NSBundle mainBundle] pathForResource:[str2 stringByAppendingString: [NSString stringWithFormat:@"%ld",(long)frame]]ofType:@"txt"];
    NSString *connect = [[NSString alloc] initWithContentsOfFile: str encoding:NSUTF8StringEncoding error:nil];
    NSCharacterSet *character = [NSCharacterSet whitespaceCharacterSet];
    NSArray *array = [connect componentsSeparatedByCharactersInSet:character];
    NSLog(@"count:%lu",(unsigned long)array.count);
    self.pointCount=(array.count-2)/3;//array里多了一个“”
    self.allVertex[frame].myVertex = (MyVertex*)malloc(sizeof(MyVertex)*_pointCount);
    for(int i= 1,j=0;i<array.count-1;i+=3,j++){
        self.allVertex[frame].myVertex[j].positionCoodinate =GLKVector3Make([array[i] floatValue]/100, [array[i+1] floatValue]/100, -[array[i+2] floatValue]/100);
        if(j< [array[0] intValue]-6636) {
            _minfoot_y=MIN(_minfoot_y, self.allVertex[frame].myVertex[j].positionCoodinate.y);
        }
    }
    //面法向量计算
    GLKVector3 v3;
    for(int j=0,i=0;j<_pointCount&&i<self.faceCount-2;j+=self.indices[i],i++){
        v3=SceneTriangleFaceNormal3(self.allVertex[frame].myVertex[j].positionCoodinate,self.allVertex[frame].myVertex[j+1].positionCoodinate,self.allVertex[frame].myVertex[j+2].positionCoodinate);
        for(int k=0;k<self.indices[i];k++){
            self.allVertex[frame].myVertex[j+k].normal=v3;
        }
    }
    self.Isframes[frame]=YES;
}


-(void) modelRead2:(NSString*) modelPath withFrame:(NSInteger) frame{
    //const char* player_name = [modelPath UTF8String];
    vector<vector<double>> pos = Display(frame);
    self.pointCount=pos.size();//array里多了一个“”
    self.allVertex[frame].myVertex = (MyVertex*)malloc(sizeof(MyVertex)*_pointCount);
    for(int i= 0;i<self.pointCount;i++){
        self.allVertex[frame].myVertex[i].positionCoodinate =GLKVector3Make(pos[i][0] / 100, pos[i][1] / 100, -pos[i][2] / 100);
        if(i<self.pointCount-6636) {
            _minfoot_y=MIN(_minfoot_y,self.allVertex[frame].myVertex[i].positionCoodinate.y);
        }
    }
    //面法向量计算
    GLKVector3 v3;
    for(int j=0,i=0;j<_pointCount&&i<self.faceCount-2;j+=self.indices[i],i++){
        v3=SceneTriangleFaceNormal3(self.allVertex[frame].myVertex[j].positionCoodinate,self.allVertex[frame].myVertex[j+1].positionCoodinate,self.allVertex[frame].myVertex[j+2].positionCoodinate);
        for(int k=0;k<self.indices[i];k++){
            self.allVertex[frame].myVertex[j+k].normal=v3;
        }
    }
    vector<vector<double>>().swap(pos);
    self.Isframes[frame]=YES;
}

-(void) modelRead3:(NSString*) modelPath withFrame:(NSInteger) frame{
    const char* player_name = [modelPath UTF8String];
    for(int frame = 0;frame<self.frames;frame++){
        vector<vector<double>> pos = Display(frame);
        self.pointCount=pos.size();//array里多了一个“”
        self.allVertex[frame].myVertex = (MyVertex*)malloc(sizeof(MyVertex)*_pointCount);
        for(int i= 0;i<self.pointCount;i++){
            self.allVertex[frame].myVertex[i].positionCoodinate =GLKVector3Make(pos[i][0] / 100, pos[i][1] / 100, -pos[i][2] / 100);
            if(i<self.pointCount-6636) {
                _minfoot_y=MIN(_minfoot_y,self.allVertex[frame].myVertex[i].positionCoodinate.y);
            }
        }
        //面法向量计算
        GLKVector3 v3;
        for(int j=0,i=0;j<_pointCount&&i<self.faceCount-2;j+=self.indices[i],i++){
            v3=SceneTriangleFaceNormal3(self.allVertex[frame].myVertex[j].positionCoodinate,self.allVertex[frame].myVertex[j+1].positionCoodinate,self.allVertex[frame].myVertex[j+2].positionCoodinate);
            for(int k=0;k<self.indices[i];k++){
                self.allVertex[frame].myVertex[j+k].normal=v3;
            }
        }
        vector<vector<double>>().swap(pos);
        self.Isframes[frame]=YES;
    }
}
-(void) modelRead4:(NSString*) modelPath withFrame:(NSInteger) frame{
    vector<vector<vector<double>>>  pos = Display2((int)frame);
    self.pointCount=pos[0].size();
    self.allVertex[frame].myVertex = (MyVertex*)malloc(sizeof(MyVertex)*_pointCount);
    
    for(int i= 0;i<self.pointCount;i++){
        self.allVertex[frame].myVertex[i].positionCoodinate =GLKVector3Make(pos[0][i][0] / 100, pos[0][i][1] / 100, -pos[0][i][2] / 100);
        self.allVertex[frame].myVertex[i].normal =GLKVector3Make(pos[1][i][0], pos[1][i][1] , pos[1][i][2] );
        self.allVertex[frame].myVertex[i].texture = GLKVector2Make(pos[2][i][0], pos[2][i][1]);
        if(i<self.pointCount-6636) {
            _minfoot_y=MIN(_minfoot_y,self.allVertex[frame].myVertex[i].positionCoodinate.y);
//            NSLog(@"%f",_minfoot_y);
        }
    }
    vector<vector<vector<double>>>().swap(pos);
    self.Isframes[frame]=YES;
    [self lineReadwithFrame:frame];
}

-(void) lineReadwithFrame:(NSInteger) frame{
    vector<vector<vector<double>>>  pos = front_lines();
    NSInteger lineCount = pos.size();

    for(int j = 0; j < lineCount;j++){
        NSInteger pointCount = pos[j].size();
        for(int i = 0; i < pointCount;i++){
            if(j == 0){
                _headtop[frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 1){
                _headposition[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 2){
                _lowBodyPosition[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 3){
                _spineTilt[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 4){
                _leadarmLine[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 5){
                _shoulderAngle[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 6){
                _shaftLine[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 7){
                _gripEndHeight[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 8){
                _leadForearmLine[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 9){
                _feetWidth[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 10){
                _trailElbowAngle[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 11){
                _leadElbowAngle[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if(j == 12){
                _kneeWidth[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 13){
                _trailLegAngle[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 14){
                _leadLegAngle[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }
        }
    }
    
    pos = beside_lines();
    lineCount = pos.size();
    for(int j = 0; j < lineCount;j++){
        NSInteger pointCount = pos[j].size();
        for(int i = 0; i < pointCount;i++){
            if(j == 0){
                _elbowHosel[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 1){
                _hipDepth[frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 2){
                _headPositionBeside[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 3){
                _shaftLineToArmpit[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 4){
                _handPosition[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 5){
                _kneeWidthBeside[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }else if (j == 6){
                _elbowLine[i][frame]=GLKVector4Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100,1);
            }
        }
    }
    
    pos = new_lines();
    lineCount = pos.size();
    self.newVertex[frame].myVertex = (LineVertex*)malloc(sizeof(MyVertex)*10);
    int index = 0;
    for (int j = 0; j < lineCount; j++) {
        NSInteger pointCount = pos[j].size();
        for(int i = 0; i < pointCount;i++){
            if(j == 0){
                self.newVertex[frame].myVertex[index].colorCoodinate = GLKVector3Make(0, 172, 212);
                self.newVertex[frame].myVertex[index++].positionCoodinate = GLKVector3Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100);
            }else if (j == 1){
                self.newVertex[frame].myVertex[index].colorCoodinate = GLKVector3Make(128,0,0);
                self.newVertex[frame].myVertex[index++].positionCoodinate = GLKVector3Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100);
            }else if (j == 2){
                self.newVertex[frame].myVertex[index].colorCoodinate = GLKVector3Make(0,128,0);
                self.newVertex[frame].myVertex[index++].positionCoodinate = GLKVector3Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100);
            }else if (j == 3){
                self.newVertex[frame].myVertex[index].colorCoodinate = GLKVector3Make(128,0,128);
                self.newVertex[frame].myVertex[index++].positionCoodinate = GLKVector3Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100);
            }else if (j == 4){
                self.newVertex[frame].myVertex[index].colorCoodinate = GLKVector3Make(255.0/255, 218.0/255, 55.0/255);
                self.newVertex[frame].myVertex[index++].positionCoodinate = GLKVector3Make(pos[j][i][0] / 100, pos[j][i][1] / 100, -pos[j][i][2] / 100);
            }
        }
    }
    float a1 = angleBetweenSegmentAndHorizontal2(self.newVertex[frame].myVertex[0].positionCoodinate, self.newVertex[frame].myVertex[1].positionCoodinate);
    float a2 = angleBetweenSegmentAndHorizontal(self.newVertex[frame].myVertex[2].positionCoodinate, self.newVertex[frame].myVertex[3].positionCoodinate);
    float a3 = angleBetweenSegmentAndHorizontal(self.newVertex[frame].myVertex[4].positionCoodinate, self.newVertex[frame].myVertex[5].positionCoodinate);
    float a4 = angleBetweenSegmentAndHorizontal(self.newVertex[frame].myVertex[6].positionCoodinate, self.newVertex[frame].myVertex[7].positionCoodinate);
    float a5 = angleBetweenSegmentAndHorizontal(self.newVertex[frame].myVertex[8].positionCoodinate, self.newVertex[frame].myVertex[9].positionCoodinate);
    NSArray* angles = [NSArray arrayWithObjects:@(a1), @(a2),@(a3),@(a4),@(a5),nil];
    self.linesAngle[frame] = angles;
    vector<vector<vector<double>>>().swap(pos);
}
#pragma mark - 根据顶点求出法向量
GLKVector3 SceneTriangleFaceNormal3(GLKVector3 a,GLKVector3 b,GLKVector3 c)
{
    //vectorA =  b - a
    GLKVector3 vectorA = GLKVector3Subtract(b,a);
    //vectorB =  c - a
    GLKVector3 vectorB = GLKVector3Subtract(c,a);
    //NSLog(@"vextor%f %f %f %f %f %f",vectorA.x,vectorA.y,vectorA.z,vectorB.x,vectorB.y,vectorB.z);
    //通过 向量A和向量B的叉积求出平面法向量，单元化后返回
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

NSArray *NSIntegerVectorToNSArrayOfNSIntegers(const std::vector<NSInteger>& vec) {
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < vec.size(); ++i) {
        [result addObject:@(vec[i])];
    }
    return result;
}

float angleBetweenSegmentAndHorizontal(GLKVector3 p1, GLKVector3 p2) {
    GLKVector3 vector = GLKVector3Make(p1.x-p2.x, p1.y-p2.y, p1.z-p2.z);
    
    float angle = atan(vector.y / sqrt(vector.x * vector.x + vector.z * vector.z));
//    double angleDegrees = angleRadians * (180.0 / M_PI);
//        
//    // 如果向量的z分量小于0，调整角度
//    if (vz < 0) {
//        angleDegrees = 180.0 - angleDegrees;
//    }
    return angle * (180.0 / M_PI);;
}
float angleBetweenSegmentAndHorizontal2(GLKVector3 p1, GLKVector3 p2) {
    GLKVector3 vector = GLKVector3Make(p1.x-p2.x, p1.y-p2.y, p1.z-p2.z);
    float angle ;
//    GLKVector3 vector = GLKVector3Make(p2.x-p1.x, p2.y-p1.y, p2.z-p1.z);
//    float angle = acos(sqrt(vector.x * vector.x + vector.z * vector.z)/ sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z));
    if(p1.x-p2.x>=0){
        angle = acos(sqrt(vector.x * vector.x )/ sqrt(vector.x * vector.x + vector.y * vector.y));
    }else{
        angle = acos(-sqrt(vector.x * vector.x )/ sqrt(vector.x * vector.x + vector.y * vector.y));
    }
//    double angleDegrees = angleRadians * (180.0 / M_PI);
//
//    // 如果向量的z分量小于0，调整角度
//    if (vz < 0) {
//        angleDegrees = 180.0 - angleDegrees;
//    }
    return angle * (180.0 / M_PI);;
}
@end

