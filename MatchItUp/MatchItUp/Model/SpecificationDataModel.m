//
//  SpecificationModel.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/22.
//

#import "SpecificationDataModel.h"

@implementation SpecificationDataModel

- (instancetype)initWithSpecificatins:(NSArray<SpecificationModel*> *)models{
    self = [super init];
    if (self){
        self.assets = [NSMutableArray array];
        for (SpecificationModel *model in models) {
            [self.assets addObject: [[SpecificationAsset alloc] initWithSpecificationModel:model]];
        }
    }
    return self;
}
@end
