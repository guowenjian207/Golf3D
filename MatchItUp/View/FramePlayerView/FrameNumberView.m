//
//  FrameNumberView.m
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/7/27.
//

#import "FrameNumberView.h"
#import "ButtonCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface FrameNumberView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) UIButton *turnButoon;

@end

@implementation FrameNumberView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
        [self layoutView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelButton:) name:@"deleteFrameAtIndex" object:nil];
    return self;
}

- (void)initView {
    // 创建collectionView的布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 行列间距
    static const float kSpacing = 10;
    layout.minimumLineSpacing = kSpacing;
    layout.minimumInteritemSpacing = kSpacing;
    // 设置item大小
    CGFloat kItemWidth = ([UIScreen mainScreen].bounds.size.width - 100 - 3 * 10) / 4;
    CGFloat kItemHeight = kItemWidth / 3 * 4;
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    
    // 创建 collectionView
    self.buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.buttonCollectionView.backgroundColor = [UIColor grayColor];
    // self.alpha = 0.8;
    self.buttonCollectionView.showsVerticalScrollIndicator = NO;
    self.buttonCollectionView.scrollEnabled = YES;
    [self addSubview:_buttonCollectionView];
    self.buttonCollectionView.delegate = self;
    self.buttonCollectionView.dataSource = self;
    [self.buttonCollectionView registerClass:[ButtonCollectionViewCell class] forCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID"];
    
    _turnButoon = [UIButton buttonWithType:UIButtonTypeCustom];
    [_turnButoon setImage:[UIImage imageNamed:@"turn"] forState:UIControlStateNormal];
    [_turnButoon addTarget:self action:@selector(turnImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_turnButoon];
}

- (void)layoutView {
    [self.buttonCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.top.left.equalTo(self);
    }];
    
    [self.turnButoon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
            make.right.equalTo(self).offset(-10);
            make.bottom.equalTo(self).offset(-10);
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 13;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MAINCOLLECTIONVIEWID" forIndexPath:indexPath];
    [cell setImageAndText:[NSString stringWithFormat:@"%ld", indexPath.row + 1] withIsFront:_isFront];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonCollectionViewCell *cell = (ButtonCollectionViewCell *)[self.buttonCollectionView cellForItemAtIndexPath:indexPath];
    [cell buttonSelect];
    [self.delegate selectFrameWithIndex:(int)indexPath.row];
}

- (void)turnImage {
    for (int i = 0; i < 13; i++) {
        NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:i inSection:0];
        ButtonCollectionViewCell *cell = (ButtonCollectionViewCell *)[self.buttonCollectionView cellForItemAtIndexPath:tmpPath];
        [cell turnImage:[NSString stringWithFormat:@"%d", i + 1]];
    }
}

- (void)hasSelectedIndex:(NSArray *)array {
    for (int i = 0; i < 13; i++) {
        NSNumber *tmp = array[i];
        if ([tmp intValue] != -1) {
            ButtonCollectionViewCell *cell = (ButtonCollectionViewCell *)[self.buttonCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell buttonSelect];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteFrameAtIndex" object:nil];
}

- (void)cancelButton:(NSNotification *)noti {
    int index = ((NSNumber *)[noti.userInfo objectForKey:@"index"]).intValue;
    NSIndexPath *tmpPath = [NSIndexPath indexPathForRow:index inSection:0];
    ButtonCollectionViewCell *cell = (ButtonCollectionViewCell *)[self.buttonCollectionView cellForItemAtIndexPath:tmpPath];
    [cell buttonCancel];
    
    [self.delegate deselectFrameWithIndex:index];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
