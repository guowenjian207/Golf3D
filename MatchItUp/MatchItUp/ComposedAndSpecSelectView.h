//
//  ComposedView.h
//  FrameCut
//
//  Created by 郭文坚 on 2022/4/7.
//

#import <UIKit/UIKit.h>
#import "Video+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposedAndSpecSelectView : UIView <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *frameViewArray;
@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, weak) id delegate;
- (instancetype)initWithFrame:(CGRect)frame andisFront:(BOOL)isFrontParam andVideoURL:(NSURL *)videoURL andVideo:(nonnull Video *)video andFrameIndexArray:(NSMutableArray*)frameIndexArray andSpecModels:(NSMutableArray*)models;
- (void)restoreSize;
- (void)saveCurrentState;
- (void)willDisappear;

@end

@protocol ComposedAndSpecSelectViewwDelegate <NSObject>

- (void)changeHeightWithOffset:(CGFloat)offset;
- (BOOL)hasCompleteFrameSelect;
- (void)enableSelectFrame;
- (void)disableSelectFrame;
- (void)presentAlertView:(UIAlertController *)alert;
- (void)videoModeChange:(NSNumber *)num;
@end

NS_ASSUME_NONNULL_END
