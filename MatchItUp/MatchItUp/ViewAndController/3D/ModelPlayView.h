//
//  ModelPlayView.h
//  Opengl-test
//
//  Created by GWJ on 2023/2/27.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MyKeyFrameSlider.h"
NS_ASSUME_NONNULL_BEGIN

@interface ModelPlayView : UIView

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIButton *changeModelBtn;
@property (nonatomic, strong) UIButton *changeBackgroudBtn;
@property (nonatomic, strong) UIButton *rotationlBtn;
@property (nonatomic, strong) UIButton *settinglBtn;

@property (nonatomic, strong) UISwitch *linesSwitch;
@property (nonatomic, strong) UILabel *lable1;
@property (nonatomic, strong) UILabel *lable2;
@property (nonatomic, strong) UILabel *lable3;
@property (nonatomic, strong) UILabel *lable4;
@property (nonatomic, strong) UILabel *lable5;

@property (nonatomic,strong)  UILabel *topLabel;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)drawLine2with:(CGPoint)point;

@end
@protocol ModelPlayViewDelegate <NSObject>
-(void)switchChanged;
-(void)preFrame;
-(void)nextFrame;
-(void)playOrPause;
-(void)sliderValueChanged:(UISlider*)slider;
-(void)changeModel;
-(void)changeBackground;
-(void)rotationModel;
-(void)pushToSetting;
-(void)QLPreviewControllerLoad;
@end

NS_ASSUME_NONNULL_END
