//
//  PlayerRateView.h
//  MatchItUp
//
//  Created by 安子和 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerRateViewDelegate <NSObject>

- (void)setPlayerRate:(float)rate;

@end

@interface PlayerRateView : UIView

@property(nonatomic, weak) id<PlayerRateViewDelegate> delegate;

//float
@property(nonatomic, strong) NSArray<NSNumber*> *rates;

- (instancetype)initWithRates:(NSArray<NSNumber*> *) rates;

@end

NS_ASSUME_NONNULL_END
