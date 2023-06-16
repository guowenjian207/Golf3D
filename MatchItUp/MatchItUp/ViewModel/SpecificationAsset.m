//
//  SpecificationAsset.m
//  MatchItUp
//
//  Created by GWJ on 2023/3/22.
//

#import "SpecificationAsset.h"

@implementation SpecificationAsset

- (instancetype)initWithSpecificationModel:(SpecificationModel *)model{
    self = [super init];
    if (self){
        _model = model;
        _cover = [[UIImage alloc]initWithContentsOfFile:[GlobalVar.sharedInstance.specificationAlbumDir stringByAppendingString:model.shotPicFile]];
        _uuid = model.uuid;
        _state = model.state;
        _isEdite = model.isEdit;
        _isFront = model.isFront;
        _modelFile = [GlobalVar.sharedInstance.specificationDocDir stringByAppendingString:model.modelFile];
        _updataTime = model.updataTime;
        _name = model.name;
        NSLog(@"%@",model.shotPicFile);
        NSLog(@"%@",model.shotPicFile);
    }
    return self;
}
@end
