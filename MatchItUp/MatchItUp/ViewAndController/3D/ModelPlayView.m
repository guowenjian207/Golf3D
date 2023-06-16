//
//  ModelPlayView.m
//  Opengl-test
//
//  Created by GWJ on 2023/2/27.
//

#import "ModelPlayView.h"
#import <Masonry/Masonry.h>
@interface ModelPlayView ()
@property (nonatomic, strong) UIView *tmpView;
@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIImageView *bottomView;
@property(nonatomic,strong)UIBezierPath *apath;


@end

@implementation ModelPlayView{
    CAShapeLayer *lineLayer;
    UIImageView *sliderThumbImg;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _tmpView = [[UIView alloc] init];
        [self addSubview:_tmpView];
        _tmpView.clipsToBounds = YES;
        _tmpView.backgroundColor = [UIColor blackColor];
        
        _topView = [[UIImageView alloc] init];//WithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
//        _topView.backgroundColor = [UIColor blackColor];
        [_topView setImage:[UIImage imageNamed:@"topView"]];
        _topView.userInteractionEnabled = YES;
        [self addSubview:_topView];
        [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(self);
                    make.height.mas_equalTo(30);
        }];
        
        _glkView = [[GLKView alloc] init];
        [_tmpView addSubview:_glkView];
        
        _bottomView = [[UIImageView alloc] init];
        _bottomView.backgroundColor = [UIColor blackColor];
//        [_bottomView setImage:[UIImage imageNamed:@"framePlayerBottomView"]];
        _bottomView.userInteractionEnabled = YES;
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.width.equalTo(self);
                    make.height.mas_equalTo(40);
                    make.bottom.equalTo(self);
        }];
        //play btns
        self.playOrPauseBtn = [[UIButton alloc] init];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"playFrame"] forState:UIControlStateNormal];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateSelected];
        [self.playOrPauseBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
        self.playOrPauseBtn.selected=YES;
        [self.bottomView addSubview:_playOrPauseBtn];
        self.preBtn = [[UIButton alloc] init];
        
        [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.bottomView);
                make.width.height.mas_equalTo(35);
        }];
        
        [self.preBtn setImage:[UIImage imageNamed:@"leftFrame"] forState:UIControlStateNormal];
        [self.preBtn addTarget:self action:@selector(previousFrame) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_preBtn];
        
        [self.preBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.right.equalTo(_playOrPauseBtn.mas_left).offset(-120);
        }];
        
        self.nextBtn = [[UIButton alloc] init];
        [self.nextBtn setImage:[UIImage imageNamed:@"rightFrame"] forState:UIControlStateNormal];
        [self.nextBtn addTarget:self action:@selector(nextFrame) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_nextBtn];
        
        [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.bottom.equalTo(_playOrPauseBtn);
                make.left.equalTo(_playOrPauseBtn.mas_right).offset(120);
        }];
        
        self.changeModelBtn = [[UIButton alloc] init];
        [self.changeModelBtn setImage:[UIImage imageNamed:@"模型"] forState:UIControlStateNormal];
        [self.changeModelBtn addTarget:self action:@selector(changeModel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeModelBtn];
        
        [self.changeModelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self.topView.mas_bottom).offset(160);
        }];
        
        self.changeBackgroudBtn = [[UIButton alloc] init];
        [self.changeBackgroudBtn setImage:[UIImage imageNamed:@"背景"] forState:UIControlStateNormal];
        [self.changeBackgroudBtn addTarget:self action:@selector(changeBack) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeBackgroudBtn];
        
        [self.changeBackgroudBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self.changeModelBtn.mas_bottom).offset(40);
        }];
        
        self.rotationlBtn = [[UIButton alloc] init];
        [self.rotationlBtn setImage:[UIImage imageNamed:@"旋转"] forState:UIControlStateNormal];
        [self.rotationlBtn addTarget:self action:@selector(rotationModel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rotationlBtn];
        
        [self.rotationlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self.changeBackgroudBtn.mas_bottom).offset(40);
        }];
        
        self.settinglBtn = [[UIButton alloc] init];
        [self.settinglBtn setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
        [self.settinglBtn addTarget:self action:@selector(pushToSetting) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_settinglBtn];
        
        [self.settinglBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.08);
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self.topView.mas_bottom).offset(268);
        }];
        
        //slider
        self.slider = [[UISlider alloc] init];
        self.slider.minimumValue = 0;
        self.slider.minimumTrackTintColor =  [UIColor blueColor];
        self.slider.maximumTrackTintColor = [UIColor grayColor];
        self.slider.continuous=YES;
        self.slider.thumbTintColor= [UIColor redColor];
//        UIFont *font = [UIFont boldSystemFontOfSize:15];
//        UIImage *image = [UIImage imageNamed:@"sliderThumb"];
//        UIGraphicsBeginImageContext(CGSizeMake(40, 60));
//        [image drawInRect:CGRectMake(0,20,20,20)];
//        CGRect rect = CGRectMake(0, 0, 40, 10);
//        [[UIColor whiteColor] set];
//        [@"  0.0s" drawInRect:CGRectIntegral(rect) withFont:font];
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
//        [self.slider setThumbImage:newImage forState:UIControlStateNormal];
        [self addSubview:_slider];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.mas_width).offset(-60);
                make.centerX.equalTo(self);
                make.height.mas_equalTo(40);
                make.bottom.equalTo(self.bottomView.mas_top);
        }];
    }
    return self;
}

-(void) previousFrame{
    [self.delegate preFrame];
}
-(void) nextFrame{
    [self.delegate nextFrame];
}
-(void) playOrPause{
    [self.delegate playOrPause];
}
-(void) sliderValueChanged:(UISlider*) slider{
    [self.delegate sliderValueChanged:slider];
}
-(void) changeModel{
    [self.delegate changeModel];
}
-(void) changeBack{
    [self.delegate changeBackground];
}
-(void) rotationModel{
    [self.delegate rotationModel];
}

-(void) pushToSetting{
    [self.delegate pushToSetting];
}

- (void)drawLine2with:(CGPoint)point
{
    _apath = [[UIBezierPath alloc] init];
    if(lineLayer){
        [lineLayer removeFromSuperlayer];
    }
    [_apath moveToPoint:CGPointMake(point.x-500, point.y)];
    [_apath addLineToPoint:CGPointMake(point.x+500, point.y)];
    lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 2;
    lineLayer.strokeColor = [UIColor greenColor].CGColor;
    lineLayer.path = _apath.CGPath;
    [self.glkView.layer addSublayer:lineLayer];
    
}
@end
