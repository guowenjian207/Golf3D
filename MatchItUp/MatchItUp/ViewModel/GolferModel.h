//
//  GolferModel.h
//  Opengl-test
//
//  Created by GWJ on 2022/5/16.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef struct {
    GLKVector3 positionCoodinate; // 顶点坐标
    //GLKVector3 colorCoodinate; // 顶点颜色
    GLKVector3 normal;//法线
    GLKVector2 texture;//纹理坐标
} MyVertex;
typedef struct {
   MyVertex *myVertex;
} AllVertex;
@interface GolferModel : NSObject
@property (nonatomic, assign) AllVertex *allVertex;
@property (nonatomic, assign) GLuint *indices;//
@property (nonatomic, assign) NSInteger frames;
@property (nonatomic, assign) bool *Isframes;
@property (nonatomic, assign) NSInteger pointCount;
@property (nonatomic, assign) NSInteger faceCount;
@property (nonatomic, assign) float minfoot_y;

@property (nonatomic, assign) GLKVector4 *headtop;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable headposition;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable lowBodyPosition;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable shaftLine;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable spineTilt;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable leadarmLine;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable shoulderAngle;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable gripEndHeight;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable leadForearmLine;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable feetWidth;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable trailElbowAngle;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable leadElbowAngle;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable trailLegAngle;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable leadLegAngle;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable kneeWidth;

@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable elbowHosel;
@property (nonatomic, assign) GLKVector4 * hipDepth;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable headPositionBeside;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable shaftLineToArmpit;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable handPosition;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable kneeWidthBeside;
@property (nonatomic, assign) GLKVector4 *_Nullable* _Nullable elbowLine;

@property (nonatomic, strong) NSArray *keyFrames;
//-(void) initgolferModel;
-(id) init:(NSString*) path;
-(void) modelRead:(NSString*) modelPath withFrame:(NSInteger) frame;
-(void) modelRead2:(NSString*) modelPath withFrame:(NSInteger) frame;
-(void) modelRead3:(NSString*) modelPath withFrame:(NSInteger) frame;
-(void) modelRead4:(NSString*) modelPath withFrame:(NSInteger) frame;
@end

NS_ASSUME_NONNULL_END
