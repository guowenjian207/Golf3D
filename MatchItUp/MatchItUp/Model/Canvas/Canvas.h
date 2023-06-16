//
//  Canvas.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/21.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "AngleTool.h"
#import "GlobalVar.h"

typedef NS_OPTIONS(NSUInteger, DrawTool){
    NoTool      = 0,
    Line        = 1,       //线
    Angle       = 1 << 1,  //角度
    Rectangle   = 1 << 2   //矩形
};

@protocol CanvasDelegate <NSObject>
@optional
-(void)hideToolbox;
- (void)closeCanvas;
@end

NS_ASSUME_NONNULL_BEGIN

@interface Canvas : UIView

@property(nonatomic,weak) id<CanvasDelegate> delegate;
@property(nonatomic,strong) UIView* toolboxView;
@property(nonatomic,strong) UIView* colorView;

- (void)closeToolbox;
- (void)clear;
- (AngleTool *)addAngleTool;

@end

NS_ASSUME_NONNULL_END
