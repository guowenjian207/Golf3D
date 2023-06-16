//
//  FramesSelect.h
//  MatchItUp
//
//  Created by GWJ on 2023/4/4.
//

#import <UIKit/UIKit.h>
#import "FramesSelectCellCollectionViewCell.h"
#import "HomeViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FramesSelect : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) id delegate;
@property(nonatomic,strong) UICollectionView* framesCollectionView;
@property (nonatomic, strong) NSMutableArray *frameViewArray;
@property (nonatomic, strong) UIButton *specModelSelect;
@property (nonatomic, strong) UIButton *drawRes;

- (instancetype)initWithFrame:(CGRect)frame andVideo:(Video*) video andVideoURL:(NSURL *)videoURL andFameIndexArray:(NSMutableArray*) array;

-(void) updataframeIndexArray;

@end

@protocol FramesSelectDelegate <NSObject>
-(void) selectToFrame:(NSIndexPath*)frameN;
-(void) frameLockWithIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
