//
//  specificationCanvasView.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SpecificationTool.h"
NS_ASSUME_NONNULL_BEGIN
@protocol specificationCanvasDelegate <NSObject>
- (SpecificationTool *)chooseNearestSpecificationToolWithX:(CGPoint)x0;
- (SpecificationTool *)chooseNearestSpecificationToolWithXInGlk:(CGPoint)x0;
- (SpecificationTool *)getHeadPositionTool;
-(void) updateColorWithTool:(SpecificationTool*)currentTool;
-(BOOL)isContainPoint:(CGPoint) point andIndex:(int) i;
-(void) addSpectificationToolWithTool:(SpecificationTool*) tool andIndex:(int)i;
@end

@interface specificationCanvasView : NSObject
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) UIView *superview;
@property (nonatomic, weak) id delegate;
- (void)deselectCurrentTool;
- (void)initializeWithScrollView:(UIScrollView *)scrollV andSuperView:(UIView *)superView;
- (void)initializeWithUIView:(UIView *)scrollV andSuperView:(UIView *)superView;
-(void)initializeWithColelctionView:(UICollectionView *)scrollV andSuperView:(UICollectionView *)superView;
-(void)initializeChangeWithUIView:(UIView *)scrollV andSuperView:(UIView *)superView;
- (void)drawCanvasWithTool:(SpecificationTool *)tool;
- (void)drawCanvasWithTool:(SpecificationTool *)tool andvideoH:(float) h andvideoW:(float)w;
- (void)drawCanvasWithToolInGlk:(SpecificationTool *)tool;
- (void)drawCanvasSmallWithTool:(SpecificationTool *)tool;
@end

NS_ASSUME_NONNULL_END
