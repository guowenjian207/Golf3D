//
//  SpecificationAsset.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/22.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "SpecificationModel+CoreDataClass.h"
#import "GlobalVar.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecificationAsset : NSObject

@property(nonatomic, strong) UIImage *cover;

@property(nonatomic, strong) SpecificationModel *model;

@property(nonatomic, assign) BOOL isFront;

@property(nonatomic, assign) BOOL isEdite;

@property(nonatomic, assign) BOOL state;

@property(nonatomic, strong) NSString *modelFile;

@property(nonatomic, strong) NSString *updataTime;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSString *uuid;

- (instancetype)initWithSpecificationModel:(SpecificationModel *)model;
@end

NS_ASSUME_NONNULL_END
