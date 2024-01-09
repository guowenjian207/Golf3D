//
//  HumanBodyPoseDetector.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/6.
//

#import "HumanBodyPoseDetector.h"
#import "GlobalVar.h"

@implementation HumanBodyPoseDetector{
    dispatch_queue_t highQueue;
    int countPrepare;
    int countTallest;
    int countLowest;
    int countEnd;
    NSDate *tallTime;
    NSDate *lowTime;
    NSDate *endTime;
    BOOL flag_start; // 标志是否已经开始录制
    NSTimer *timer; // 定时器
    NSRunLoop *currentRunLoop;
    NSNotification *disableNoti;
    NSNotification *enableNoti;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        highQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
        _currentStage = Prepare;
        countPrepare = 0;
        countTallest = 0;
        countLowest = 0;
        countEnd = 0;
        flag_start = 0;
        currentRunLoop = [NSRunLoop currentRunLoop];
        disableNoti = [NSNotification notificationWithName:@"hideRecordingDurationBtn" object:nil];
        enableNoti = [NSNotification notificationWithName:@"unhideRecordingDurationBtn" object:nil];
    }
    return self;
}

- (void)predict:(CMSampleBufferRef)sampleBuffer isAutoRecord:(BOOL)isAuto{
    __block VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCMSampleBuffer:sampleBuffer orientation:kCGImagePropertyOrientationUp options:@{}];
    __block VNDetectHumanBodyPoseRequest *humanBodyPoseRequest = [[VNDetectHumanBodyPoseRequest alloc]init];
    __block NSError *err;
    if(isAuto&&timer==nil){
        timer = [NSTimer timerWithTimeInterval:[GlobalVar sharedInstance].recordingDuration target:self selector:@selector(endAutoRecordByTime) userInfo:nil repeats:YES];
        [currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
        [_delegate autoRecordBegin];
    }
    dispatch_async(highQueue, ^(void){

        [handler performRequests:@[humanBodyPoseRequest] error:&err];
        if (err != nil){
            NSLog(@"人体姿态估计失败:%@",err.localizedDescription);
            handler = nil;
            humanBodyPoseRequest = nil;
            err = nil;
            if ([self->_delegate respondsToSelector:@selector(hidePersonView)]){
                [self->_delegate hidePersonView];
            }
            return;
        }

        //选择置信度最高的人
        VNConfidence confidence = 0.0;
        VNHumanBodyPoseObservation *bestObservation;
        for (VNHumanBodyPoseObservation *observation in humanBodyPoseRequest.results){
            if (observation.confidence > confidence){
                confidence = observation.confidence;
                bestObservation = observation;
            }
        }
        
        //检测到了人
        if (confidence > 0.0){
            double X[13] = {0};
            double Y[13] = {0};
            
            //是否判断关键帧
            BOOL flag = true;
            VNRecognizedPoint *point;
            
            //鼻子
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameNose error:&err];
            if (err == nil && point.confidence > 0.1){
                double x = point.x;
                double y = 1-point.y;
            }else if (err != nil){
                NSLog(@"鼻子出错了%@",err.localizedDescription);
                err = nil;
            }
            
            //脖子
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameNeck error:&err];
            if (err == nil && point.confidence > 0.1){
                X[0] = point.x;
                Y[0] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"脖子出错了%@",err.localizedDescription);
                   err = nil;
                }
                flag = NO;
            }
            
            //右脚踝
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightAnkle error:&err];
            if (err == nil && point.confidence > 0.1){
                X[11] = point.x;
                Y[11] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右脚踝出错了%@",err.localizedDescription);
                   err = nil;
                }
                flag = NO;
            }
            
            //左脚踝
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftAnkle error:&err];
            if (err == nil && point.confidence > 0.1){
                X[12] = point.x;
                Y[12] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左脚踝出错了%@",err.localizedDescription);
                   err = nil;
                }
                flag = NO;
            }
            
            
//            if (count>2){
//                //至少3个才能确定boundingbox
//                CGRect rect = CGRectMake(minX, minY, maxX, maxY);
//                if ([self->_delegate respondsToSelector:@selector(getPersonViewRect:)]){
//                    [self->_delegate getPersonViewRect:rect];
//                }
//            }else{
//                if ([self->_delegate respondsToSelector:@selector(hidePersonView)]){
//                    [self->_delegate hidePersonView];
//                }
//            }
            
            if (flag == NO || isAuto==NO){
                //缺一个就直接停止判断或者没有自动录制
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //右肩
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightShoulder error:&err];
            if (err == nil && point.confidence > 0.1){
                X[1] = point.x;
                Y[1] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右肩出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //左肩
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftShoulder error:&err];
            if (err == nil && point.confidence > 0.1){
                X[2] = point.x;
                Y[2] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左肩出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //右肘
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightElbow error:&err];
            if (err == nil && point.confidence > 0.1){
                X[3] = point.x;
                Y[3] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右肘出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //左肘
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftElbow error:&err];
            if (err == nil && point.confidence > 0.1){
                X[4] = point.x;
                Y[4] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左肘出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //右手腕
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightWrist error:&err];
            if (err == nil && point.confidence > 0.1){
                X[5] = point.x;
                Y[5] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右手腕出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //左手腕
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftWrist error:&err];
            if (err == nil && point.confidence > 0.1){
                X[6] = point.x;
                Y[6] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左手腕出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //右臀
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightHip error:&err];
            if (err == nil && point.confidence > 0.1){
                X[7] = point.x;
                Y[7] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右臀出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //左臀
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftHip error:&err];
            if (err == nil && point.confidence > 0.1){
                X[8] = point.x;
                Y[8] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左臀出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //右膝盖
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameRightKnee error:&err];
            if (err == nil && point.confidence > 0.1){
                X[9] = point.x;
                Y[9] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"右膝盖出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            
            //左膝盖
            point = [bestObservation recognizedPointForKey:VNHumanBodyPoseObservationJointNameLeftKnee error:&err];
            if (err == nil && point.confidence > 0.1){
                X[10] = point.x;
                Y[10] = 1-point.y;
            }else{
                if (err != nil){
                   NSLog(@"左膝盖出错了%@",err.localizedDescription);
                }
                handler = nil;
                humanBodyPoseRequest = nil;
                err = nil;
                return;
            }
            //自动录制
            [self detectActionWithX:X Y:Y];
        }else{
            //没检测到人
            if (self->flag_start) {
                NSLog(@"没有检测到人");
                self->flag_start = 0;
//                [self endAutoRecord];
            }
            handler = nil;
            humanBodyPoseRequest = nil;
            err = nil;
            if ([self->_delegate respondsToSelector:@selector(hidePersonView)]){
                [self->_delegate hidePersonView];
            }
        }
    });
}

- (void)endAutoRecordByTime {
    NSLog(@"一段结束");

    [_delegate autoRecordEndByTime];
}
- (void)endAutoRecord {
    //销毁定时器
    NSLog(@"销毁定时器");
    [timer invalidate];
    timer = nil;
    _currentStage = DoNoting;
    NSLog(@"结束");
    endTime = [NSDate now];
    NSTimeInterval interval = [endTime timeIntervalSinceDate:lowTime];
    NSLog(@"interval %f", interval);
    [_delegate autoRecordFinishedWith:interval];
    [[NSNotificationCenter defaultCenter] postNotification:enableNoti];
}
- (void)cancelAutoRecord{
    //销毁定时器
    NSLog(@"销毁定时器");
    [timer invalidate];
    timer = nil;
    _currentStage = DoNoting;
    NSLog(@"结束");
    endTime = [NSDate now];
    NSTimeInterval interval = [endTime timeIntervalSinceDate:lowTime];
    NSLog(@"interval %f", interval);
}
- (void)detectionInitialize{
    //NSLog(@"我是%@",_isFront?@"向前":@"向后");
    _currentStage = Prepare;
    countPrepare = 0;
    countTallest = 0;
    countEnd = 0;
}

- (void) detectActionWithX:(double *)X Y:(double *)Y{
    //NSLog(@"我来了");
    double height = (Y[12]+Y[11])/2 - Y[0];
    if (height<=0){
        NSLog(@"人不正常");
        return;
    }
    double centerX = ((X[11] + X[12]) / 2 + X[0]) / 2;
    double centerY = ((Y[11] + Y[12]) / 2 + Y[0]) / 2;
//    if (_isFront ? [self isFrontCompleteWithX:X Y:Y height:height centerX:centerX centerY:centerY] : [self isRightCompleteWithX:X Y:Y height:height centerX:centerX centerY:centerY]){
//       countEnd++;
//       if (countEnd>4){
//           [self endAutoRecord];
//       }
//    }else{
//       countEnd=0;
//    }
    switch (_currentStage) {
        case Prepare:
            if (_isFront ? [self isFrontPrepareWithX:X Y:Y height:height centerX:centerX centerY:centerY] : [self isRightPrepareWithX:X Y:Y height:height centerX:centerX centerY:centerY]){
                countPrepare++;
                [_delegate autoRecordReady];
                if (countPrepare>8){
                    _currentStage = Tallest;
                    //开始录制
                    NSLog(@"开始计时");
//                    timer = [NSTimer timerWithTimeInterval:[GlobalVar sharedInstance].recordingDuration target:self selector:@selector(endAutoRecord) userInfo:nil repeats:YES];
//                    [currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
                    [[NSNotificationCenter defaultCenter] postNotification:disableNoti];
                    flag_start = 1;
//                    [_delegate autoRecordBegin];
                }
            }else{
                [_delegate autoRecordNotReady];
                countPrepare=0;
            }
            break;
        case Tallest:
            if (_isFront ? [self isFrontTallestWithX:X Y:Y height:height centerX:centerX centerY:centerY] : [self isRightTallestWithX:X Y:Y height:height centerX:centerX centerY:centerY]){
                countTallest++;
                if (countTallest>3){
                    _currentStage = Lowest;
                    //下一阶段
                    NSLog(@"最高啦");
                    tallTime = [NSDate now];
                }
            }else{
                countTallest=0;
            }
            break;
        case Lowest:
            if (_isFront ? [self isFrontLowestWithX:X Y:Y height:height centerX:centerX centerY:centerY] : [self isRightLowestWithX:X Y:Y height:height centerX:centerX centerY:centerY]){
                countLowest++;
                if (countLowest>0){
                    _currentStage = End;
                    //下一阶段
                    NSLog(@"最低啦");
                    lowTime = [NSDate now];
                }
            }else{
                countLowest=0;
            }
            break;
        case End:
            if (_isFront ? [self isFrontCompleteWithX:X Y:Y height:height centerX:centerX centerY:centerY] : [self isRightCompleteWithX:X Y:Y height:height centerX:centerX centerY:centerY]){
                countEnd++;
                if (countEnd>4){
                    [self endAutoRecord];
                }
            }else{
                countEnd=0;
            }
            break;
        default:
            break;
    }
}

- (BOOL)isFrontPrepareWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_front_prepare[i], 2) / dX_front_prepare[i];
        double sY = pow((Y[i] - centerY) / height - meansY_front_prepare[i], 2) / dY_front_prepare[i];
        if (i==5 || i==6){
            score += (sX*5 + sY*3);
        }else{
            score += (sX + sY);
        }
    }
    BOOL flag = X[5] > X[7] && Y[5] > Y[7];
    return (score < 300 && flag) ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isFrontTallestWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_front_tallest[i], 2) / dX_front_tallest[i];
        double sY = pow((Y[i] - centerY) / height - meansY_front_tallest[i], 2) / dY_front_tallest[i];
        if (i==5 || i==6){
            score += (sX*5 + sY*2);
        }else{
            score += (sX + sY);
        }
    }
    return score < 90 ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isFrontLowestWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
//    double score = 0.0;
//    for (int i=0; i<13; ++i) {
//        double sX = pow((X[i] - centerX) / height - meansX_front_lowest[i], 2) / dX_front_lowest[i];
//        double sY = pow((Y[i] - centerY) / height - meansY_front_lowest[i], 2) / dY_front_lowest[i];
//        if (i==5 || i==6){
//            score += (sX*5 + sY*3);
//        }else{
//            score += (sX + sY);
//        }
//    }
//    NSLog(@"lowest score : %f", score);
    BOOL flag = X[5] > X[7] && Y[5] > Y[7];
    NSLog(@"%f %f %f %f", X[5], X[7], Y[5], X[7]);
    return flag ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isFrontCompleteWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_front_complete[i], 2) / dX_front_complete[i];
        double sY = pow((Y[i] - centerY) / height - meansY_front_complete[i], 2) / dY_front_complete[i];
        if (i==5 || i==6){
            score += (sX*5 + sY*3);
        }else{
            score += (sX + sY);
        }
    }
    return score < 200 ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isRightPrepareWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_right_prepare[i], 2) / dX_right_prepare[i];
        double sY = pow((Y[i] - centerY) / height - meansY_right_prepare[i], 2) / dY_right_prepare[i];
        if (i==5 || i==6){
            score += (sX/2 + sY*3);
        }else{
            score += (sX + sY);
        }
    }
    NSLog(@"%f",score);
    NSLog(@"双手%f", pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2));
    BOOL flag = X[5] > X[7]*0.9 && Y[5] > Y[7];
    //NSLog(@"%f %f %f %f", X[5], X[7], Y[5], Y[7]);
    return (score < 1100 && flag) ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isRightTallestWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_right_tallest[i], 2) / dX_right_tallest[i];
        double sY = pow((Y[i] - centerY) / height - meansY_right_tallest[i], 2) / dY_right_tallest[i];
        if (i==5 || i==6){
            score += (sX*5 + sY*3);
        }else{
            score += (sX + sY);
        }
    }
    NSLog(@"双手%f", pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2));
    return score < 700 ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isRightLowestWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
//    double score = 0.0;
//    for (int i=0; i<13; ++i) {
//        double sX = pow((X[i] - centerX) / height - meansX_right_lowest[i], 2) / dX_right_lowest[i];
//        double sY = pow((Y[i] - centerY) / height - meansY_right_lowest[i], 2) / dY_right_lowest[i];
//        if (i==5 || i==6){
//            score += (sX*5 + sY*3);
//        }else{
//            score += (sX + sY);
//        }
//    }
//    NSLog(@"lowest score : %f", score);
    NSLog(@"%f %f %f", X[5], X[7], X[5] - X[7]);
    NSLog(@"%f %f %f", Y[5], Y[7], Y[5] - Y[7]);
//    NSLog(@"%d =+++= %d %f", (X[5] > X[7]), (Y[5]-Y[7]>0.0), Y[5]-Y[7]);
    BOOL flag = ((X[5] > X[7]) && (Y[5] > Y[7] * 0.95));
    NSLog(@"%f %f %f %f", X[5], X[7], Y[5], Y[7]);
//    NSLog(@"%d -- %f", flag, pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2));
    return flag ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

- (BOOL)isRightCompleteWithX:(double *)X Y:(double *)Y height:(double)height centerX:(double)centerX centerY:(double)centerY{
    double score = 0.0;
    for (int i=0; i<13; ++i) {
        double sX = pow((X[i] - centerX) / height - meansX_right_complete[i], 2) / dX_right_complete[i];
        double sY = pow((Y[i] - centerY) / height - meansY_right_complete[i], 2) / dY_right_complete[i];
        if (i==5 || i==6){
            score += (sX*5 + sY*3);
        }else{
            score += (sX + sY);
        }
    }
    return score < 400 ? (pow(X[5] - X[6], 2) + pow(Y[5] - Y[6], 2) < 0.02) : NO;
}

@end
