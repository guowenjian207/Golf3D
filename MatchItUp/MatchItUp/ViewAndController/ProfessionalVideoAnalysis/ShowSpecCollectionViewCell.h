//
//  ShowSpecCollectionViewCell.h
//  MatchItUp
//
//  Created by GWJ on 2023/4/13.
//

#import <UIKit/UIKit.h>
#import "specificationCanvasView.h"
#import "SpecificationTool.h"
NS_ASSUME_NONNULL_BEGIN

@interface ShowSpecCollectionViewCell : UICollectionViewCell<UICollectionViewDelegate,UICollectionViewDataSource,specificationCanvasDelegate>
@property (nonatomic, strong) NSMutableArray *frameViewArray;
@property (nonatomic, strong) NSMutableArray *frameIndexArray;
@property (nonatomic, strong) NSMutableArray *specTools;
@property (nonatomic, strong) specificationCanvasView *speCanvas;
@property (nonatomic, strong) specificationCanvasView *bigViewCanvas;

- (void)reset;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
