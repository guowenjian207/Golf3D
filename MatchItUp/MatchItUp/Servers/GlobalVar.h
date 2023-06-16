//
//  GlobalVar.h
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SharedInstance.h"
#import "yolov8n.h"
#import "best.h"

#define kScreenH UIScreen.mainScreen.bounds.size.height
#define kScreenW UIScreen.mainScreen.bounds.size.width
#define deviceArr @[@"iPhone Simulator",@"iPhone 12 mini",@"iPhone 12",@"iPhone 12 Pro",@"iPhone 12 Pro Max",@"iPhone SE 2020",@"iPhone 11",@"iPhone 11 Pro",@"iPhone 11 Pro Max",@"iPhone XR"]

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate;     //解决循环import

@interface GlobalVar : NSObject

@property(nonatomic, weak) UIWindow *appWindow;

//路径 文件夹
@property(readonly) NSString *libraryDir;
@property(readonly) NSString *documentsDir;
@property(readonly) NSString *video2dLocalDir;
@property(readonly) NSString *video2dServerDir;
@property(readonly) NSString *video3dDir;
@property(readonly) NSString *videoFlowDir;
@property(readonly) NSString *videoOriDir;
@property(readonly) NSString *keyFrameDir;
@property(readonly) NSString *albumDir;
@property(readonly) NSString *specificationAlbumDir;
@property(readonly) NSString *specificationDocDir;
@property(readonly) NSString *shotPicDir;
@property(readonly) NSString *golferIconDir;
@property(readonly) NSString *screenRecordDir;
@property(readonly) NSString *analysisVideoDir;
@property(readonly) NSString *mriDir;
@property(readonly) NSString *favoriteDir; // 收藏夹
@property(readonly) NSString *remarkDir; // 注释
@property(readonly) NSString *scoreDir; // 分数
//路径 文件
@property(readonly) NSString *tmpVideoPath;
@property(readonly) NSString *tmpVideoPath2;
@property(readonly) NSString *tmpVideoPath3;
@property(readonly) NSString *tmpNewVideoPath;
@property(readonly) NSString *tmpmergeVideoPath;
@property(readonly) NSString *usrIconPath;
@property(readonly) NSString *sqlitePath;

//字体
@property(nonatomic,readonly) UIFont *titleFont;
@property(nonatomic,readonly) UIFont *cameraBtnFont;

//UI
@property(nonatomic,readonly) CGFloat kStatusBarH;
@property(nonatomic,readonly) CGFloat kNavigationBarH;
@property(nonatomic,readonly) CGFloat kTabbarH;

@property(nonatomic,readonly) AppDelegate *appDelegate;

//posevideo
@property(nonatomic, strong) NSMutableArray<NSString*> *processingVideos;

//yolo模型
@property(nonatomic, strong) yolov8n *yoloModelv8n;
@property(nonatomic, strong) best *golfball;

//+ (GlobalVar *)sharedInstance;
SingleH(Instance)

- (NSString *)durationGetSecs:(CMTime)duration;

//自动录制最大时长
@property (nonatomic, assign) int recordingDuration;

@end

NS_ASSUME_NONNULL_END
