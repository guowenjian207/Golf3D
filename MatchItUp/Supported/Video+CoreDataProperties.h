//
//  Video+CoreDataProperties.h
//  
//
//  Created by 胡跃坤 on 2022/3/2.
//
//

#import "Video+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

+ (NSFetchRequest<Video *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSDate *creationTime;
@property (nonatomic) BOOL interpolate;
@property (nonatomic) BOOL postFlag;
@property (nullable, nonatomic, copy) NSString *secs;
@property (nullable, nonatomic, copy) NSString *shotPicFile;
@property (nonatomic) int32_t swingAngle;
@property (nullable, nonatomic, copy) NSString *swingId;
@property (nonatomic) BOOL trashFlag;
@property (nonatomic) float uploadProgress;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *videoFile;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) float videoHeight;
@property (nonatomic) float videoWidth;
@property (nonatomic) BOOL isFront;
@property (nonatomic) BOOL isEdite;
@property (nonatomic) BOOL isUse;

@end

NS_ASSUME_NONNULL_END
