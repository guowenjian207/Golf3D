//
//  CanvasView_update.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2022/3/8.
//

#import <UIKit/UIKit.h>
#import "Tool.h"

NS_ASSUME_NONNULL_BEGIN

@interface CanvasView_update : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) UIView *superview;
- (void)endAddTool;
- (void)initializeWithScrollView:(UIScrollView *)scrollV andSuperView:(UIView *)superView;
- (void)drawCanvasWithTool:(Tool *)tool;
- (void)deselectCurrentTool;
- (void)enableBtns;
- (void)disableBtns;
@end

@protocol CanvasViewDelegate <NSObject>
- (void)toolArrayAddObj:(Tool *)newTool;
- (void)deleteAllTools;
- (void)toolArrayRemoveObj:(Tool *)tool;
- (BOOL)viewIsLocked;
- (Tool *)chooseNearestToolWithX:(CGPoint)x0;
- (void)mas_makeConstraintsFor:(UIButton *)pencilBtn
                          and:(UIButton *)eraseBtn
                          and:(UIButton *)deleteAllBtn
                          and:(UIButton *)lineBtn
                          and:(UIButton *)redBtn
                          and:(UIButton *)rectBtn
                          and:(UIButton *)yellowBtn
                          and:(UIButton *)angleBtn
                          and:(UIButton *)greenBtn
                          and:(UIButton *)circleBtn
                          and:(UIButton *)blueBtn
                          and:(UIButton *)curveBtn
                          and:(UIButton *)blackBtn;
@optional
- (void)startDraw;
- (void)endDraw;
@end

NS_ASSUME_NONNULL_END
