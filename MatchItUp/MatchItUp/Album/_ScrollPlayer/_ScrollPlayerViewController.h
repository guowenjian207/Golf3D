//
//  _ScrollPlayerViewController.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/18.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"
#import "Swing+CoreDataClass.h"
#import "Video+CoreDataClass.h"
#import "ScreenRecord+CoreDataClass.h"
#import "PhotosVideo.h"
#import "Canvas.h"
#import "ZHDoubleSlider.h"
#import "ZHFileManager.h"
#import "ZHScreenRecordManager.h"

typedef NS_OPTIONS(NSUInteger, VideoSource){
    uploadedAlbum = 1,
    appAlbum      = 1<<1,
    systemAlbum   = 1<<2,
    screenRecordAlbum = 1<<3
};

NS_ASSUME_NONNULL_BEGIN

@interface _ScrollPlayerViewController : UIViewController<UIScrollViewDelegate,CanvasDelegate>

@property(nonatomic,assign) VideoSource videoSource;
@property(nonatomic,strong) NSMutableArray<Video *> *videoArr;
@property(nonatomic,strong) NSMutableArray<PhotosVideo *> *photosVideoArr;
@property(nonatomic,strong) NSMutableArray<ScreenRecord *> *screenRecordArr;
@property(nonatomic,assign) int currentIndex;

@end

NS_ASSUME_NONNULL_END
