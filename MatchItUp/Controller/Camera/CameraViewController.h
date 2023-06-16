//
//  CameraViewController.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/5.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import "RootTabbarController.h"
//#import "RealtimePlayerViewController.h"
#import "GlobalVar.h"
#import "ZHVideoCapture.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController<ZHVideoCaptureDelegate>

@end

NS_ASSUME_NONNULL_END
