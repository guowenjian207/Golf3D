//
//  Video+CoreDataProperties.m
//  
//
//  Created by 胡跃坤 on 2022/3/2.
//
//

#import "Video+CoreDataProperties.h"

@implementation Video (CoreDataProperties)

+ (NSFetchRequest<Video *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Video"];
}

@dynamic creationTime;
@dynamic interpolate;
@dynamic postFlag;
@dynamic secs;
@dynamic shotPicFile;
@dynamic swingAngle;
@dynamic swingId;
@dynamic trashFlag;
@dynamic uploadProgress;
@dynamic uuid;
@dynamic videoFile;
@dynamic videoHeight;
@dynamic videoWidth;
@dynamic isFront;
@dynamic isEdite;
@dynamic isUse;
@dynamic name;
@end
