//
//  CountDownView.h
//  timerTest
//
//  Created by ios2chen on 2017/8/22.
//  Copyright © 2017年 Lfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountDownView : UIView
@property (nonatomic, copy) NSString *flag;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) CABasicAnimation *pathAnima;
@property (nonatomic, assign) CAShapeLayer *shapeLayer;

-(void)addAmation;
@end
