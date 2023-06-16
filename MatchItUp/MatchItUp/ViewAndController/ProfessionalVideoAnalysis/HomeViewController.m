//
//  HomeViewController.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/28.
//

#import "HomeViewController.h"
#import "FramePlayerView.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ComposedView.h"
#import "AppDelegate.h"
#import "UIDevice+WJDevice.h"
#import "FramesSelect.h"
#import "FramesSelectCellCollectionViewCell.h"
#import "FrameCollectionViewCell.h"
#import "ComposedAndSpecSelectView.h"
#import "CompesedForSpec.h"
#import "SpecificationDataModel.h"
#import "SpecificationAsset.h"
#import "CoreDataManager.h"

@interface HomeViewController ()<FramePlayerViewDelegate, composedViewDelegate,FramesSelectDelegate>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) ZHVideoAsset *asset;
@property (nonatomic, assign) BOOL isFront;
@property (nonatomic, strong) FramePlayerView *framePlayerView;
@property (nonatomic, strong) FramesSelect *framesSelectView;
@property (nonatomic, strong) NSMutableArray<SpecificationAsset*> *models;
@end

@implementation HomeViewController {
    NSLock *lock;
    MBProgressHUD *hud;
    int currentFrameIndex;
    //UIView *iscuttingView;
    CGFloat originY;
    ComposedView *composedView;
    ComposedAndSpecSelectView *composedAndSpecSelectView;
    CompesedForSpec *compesedForSpec;
    UIImageView *tmpImgView;
    CGRect framePlayerViewOriginFrame;
    BOOL framePlayerViewHeightHasChanged;
    NSMutableArray *frameIndexArray;
    NSMutableArray *frameListArray;
    NSMutableArray *frameStateArray;
    BOOL isCompare;
    CGRect compareFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(isCompare==YES){
        self.view.frame=compareFrame;
    }
    [self initView];
    [self layoutConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrames) name:[NSString stringWithFormat:@"%@updateFrames", _videoURL] object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
//    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    //允许转成横屏
//    appDelegate.allowRotation = YES;
//    [self.navigationController.navigationBar setHidden:YES];
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.framePlayerView initLockState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [composedView willDisappear];
    [_framePlayerView willDisappear];
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andisFront:(BOOL)isFront
{
    self = [super init];
    if (self) {
        _videoURL = videoURL;
        _isFront = isFront;
        _asset = asset;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeFront) name:@"changeVideoFront" object:nil];
    }
    return self;
}
- (instancetype)initWithVideoURL:(NSURL *)videoURL andAsset:(ZHVideoAsset *)asset andisFront:(BOOL)isFront andFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _videoURL = videoURL;
        _isFront = isFront;
        _asset = asset;
        compareFrame=frame;
        isCompare=YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeFront) name:@"changeVideoFront" object:nil];
    }
    return self;
}
- (void)hasChangeFront {
    _isFront = !_isFront;
}

- (void)initView {
    CGFloat kItemWidth = self.view.frame.size.width/13;
    CGFloat kItemHeight = kItemWidth/354*399;
    self.view.backgroundColor = [UIColor colorWithRed:53/255.f green:53/255.f blue:53/255.f alpha:1];
    _framePlayerView = [[FramePlayerView alloc] initWithVideoURL:_videoURL andAsset:_asset andVideo:_asset.video andFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, (self.view.frame.size.width / 4 * 5 + 30 + 30 + 40 + kItemHeight - 100))];
    _framePlayerView.frame = CGRectMake(_framePlayerView.frame.origin.x,
                                        _framePlayerView.frame.origin.y,
                                        _framePlayerView.frame.size.width,
                                        800);
    [_framePlayerView scrollZoomByRate:((self.framePlayerView.frame.size.height - 100) / (self.view.frame.size.width / 4 * 5 + 30 + 30 + 40 + kItemHeight - 100))];
    _framePlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_framePlayerView];
    _framePlayerView.delegate = self;
    lock = [[NSLock alloc] init];
    currentFrameIndex = 0;
    

    _framesSelectView = [[FramesSelect alloc]initWithFrame:CGRectMake(0, self.framePlayerView.frame.origin.y + self.framePlayerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.framePlayerView.frame.size.height-65-[GlobalVar sharedInstance].kStatusBarH)andVideo:_asset.video andVideoURL:_videoURL andFameIndexArray:frameIndexArray];
    [self.view addSubview:_framesSelectView];
    _framesSelectView.delegate = self;
    [_framesSelectView setHidden:YES];
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
    if (!frameIndexArray) {
        frameIndexArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 13; i++) {
            [frameIndexArray addObject:@-1];
        }
    }

    NSString *frameListSavePath = [filePath stringByAppendingPathComponent:@"frameList"];
    frameListArray = [NSMutableArray arrayWithContentsOfFile:frameListSavePath];
    if (!frameListArray) {
        frameListArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 13; i++) {
            [frameListArray addObject:@-1];
        }
    }
    
//    NSString *frameStateSavePath = [filePath stringByAppendingPathComponent:@"frameState"];
//    frameStateArray = [NSMutableArray arrayWithContentsOfFile:frameStateSavePath];

    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    NSNumber* videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    if(videoId){
        NSNumber *videoModelState = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
        NSLog(@"beginvideoId%@",videoId);
        [self videoModeChange:videoModelState];
    }
}

- (void)updateFrames {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
    for (int i = 0; i < 15; i++) {
        if (i > 4 && i <10) {
            UIImageView *tmpView = composedAndSpecSelectView.frameViewArray[i];
            tmpView.image = [UIImage imageWithData:frameIndexArray[i-1]];
        }else if (i >= 10){
            UIImageView *tmpView = composedAndSpecSelectView.frameViewArray[i];
            tmpView.image = [UIImage imageWithData:frameIndexArray[i-2]];
        }else{
            UIImageView *tmpView = composedAndSpecSelectView.frameViewArray[i];
            tmpView.image = [UIImage imageWithData:frameIndexArray[i]];
        }
    }
    NSLog(@"更新了frames!!!!!!!");
}

- (BOOL)hasCompleteFrameSelect {
    for (int i = 0; i < 15; i++) {
        if ([frameIndexArray[i] isEqual:@-1]) {
            return false;
        }
    }
    return true;
}

- (void)enableSelectFrame {
    [_framePlayerView enableSelectFrame];
}

- (void)disableSelectFrame {
    [_framePlayerView disableSelectFrame];
}

/*
- (void)loadFrames {
    NSString *path = NSTemporaryDirectory();
    for (int i = 0; i < 15; i++) {
        int idx = [frameIndexArray[i] intValue];
        if (idx != -1) {
            NSString *filePath = [path stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"frame%d.jpg", idx]];  // 保存文件的名称
            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
            UIImageView *tmpView = composedView.frameViewArray[i];
            tmpView.image = img;
        }
    }
}*/

- (void)beginSelect {
    tmpImgView = [[UIImageView alloc] init];
    tmpImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    tmpImgView.layer.borderWidth = 5.0f;
    tmpImgView.layer.cornerRadius = 5.0f;
    tmpImgView.layer.masksToBounds = YES;
    [self.view addSubview:tmpImgView];
    [composedView restoreSize];
    
    if (self.framePlayerView.frame.size.height > 800) {
        framePlayerViewOriginFrame = self.framePlayerView.frame;
        framePlayerViewHeightHasChanged = true;
        composedView.frame = CGRectMake(composedView.frame.origin.x,
                                        composedView.frame.origin.y + 800 - self.framePlayerView.frame.size.height,
                                        composedView.frame.size.width,
                                        composedView.frame.size.height);
        self.framePlayerView.frame = CGRectMake(self.framePlayerView.frame.origin.x,
                                                self.framePlayerView.frame.origin.y,
                                                self.framePlayerView.frame.size.width,
                                                800);
        [self.framePlayerView scrollZoomByRate:((self.framePlayerView.frame.size.height - 100) / (framePlayerViewOriginFrame.size.height - 100))];
    }
    else {
        framePlayerViewHeightHasChanged = false;
    }
}

- (void)choosingFrame:(CGPoint)point {
    if (point.y < composedView.frame.origin.y) {
        [tmpImgView setHidden:YES];
        return;
    }
    [tmpImgView setHidden:NO];
    int idx = 0;
    CGFloat distance = CGFLOAT_MAX;
    for (int i = 0; i < 15; i++) {
        UIImageView *tmpView = composedView.frameViewArray[i];
        CGFloat tmpDis = (tmpView.center.x - point.x) * (tmpView.center.x - point.x) + (tmpView.center.y + composedView.frame.origin.y - point.y) * (tmpView.center.y + composedView.frame.origin.y - point.y);
        if (distance > tmpDis) {
            distance = tmpDis;
            idx = i;
        }
    }
    UIImageView *tmpView = composedView.frameViewArray[idx];
    int frameIdx;
    if (idx < 5) {
        frameIdx = idx;
    }
    else if (idx < 10) {
        frameIdx = idx - 1;
    }
    else {
        frameIdx = idx - 2;
    }
    frameIdx++;
    if (_isFront) {
        tmpImgView.image = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", frameIdx]];
    }
    else {
        tmpImgView.image = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", frameIdx]];
    }
    if (idx % 5 == 0) {
        tmpImgView.frame = CGRectMake(0, composedView.frame.origin.y + tmpView.frame.origin.y - 125, 100, 125);
    }
    else if (idx % 5 == 4) {
        tmpImgView.frame = CGRectMake(self.view.frame.size.width - 100, composedView.frame.origin.y + tmpView.frame.origin.y - 125, 100, 125);
    }
    else {
        tmpImgView.frame = CGRectMake(tmpView.center.x - 50, composedView.frame.origin.y + tmpView.frame.origin.y - 125, 100, 125);
    }
}

- (void)finishSelect:(UIImage *)image andframeindex:(int) fameindex andPoint:(CGPoint)point {
    [tmpImgView removeFromSuperview];
    tmpImgView = nil;
    NSArray * array = [_framesSelectView.framesCollectionView visibleCells];
    NSIndexPath * indexPath = [_framesSelectView.framesCollectionView indexPathForCell:array.firstObject];
    int idx = (int)indexPath.row;
    
    CGPoint newpoint = [_framePlayerView convertPoint:point toView:(UIImageView *)_framesSelectView.frameViewArray[idx]];
    
    frameStateArray = [_framesSelectView valueForKey:@"frameStateArray"];
    if(!CGRectContainsPoint(((UIImageView *)_framesSelectView.frameViewArray[idx]).bounds, newpoint) || [frameStateArray[idx] isEqual:@1]){
        return;
    }
    
    UIImageView *tmpView = _framesSelectView.frameViewArray[idx];
    tmpView.image = image;
    NSData *imgData = UIImageJPEGRepresentation(image , 1.0);
    frameIndexArray[idx] = imgData;
    frameListArray[idx]=[NSNumber numberWithInt:fameindex];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    if ([frameIndexArray writeToFile:frameIdxSavePath atomically:NO]) {
        NSLog(@"图片写入成功");
        [_framesSelectView updataframeIndexArray];
        [((FramesSelectCellCollectionViewCell*)array.firstObject).contentView setHidden:NO];
        [_framesSelectView.framesCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else {
        NSLog(@"图片写入失败");
    }
    NSString *frameListSavePath = [filePath stringByAppendingPathComponent:@"frameList"];
    if ([frameListArray writeToFile:frameListSavePath atomically:NO]) {
        NSLog(@"13帧写入成功");
    }
    else {
        NSLog(@"13帧写入失败");
    }
    if (framePlayerViewHeightHasChanged) {
        [self.framePlayerView scrollZoomByRate:((framePlayerViewOriginFrame.size.height - 100) / (self.framePlayerView.frame.size.height - 100))];
        self.framePlayerView.frame = framePlayerViewOriginFrame;
        composedView.frame = CGRectMake(composedView.frame.origin.x,
                                        composedView.frame.origin.y - 400 + framePlayerViewOriginFrame.size.height,
                                        composedView.frame.size.width,
                                        composedView.frame.size.height);
        
    }
}

- (void)autoSelectedWithX:(CGFloat)x andY:(CGFloat)y andW:(CGFloat)w andH:(CGFloat)h{
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    NSNumber* videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    NSArray *frameList = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", videoId]];
    for (int i = 0; i < 13; i++) {
        int fameindex = [frameList[i] intValue];
        UIImage *image = [_framePlayerView getFrameFromFile:fameindex];
        UIImage *resizeImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, CGRectMake(image.size.width * x, image.size.height * y, image.size.width * w, image.size.height * h))];
        NSData *imgData = UIImageJPEGRepresentation(resizeImage , 1.0);
        frameIndexArray[i] = imgData;
        frameListArray[i]=[NSNumber numberWithInt:fameindex];
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
        if ([frameIndexArray writeToFile:frameIdxSavePath atomically:NO]) {
            NSLog(@"图片写入成功");
            [_framesSelectView updataframeIndexArray];
        }
        else {
            NSLog(@"图片写入失败");
        }
        NSString *frameListSavePath = [filePath stringByAppendingPathComponent:@"frameList"];
        if ([frameListArray writeToFile:frameListSavePath atomically:NO]) {
            NSLog(@"13帧写入成功");
        }
        else {
            NSLog(@"13帧写入失败");
        }
    }
    [_framesSelectView.framesCollectionView reloadData];
}

- (void)hideHud {
    //[hud hideAnimated:YES];
    //[iscuttingView setHidden:YES];
}

- (void)updateHudWithFrameNum:(int)frameNum {
    [lock lock];
    hud.mode = MBProgressHUDModeDeterminate;
    currentFrameIndex++;
    hud.progress = (float)currentFrameIndex / frameNum;
    hud.label.text = @"提取视频帧中...";
    [lock unlock];
}

- (void)panBegan {
    originY = composedView.frame.origin.y;
}

- (void)panChangedWithOffset:(CGFloat)offsetY {
    composedView.frame = CGRectMake(composedView.frame.origin.x,
                                    originY + offsetY,
                                    composedView.frame.size.width,
                                    composedView.frame.size.height);
}

- (void)layoutConfig {
    
}

- (void)popNavigationVC {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
        
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeHeightWithOffset:(CGFloat)offset {
    if (self.view.frame.origin.y + offset <= 0) {
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y + offset,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    }
}

- (void)saveCurrentState {
    [composedView saveCurrentState];
}

- (void)presentAlertView:(UIAlertController *)alert {
    [self presentViewController:alert animated:true completion:nil];
}

- (void)shareButtonDidTouched{
//    NSString *textToShare1 = @"要分享的文本内容";
//    UIImage *imageToShare = _asset.cover;
    NSURL *urlToShare = _asset.videoURL;
    NSArray *activityItems = @[urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];

    //去除一些不需要的图标选项
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypePostToWeibo, UIActivityTypePostToTencentWeibo];

    //成功失败的回调block
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {

        if (completed){
            NSLog(@"completed");
        }else{
            NSLog(@"canceled");
        }
    };
    activityVC.completionWithItemsHandler = myBlock;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = _framePlayerView.shareBtn;
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)scrollToFrame:(int)frameN{
    [_framesSelectView.framesCollectionView setContentOffset:CGPointMake(frameN * kScreenW, 0)];
}
- (void)selectToFrame:(NSIndexPath*)frameN{
    NSLog(@"zhixing");
    FrameCollectionViewCell *cell = (FrameCollectionViewCell*)[_framePlayerView.frameCollectionView cellForItemAtIndexPath:frameN];
    for(FrameCollectionViewCell *indexcell in _framePlayerView.frameCollectionView.visibleCells){
        if(indexcell==cell){
            [indexcell setSelected:YES];
            NSArray *frameList = [_framePlayerView valueForKey:@"frameList"];
            [_framePlayerView showFrameAtIndex:[frameList[frameN.row] intValue]];
            indexcell.backgroundColor = [UIColor redColor];
        }else{
            [indexcell setSelected:NO];
            indexcell.backgroundColor = [UIColor blackColor];
        }
    }
}
- (void)frameLockWithIndexPath:(NSIndexPath *)indexPath{
    FrameCollectionViewCell *cell = (FrameCollectionViewCell*)[_framePlayerView.frameCollectionView cellForItemAtIndexPath:indexPath];
    [cell setFrameImg:[UIImage imageWithData:frameIndexArray[indexPath.row]] withRate:0];
}
- (void)videoModeChange:(NSNumber *)num{
    if([num isEqual:@2]){
//        [self autoSelected];
        [_framePlayerView.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame2"] forState:UIControlStateNormal];
        [_framesSelectView setHidden:NO];
    }else if ([num isEqual:@3]){
        [self videoStateOf3];
    }else if([num isEqual:@4]){
        [self videoStateOf3];
        [self videoStateOf4];
    }
}

- (void)videoStateOf3{
    [_framesSelectView setHidden:NO];
    [_framePlayerView.autoChooseFrameBtn setImage:[UIImage imageNamed:@"autoChooseFrame3"] forState:UIControlStateNormal];
    [_framesSelectView.framesCollectionView setHidden:YES];
    [_framesSelectView.specModelSelect setHidden:NO];
    [_framesSelectView.specModelSelect addTarget:self action:@selector(toComposedAndSpecSeleect) forControlEvents:UIControlEventTouchUpInside];
    self.models = [[SpecificationDataModel alloc] initWithSpecificatins:[[CoreDataManager sharedManager] getSpecificationOfUsing]].assets;
    composedAndSpecSelectView = [[ComposedAndSpecSelectView alloc] initWithFrame:CGRectMake(0, [GlobalVar sharedInstance].kStatusBarH ,
                                                            self.view.frame.size.width,
//                                                    (self.view.frame.size.width - 10) / 4 * 3 + 50)
                                                                  self.view.frame.size.height-[GlobalVar sharedInstance].kStatusBarH-65)
                                            andisFront:_isFront
                                           andVideoURL:_videoURL
                                              andVideo:_asset.video
                                            andFrameIndexArray:frameIndexArray andSpecModels:_models];
    composedAndSpecSelectView.videoName = [[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension];
    composedAndSpecSelectView.delegate = self;
    UIGraphicsBeginImageContextWithOptions(composedAndSpecSelectView.bounds.size, composedAndSpecSelectView.opaque, 0.0);
    [composedAndSpecSelectView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_framesSelectView.specModelSelect setImage:image forState:UIControlStateNormal];
    [self.view addSubview:composedAndSpecSelectView];
    [composedAndSpecSelectView setHidden:YES];
    
    
}
- (void)videoStateOf4{
    compesedForSpec = [[CompesedForSpec alloc]initWithFrame:CGRectMake(0, [GlobalVar sharedInstance].kStatusBarH ,
                                                                       self.view.frame.size.width,
           //                                                    (self.view.frame.size.width - 10) / 4 * 3 + 50)
                                                                       self.view.frame.size.height-[GlobalVar sharedInstance].kStatusBarH-65) andisFront:_isFront andVideoURL:_videoURL andFrameIndexArray:frameIndexArray];
    [self.view addSubview:compesedForSpec];
    UIGraphicsBeginImageContextWithOptions(compesedForSpec.bounds.size, compesedForSpec.opaque, 0.0);
    [compesedForSpec.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_framesSelectView.drawRes setImage:image1 forState:UIControlStateNormal];
    [self.view addSubview:composedAndSpecSelectView];
    [_framesSelectView.drawRes setHidden:NO];
    [_framesSelectView.drawRes addTarget:self action:@selector(toComposedForSpec) forControlEvents:UIControlEventTouchUpInside];
    [compesedForSpec setHidden:YES];
}
- (void)toComposedAndSpecSeleect{
    [composedAndSpecSelectView setHidden:NO];
}

- (void)toComposedForSpec{
    [compesedForSpec setHidden:NO];
}
@end
