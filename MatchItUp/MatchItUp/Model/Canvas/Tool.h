//
//  Tool.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/1/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DrawTool){
    Line        = 1,       //线
    Rectangle   = 1 << 1,   //矩形
    Angle       = 1 << 2,  //角度
    Curve       = 1 << 3,   //曲线
    Circle      = 1 << 4   //圆
};

NS_ASSUME_NONNULL_BEGIN

@interface Tool : NSObject <NSCoding>

@property (nonatomic, assign) DrawTool tool;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) CAShapeLayer *toolLayer;
@property (nonatomic, strong) UIBezierPath *toolPath;
@property (nonatomic, strong) UILabel *angleLabel;

- (instancetype)initWithLinePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color;
- (instancetype)initWithRectPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color;
- (instancetype)initWithPoints:(NSMutableArray *)pointArray andColor:(UIColor *)color;
- (instancetype)initWithCirclePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andColor:(UIColor *)color;
- (instancetype)initWithAnglePoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andColor:(UIColor *)color;
- (void)updateWithContentSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
