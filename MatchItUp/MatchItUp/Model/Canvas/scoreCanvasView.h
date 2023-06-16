//
//  scoreCanvasView.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "scoreTool.h"
#import "SpecificationTool.h"
NS_ASSUME_NONNULL_BEGIN

@protocol scoreCanvasDelegate <NSObject>

- (scoreTool *)chooseNearestScoreToolWithX:(CGPoint)x0;
- (scoreTool *)getHeadPositionTool;

@end

@interface scoreCanvasView : NSObject

@property (nonatomic, weak) UIView *superview;
@property (nonatomic, weak) id<scoreCanvasDelegate> delegate;
- (void)initializeWithScrollView:(UIScrollView *)scrollV andSuperView:(UIView *)superView;
//- (void)drawCanvasWithTool:(scoreTool *)tool;
- (void)drawCanvasWithTool:(SpecificationTool *)tool andIndex:(int) index;
- (void)drawCanvasWithTool:(scoreTool *)tool andvideoH:(float) h andvideoW:(float)w;
@end

NS_ASSUME_NONNULL_END
