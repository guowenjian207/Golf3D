//
//  SpecificationTool.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpecificationTool : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSNumber *frame;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSNumber *corresFrame;
@property (nonatomic, strong) NSNumber *x1;
@property (nonatomic, strong) NSNumber *y1;
@property (nonatomic, strong) NSNumber *x2;
@property (nonatomic, strong) NSNumber *y2;
@property (nonatomic, strong) NSNumber *x3;
@property (nonatomic, strong) NSNumber *y3;
@property (nonatomic, strong) NSNumber *x4;
@property (nonatomic, strong) NSNumber *y4;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL LRMovable;
@property (nonatomic, assign) BOOL UDMovable;
@property (nonatomic, assign) BOOL Rotatable;
@property (nonatomic, strong) CAShapeLayer *toolLayer;
@property (nonatomic, strong) CAShapeLayer *rulerLayer;
@property (nonatomic, strong) CAShapeLayer *lastLayer;//单图绘制图层
@property (nonatomic, strong) UIBezierPath *toolPath;
@property (nonatomic, strong) UIBezierPath *rulerToolPath;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *angleLabel1;
@property (nonatomic, strong) UILabel *angleLabel2;
@property (nonatomic, assign) BOOL hasAdjust;
@property (nonatomic, assign) BOOL isSubItem;
@property (nonatomic, assign) BOOL isTemplate;
@property (nonatomic, strong) NSNumber *fatherID;
@property (nonatomic, strong) NSNumber *fatherFrame;
@property (nonatomic, strong) UIColor *adjustColor;
@property (nonatomic, assign) BOOL isForDisplay;

+ (instancetype)specificationToolWithDic:(NSDictionary *)dic;

-(instancetype)intiLineWithPointA:(CGPoint)point;
-(instancetype)intiHeadPositionWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC;
-(instancetype)intiHeadFrameWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
-(instancetype)intiLowBodyPositionWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andPointC:(CGPoint)pointC andPointD:(CGPoint)pointD;
-(instancetype)intiLeadElbowAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC;
-(instancetype)intiTrailElbowAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC;
-(instancetype)intiTrailLegAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC;
-(instancetype)intiLeadLegAngleWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB andandPointC:(CGPoint)pointC;
-(instancetype)intiShoulderTiltWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
-(instancetype)intiLeadForearmLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
-(instancetype)intiShaftLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;

-(instancetype)intiHipDepthWithPointA:(CGPoint)point;
-(instancetype)intiKneeGapsWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
-(instancetype)intiElbowHoselLineWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
-(instancetype)intiShaftLineToArmpitWithPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;

- (void)updateWithContentSize:(CGSize)size;
- (void)updateInCopyWithContentSize:(CGSize)size;
- (void)updateWithContentSize:(CGSize)size andIndex:(int) index;
@end

NS_ASSUME_NONNULL_END
