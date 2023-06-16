//
//  AlbumViewController.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"
#import "CoreDataManager.h"
#import "AlbumCollectionViewCell.h"
#import "PhotosVideo.h"
#import "_ScrollPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumViewController : UIViewController<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(atomic,assign) int selectedSegmentIndex;

@end

NS_ASSUME_NONNULL_END
