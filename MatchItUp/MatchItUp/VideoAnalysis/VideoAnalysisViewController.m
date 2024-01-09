//
//  VideoAnalysisViewController.m
//  MatchItUp
//
//  Created by GWJ on 2022/12/12.
//

#import "VideoAnalysisViewController.h"
#import <Masonry/Masonry.h>
#import "ScrollPlayerCell.h"
#import "GlobalVar.h"
#import "CoreDataManager.h"
#import "ZHFileManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PoseVideoProcessor.h"
#import "UIView+Resize.h"
#import "ZHPopupViewManager.h"
#import "HomeScreenViewController.h"
#import "indexvideoAnalysisCollectionViewCell.h"

@interface VideoAnalysisViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, HomeScreenVCProtocol>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionView *indexcollectionView;
@property(nonatomic, strong) ScrollPlayerVideoManager *videoManager;

@property(nonatomic, strong) NSMutableArray<ZHVideoAsset*> *assets;

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIButton *backBtn;
@end

@implementation VideoAnalysisViewController{
    ScrollPlayerMode _mode;
    MBProgressHUD *hud;
    NSTimer *sliderTimer;
    NSTimer *restartSliderTimer;
    HomeScreenViewController *homeScreenViewController;
    NSLock *lock;
    int currentFrameIndex;
}

+ (instancetype)playerViewControllerWithAssets:(NSMutableArray<ZHVideoAsset *> *)assets{
    VideoAnalysisViewController *vc = [[VideoAnalysisViewController alloc] init];
    vc.assets = assets;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layout];
}
-(void)layout{
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    _topView = [[UIImageView alloc] init];//WithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    [_topView setImage:[UIImage imageNamed:@"topView"]];
    _topView.userInteractionEnabled = YES;
    [self.view addSubview:_topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.navigationController.navigationBar.top);
                make.height.mas_equalTo(30);
    }];
    
    _backBtn = [[UIButton alloc] init];
    [_backBtn setImage:[UIImage imageNamed:@"left_back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.top.equalTo(self.topView).offset(3);
        make.bottom.equalTo(self.topView).offset(-3);
        make.width.mas_equalTo(25);
    }];
    [self.view addSubview:self.collectionView];
    [self.collectionView setContentOffset:CGPointMake(_currentIndex * self.view.frame.size.width, 0)];
    [self.view addSubview:self.indexcollectionView];
    
//    UIView *compareView = [[UIImageView alloc] init];
//    compareView.backgroundColor=[UIColor grayColor];
//    compareView.frame=CGRectMake(0,self.indexcollectionView.bottom,kScreenW,kScreenH/3);
//    [self.view addSubview:compareView];
//    UIImageView *imageviewA= [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, compareView.frame.size.width/3-4, compareView.frame.size.height - 4)];
//    imageviewA.backgroundColor=[UIColor greenColor];
//    imageviewA.image = [UIImage imageNamed:@"addvideo"];
//    [compareView addSubview:imageviewA];
//    UIImageView *imageviewB= [[UIImageView alloc] initWithFrame:CGRectMake(compareView.frame.size.width/3+2, 2, compareView.frame.size.width/3-4, compareView.frame.size.height - 4)];
//    imageviewB.backgroundColor=[UIColor greenColor];
//    imageviewB.image = [UIImage imageNamed:@"addvideo"];
//    [compareView addSubview:imageviewB];
//    UIImageView *imageviewC= [[UIImageView alloc] initWithFrame:CGRectMake(compareView.frame.size.width/3*2+2, 2, compareView.frame.size.width/3-4, compareView.frame.size.height - 4)];
//    imageviewC.backgroundColor=[UIColor greenColor];
//    imageviewC.image = [UIImage imageNamed:@"addvideo"];
//    [compareView addSubview:imageviewC];
    self.bottomView.backgroundColor = [UIColor blackColor];
    self.bottomView.type = self.type;
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
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
//    [self.navigationController popViewControllerAnimated:YES];
    [self removeAsset];
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
        layout.itemSize = CGSizeMake(kScreenW, 0.5*kScreenH);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = nil;
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.top+30, kScreenW, 0.5*kScreenH) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor blackColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.scrollsToTop = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)){
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            collectionView.automaticallyAdjustsScrollIndicatorInsets = YES;
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
- (UICollectionView *)indexcollectionView{
    if (_indexcollectionView == NULL){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenW/5, kScreenH/10);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = nil;
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.collectionView.height, kScreenW,kScreenH/10) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = NO;
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
        
        [collectionView registerClass:[indexvideoAnalysisCollectionViewCell class] forCellWithReuseIdentifier:@"indexvideoAnalysisCollectionViewCell"];
        
        _indexcollectionView = collectionView;
        NSLog(@"zhixingle1111111");
    }
    return _indexcollectionView;
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
    if(collectionView==self.collectionView){
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
    }else if (collectionView==self.indexcollectionView){
        indexvideoAnalysisCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"indexvideoAnalysisCollectionViewCell" forIndexPath:indexPath];
        [cell setVideoCover: _assets[indexPath.row].cover];
        UIView *tmpView = [[UIView alloc] initWithFrame:cell.frame];
        tmpView.backgroundColor = [UIColor redColor];
        cell.selectedBackgroundView = tmpView;
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass: [ScrollPlayerCell class]]){
        [(ScrollPlayerCell *)cell didDisplay];
    }else if([cell isKindOfClass:[indexvideoAnalysisCollectionViewCell class]]){
        
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView==_indexcollectionView){
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//        NSIndexPath *viewIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0 ];
//        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:0 animated:YES];
        [self.collectionView setContentOffset:CGPointMake(indexPath.row * kScreenW, 0)];
        indexvideoAnalysisCollectionViewCell *cell = (indexvideoAnalysisCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        for(indexvideoAnalysisCollectionViewCell *indexcell in _indexcollectionView.visibleCells){
            if(indexcell==cell){
                [indexcell setSelected:YES];
            }else{
                [indexcell setSelected:NO];
            }
        }
    }
}
#pragma mark - scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isEqual:self.collectionView]){
        CGFloat offSetWidth = scrollView.contentOffset.x;
        offSetWidth = offSetWidth + (self.view.frame.size.width * 0.5);

        _currentIndex = offSetWidth / self.view.frame.size.width;
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0 ];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    ScrollPlayerCell *cell = (ScrollPlayerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [cell didDisplay];
    indexvideoAnalysisCollectionViewCell *indexcell=(indexvideoAnalysisCollectionViewCell*)[self.indexcollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    for(indexvideoAnalysisCollectionViewCell *cell in _indexcollectionView.visibleCells){
        if(cell==indexcell){
            [cell setSelected:YES];
            [_indexcollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:0 animated:YES];
        }else{
            [cell setSelected:NO];
        }
    }
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    CGFloat offSetX = targetContentOffset->x;
//    CGFloat itemWidth = kScreenW;
//    NSInteger pageWidth = itemWidth + 10;
//
//    NSInteger pageNum = (offSetX + pageWidth/2)/pageWidth;
//
//    targetContentOffset->x = pageWidth*pageNum;
//
//    _currentIndex = pageNum;
//    NSLog(@"11%lu",(unsigned long)_currentIndex);
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了取消");
    }];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"删除视频" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确定");
        NSUInteger index = self->_currentIndex;
        if (index >= self.assets.count){
            [self dismiss];
            return;
        }
        ZHVideoAsset *asset = [self.assets objectAtIndex:index];
        [CoreDataManager.sharedManager deleteAnalysisVideo:asset.analysisVideo];
        if (self.assets.count == 1){
            [self back];
            return;
        }
        if (index == self.assets.count - 1){
            self.collectionView.contentOffset = CGPointMake((index - 1) * self.view.frame.size.width, 0);
            [self.assets removeObjectAtIndex:index];
            [self.collectionView reloadData];
            [self.indexcollectionView reloadData];
        }else{
            [self.assets removeObjectAtIndex:index];
            [self.collectionView reloadData];
            [self.indexcollectionView reloadData];
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[asset.videoURL absoluteString]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertController addAction:action];
    [alertController addAction:action1];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)saveAsset{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了取消");
    }];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存视频" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确定");
        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeIndeterminate title:@"保存中...." icon:NULL autoHideAfterDelayIfNeed:NULL];

        NSUInteger index = self->_currentIndex;
        ZHVideoAsset *asset = [self.assets objectAtIndex:index];
        
        CMTime start;
        CMTime end;
        if (self->_bottomView.mode == ScrollPlayerModeNormal) {
            start = CMTimeMake(0, 10000);
            end = CMTimeMake(self->_bottomView.sliderMaxValue * 10000, 10000);
        } else {
            start = CMTimeMake(self->_bottomView.doubleSliderLeftValue * 10000, 10000);
            end = CMTimeMake(self->_bottomView.doubleSliderRightValue * 10000, 10000);
        }
        
        [CoreDataManager.sharedManager addVideo:asset.videoURL withAngle:0 startTime:start endTime:end andisFront:self->_isFront completion:^(Video * newVideo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newVideo == NULL) {
                    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"保存失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                    return;
                }
                NSLog(@"save asset 成功 %@", newVideo.videoFile);
                [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"导入成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
            });
        }];
    }];
    [alertController addAction:action];
    [alertController addAction:action1];
    [self presentViewController:alertController animated:YES completion:nil];
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
