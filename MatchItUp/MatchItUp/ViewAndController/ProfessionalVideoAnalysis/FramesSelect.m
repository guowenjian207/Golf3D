//
//  FramesSelect.m
//  MatchItUp
//
//  Created by GWJ on 2023/4/4.
//

#import "FramesSelect.h"
#import "CoreDataManager.h"

#define kScreenH UIScreen.mainScreen.bounds.size.height
#define kScreenW UIScreen.mainScreen.bounds.size.width

@interface FramesSelect()

@end

@implementation FramesSelect{
    NSString *filePath;
    NSMutableArray *frameIndexArray;
    NSMutableArray *frameStateArray;
    NSIndexPath *currentIndexPath;
    NSURL *videoUrl;
    NSNumber *videoId;
    
    Video* _video;
    BOOL isFront;
    
}

- (instancetype)initWithFrame:(CGRect)frame andVideo:(Video*) video andVideoURL:(NSURL *)videoURL andFameIndexArray:(NSMutableArray*) array{
    self = [super initWithFrame:frame];
    if(self){
        
        videoUrl = videoURL;
        _video = video;
        isFront = video.isFront;
        
        self.clipsToBounds = YES;
        UIView *tmpView = [[UIView alloc]initWithFrame:frame];
        [self addSubview:tmpView];
        tmpView.backgroundColor = [UIColor colorWithRed:32/255.f green:32/255.f blue:32/255.f alpha:1];
        [tmpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.bottom.equalTo(self);
        }];
        
        _specModelSelect = [[UIButton alloc]init];
        _specModelSelect.backgroundColor = [UIColor redColor];
        [tmpView addSubview:_specModelSelect];
        [_specModelSelect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(13.5);
            make.width.mas_equalTo(frame.size.width/4);
            make.height.mas_equalTo(frame.size.width/4/3*4);
            make.right.equalTo(self).offset(-frame.size.width/2-20);
        }];
        
        _drawRes = [[UIButton alloc]init];
        _drawRes.backgroundColor = [UIColor redColor];
        [tmpView addSubview:_drawRes];
        [_drawRes mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(13.5);
            make.width.mas_equalTo(frame.size.width/4);
            make.height.mas_equalTo(frame.size.width/4/3*4);
            make.left.equalTo(self).offset(frame.size.width/2+20);
        }];
        
        [_specModelSelect setHidden:YES];
        [_drawRes setHidden:YES];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _framesCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 834, 305) collectionViewLayout:layout];
        _framesCollectionView.backgroundColor = [UIColor colorWithRed:32/255.f green:32/255.f blue:32/255.f alpha:1];
        _framesCollectionView.dataSource = self;
        _framesCollectionView.pagingEnabled = YES;
        _framesCollectionView.delegate = self;
        [_framesCollectionView registerClass:[FramesSelectCellCollectionViewCell class] forCellWithReuseIdentifier:@"framesSelectCell"];
        [self addSubview:_framesCollectionView];
        
        _frameViewArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < 13; i++) {
            [_frameViewArray addObject:@-1];
        }
        
        filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
        
        NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
        frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
        
        NSString *frameStateSavePath = [filePath stringByAppendingPathComponent:@"frameState"];
        frameStateArray = [NSMutableArray arrayWithContentsOfFile:frameStateSavePath];
        if(!frameStateArray){
            frameStateArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < 13; i++) {
                [frameStateArray addObject:@-1];
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasChangeFront) name:@"changeVideoFront" object:nil];
    }
    return  self;
}

- (void)hasChangeFront {
    isFront = !isFront;
    [_framesCollectionView reloadData];
}

#pragma mark - CollectionViewDelegate + CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 13;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    FramesSelectCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"framesSelectCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[FramesSelectCellCollectionViewCell alloc] init];
    }
    [cell resettingCell];
    if(isFront){
        UIImage *img = [UIImage imageNamed:[@"frontFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
        cell.leftImageView.image = img;
    }else{
        UIImage *img = [UIImage imageNamed:[@"sideFrame" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
        cell.leftImageView.image = img;
    }
    
    
    if([frameIndexArray[indexPath.row] isKindOfClass:[NSData class]]){
        cell.rightImageView.image = [UIImage imageWithData:frameIndexArray[indexPath.row]];
        [cell.lockStateChange addTarget:self action:@selector(lockStateChange:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView setHidden:NO];
        if([frameStateArray[indexPath.row] isEqual:@1]){
            [cell.lockStateChange setSelected:YES];
        }
    }else{
        cell.rightImageView.image = [UIImage imageNamed:[@"frontFrameTwo" stringByAppendingFormat:@"%d", (int)indexPath.row+1]];
    }
    
    _frameViewArray[indexPath.row] = cell.rightImageView;
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSArray * array = [_framesCollectionView visibleCells];
    NSIndexPath * indexPath = [_framesCollectionView indexPathForCell:array.firstObject];
    [self.delegate selectToFrame:(NSIndexPath*)indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"是我");
}
#pragma mark
-(void)lockStateChange:(id)sender{
    UIView *v = [sender superview];//获取父类view
    FramesSelectCellCollectionViewCell *cell = (FramesSelectCellCollectionViewCell *)[v superview];//获取cell
    NSIndexPath *indexpath = [_framesCollectionView indexPathForCell:cell];//获取cell对应的indexpath;
    [cell.lockStateChange setSelected:YES];
    frameStateArray[indexpath.row] = @1;
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameState"];
    if ([frameStateArray writeToFile:frameIdxSavePath atomically:NO]) {
        NSLog(@"图片状态写入成功");
        [self.delegate frameLockWithIndexPath:indexpath];
    }
    else {
        NSLog(@"图片状态写入失败");
    }
    for(int i = 0 ;i < 13; i++){
        if([frameStateArray[i] isEqual:@-1]){
            return;
        }
    }
    NSString *videoIdSavePath = [filePath stringByAppendingPathComponent:@"videoIdData"];
    videoId = [NSKeyedUnarchiver unarchiveObjectWithFile:videoIdSavePath];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@3 forKey:[NSString stringWithFormat:@"videoModelState%@",videoId]];
    [def synchronize];
}

-(void) updataframeIndexArray{
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    frameIndexArray = [NSMutableArray arrayWithContentsOfFile:frameIdxSavePath];
}
@end
