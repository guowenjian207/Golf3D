//
//  SpecificationAlbumViewController.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/14.
//

#import "SpecificationAlbumViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "ZHPopupViewManager.h"
#import "SpecificationAlbumCollectionViewCell.h"
#import "SpecificationDataModel.h"
@interface SpecificationAlbumViewController()<UIImagePickerControllerDelegate>{
    
    GlobalVar *globalVar;
    
    UICollectionView *albumCV;
    UIView *secondView;
    UILabel *secondLabel;
    UICollectionViewFlowLayout *secondLayout;
}
@property(nonatomic,strong)UIImageView* bodyView;
@property(nonatomic,assign)bool tag;
@property(nonatomic,strong)NSIndexPath* currentIndexPath;

@property(nonatomic, strong) NSMutableArray<SpecificationAsset*> *models;
@end
@implementation SpecificationAlbumViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    globalVar = [GlobalVar sharedInstance];
    [self outletConfig];
    
}

- (void)viewWillAppear:(BOOL)animated {
    // 禁用返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    [self.navigationController.navigationBar setHidden:YES];
    
    [self getData];

}
#pragma mark - setModels getmodels
- (void)getData{
    [self getVideos];
    [albumCV reloadData];
}

- (void)getVideos{
    self.models = [[SpecificationDataModel alloc] initWithSpecificatins:[[CoreDataManager sharedManager] getSpecification]].assets;
//    if (self.videos.count>0){
//        [NetworkingManager.sharedNetworkingManager uploadSS:self.videos[0]];
//    }
}
#pragma mark - outlet
/**
 子控件配置
 */
- (void)outletConfig{
    UIColor *grayColor_1 = [UIColor colorWithWhite:0.5 alpha:1];
    self.view.backgroundColor = grayColor_1;
    //scrollView+view 相册的底
    secondView = [[UIView alloc]init];
    secondView.frame = self.view.bounds;
    secondView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:secondView];
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_top);
    }];
    //rerokeView remindLabel
    secondLabel = [[UILabel alloc]init];
    [secondLabel setFont:globalVar.titleFont];
    [secondLabel setTextAlignment:NSTextAlignmentCenter];
    secondLabel.text = @"暂无指标";
//
    secondLabel.frame = secondView.bounds;
    [secondView addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_top);
    }];
    
//    cellSize = CGSizeMake((kScreenW - (numOfVideosPerRow - 1) * 4) / numOfVideosPerRow, (kScreenW - (numOfVideosPerRow - 1) * 4) / numOfVideosPerRow / 720 * 1280);
//    //相册
    secondLayout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat kItemWidth = (kScreenW/5*2-4)/3;
    CGFloat kItemHeight = kItemWidth/4*5;
    secondLayout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    albumCV = [[UICollectionView alloc]initWithFrame:secondView.bounds collectionViewLayout:secondLayout];
    albumCV.dataSource = self;
    albumCV.delegate = self;
    [albumCV registerClass:[SpecificationAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"albumCell"];
    albumCV.backgroundColor = [UIColor blackColor];
    [secondView addSubview:albumCV];
    [albumCV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_top);
    }];
    _toolView = [[UIView alloc]init];
    _toolView.backgroundColor = [UIColor colorWithRed:32/255.f green:32/255.f blue:32/255.f alpha:1];
    [albumCV addSubview:_toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [self toolButtonLine1Set];
    [self toolButtonLine2Set];
    
    _bodyView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"身体部分-1"]];
    [_toolView addSubview:_bodyView];
    CGFloat buttonWidth = (self.view.frame.size.width/5*2-5)/6;
    [_bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(-2*buttonWidth-1);
        make.top.equalTo(self.view.mas_top);
    }];
    
    _cover = [[UIImageView alloc]init];
    [_toolView addSubview:_cover];
    [_cover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_toolView.mas_right);
        make.top.equalTo(_toolView.mas_top);
        make.width.height.equalTo(_toolView.mas_width).multipliedBy(0.28);
    }];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(getStateView:)];
    longPressGesture.minimumPressDuration =0.5;
    longPressGesture.delegate = self;
    longPressGesture.delaysTouchesBegan=YES;
    [albumCV addGestureRecognizer: longPressGesture];
    [_toolView setHidden:YES];
    self.tag = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    // 允许用户交互
    _bodyView.userInteractionEnabled = YES;
 
    [_bodyView addGestureRecognizer:tap];

}

-(void) toolButtonLine1Set{
    CGFloat buttonWidth = (self.view.frame.size.width/5*2-5)/6;
    UIButton* butt1 = [[UIButton alloc]init];
    butt1.backgroundColor = [UIColor whiteColor];
    [butt1 addTarget:self action:@selector(drawLinehorizontal) forControlEvents:UIControlEventTouchUpInside];
    [butt1 setImage:[UIImage imageNamed:@"toolButton1"] forState:UIControlStateNormal];
    [_toolView addSubview:butt1];
    [butt1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt2 = [[UIButton alloc]init];
    butt2.backgroundColor = [UIColor whiteColor];
    [butt2 addTarget:self action:@selector(drawLine) forControlEvents:UIControlEventTouchUpInside];
    [butt2 setImage:[UIImage imageNamed:@"toolButton2"] forState:UIControlStateNormal];
    [_toolView addSubview:butt2];
    [butt2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt1.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt3 = [[UIButton alloc]init];
    butt3.backgroundColor = [UIColor whiteColor];
    [butt3 addTarget:self action:@selector(drawLineAngle) forControlEvents:UIControlEventTouchUpInside];
    [butt3 setImage:[UIImage imageNamed:@"toolButton3"] forState:UIControlStateNormal];
    [_toolView addSubview:butt3];
    [butt3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt2.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt4 = [[UIButton alloc]init];
    butt4.backgroundColor = [UIColor whiteColor];
    [butt4 addTarget:self action:@selector(headLine1) forControlEvents:UIControlEventTouchUpInside];
    [butt4 setImage:[UIImage imageNamed:@"toolButton4"] forState:UIControlStateNormal];
    [_toolView addSubview:butt4];
    [butt4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt3.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt5 = [[UIButton alloc]init];
    butt5.backgroundColor = [UIColor whiteColor];
    [butt5 addTarget:self action:@selector(drawAngle) forControlEvents:UIControlEventTouchUpInside];
    [butt5 setImage:[UIImage imageNamed:@"toolButton5"] forState:UIControlStateNormal];
    [_toolView addSubview:butt5];
    [butt5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt4.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt6 = [[UIButton alloc]init];
    butt6.backgroundColor = [UIColor whiteColor];
    [butt6 addTarget:self action:@selector(headLine1) forControlEvents:UIControlEventTouchUpInside];
    [butt6 setImage:[UIImage imageNamed:@"toolButton6"] forState:UIControlStateNormal];
    [_toolView addSubview:butt6];
    [butt6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt5.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom).offset(-buttonWidth-1);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}

-(void) toolButtonLine2Set{
    CGFloat buttonWidth = (self.view.frame.size.width/5*2-5)/6;
    UIButton* butt1 = [[UIButton alloc]init];
    butt1.backgroundColor = [UIColor whiteColor];
    [butt1 addTarget:self action:@selector(drawBrokenLine) forControlEvents:UIControlEventTouchUpInside];
    [butt1 setImage:[UIImage imageNamed:@"toolButton7"] forState:UIControlStateNormal];
    [_toolView addSubview:butt1];
    [butt1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt2 = [[UIButton alloc]init];
    butt2.backgroundColor = [UIColor whiteColor];
    [butt2 addTarget:self action:@selector(drawRect) forControlEvents:UIControlEventTouchUpInside];
    [butt2 setImage:[UIImage imageNamed:@"toolButton8"] forState:UIControlStateNormal];
    [_toolView addSubview:butt2];
    [butt2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt1.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt3 = [[UIButton alloc]init];
    butt3.backgroundColor = [UIColor whiteColor];
    [butt3 addTarget:self action:@selector(drawQuadrilateral) forControlEvents:UIControlEventTouchUpInside];
    [butt3 setImage:[UIImage imageNamed:@"toolButton9"] forState:UIControlStateNormal];
    [_toolView addSubview:butt3];
    [butt3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt2.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt4 = [[UIButton alloc]init];
    butt4.backgroundColor = [UIColor whiteColor];
    [butt4 addTarget:self action:@selector(headLine1) forControlEvents:UIControlEventTouchUpInside];
    [butt4 setImage:[UIImage imageNamed:@"toolButton10"] forState:UIControlStateNormal];
    [_toolView addSubview:butt4];
    [butt4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt3.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt5 = [[UIButton alloc]init];
    butt5.backgroundColor = [UIColor whiteColor];
    [butt5 addTarget:self action:@selector(drawRuler) forControlEvents:UIControlEventTouchUpInside];
    [butt5 setImage:[UIImage imageNamed:@"toolButton11"] forState:UIControlStateNormal];
    [_toolView addSubview:butt5];
    [butt5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt4.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
    UIButton *butt6 = [[UIButton alloc]init];
    butt6.backgroundColor = [UIColor whiteColor];
    [butt6 addTarget:self action:@selector(removeCurrentTool) forControlEvents:UIControlEventTouchUpInside];
    [butt6 setImage:[UIImage imageNamed:@"toolButton12"] forState:UIControlStateNormal];
    [_toolView addSubview:butt6];
    [butt6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(butt5.mas_right).offset(1);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}
#pragma mark draw Line
-(void)headLine1{
    
}

- (void) headposition1{
    
}

- (void) drawLinehorizontal{
    if(_currentPart == Head){
        [self.delegate headLine];
    }
}

- (void) drawLine{
    if(_currentPart == Head){
        [self.delegate headLine];
    }else if (_currentPart == LeadForearm){
        [self.delegate leadForearmLine];
    }else if (_currentPart == Shaft){
        [self.delegate shaftLine];
    }else if (_currentPart == LowBody){
        [self.delegate hipDepth];
    }
}

- (void) drawBrokenLine{
    if(_currentPart == Head){
        [self.delegate headposition];
    }
}

- (void) drawRect{
    if(_currentPart == Head){
        [self.delegate headFrame];
    }
}

- (void) drawQuadrilateral{
    if(_currentPart == LowBody){
        [self.delegate lowBodyPosition];
    }
}

- (void) drawAngle{
    if(_currentPart == LeadElbow){
        [self.delegate leadElbowAngle];
    }else if (_currentPart == TrailElbow){
        [self.delegate trailElbowAngle];
    }else if (_currentPart == LeadLeg){
        [self.delegate leadLegAngle];
    }else if (_currentPart == TrailLeg){
        [self.delegate trailLegAngle];
    }
}

- (void) drawLineAngle{
    if(_currentPart == Shoulder){
        [self.delegate shoulderTilt];
    }else if (_currentPart == Shaft){
        [self.delegate shaftLineToArmpit];
    }else if (_currentPart == LeadForearm){
        [self.delegate elbowHosel];
    }
}

- (void) drawRuler{
    if(_currentPart == LowBody){
        [self.delegate kneeGaps];
    }
}

- (void) removeCurrentTool{
    [self.delegate removeCurrentLine];
}

#pragma mark select Body Part
- (void)doTap:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_bodyView];
    for (int i = 0; i < sizeof(bodyPartPosition)/sizeof(double)*2; ++i){
        CGPoint x0 = CGPointMake(bodyPartPosition[i][0], bodyPartPosition[i][1]);
        x0.x = x0.x*_bodyView.frame.size.width;
        x0.y = x0.y*_bodyView.frame.size.height;
        CGFloat dis = [self computeDisWith:x0 andP1:point];
        if(dis < 20){
            _currentPart = 1 << i;
            [_bodyView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"身体部分-%d",i+2]]];
            NSLog(@"%lu",(unsigned long)_currentPart);
            break;
        }
        [_bodyView setImage:[UIImage imageNamed:@"身体部分-1"]];
    }
}
- (CGFloat)computeDisWith:(CGPoint)p1 andP1:(CGPoint)p2{
    CGFloat a = p2.y - p1.y;
    CGFloat b = p1.x - p2.x;
    CGFloat d = sqrt(pow(a, 2) + pow(b, 2));
    return d;
}
#pragma mark - CollectionViewDelegate + CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _models.count+1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SpecificationAlbumCollectionViewCell *cell = (SpecificationAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
//    [cell.bottomView setBackgroundColor:[UIColor darkGrayColor]];
//    [cell.contentView setHidden:YES];
//    cell.timeLabel.text = nil;
//    cell.remarkLabel.text = nil;
    [cell resettingCell];
    if(indexPath.row == _models.count || _models.count == 0){
        cell.backImageView.image = [UIImage imageNamed:@"upload"];
    }else{
        SpecificationAsset *asset = nil;
        asset = _models[indexPath.row];
        if (cell == nil){
            cell = [[SpecificationAlbumCollectionViewCell alloc] init];
        }
        cell.backImageView.image= asset.cover;
        if(asset.isEdite == YES){
            if(asset.state == YES){
                [cell.stateChange setSelected:NO];
                [cell.bottomView setBackgroundColor:[UIColor greenColor]];
            }else{
                [cell.stateChange setSelected:YES];
                [cell.bottomView setBackgroundColor:[UIColor redColor]];
            }
        }
        if(asset.updataTime){
            cell.timeLabel.text = asset.updataTime;
        }
        if(asset.name){
            cell.remarkLabel.text = asset.name;
        }
        [cell.deleteButton addTarget:self action:@selector(deleteSpec:) forControlEvents:UIControlEventTouchUpInside];
        [cell.stateChange addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tag && indexPath.row < _models.count){
        _currentSpecification = _models[indexPath.row].model;
        SpecificationAsset *asset = nil;
        asset = _models[indexPath.row];
        [self beginSetSpecificationWithAsset:asset];
    }else if(_currentIndexPath == indexPath){
        SpecificationAlbumCollectionViewCell *cell =(SpecificationAlbumCollectionViewCell*)[albumCV cellForItemAtIndexPath:indexPath];
        [cell.contentView setHidden:YES];
        self.tag = YES;
        _currentIndexPath = nil;
    }else if(indexPath.row == _models.count || _models.count==0){
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.selectionLimit = 0;
        config.filter = [PHPickerFilter imagesFilter];
        config.preferredAssetRepresentationMode=PHPickerConfigurationAssetRepresentationModeCurrent;
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
        pickerViewController.delegate = self;
        [self presentViewController:pickerViewController animated:YES completion:nil];
    }
}

-(void)beginSetSpecificationWithAsset:(SpecificationAsset*)asset{
    [_toolView setHidden:NO];
    _cover.image = asset.cover;
    [self.delegate hiddenViewAppearWithAsset:asset];
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section { return 1; }
//设置水平间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section { return 1; }
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 0);
}
#pragma imagePicker
-(void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results{
    NSLog(@"-picker:%@ didFinishPicking:%@", picker, results);
    
    for (PHPickerResult *result in results) {
        NSLog(@"result: %@", result);
        
        NSLog(@"%@", result.assetIdentifier);
        NSLog(@"%@", result.itemProvider);
        
        // Get UIImage
        [result.itemProvider loadFileRepresentationForTypeIdentifier:@"public.image" completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
            NSLog(@"url%@:",url);
            NSString * fielname =[NSString stringWithFormat:@"%@.%@",[self htmi_getCurrentTime],[[[url absoluteString] lastPathComponent] pathExtension]];
            NSURL *newurl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:fielname]];
            NSFileManager * manager = [NSFileManager defaultManager];
            NSError *copyerror = nil;
            if([manager copyItemAtURL:url toURL:newurl error:&copyerror]){
                NSLog(@"copy yes %@",newurl);
            }
            [CoreDataManager.sharedManager addSpecification:newurl completion:^(SpecificationModel * _Nonnull newModel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (newModel == NULL) {
                        NSLog(@"保存失败");
                        [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeText title:@"保存失败" icon:NULL autoHideAfterDelayIfNeed:@1];
                        return;
                    }
                    NSLog(@"save asset 成功 %@", newModel.shotPicFile);
                    [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"导入成功" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
                    [self getData];
                    [self->albumCV reloadData];
                });
            }];
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)htmi_getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}
#pragma 手势
-(void) getStateView:(UILongPressGestureRecognizer *)gestureRecognizer{
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
        if(indexPath ==nil || indexPath.row == _models.count){
            NSLog(@"couldn't find index path");
        }else{
            _currentIndexPath = indexPath;
            SpecificationAlbumCollectionViewCell *cell =(SpecificationAlbumCollectionViewCell*)[albumCV cellForItemAtIndexPath:indexPath];
            [cell.contentView setHidden:NO];
        }
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
          
    }
}
- (void) deleteSpec:(id)sender{
    UIView *v = [sender superview];//获取父类view
    SpecificationAlbumCollectionViewCell *cell = (SpecificationAlbumCollectionViewCell *)[v superview];//获取cell
      
    NSIndexPath *indexpath = [albumCV indexPathForCell:cell];//获取cell对应的indexpath;
      
    NSLog(@"设备图片按钮被点击:%ld        %ld",(long)indexpath.section,(long)indexpath.row);
    [[CoreDataManager sharedManager] deleteSpecification:_models[indexpath.row].model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getData];
        [self->albumCV reloadData];
    });
    [cell.contentView setHidden:YES];
    
}
- (void) changeState:(id)sender{
    UIView *v = [sender superview];//获取父类view
    SpecificationAlbumCollectionViewCell *cell = (SpecificationAlbumCollectionViewCell *)[v superview];//获取cell
    NSIndexPath *indexpath = [albumCV indexPathForCell:cell];//获取cell对应的indexpath;
    if(_models[indexpath.row].model.isEdit){
        if([cell.stateChange isSelected]){
            [cell.stateChange setSelected:NO];
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"指标启用" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
        }else{
            [cell.stateChange setSelected:YES];
            [ZHPopupViewManager.sharedManager showPromptViewWithSuperview:self.view mode:MBProgressHUDModeCustomView title:@"指标停用" icon:[UIImage imageNamed:@"complete"] autoHideAfterDelayIfNeed:@1];
        }
        
        NSLog(@"设备图片按钮被点击:%ld        %ld",(long)indexpath.section,(long)indexpath.row);
        [CoreDataManager.sharedManager updataSpecificationState:!_models[indexpath.row].state withUuid:_models[indexpath.row].uuid];
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
@end
