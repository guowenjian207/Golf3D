//
//  ComposedView.h
//  MatchItUp
//
//  Created by 胡跃坤 on 2021/12/29.
//

#import <UIKit/UIKit.h>
#import "Video+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposedView : UIView <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *frameViewArray;
@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, weak) id delegate;
- (instancetype)initWithFrame:(CGRect)frame andisFront:(BOOL)isFrontParam andVideoURL:(NSURL *)videoURL andVideo:(Video *)video;
- (void)restoreSize;
- (void)saveCurrentState;
- (void)willDisappear;

@end

@protocol composedViewDelegate <NSObject>

- (void)changeHeightWithOffset:(CGFloat)offset;
- (BOOL)hasCompleteFrameSelect;
- (void)enableSelectFrame;
- (void)disableSelectFrame;
- (void)presentAlertView:(UIAlertController *)alert;

@end

NS_ASSUME_NONNULL_END
