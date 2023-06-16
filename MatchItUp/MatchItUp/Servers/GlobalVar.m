//
//  GlobalVar.m
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import "GlobalVar.h"
#import "AppDelegate.h"     //解决循环import

@implementation GlobalVar

@synthesize kStatusBarH = _kStatusBarH;
- (CGFloat)kStatusBarH{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kStatusBarH  =[UIApplication sharedApplication].windows[0].windowScene.statusBarManager.statusBarFrame.size.height;
    });
    return _kStatusBarH;
}

SingleM(Instance)

//- (CGFloat)kStatusBarH{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _kStatusBarH  =[UIApplication sharedApplication].windows[0].windowScene.statusBarManager.statusBarFrame.size.height;
//    });
//    return _kStatusBarH;
//}

- (id)init{
    if (self = [super init]){
        //appDelegate
        dispatch_async(dispatch_get_main_queue(), ^{
            _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        });
        //字体
        NSUInteger deviceType = [deviceArr indexOfObject: [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceType"]];
        switch (deviceType) {
            case 0:
                //模拟器
                //break;
            case 1:
                //12 mini
                _kTabbarH = 83;
                _titleFont = [UIFont boldSystemFontOfSize:19];
                _cameraBtnFont = [UIFont systemFontOfSize:14];
                break;
            case 5:
                //SE 2020
                _kTabbarH = 49;
                _titleFont = [UIFont boldSystemFontOfSize:19];
                _cameraBtnFont = [UIFont systemFontOfSize:14];
                break;
            case 2:
            case 3:
            case 6:
            case 7:
                _kTabbarH = 83;
                _titleFont = [UIFont boldSystemFontOfSize:20];
                _cameraBtnFont = [UIFont systemFontOfSize:15];
                break;
                
            default:
                _kTabbarH = 49;
                _titleFont = [UIFont boldSystemFontOfSize:21];
                _cameraBtnFont = [UIFont systemFontOfSize:16];
                break;
        }
        
        //UI
        //_kStatusBarH =
        _kNavigationBarH = 44;

        //路径
        //_libraryDir = [[NSString alloc]initWithFormat:@"%@%@",NSHomeDirectory(),@"/Library"];
        _libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        _documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _video2dLocalDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/video2dLocal/"];
        _video2dServerDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/video2dServer/"];
        _videoFlowDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/videoFlow/"];
        _video3dDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/video3d/"];
        _videoOriDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/videoOri/"];
        _keyFrameDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/keyFrame/"];
        _shotPicDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/shotPic/"];
        _albumDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/album/"];
        _specificationAlbumDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/specificationAlbum/"];
        _specificationDocDir = [[NSString alloc]initWithFormat:@"%@%@",_documentsDir,@"/specificationDocDir/"];
        _golferIconDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/golferIcon/"];
        _screenRecordDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/screenRecord/"];
        _analysisVideoDir=[[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/analysisVideo/"];
        _mriDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/mri/"];
        _favoriteDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/favorite/"];
        _remarkDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/remark/"];
        _scoreDir = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/score/"];
        
        _tmpVideoPath = [[NSString alloc]initWithFormat:@"%@%@",NSTemporaryDirectory(),@"tmpVideo.mp4"];
        _tmpVideoPath2 = [[NSString alloc]initWithFormat:@"%@%@",NSTemporaryDirectory(),@"tmpVideo2.mp4"];
        _tmpVideoPath3 = [[NSString alloc]initWithFormat:@"%@%@",NSTemporaryDirectory(),@"tmpVideo3.mp4"];
        _tmpNewVideoPath = [[NSString alloc]initWithFormat:@"%@%@",NSTemporaryDirectory(),@"newVideo.mp4"];
        _tmpmergeVideoPath = [[NSString alloc]initWithFormat:@"%@%@",NSTemporaryDirectory(),@"tmpmergeVideo.mp4"];
        _usrIconPath = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/icon.jpg"];
        _sqlitePath = [[NSString alloc]initWithFormat:@"%@%@",_libraryDir,@"/MatchItUp.sqlite"];
        
        _processingVideos = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self-> _yoloModelv8n = [[yolov8n alloc]init];
            self ->_golfball = [[best alloc]init];
        });
    }
    return self;
}

- (NSString *)durationGetSecs:(CMTime)duration{
    //NSLog(@"%@",duration);
    int secs = (int)(CMTimeGetSeconds(duration)*100);
    if (secs > 6000){
        return [NSString stringWithFormat:@"%d:%02d:%02d",secs/6000,secs/100%60,secs%100];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d",secs/100,secs%100];
    }
}

@end

