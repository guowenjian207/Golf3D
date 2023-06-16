//
//  protractorView.m
//  TinyYOLO-CoreML
//
//  Created by 文昊天 on 2018/12/23.
//  Copyright © 2018年 MachineThink. All rights reserved.
//

#import "protractorView.h"

@implementation myProtractorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.change_protractor_angle = YES;
        self.move_protractor = NO;
        //NSLog(@"wojiuxiangzhidao zashuishi ");
        UIPanGestureRecognizer *recognizer1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
        [recognizer1 setMinimumNumberOfTouches:1];
        [recognizer1 setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:recognizer1];
        [self.layer addSublayer:self.myProtractorLayer];
    }
    return self;
}

-(myProtractorLayer *)myProtractorLayer {
    if (!_myProtractorLayer)
    {
        _myProtractorLayer = [myProtractorLayer drawProtractorLayer];
    }
    return _myProtractorLayer;
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
//    CGMutablePathRef pathRefOne = CGPathCreateMutable();
//    CGMutablePathRef pathRefTwo = CGPathCreateMutable();
//    CGFloat w = (self.myProtractorLayer.protractor_nop + 2) * 1.5;
//
//    //改变角度的触摸范围
//    CGPathMoveToPoint(pathRefOne, NULL, self.myProtractorLayer.end_angle_position.x - w, self.myProtractorLayer.end_angle_position.y - w);
//    CGPathAddLineToPoint(pathRefOne, NULL, self.myProtractorLayer.end_angle_position.x + w, self.myProtractorLayer.end_angle_position.y - w);
//    CGPathAddLineToPoint(pathRefOne, NULL, self.myProtractorLayer.end_angle_position.x + w, self.myProtractorLayer.end_angle_position.y + w);
//    CGPathAddLineToPoint(pathRefOne, NULL, self.myProtractorLayer.end_angle_position.x - w, self.myProtractorLayer.end_angle_position.y + w);
//    CGPathAddLineToPoint(pathRefOne, NULL, self.myProtractorLayer.end_angle_position.x - w, self.myProtractorLayer.end_angle_position.y - w);
//    CGPathCloseSubpath(pathRefOne);
//
//    //改变量角器位置的触摸范围
//    CGPathMoveToPoint(pathRefTwo, NULL, self.myProtractorLayer.protractor_center.x - w, self.myProtractorLayer.protractor_center.y - w);
//    CGPathAddLineToPoint(pathRefTwo, NULL, self.myProtractorLayer.protractor_center.x + w, self.myProtractorLayer.protractor_center.y - w);
//    CGPathAddLineToPoint(pathRefTwo, NULL, self.myProtractorLayer.protractor_center.x + w, self.myProtractorLayer.protractor_center.y + w);
//    CGPathAddLineToPoint(pathRefTwo, NULL, self.myProtractorLayer.protractor_center.x - w, self.myProtractorLayer.protractor_center.y + w);
//    CGPathAddLineToPoint(pathRefTwo, NULL, self.myProtractorLayer.protractor_center.x - w, self.myProtractorLayer.protractor_center.y - w);
//    CGPathCloseSubpath(pathRefTwo);
//
//    if (CGPathContainsPoint(pathRefOne, NULL, point, NO)) {
//        self.change_protractor_angle = YES;
//        self.move_protractor = NO;
//        self.touch_direct_determined = NO;
//        CGFloat angle = [self.myProtractorLayer point_to_angle:point];
//        self.touch_begin_angle = angle;
//        self.layer_start_angle = radia_to_angle(self.myProtractorLayer.startAngle);
//        self.layer_end_angle = radia_to_angle(self.myProtractorLayer.endAngle);
//
//        if (fabs(self.layer_end_angle - self.layer_start_angle) > 0.00001) {
//            self.touch_direct_determined = YES;
//            //            if (fabs(self.touch_begin_angle - self.layer_start_angle) > fabs(self.layer_end_angle - self.touch_begin_angle)) {
//            //                self.touch_min = NO;
//            //            } else {
//            //                self.touch_min = YES;
//            //            }
//            self.touch_min = NO;
//        }
//        NSLog(@"现在触摸的是第一个点");
//    }
    //    }else if(CGPathContainsPoint(pathRefTwo, NULL, point, NO)){
    //        self.change_protractor_angle = NO;
    //        self.move_protractor = YES;
    //        NSLog(@"现在触摸的是第二个点");
    //    }
    self.touch_begin_point = point;
    
    //
    //    if (self.change_protractor_angle == TRUE) {
    //        self.touch_direct_determined = NO;
    //        CGFloat angle = [self.myProtractorLayer point_to_angle:point];
    //        self.touch_begin_angle = angle;
    //        self.layer_start_angle = radia_to_angle(self.myProtractorLayer.startAngle);
    //        self.layer_end_angle = radia_to_angle(self.myProtractorLayer.endAngle);
    //
    //        if (fabs(self.layer_end_angle - self.layer_start_angle) > 0.00001) {
    //            self.touch_direct_determined = YES;
    ////            if (fabs(self.touch_begin_angle - self.layer_start_angle) > fabs(self.layer_end_angle - self.touch_begin_angle)) {
    ////                self.touch_min = NO;
    ////            } else {
    ////                self.touch_min = YES;
    ////            }
    //            self.touch_min = NO;
    //        }
    //    } else {
    //        self.touch_begin_point = point;
    //    }
    
}


//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    CGPoint movePoint = [[touches anyObject] locationInView:self];
//    CGFloat change_point_x = movePoint.x - self.touch_begin_point.x;
//    CGFloat change_point_y = movePoint.y - self.touch_begin_point.y;
//    if (self.change_protractor_angle) {
//        CGFloat moveAngle = [self.myProtractorLayer point_to_angle:movePoint];
//        CGFloat angle_change = moveAngle - self.touch_begin_angle;
//        if (!self.touch_direct_determined) {
//            self.touch_direct_determined = YES;
//        }
//
//        if (self.touch_min){
//            CGFloat angle_now = angle_change + self.layer_start_angle;
//            CGFloat radia_now = angle_to_radia(angle_now);
//            [self.myProtractorLayer redrawIncludedAngleLineFromAngle:radia_now toAngle:self.myProtractorLayer.endAngle];
//        }else {
//            CGFloat angle_now = angle_change + self.layer_end_angle;
//            CGFloat radia_now = angle_to_radia(angle_now);
//            [self.myProtractorLayer redrawIncludedAngleLineFromAngle:self.myProtractorLayer.startAngle toAngle:radia_now];
//        }
//        //添加控制中心，更改夹角值
//        NSString* angle = self.myProtractorLayer.getAngleFromAngelLayer;
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendAngleFromProtractorLayer" object:angle];
//
//
//    } else if(self.move_protractor) {
//        CGFloat new_point_x = self.frame.origin.x + change_point_x;
//        CGFloat new_point_y = self.frame.origin.y + change_point_y;
//        [self setX: new_point_x];
//        [self setY: new_point_y];
//    }
//}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)pan1 : (UIPanGestureRecognizer *)recognizer{
    //NSLog(@"一根指头");
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate startPan];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate endPan];
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint movePoint = [recognizer translationInView:self];
        CGPoint newLocation = CGPointMake(_touch_begin_point.x+movePoint.x, _touch_begin_point.y+movePoint.y);
        CGFloat moveAngle = [self.myProtractorLayer point_to_angle:newLocation];
        CGFloat angle_change = moveAngle - self.touch_begin_angle;
        if (!self.touch_direct_determined) {
            self.touch_direct_determined = YES;
        }
        
        if (self.touch_min){
            CGFloat angle_now = angle_change + self.layer_start_angle;
            CGFloat radia_now = angle_to_radia(angle_now);
            [self.myProtractorLayer redrawIncludedAngleLineFromAngle:radia_now toAngle:self.myProtractorLayer.endAngle];
        }else {
            CGFloat angle_now = angle_change;
            CGFloat radia_now = angle_to_radia(angle_now);
            [self.myProtractorLayer redrawIncludedAngleLineFromAngle:self.myProtractorLayer.startAngle toAngle:radia_now];
            self.layer_end_angle = angle_now;
        }
        //添加控制中心，更改夹角值
        NSString* angle = self.myProtractorLayer.getAngleFromAngelLayer;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendAngleFromProtractorLayer" object:angle];
    }
}

- (void)pan3 : (UIPanGestureRecognizer *)recognizer{
    NSLog(@"三根指头");
}

@end
