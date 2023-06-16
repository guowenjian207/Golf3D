//
//  CompesedForSpec.h
//  MatchItUp
//
//  Created by GWJ on 2023/4/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CompesedForSpec : UIView

- (instancetype)initWithFrame:(CGRect)frame andisFront:(BOOL)isFrontParam andVideoURL:(NSURL *)videoURL andFrameIndexArray:(NSMutableArray*)frameIndexArray;
@end

NS_ASSUME_NONNULL_END
