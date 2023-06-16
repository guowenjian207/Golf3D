//
//  SpecificationAlbumViewController.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/14.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import "GlobalVar.h"
#import "CoreDataManager.h"
#import "AlbumCollectionViewCell.h"
#import "SpecificationAsset.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, BodyParts){
    None            = 0,
    Head            = 1,
    Shoulder        = 1 << 1,
    LeadElbow       = 1 << 2,
    TrailElbow      = 1 << 3,
    LeadLeg         = 1 << 4,
    TrailLeg        = 1 << 5,
    LowBody         = 1 << 6,
    LeadForearm     = 1 << 7,
    TrailForearm    = 1 << 8,
    LeadShank       = 1 << 9,
    TrailShank      = 1 << 10,
    Shaft           = 1 << 11
};

static double bodyPartPosition[12][2] = {
    415.0/816,
    288.0/1246,
    
    415.0/816,
    417.0/1246,
    
    529.0/816,
    515.0/1246,
    
    309.0/816,
    515.0/1246,
    
    460.0/816,
    799.0/1246,
    
    370.0/816,
    799.0/1246,
    
    415.0/816,
    667.0/1246,
    
    541.0/816,
    631.0/1246,
    
    292.0/816,
    631.0/1246,
    
    456.0/816,
    1002.0/1246,
    
    375.0/816,
    1002.0/1246,
    
    635.0/816,
    969.0/1246
};
@protocol SpecificationAlbumViewControllerDelegate;

@interface SpecificationAlbumViewController : UIViewController<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(atomic,assign) int selectedSegmentIndex;
@property (nonatomic, weak) id<SpecificationAlbumViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) SpecificationModel *currentSpecification;
@property (nonatomic, strong) UIImageView *cover;
@property(nonatomic,assign) BodyParts currentPart;
- (void) getData;
@end
@protocol SpecificationAlbumViewControllerDelegate <NSObject>
- (void) hiddenViewAppearWithAsset:(SpecificationAsset*)asset;
- (void) headLine;
- (void) shaftLine;
- (void) leadForearmLine;
- (void) headposition;
- (void) headFrame;
- (void) lowBodyPosition;
- (void) trailElbowAngle;
- (void) leadElbowAngle;
- (void) trailLegAngle;
- (void) leadLegAngle;
- (void) shoulderTilt;
- (void) removeCurrentLine;
- (void) kneeGaps;
- (void) elbowHosel;
- (void) shaftLineToArmpit;
-(void) hipDepth;
@end
NS_ASSUME_NONNULL_END
