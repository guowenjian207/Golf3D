//
//  ViewController.m
//  ScrollPlayer
//
//  Created by bytedance on 2021/5/17.
//

#import "ScrollPlayerViewController.h"
#import "ScrollPlayerCell.h"
#import "GlobalVar.h"
#import "CoreDataManager.h"
#import "ZHFileManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PoseVideoProcessor.h"
#import "UIView+Resize.h"
#import "ZHPopupViewManager.h"
#import "HomeScreenViewController.h"

@interface ScrollPlayerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, HomeScreenVCProtocol>

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) ScrollPlayerVideoManager *videoManager;

@property(nonatomic, strong) NSMutableArray<ZHVideoAsset*> *assets;

@end

@implementation ScrollPlayerViewController{
    ScrollPlayerMode _mode;
    MBProgressHUD *hud;
    NSTimer *sliderTimer;
    NSTimer *restartSliderTimer;
    HomeScreenViewController *homeScreenViewController;
    NSLock *lock;
    int currentFrameIndex;
}

+ (instancetype)playerViewControllerWithAssets:(NSMutableArray<ZHVideoAsset *> *)assets{
    ScrollPlayerViewController *vc = [[ScrollPlayerViewController alloc] init];
    vc.assets = assets;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView setContentOffset:CGPointMake(_currentIndex * self.view.frame.size.width, 0)];
    
    self.bottomView.backgroundColor = [UIColor blackColor];
    self.bottomView.type = self.type;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.collectionView setContentOffset:CGPointMake(_currentIndex * kScreenW, 0)];
}

- (void)viewDidAppear:(BOOL)animated{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100000), dispatch_get_main_queue(), ^{
        [self scrollViewDidEndDecelerating:self->_collectionView];
    });
    sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(updateSliderValue) userInfo:nil repeats:YES];
    dispatch_after(0.25f, dispatch_get_main_queue(), ^{
        self.bottomView.mode = ScrollPlayerModeEdit;
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [sliderTimer invalidate];
    [restartSliderTimer invalidate];
}

- (void)dealloc
{
    if (_videoManager){
        [_videoManager destory];
    }
}

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - get & set
- (ScrollPlayerBottomView *)bottomView{
    if (_bottomView == NULL){
        _bottomView = [[ScrollPlayerBottomView alloc] initWithSuperview:self.view];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (UICollectionView *)collectionView{
    if (_collectionView == NULL){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenW, kScreenH);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = nil;
        collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor blackColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.scrollsToTop = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)){
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
        }
        collectionView.alwaysBounceVertical = NO;
        collectionView.alwaysBounceHorizontal = NO;
        
        if (_assets.count == 1) {
            collectionView.scrollEnabled = NO;
        }
        
        [collectionView registerClass:[ScrollPlayerCell class] forCellWithReuseIdentifier:@"ScrollPlayerCell"];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (ScrollPlayerVideoManager *)videoManager {
    if (_videoManager == nil) {
        _videoManager = [[ScrollPlayerVideoManager alloc] init];
        _videoManager.myVC = self;
    }
    return _videoManager;
}

- (void)setMode:(ScrollPlayerMode)mode{
    _mode = mode;
    
}

- (void)setCurrentIndex:(NSUInteger)currentIndex{
    _currentIndex = currentIndex;
}

#pragma mark - private method
- (void)singleTapCell:(ScrollPlayerCell *)cell{
    if (_bottomView.isHidden){
        _bottomView.hidden = NO;
    }
    else {
        _bottomView.hidden = YES;
    }
}

- (void)doubleTapCell:(ScrollPlayerCell *)cell{
    if (_mode == ScrollPlayerModeNormal){
        if (cell.videoView.state == ScrollPlayerStatePlaying){
            [cell.videoView pause];
        }else{
            [cell.videoView play];
        }
    }
}

- (void)dismiss{
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateSliderValue {
    
    float duration = CMTimeGetSeconds(_videoManager.videoPlayer.player.currentItem.duration);
    
    if (duration > 0) {
        if (_videoManager.videoPlayer.player.currentItem && duration != self.bottomView.sliderMaxValue) {
            self.bottomView.sliderMaxValue = duration;
        }
        [self.bottomView setSliderCurrentValue:CMTimeGetSeconds(_videoManager.videoPlayer.player.currentItem.currentTime)];
    }
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScrollPlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollPlayerCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.myVC = self;
    cell.videoManager = self.videoManager;
    cell.asset = _assets[indexPath.row];
    cell.videoView.image = _assets[indexPath.row].cover;
    
    if (!cell.singleTapAction){
        __weak typeof(self) weakSelf = self;
        cell.singleTapAction = ^(ScrollPlayerCell * _Nonnull cell) {
            __strong typeof(weakSelf) self = weakSelf;
            [self singleTapCell:cell];
        };
    }
    
    if (!cell.doubleTapAction){
        __weak typeof(self) weakSelf = self;
        cell.doubleTapAction = ^(ScrollPlayerCell * _Nonnull cell) {
            __strong typeof(weakSelf) self = weakSelf;
            [self doubleTapCell:cell];
        };
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass: [ScrollPlayerCell class]]){
        [(ScrollPlayerCell *)cell willDisplay];
    }
}

#pragma mark - scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth + (self.view.frame.size.width * 0.5);

    _currentIndex = offSetWidth / self.view.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    ScrollPlayerCell *cell = (ScrollPlayerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [cell didDisplay];
}

#pragma mark - topbar delegate
- (void)back{
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - bottom view delegate
- (void)removeAsset{
    NSUInteger index = _currentIndex;
    if (index >= self.assets.count){
        [self dismiss];
        return;
    }
    ZHVideoAsset *asset = [self.assets objectAtIndex:index];
    if (_type == ScrollPlayerTypeScreenRecord){
        [CoreDataManager.sharedManager deleteScreenRecord:asset.screenRecord];
    }else if (_type == ScrollPlayerTypeLocal || _type == ScrollPlayerTypePosted){
        [CoreDataManager.sharedManager deleteVideo:asset.video];
    }
    if (self.assets.count == 1){
        [self back];
        return;
    }
    if (index == self.assets.count - 1){
        self.collectionView.contentOffset = CGPointMake((index - 1) * self.view.frame.size.width, 0);
        [self.assets removeObjectAtIndex:index];
        [self.collectionView reloadData];
    }else{
        [self.assets removeObjectAtIndex:index];
        [self.collectionView reloadData];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[asset.videoURL absoluteString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveAsset{
    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeIndeterminate title:@"保存中...." icon:NULL autoHideAfterDelayIfNeed:NULL];
    
    NSUInteger index = _currentIndex;
    ZHVideoAsset *asset = [self.assets objectAtIndex:index];
    
    CMTime start;
    CMTime end;
    if (_bottomView.mode == ScrollPlayerModeNormal) {
        start = CMTimeMake(0, 10000);
        end = CMTimeMake(_bottomView.sliderMaxValue * 10000, 10000);
    } else {
        start = CMTimeMake(_bottomView.doubleSliderLeftValue * 10000, 10000);
        end = CMTimeMake(_bottomView.doubleSliderRightValue * 10000, 10000);
    }
    
    [CoreDataManager.sharedManager addVideo:asset.videoURL withAngle:0 startTime:start endTime:end andisFront:_isFront completion:^(Video * newVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newVideo == NULL) {
                [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"保存失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                return;
            }
            NSLog(@"save asset 成功 %@", newVideo.videoFile);
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"导入成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }];
}

- (void)playControl{
    ScrollPlayerCell *cell = [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if (cell){
        if (cell.videoView.state == ScrollPlayerStatePlaying){
            [cell.videoView pause];
        }else{
            [cell.videoView play];
        }
    }
}

- (void)restartSliderTimer {
    [restartSliderTimer invalidate];
    __weak typeof(self) weakSelf = self;
    restartSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:strongSelf selector:@selector(updateSliderValue) userInfo:nil repeats:YES];
    }];
}

- (void)playerSeekTo:(float)time {
    [sliderTimer invalidate];
    __weak typeof(self) weakSelf = self;
    [self.videoManager.videoPlayer.player seekToTime:CMTimeMake(time * 10000, 10000) toleranceBefore:CMTimeMake(1, 10000) toleranceAfter:CMTimeMake(1, 10000) completionHandler:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf restartSliderTimer];
    }];
}

// 加入逐帧播放功能
- (void)framePlay {
    lock = [[NSLock alloc] init];
    currentFrameIndex = 0;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"正在获取视频总帧数...";
    
    NSUInteger index = _currentIndex;
    ZHVideoAsset *asset = [self.assets objectAtIndex:index];
    //AVAsset *Avasset = [AVAsset assetWithURL:asset.videoURL];
    homeScreenViewController = [[HomeScreenViewController alloc] init];
    //homeScreenViewController.view.backgroundColor = [UIColor blackColor];
    //homeScreenViewController.videoAsset = Avasset;
    homeScreenViewController.videoUrl = asset.videoURL;
    homeScreenViewController.isFront = asset.isFront;
    homeScreenViewController.view.backgroundColor = [UIColor whiteColor];
    homeScreenViewController.delegate = self;
}

- (void)hideHud {
    [hud hideAnimated:YES];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];
}

- (void)updateHudWithFrameNum:(int)frameNum {
    [lock lock];
    hud.mode = MBProgressHUDModeDeterminate;
    currentFrameIndex++;
    hud.progress = (float)currentFrameIndex / frameNum;
    hud.label.text = @"提取视频帧中...";
    [lock unlock];
}

@end
