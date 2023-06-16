//
//  UIView+Resize.h
//  TinyYOLO-CoreML
//
//  Created by 文昊天 on 2018/12/23.
//  Copyright © 2018年 MachineThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView(Resize)

//x坐标
@property(nonatomic,assign) CGFloat x;
//y坐标
@property(nonatomic,assign) CGFloat y;
//宽度
@property(nonatomic,assign) CGFloat width;
//高度
@property(nonatomic,assign) CGFloat height;
//大小
@property(nonatomic,assign) CGSize size;
//位置
@property(nonatomic,assign) CGPoint origin;
//中心点x
@property(nonatomic,assign) CGFloat centerX;
//中心点y
@property(nonatomic,assign) CGFloat centerY;

@property(nonatomic,assign) CGFloat left;
@property(nonatomic,assign) CGFloat right;
@property(nonatomic,assign) CGFloat top;
@property(nonatomic,assign) CGFloat bottom;

@end


