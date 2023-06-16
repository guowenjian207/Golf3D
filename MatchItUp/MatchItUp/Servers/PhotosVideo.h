//
//  PhotosVideo.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "GlobalVar.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotosVideo : NSObject

@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,strong) UIImage *img;
@property(nonatomic,strong) NSString *secs;
@property(nonatomic,strong) NSURL *url;

- (instancetype)initWithPHAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
