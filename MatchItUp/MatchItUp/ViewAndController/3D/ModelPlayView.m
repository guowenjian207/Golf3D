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
        
        _topLabel = [[UILabel alloc]init];
        [_topLabel setFont: [UIFont boldSystemFontOfSize:20]];
        [_topLabel setTextAlignment:NSTextAlignmentCenter];
//        _topLabel.text = @"hhhhhhh";
        _topLabel.textColor = [UIColor whiteColor];
        [_topView addSubview:_topLabel];
        
        [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(_topView);
            make.top.equalTo(_topView);
            make.bottom.equalTo(_topView);
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
        
        self.lable1 = [[UILabel alloc]init];
        [self addSubview:_lable1];
        
        [self.lable1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.mas_height).multipliedBy(0.15);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.1);
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self.topView.mas_top).offset(20);
        }];
        
        self.lable2 = [[UILabel alloc]init];
        [self addSubview:_lable2];
        
        [self.lable2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.lable1);
            make.left.equalTo(self.lable1.mas_right).offset(10);
            make.top.equalTo(self.lable1);
        }];
        
        self.lable3 = [[UILabel alloc]init];
        [self addSubview:_lable3];
        
        [self.lable3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.lable1);
            make.left.equalTo(self.lable2.mas_right).offset(10);
            make.top.equalTo(self.lable2);
        }];
        
        self.lable4 = [[UILabel alloc]init];
        [self addSubview:_lable4];
        
        [self.lable4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.lable1);
            make.left.equalTo(self.lable3.mas_right).offset(10);
            make.top.equalTo(self.lable3);
        }];
        
        self.lable5 = [[UILabel alloc]init];
        [self addSubview:_lable5];
        
        [self.lable5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.lable1);
            make.left.equalTo(self.lable4.mas_right).offset(10);
            make.top.equalTo(self.lable4);
        }];
        
        UIColor *linesColor1 = [UIColor colorWithRed:0 green:172  blue:212 alpha:1];
        UIColor *linesColor2 = [UIColor colorWithRed:128 green:0 blue:0 alpha:1];
        UIColor *linesColor3 = [UIColor colorWithRed:0 green:128 blue:0 alpha:1];
        UIColor *linesColor4 = [UIColor colorWithRed:128 green: 0 blue:128 alpha:1];
        UIColor *linesColor5 = [UIColor colorWithRed:1 green: 218.0/255 blue:55.0/255 alpha:1];
        
        [self.lable1 setTextColor:linesColor1];
        [self.lable2 setTextColor:linesColor2];
        [self.lable3 setTextColor:linesColor3];
        [self.lable4 setTextColor:linesColor4];
        [self.lable5 setTextColor:linesColor5];
        
        [self.lable1 setHidden:NO];
        [self.lable2 setHidden:NO];
        [self.lable3 setHidden:NO];
        [self.lable4 setHidden:NO];
        [self.lable5 setHidden:NO];
        
        self.linesSwitch = [[UISwitch alloc]init];
        [self.linesSwitch setOnTintColor:[UIColor greenColor]];
        [self.linesSwitch setThumbTintColor:[UIColor whiteColor]];
        self.linesSwitch.enabled = YES;
        [self.linesSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        [_topView addSubview:self.linesSwitch];
        
        [self.linesSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(30);
            make.right.equalTo(_topView).offset(-23);
            make.top.equalTo(_topView);
        }];
        //slider
        self.slider = [[UISlider alloc] init];
        self.slider.minimumValue = 0;
        self.slider.minimumTrackTintColor =  [UIColor blueColor];
        self.slider.maximumTrackTintColor = [UIColor grayColor];
        self.slider.continuous=YES;
        self.slider.thumbTintColor= [UIColor redColor];

        [self addSubview:_slider];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.mas_width).offset(-60);
                make.centerX.equalTo(self);
                make.height.mas_equalTo(40);
                make.bottom.equalTo(self.bottomView.mas_top);
        }];
        
        UIButton *help = [[UIButton alloc]init];
        [help addTarget:self action:@selector(viewDocumentation) forControlEvents:UIControlEventTouchUpInside];
        [help setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        [_topView addSubview:help];
        
        [help mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(30);
            make.left.equalTo(_topView).offset(10);
            make.top.equalTo(_topView);
        }];
    }
    return self;
}

-(void) switchChanged{
    [self.delegate switchChanged];
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

- (void)viewDocumentation {
    NSLog(@"ssss");
    [self.delegate QLPreviewControllerLoad];
}
@end
