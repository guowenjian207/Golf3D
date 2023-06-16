//
//  scoreTool.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface scoreTool : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *frame;
@property (nonatomic, strong) NSNumber *x1;
@property (nonatomic, strong) NSNumber *y1;
@property (nonatomic, strong) NSNumber *x2;
@property (nonatomic, strong) NSNumber *y2;
@property (nonatomic, strong) NSNumber *x3;
@property (nonatomic, strong) NSNumber *y3;
@property (nonatomic, strong) NSNumber *x4;
@property (nonatomic, strong) NSNumber *y4;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, assign) BOOL LRMovable;
@property (nonatomic, assign) BOOL UDMovable;
@property (nonatomic, assign) BOOL Rotatable;
@property (nonatomic, strong) CAShapeLayer *toolLayer;
@property (nonatomic, strong) UIBezierPath *toolPath;
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
+ (instancetype)scoreToolWithDic:(NSDictionary *)dic;
- (void)updateWithContentSize:(CGSize)size;
- (void)updateWithContentSize:(CGSize)size andvideoH:(float) h andvideoW:(float)w;
@end

NS_ASSUME_NONNULL_END
