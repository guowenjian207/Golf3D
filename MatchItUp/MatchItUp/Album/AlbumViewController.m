//
//  AlbumViewController.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import "AlbumViewController.h"
#import "ZHVideoModel.h"
#import <QuickLook/QuickLook.h>
#import "CameraViewController.h"
#import "HomeViewController.h"
#import "MyAlbumBtn.h"
#import "ZHPopupViewManager.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
@interface AlbumViewController ()<QLPreviewControllerDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    //UI控件
    UIView *secondView;
    
    UICollectionView *albumCV;
    
    UILabel *secondLabel;
    UICollectionViewFlowLayout *secondLayout;
    
    UIView *topView;
    UIView *buttomView;
    UIButton *cameraBtn;
    UIButton *uploadBtn;
    UIButton *settingBtn;
    
    GlobalVar *globalVar;
//    UIBarButtonItem *leftButton;
//    UIBarButtonItem *rightButton;
    BOOL isProfessionAlbum;
    CGSize cellSize;
    int numOfVideosPerRow;
    
    MyAlbumBtn *myAlbumBtn;
    MyAlbumBtn *proBtn;
    CGFloat topViewHeight;
    
    UIView* state;
    UILabel *topLabel;
}

@property(nonatomic, strong) NSMutableArray<ZHVideoAsset*> *videos;
@property(nonatomic, strong) NSMutableArray<ZHVideoAsset*> *screenRecordVideos;

@property(nonatomic,assign)bool tag;
@property(nonatomic,strong)NSIndexPath* currentIndexPath;

@end

@implementation AlbumViewController

#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    globalVar = [GlobalVar sharedInstance];
    [self outletConfig];
    [self outletLayout];
    
    UIButton *help = [[UIButton alloc] init];
    [help addTarget:self action:@selector(viewFeatureDocumentation) forControlEvents:UIControlEventTouchUpInside];
    [help setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    [topView addSubview:help];
    
    [help mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.left.equalTo(topView).offset(10);
        make.top.equalTo(topView);
    }];
}

#pragma mark -- QLPreviewController
- (void)viewFeatureDocumentation {
    [self QLPreviewControllerLoad];
}
- (void)QLPreviewControllerLoad {
    QLPreviewController *qlpVC = [[QLPreviewController alloc] init];
    qlpVC.dataSource = self;
    [self presentViewController:qlpVC animated:YES completion:nil];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;//需要显示文件的个数
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"swing pro使用手册.pdf" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}

/////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }  
    [self.navigationController.navigationBar setHidden:YES];
//    if (isProfessionAlbum) {
//        [self getProfessionVideos];
//    }
//    else {
//        [self getData];
//    }
    [self getData];
}

- (void)gotoCamera {
    CameraViewController *vc = [[CameraViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - setvideos
- (void)getData{
    [self getVideos];
    [CATransaction setDisableActions:YES];//解决刷新闪烁问题
    [albumCV reloadData];
    [CATransaction commit];
//    [albumCV setHidden:_videos.count == 0];
    //[self getScreenRecordVideos];
}

- (void)setVideos:(NSMutableArray<ZHVideoAsset *> *)videos{
    _videos = videos;
    [albumCV reloadData];
//    [albumCV setHidden:videos.count == 0];
}

#pragma mark - getvideos

- (void)getVideos{
    self.videos = [[ZHVideoModel alloc] initWithVideos:[[CoreDataManager sharedManager] getVideosWithPosted:NO andTrashed:NO]].assets;
//    if (self.videos.count>0){
//        [NetworkingManager.sharedNetworkingManager uploadSS:self.videos[0]];
//    }
}

- (UIImage *)getThumbnailImage:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    generator.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
        
    return thumb;
}

- (void)getProfessionVideos {
    NSMutableArray *videoArr = [[NSMutableArray alloc] init];
    for (int i = 1; i < 2; i++) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"example%d.MOV", i] withExtension:nil];
        ZHVideoAsset *asset = [[ZHVideoAsset alloc] initWithLocalURL:url andIsFront:NO];
        asset.cover = [self getThumbnailImage:url];
        asset.videoURL = url;
        asset.isFront = NO;
        NSLog(@"%f",asset.video.videoHeight);
        [videoArr addObject:asset];
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"test5"] withExtension:@"mp4"];
    ZHVideoAsset *asset = [[ZHVideoAsset alloc] initWithLocalURL:url andIsFront:NO];
    asset.cover = [self getThumbnailImage:url];
    asset.videoURL = url;
    asset.isFront = YES;
    NSLog(@"%f",asset.video.videoHeight);
    [videoArr addObject:asset];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"test3"] withExtension:@"mp4"];
    ZHVideoAsset *asset2 = [[ZHVideoAsset alloc] initWithLocalURL:url2 andIsFront:NO];
    asset2.cover = [self getThumbnailImage:url2];
    asset2.isFront = YES;
    NSLog(@"%f",asset2.video.videoHeight);
    [videoArr addObject:asset2];
//    for (int i = 0; i < 10; i++) {
//        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"example%d.mp4", i] withExtension:nil];
//        ZHVideoAsset *asset = [[ZHVideoAsset alloc] initWithLocalURL:url andIsFront:NO];
//        asset.cover = [self getThumbnailImage:url];
//        asset.videoURL = url;
//        [videoArr addObject:asset];
//    }
    self.videos = videoArr;
}

#pragma mark - event
- (void)segmentedControlValueChanged:(MyAlbumBtn *)btn {
    if (btn == myAlbumBtn && !isProfessionAlbum) {
        return ;
    }
    if (btn == proBtn && isProfessionAlbum) {
        return ;
    }
    if (isProfessionAlbum) {
        albumCV.backgroundColor = [UIColor colorWithRed:0.693 green:0.898 blue:0.839 alpha:1];
        uploadBtn.enabled = YES;
        [self getData];
        [albumCV reloadData];
        isProfessionAlbum = false;
        [myAlbumBtn removeFromSuperview];
        [topView addSubview:myAlbumBtn];
        [myAlbumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(topView.mas_width).multipliedBy(0.07);
            make.left.equalTo(topView);
            make.bottom.equalTo(topView);
            make.width.equalTo(topView);
        }];
    }
    else {
        albumCV.backgroundColor = [UIColor colorWithRed:0.694 green:0.776 blue:0.898 alpha:1];
        uploadBtn.enabled = NO;
        [self getProfessionVideos];
        [albumCV reloadData];
        isProfessionAlbum = true;
        [proBtn removeFromSuperview];
        [topView addSubview:proBtn];
        [proBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(topView.mas_width).multipliedBy(0.07);
            make.left.equalTo(topView);
            make.bottom.equalTo(topView);
            make.width.equalTo(topView);
        }];
    }
    /*
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //NSLog(@"应用相册");
            scrollView.contentOffset = CGPointMake(0, 0);
            //[rightBtn setTitle:@"删除" forState:UIControlStateNormal];
            break;
        case 1:
            //NSLog(@"系统相册");
            scrollView.contentOffset = CGPointMake(kScreenW, 0);
            //[rightBtn setTitle:@"导入" forState:UIControlStateNormal];
            break;
        default:
            break;
    }*/
}


#pragma mark - CollectionViewDelegate + CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _videos.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[AlbumCollectionViewCell alloc] init];
    }
    [cell resettingCell];
    if(indexPath.row == _videos.count || _videos.count == 0){
        cell.backImageView.image = [UIImage imageNamed:@"upload"];
        return cell;
    }
    
    ZHVideoAsset *asset = nil;
    asset = _videos[indexPath.row];

    cell.backImageView.image = asset.cover;
    NSDateFormatter *matter = [[NSDateFormatter alloc]init];
    matter.dateFormat =@"YYYY-MM-dd HH:mm";
    NSString *timeStr = [matter stringFromDate:asset.video.creationTime];
    cell.timeLabel.text = timeStr;
 
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:@"starInfo.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    NSString *videoName = [[[asset.videoURL relativeString] lastPathComponent] stringByDeletingPathExtension];
    if (dic[videoName] != nil) {
        if ([dic[videoName] boolValue]) {
            cell.favoriteImgView.image = [UIImage imageNamed:@"albumStar"];
        }
        else {
            cell.favoriteImgView.image = nil;
        }
    }
    else {
        cell.favoriteImgView.image = nil;
    }
    filepath = [docPath stringByAppendingPathComponent:@"scoreInfo.plist"];
    dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    if (dic[videoName] != nil) {
        cell.scoreLabel.text = dic[videoName];
    }
    else {
        cell.scoreLabel.text = @"";
    }
    if(asset.video.isEdite == YES){
        [cell.bottomView setHidden:NO];
        if(asset.video.isUse == YES){
            [cell.stateChange setSelected:NO];
            [cell.bottomView setBackgroundColor:[UIColor greenColor]];
        }else{
            [cell.stateChange setSelected:YES];
            [cell.bottomView setBackgroundColor:[UIColor redColor]];
        }
    }
    
    if (asset.video.name != nil) {
        cell.remarkLabel.text = [asset.video.name copy];
        [cell.remarkLabel setFont:cell.timeLabel.font];
    }
    else {
        cell.remarkLabel.text = nil;
    }
    //cell.durationLabel.text = asset.secs;
    [cell.duplicateButton addTarget:self action:@selector(duplicateVideo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.stateChange addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bianjiButton addTarget:self action:@selector(bianji:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == _videos.count || _videos.count==0){
        [self uploadVideoFromSystem];
    }else if(self.tag && indexPath.row < _videos.count){
        ZHVideoAsset *asset = nil;
        asset = _videos[indexPath.row];
        HomeViewController *vc = [[HomeViewController alloc] initWithVideoURL:asset.videoURL andAsset:asset andisFront:asset.isFront];
        vc.view.backgroundColor = [UIColor blackColor];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (_currentIndexPath == indexPath){
        AlbumCollectionViewCell *cell = (AlbumCollectionViewCell*)[albumCV cellForItemAtIndexPath:indexPath];
        [cell.topView setHidden:YES];
        self.tag = YES;
        _currentIndexPath = nil;
    }
}

- (void) duplicateVideo:(id)sender{
    UIView *v = [sender superview];//获取父类view
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[[v superview] superview];//获取cell
      
    NSIndexPath *indexpath = [albumCV indexPathForCell:cell];//获取cell对应的indexpath;
      
    NSLog(@"设备图片按钮被点击:%ld        %ld",(long)indexpath.section,(long)indexpath.row);
    [CoreDataManager.sharedManager addVideo:_videos[indexpath.row].videoURL withAngle:0 completion:^(Video * newVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newVideo == NULL) {
                NSLog(@"复制失败");
                [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"复制失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                return;
            }
            NSLog(@"save asset 成功 %@", newVideo.videoFile);
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"复制成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
            [self getData];
        });
    }];
}

- (void) changeState:(id)sender{
    UIView *v = [sender superview];//获取父类view
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[[v superview] superview];//获取cell
    NSIndexPath *indexpath = [albumCV indexPathForCell:cell];//获取cell对应的indexpath;
    if(_videos[indexpath.row].video.isEdite){
        if([cell.stateChange isSelected]){
            [cell.stateChange setSelected:NO];
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"模型启用" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
        }else{
            [cell.stateChange setSelected:YES];
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"模型停用" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
        }
        
        NSLog(@"设备图片按钮被点击:%ld        %ld",(long)indexpath.section,(long)indexpath.row);
        [CoreDataManager.sharedManager changeUseForVideo:_videos[indexpath.row].video];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getData];
            [self->albumCV reloadData];
        });
//        _models[indexpath.row].model.state = !_models[indexpath.row].model.state;
    }else{
        NSLog(@"没有编辑，无法更改:%ld        %ld",(long)indexpath.section,(long)indexpath.row);
        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"请先上传" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
    }
    
//    [cell.contentView setHidden:YES];
}

- (void) bianji:(id)sender{
    
    UIView *v = [sender superview];//获取父类view
    AlbumCollectionViewCell *cell = (AlbumCollectionViewCell *)[[v superview] superview];//获取cell
      
    NSIndexPath *indexpath = [albumCV indexPathForCell:cell];//获取cell对应的indexpath;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入模型名称" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"存储" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *modelNameTextField = alertController.textFields.firstObject;
        cell.remarkLabel.text = modelNameTextField.text;
        [CoreDataManager.sharedManager changeNameForVideo:self->_videos[indexpath.row].video andName:modelNameTextField.text];
    }]];
    
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入模型名称";
        textField.text = cell.remarkLabel.text;
      }];
  
    [self presentViewController:alertController animated:true completion:nil];
   
}
#pragma mark - outlet
/**
 子控件配置
 */
- (void)outletConfig{
    UIColor *grayColor_1 = [UIColor blackColor];
    self.view.backgroundColor = grayColor_1;

    NSLog(@"000%f",[GlobalVar sharedInstance].kStatusBarH);
    //scrollView+view 相册的底
    topViewHeight = 30;
    CGFloat albumH = kScreenH-[GlobalVar sharedInstance].kStatusBarH-topViewHeight;

    secondView = [[UIView alloc]init];
    secondView.frame = CGRectMake(0, topViewHeight+[GlobalVar sharedInstance].kStatusBarH, kScreenW, albumH);
    
    [self.view addSubview:secondView];
    
    //rerokeView remindLabel
//    secondLabel = [[UILabel alloc]init];
//    [secondLabel setFont:globalVar.titleFont];
//    [secondLabel setTextAlignment:NSTextAlignmentCenter];
//    secondLabel.text = @"暂无视频";
//
//    secondLabel.frame = secondView.bounds;
//    [secondView addSubview:secondLabel];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *tmpString = @"numOfVideosPerRow";
    if ([def valueForKey:tmpString]) {
        numOfVideosPerRow = [[def valueForKey:tmpString] intValue];
    }
    else {
        numOfVideosPerRow = 3;
    }
    cellSize = CGSizeMake((kScreenW - (numOfVideosPerRow - 1) * 2) / numOfVideosPerRow, (kScreenW - (numOfVideosPerRow - 1) * 2) / numOfVideosPerRow / 4 * 5);
    //相册
    secondLayout = [[UICollectionViewFlowLayout alloc]init];
    
    albumCV = [[UICollectionView alloc]initWithFrame:secondView.bounds collectionViewLayout:secondLayout];
    albumCV.dataSource = self;
    albumCV.delegate = self;
    [albumCV registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"albumCell"];
//    albumCV.backgroundColor = [UIColor colorWithRed:0.693 green:0.898 blue:0.839 alpha:1];
    albumCV.backgroundColor = [UIColor colorWithRed:32/255.f green:32/255.f blue:32/255.f alpha:1];
    [secondView addSubview:albumCV];
    
    topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithRed:53/255.f green:53/255.f blue:53/255.f alpha:1];
    [self.view addSubview:topView];

    topLabel = [[UILabel alloc]init];
    [topLabel setFont: [UIFont boldSystemFontOfSize:20]];
    [topLabel setTextAlignment:NSTextAlignmentCenter];
    topLabel.text = @"Model  Swings";
    topLabel.textColor = [UIColor whiteColor];
    [topView addSubview:topLabel];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"deleteVideo" object:nil];
    
    
    settingBtn = [[UIButton alloc] init];
    [settingBtn addTarget:self action:@selector(settingForView) forControlEvents:UIControlEventTouchUpInside];
    [settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [topView addSubview:settingBtn];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(getStateView:)];
    longPressGesture.minimumPressDuration =0.5;
    longPressGesture.delegate = self;
    longPressGesture.delaysTouchesBegan=YES;
    [albumCV addGestureRecognizer: longPressGesture];
    self.tag = YES;
}

- (void)refreshData {
    if (!isProfessionAlbum) {
        [self getData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteVideo" object:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}
// 设置垂直间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section { return 2; }
//设置水平间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section { return 2; }

- (void)settingForView {
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (numOfVideosPerRow < 5) {
        UIAlertAction *bigger = [UIAlertAction actionWithTitle:@"缩小" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self->numOfVideosPerRow += 1;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setValue:@(self->numOfVideosPerRow) forKey:@"numOfVideosPerRow"];
            [def synchronize];
            self->cellSize = CGSizeMake((kScreenW - (self->numOfVideosPerRow - 1) * 2) / self->numOfVideosPerRow, (kScreenW - (self->numOfVideosPerRow - 1) * 2) / self->numOfVideosPerRow / 4 * 5);
            if (self->isProfessionAlbum) {
                [self getProfessionVideos];
            }
            else {
                [self getData];
            }
            [self->albumCV reloadData];
            [self->albumCV layoutIfNeeded];
        }];
        [bigger setValue:[UIImage imageNamed:@"zoomOut"] forKey:@"image"];
        [alertControl addAction:bigger];
    }
    if (numOfVideosPerRow > 1) {
        UIAlertAction *smaller = [UIAlertAction actionWithTitle:@"放大" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self->numOfVideosPerRow -= 1;
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setValue:@(self->numOfVideosPerRow) forKey:@"numOfVideosPerRow"];
            [def synchronize];
            self->cellSize = CGSizeMake((kScreenW - (self->numOfVideosPerRow - 1) * 2) / self->numOfVideosPerRow, (kScreenW - (self->numOfVideosPerRow - 1) * 2) / self->numOfVideosPerRow / 4 * 5);
            if (self->isProfessionAlbum) {
                [self getProfessionVideos];
            }
            else {
                [self getData];
            }
            [self->albumCV reloadData];
            [self->albumCV layoutIfNeeded];
        }];
        [smaller setValue:[UIImage imageNamed:@"zoomIn"] forKey:@"image"];
        [alertControl addAction:smaller];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertControl addAction:cancel];
    
    UIPopoverPresentationController *popover = alertControl.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.view;
        float tmp = self.navigationController.navigationBar.frame.size.height + 20;
        popover.sourceRect = CGRectMake(self.view.size.width - tmp - 3, 0, tmp, tmp);
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)outletLayout{
    [topView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.right.left.equalTo(self.view);
        maker.bottom.equalTo(albumCV.mas_top);
        maker.height.mas_equalTo(30);
    }];
    
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(topView);
        make.top.equalTo(topView);
        make.bottom.equalTo(topView);
    }];
    
    [buttomView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.right.left.bottom.equalTo(self.view);
        maker.height.mas_equalTo([GlobalVar sharedInstance].kTabbarH+21);
    }];
    
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
            make.centerX.equalTo(buttomView).multipliedBy(0.7);
        make.centerY.equalTo(buttomView);
    }];
    
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo([GlobalVar sharedInstance].kTabbarH - 21);
            make.centerX.equalTo(buttomView).multipliedBy(1.3);
        make.centerY.equalTo(buttomView);
    }];
    
    [myAlbumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(topView.mas_width).multipliedBy(0.07);
        make.left.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.equalTo(topView);
    }];
    
    [proBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(topView.mas_width).multipliedBy(0.07);
        make.left.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.equalTo(topView);
    }];
    
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(50);
        make.right.equalTo(topView);
        make.top.equalTo(topView).offset(-10);
    }];
}
#pragma mark - PHPicker
- (void)uploadVideoFromSystem {
    NSLog(@"从相册选择");
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
    config.selectionLimit = 0;
    config.filter = [PHPickerFilter videosFilter];
    config.preferredAssetRepresentationMode=PHPickerConfigurationAssetRepresentationModeCurrent;
    PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
    pickerViewController.delegate = self;
    [self presentViewController:pickerViewController animated:YES completion:nil];
 
}
- (NSString *)htmi_getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}
-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results{
    NSLog(@"-picker:%@ didFinishPicking:%@", picker, results);
    
    for (PHPickerResult *result in results) {
        NSLog(@"result: %@", result);
        
        NSLog(@"%@", result.assetIdentifier);
        NSLog(@"%@", result.itemProvider);
        
        // Get UIImage
        [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.movie" completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
            NSLog(@"url%@:",url);
            NSString * fielname =[NSString stringWithFormat:@"%@.%@",[self htmi_getCurrentTime],[[[url absoluteString] lastPathComponent] pathExtension]];
            NSURL *newurl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:fielname]];
            NSFileManager * manager = [NSFileManager defaultManager];
            NSError *copyerror = nil;
            if([manager copyItemAtURL:url toURL:newurl error:&copyerror]){
                NSLog(@"copy yes %@",newurl);
            }
            [CoreDataManager.sharedManager addVideo:newurl withAngle:0 completion:^(Video * newVideo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (newVideo == NULL) {
                        NSLog(@"保存失败");
                        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"保存失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                        return;
                    }
                    NSLog(@"save asset 成功 %@", newVideo.videoFile);
                    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"导入成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
                    [self getData];
                });
            }];
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark
-(void) getStateView:(UILongPressGestureRecognizer *)gestureRecognizer{
    NSLog(@"1");
    if(gestureRecognizer.state ==UIGestureRecognizerStateBegan){
        if (@available(iOS 10.0, *)) {
               UIImpactFeedbackGenerator *r = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
               [r prepare];
               [r impactOccurred];
            } else {
                // Fallback on earlier versions
            }
        self.tag = NO;
        
        CGPoint p=[gestureRecognizer locationInView:albumCV];

        NSIndexPath*indexPath =[albumCV indexPathForItemAtPoint:p];
        if(indexPath ==nil || indexPath.row == _videos.count){
            NSLog(@"couldn't find index path");
        }else{
            _currentIndexPath = indexPath;
            AlbumCollectionViewCell *cell =(AlbumCollectionViewCell*)[albumCV cellForItemAtIndexPath:indexPath];
            [cell.topView setHidden:NO];
        }
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
          
    }
}

@end
