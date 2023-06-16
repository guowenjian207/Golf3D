//
//  SpecificationViewController.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/8.
//

#import <Foundation/Foundation.h>
#import "GolferModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SpecificationViewController: GLKViewController

@property (nonatomic, strong) GolferModel* gl;
@property (nonatomic, strong) NSMutableArray *frameViewArray;//
@property (nonatomic, strong) NSMutableArray *frameNumArray;//
@property (nonatomic, strong) NSMutableArray *frameIndexArray;//
- (instancetype)initWithModel:(GolferModel*) gm andBackgroundID:(int) backgroundID andPlayerName:(NSString*) player_name;
@end

NS_ASSUME_NONNULL_END
