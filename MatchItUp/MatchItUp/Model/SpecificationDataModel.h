//
//  SpecificationModel.h
//  MatchItUp
//
//  Created by GWJ on 2023/3/22.
//

#import <Foundation/Foundation.h>
#import "SpecificationAsset.h"

@interface SpecificationDataModel : NSObject

@property(nonatomic, strong) NSMutableArray<SpecificationAsset*> *assets;

- (instancetype)initWithSpecificatins:(NSArray<SpecificationModel*> *)models;

@end

