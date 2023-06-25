//
//  CompesedForSpec.m
//  MatchItUp
//
//  Created by GWJ on 2023/4/11.
//

#import "CompesedForSpec.h"
#import "specificationCanvasView.h"
#import "ShowSpecCollectionViewCell.h"
#import "FrameCollectionViewCell.h"
#import "SpecificationAsset.h"
#import "SpecificationDataModel.h"
#import "CoreDataManager.h"
@interface CompesedForSpec()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *canvasToolArray;
@property (nonatomic, strong) NSMutableArray *frameIndexArray;
@end

@implementation CompesedForSpec{
    NSURL *_videoURL;
    
    UIImageView *topView;
    CGFloat topViewH;
    UIButton *backBtn;
    UICollectionView *showCollectionView;
    UICollectionView *specCollectionView;
    UIView *showView;
    
    NSMutableArray<SpecificationAsset*> *models;
    NSMutableDictionary *zhiyeModelData;
    
    NSMutableArray *frameIndexArray;
}

- (instancetype)initWithFrame:(CGRect)frame andisFront:(BOOL)isFrontParam andVideoURL:(NSURL *)videoURL andFrameIndexArray:(NSMutableArray*)frameIndexArray{
    self = [super initWithFrame:frame];
    if(self){
        _videoURL = videoURL;
        _frameIndexArray =frameIndexArray;

        topView = [[UIImageView alloc] init];
        [topView setImage:[UIImage imageNamed:@"topView"]];
        topView.userInteractionEnabled = YES;
        topViewH = 50;
        topView.frame = CGRectMake(0, 0, self.frame.size.width, topViewH);
        [self addSubview:topView];
        
        backBtn=[[UIButton alloc] init];
        backBtn.frame= CGRectMake(0, 0, 40, 40);
        [backBtn setCenter:CGPointMake(topView.frame.size.width / 7 * 6.5, 25)];
        [backBtn setImage:[UIImage imageNamed:@"right_back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backView)
              forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:backBtn];
        
        showView = [[UIView alloc]initWithFrame:CGRectMake(0, topViewH, frame.size.width, frame.size.height - topViewH -75)];
        showView.backgroundColor = [UIColor blackColor];
        [self addSubview:showView];
        
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        NSString *didSelectSpecSavePath = [filePath stringByAppendingPathComponent:@"didSelectSpec"];
        NSDictionary *selectModels = [NSDictionary dictionaryWithContentsOfFile:didSelectSpecSavePath];
        NSArray *keys = [selectModels allKeys];
        if(keys){
            models = [[SpecificationDataModel alloc] initWithSpecificatins:[[CoreDataManager sharedManager] getSpecificationOfUsingWith:keys]].assets;
        }
        
        NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"zhiyeModelData"];
        zhiyeModelData = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
        
        UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
        layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout1.minimumInteritemSpacing = 0;
        layout1.minimumLineSpacing = 0;
        layout1.itemSize = CGSizeMake(frame.size.width,frame.size.height - topViewH -75);
        showCollectionView = [[UICollectionView alloc]initWithFrame:showView.frame collectionViewLayout:layout1];
        [self addSubview:showCollectionView];
        [showCollectionView registerClass:[ShowSpecCollectionViewCell class] forCellWithReuseIdentifier:@"show"];
        showCollectionView.delegate = self;
        showCollectionView.dataSource = self;
        showCollectionView.scrollEnabled = NO;
        
        UICollectionViewFlowLayout *layout2 = [[UICollectionViewFlowLayout alloc] init];
        layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout2.minimumInteritemSpacing = 0;
        layout2.minimumLineSpacing = 0;
        layout2.itemSize = CGSizeMake(75,75);
        specCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, frame.size.height-75, frame.size.width, 75) collectionViewLayout:layout2];
        specCollectionView.backgroundColor = [UIColor colorWithRed:52/255.f green:52/255.f blue:52/255.f alpha:1];
        specCollectionView.delegate = self;
        specCollectionView.dataSource =self;
        [self addSubview:specCollectionView];
        [specCollectionView registerClass:[FrameCollectionViewCell class] forCellWithReuseIdentifier:@"spec"];
        if(models.count<8){
            CGFloat collectionViewWidth = specCollectionView.bounds.size.width;
            CGFloat cellWidth = 75*models.count;
            CGFloat inset = (collectionViewWidth - cellWidth) / 2.0;
            specCollectionView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeToolColor:) name:@"specToolColorChange" object:nil];
    }
    return  self;
}

- (void)hasChangeToolColor:(NSNotification *)notification{
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"zhiyeModelData"];
    if ([NSKeyedArchiver archiveRootObject:zhiyeModelData toFile:toolsSavePath]) {
        NSLog(@"写入成功");
    }
    else {
        NSLog(@"写入失败");
    }
}

- (void)backView{
    [self setHidden:YES];
}

- (void)displayAutoDrawLinesResult {
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[_videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *toolsSavePath = [filePath stringByAppendingPathComponent:@"zhiyeModelData"];
    zhiyeModelData = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
//    NSString *videoSavePath = [filePath stringByAppendingPathComponent:@"out_up.mp4"];
//    if([[NSFileManager defaultManager] fileExistsAtPath:videoSavePath]){
//        [self playVideoPIP];
//    }

}
#pragma mark collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return models.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView==showCollectionView){
        ShowSpecCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"show" forIndexPath:indexPath];
        [cell reset];
        cell.userInteractionEnabled=YES;
        SpecificationAsset *asset = nil;
        asset = models[indexPath.row];
        NSMutableArray<SpecificationTool*> *specTools = [zhiyeModelData valueForKey:asset.model.uuid];
        cell.specTools = specTools;
        cell.frameIndexArray = _frameIndexArray;
        [cell reloadData];
        return cell;
    }else{
        FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spec" forIndexPath:indexPath];
        SpecificationAsset *asset = nil;
        asset = models[indexPath.row];
        [cell setFrameImg:asset.cover withRate:0];
        return cell;
    }
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView==specCollectionView){
        FrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spec" forIndexPath:indexPath];
        [cell selectCell];
        [specCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        // 获取之前选中的cell
//        NSIndexPath *previousSelectedIndexPath = [[collectionView indexPathsForSelectedItems] firstObject];
//        FrameCollectionViewCell *previousSelectedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spec" forIndexPath:previousSelectedIndexPath];
//        [previousSelectedCell sesetting];
//        [specCollectionView reloadItemsAtIndexPaths:@[previousSelectedIndexPath]];
        cell.highlighted = YES;
        [showCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

@end
