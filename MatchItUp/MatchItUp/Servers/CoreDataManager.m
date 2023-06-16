//
//  CoreDataManager.m
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import "CoreDataManager.h"
#import "ZHFileManager.h"

@implementation CoreDataManager{
    GlobalVar *globalVar;
    dispatch_queue_t coredataQueue;
    NSManagedObjectContext *managedObjectContext;
}

@synthesize rootMOC = _rootMOC;
@synthesize mainMOC = _mainMOC;

#pragma mark - 单例
SingleM(Manager)

#pragma mark - init and dealloc
- (instancetype)init
{

    self = [super init];
    if (self) {
        
        globalVar = [GlobalVar sharedInstance];
        
        //初始化model
        mom = [[NSManagedObjectModel alloc]initWithContentsOfURL: [[NSBundle mainBundle] URLForResource:@"MatchItUp" withExtension:@"momd"]];
        //momd
        //mom = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSError *err;
        //初始化持久存储协调器
        psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:globalVar.sqlitePath] options:nil error:&err];
        if (err){
            NSLog(@"psc设置路径失败:%@",err.localizedDescription);
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - context save
- (void)contextWillSave:(NSNotification *)notification {
    NSManagedObjectContext *context = notification.object;
    NSSet *insertedObjects = [context insertedObjects];
    
    if ([insertedObjects count]) {
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:insertedObjects.allObjects error:&error];
        if (!success) {
            // log error
            NSLog(@"context %@ obtain defeat",context);
        }
    }
}

- (void)saveContext:(NSManagedObjectContext *)context {
    if (!context) return;
    NSError *error = nil;
    // 判断MOC监听的MO对象是否有改变，如果有则提交保存
    // log error
    [context save:&error];
    if (error) {
        NSLog(@"save defeat %@",error.localizedDescription);
    }
    //NSAssert(YES, @"save error!!!");
    if (context.parentContext) {
        // 递归保存
        [self saveContext:context.parentContext];
    }else{
        
    }
}

#pragma mark - Create Context
- (NSManagedObjectContext *)rootMOC{
    if (!_rootMOC) {
        _rootMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_rootMOC setPersistentStoreCoordinator:psc];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextWillSave:) name:NSManagedObjectContextWillSaveNotification object:_rootMOC];
    }
    return _rootMOC;
}

- (NSManagedObjectContext *)mainMOC{
    if (!_mainMOC) {
        _mainMOC = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainMOC setParentContext: self.rootMOC];
    }
    return _mainMOC;
}


- (NSManagedObjectContext *)createPrivateMOC{
    NSManagedObjectContext *privateMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateMOC setParentContext: self.mainMOC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextWillSave:) name:NSManagedObjectContextWillSaveNotification object:privateMOC];
    return privateMOC;
}

#pragma mark - Video Operation
- (NSArray *)getVideosWithPosted:(BOOL)isPosted andTrashed:(BOOL)isTrashed{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Video fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(postFlag == %@) AND (trashFlag == %@)", isPosted ? @"true" : @"false", isTrashed ? @"true" : @"false"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"%lu", (unsigned long)result.count);
        if (error) NSLog(@"查询videos失败%@",error.description);
    }];
    NSLog(@"video 有 %lu 个", (unsigned long)result.count);
    return result;
}

- (NSArray *)getVideosWithKey:(NSString *)key andValue:(NSString *)value{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Video fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'", key, value]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"%lu", (unsigned long)result.count);
        if (error) NSLog(@"查询videos失败%@",error.description);
    }];
    NSLog(@"video 有 %lu 个", (unsigned long)result.count);
    return result;
}

- (void)addVideo:(NSString *)fileName withAngle:(int)angle{
    NSManagedObjectContext *context = [self createPrivateMOC];
    [context performBlock: ^{
        Video *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
        newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
        newVideo.swingAngle = angle;
        newVideo.isUse = YES;
        newVideo.isEdite = NO;
        //
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.albumDir,newVideo.videoFile]];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
        
        //读帧率
        AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        if (track.nominalFrameRate > 48.0){
            newVideo.interpolate = NO;
        }else{
            newVideo.interpolate = YES;
        }
        newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
        newVideo.creationTime = asset.creationDate.dateValue;
        NSLog(@"creationTime:%@",asset.creationDate);
        newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
        NSLog(@"sec:::::%@",newVideo.secs);
        
        newVideo.videoHeight = track.naturalSize.height;
        newVideo.videoWidth = track.naturalSize.width;
        newVideo.uuid = NSUUID.UUID.UUIDString;
        
        [self saveContext:context];
        NSLog(@"-------+++++++++++%lu", (unsigned long)[self getVideosWithPosted:NO andTrashed:NO].count);
    }];
}

- (void)addVideo:(NSURL *)videoURL withAngle:(int)angle completion:(nullable void (^)(Video *))completionBlock{
    [ZHFileManager.sharedManager copyVideo:videoURL completion:^(NSString *fileName) {
        if (fileName == nil){
            completionBlock(nil);
            return;
        }
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlock: ^{
            Video *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
            newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
            newVideo.swingAngle = angle;
            newVideo.isUse = YES;
            newVideo.isEdite = NO;
            //
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.albumDir,newVideo.videoFile]];
            AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
            
            //读帧率
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track.nominalFrameRate > 48.0){
                newVideo.interpolate = NO;
            }else{
                newVideo.interpolate = YES;
            }
            newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
            newVideo.creationTime = asset.creationDate.dateValue;
            NSLog(@"creationTime:%@",asset.creationDate);
            newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
            NSLog(@"sec:::::%@",newVideo.secs);
            
            newVideo.videoHeight = track.naturalSize.height;
            newVideo.videoWidth = track.naturalSize.width;
            newVideo.uuid = NSUUID.UUID.UUIDString;
            
            [self saveContext:context];
            NSLog(@"-------+++++++++++%lu", (unsigned long)[self getVideosWithPosted:NO andTrashed:NO].count);
            
            if (completionBlock){
                completionBlock(newVideo);
            }
        }];
    }];
}

- (void)addVideo:(NSURL *)videoURL withAngle:(int)angle startTime:(CMTime)start endTime:(CMTime)end andisFront:(BOOL)isFront completion:(void (^)(Video * _Nonnull))completionBlock {
    [ZHFileManager.sharedManager cutVideo:videoURL startTime:start endTime:end completion:^(NSString *fileName) {
        if (fileName == nil){
            completionBlock(NULL);
            return;
        }
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlock: ^{
            Video *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
            newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
            newVideo.swingAngle = angle;
            newVideo.isFront = isFront;
            newVideo.isUse = YES;
            newVideo.isEdite = NO;
            //
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.albumDir,newVideo.videoFile]];
            AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
            
            //读帧率
            AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            if (track.nominalFrameRate > 48.0){
                newVideo.interpolate = NO;
            }else{
                newVideo.interpolate = YES;
            }
            newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
            newVideo.creationTime = asset.creationDate.dateValue;
            NSLog(@"creationTime:%@",asset.creationDate);
            newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
            NSLog(@"sec:::::%@",newVideo.secs);
            
            newVideo.videoHeight = track.naturalSize.height;
            newVideo.videoWidth = track.naturalSize.width;
            newVideo.uuid = NSUUID.UUID.UUIDString;
            
            [self saveContext:context];
            NSLog(@"-------+++++++++++%lu", (unsigned long)[self getVideosWithPosted:NO andTrashed:NO].count);
            if (completionBlock){
                completionBlock(newVideo);
            }
        }];
    }];
}

- (void)deleteVideo:(Video *)video{
    NSManagedObjectContext *context = video.managedObjectContext;
    [context performBlock: ^{
        [ZHFileManager.sharedManager clearVideo:video];
        [context deleteObject:video];
        [self saveContext:context];
        NSNotification *notification = [NSNotification notificationWithName:@"deleteVideo" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }];
}

- (void)changeFrontForVideo:(Video *)video {
    NSManagedObjectContext *context = video.managedObjectContext;
    [context performBlock: ^{
        video.isFront = !video.isFront;
        [self saveContext:context];
        NSNotification *notification = [NSNotification notificationWithName:@"changeVideoFront" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }];
}

- (void)changeEditeForVideo:(Video *)video {
    NSManagedObjectContext *context = video.managedObjectContext;
    [context performBlock: ^{
        video.isEdite = YES;
        [self saveContext:context];
//        NSNotification *notification = [NSNotification notificationWithName:@"changeVideoEdite" object:nil userInfo:nil];
//        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }];
}

- (void)changeUseForVideo:(Video *)video {
    NSManagedObjectContext *context = video.managedObjectContext;
    [context performBlock: ^{
        video.isUse = !video.isUse;
        [self saveContext:context];
//        NSNotification *notification = [NSNotification notificationWithName:@"changeVideoUse" object:nil userInfo:nil];
//        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }];
}

- (void)changeNameForVideo:(Video *)video andName:(NSString *)name {
    NSManagedObjectContext *context = video.managedObjectContext;
    [context performBlock: ^{
        video.name = name;
        [self saveContext:context];
    }];
}

#pragma mark - Swing Operation
- (NSArray *)getSwingList{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Swing fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deleteFlag == false"];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

- (NSArray *)getSwingListWithGolferID:(NSString *)idString{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Swing fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(golferID == %@) AND (deleteFlag == false)",idString]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

- (NSMutableArray<Swing *> *)getLocalSwingListWith:(nullable NSString *)golferID binFlag:(BOOL)deleted{
    __block NSMutableArray *swingArr = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Swing fetchRequest];
        
        NSPredicate *predicate;
        if (golferID){
            [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(golferID == %@) AND (deleteFlag == %@)", golferID, deleted ? @"true" : @"false"]];
        }else{
            [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"deleteFlag == %@", deleted ? @"true" : @"false"]];
        }

        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        swingArr = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return swingArr;
}

- (Swing *)getSwingWithBriefInfo:(NSDictionary *)info{
    NSNumber *swingId = info[@"swingId"];
    Swing *ret = nil;
    
    if (swingId == nil){
        return ret;
    }

    __block NSMutableArray *swingArr = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Swing fetchRequest];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"swingId == %@", swingId]];
        
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        swingArr = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    
    if (swingArr.count > 0){
        ret = swingArr.firstObject;
        
        [context performBlockAndWait: ^{
            ret.swingId = [swingId stringValue];
            ret.urlShotPic = info[@"screenshotUrl"];
            ret.title = info[@"title"];
            if (info[@"videoId"] != [NSNull null]){
                ret.videoId = [info[@"videoId"] stringValue];
            }
            
            [self saveContext:context];
        }];
    }else{
        __block Swing *swing = nil;
        
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlockAndWait: ^{
            swing = [NSEntityDescription insertNewObjectForEntityForName:@"Swing" inManagedObjectContext:context];
            swing.swingId = [swingId stringValue];
            swing.urlShotPic = info[@"screenshotUrl"];
            swing.title = info[@"title"];
            if (info[@"videoId"] != [NSNull null]){
                swing.videoId = [info[@"videoId"] stringValue];
            }
            
            [self saveContext:context];
        }];
        
        ret = swing;
    }
    
    return ret;
}

- (Swing *)getSwingWithInfo:(NSDictionary *)info{
    return nil;
}

#pragma mark - Screen Record Operation
- (NSArray *)getScreenRecords{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [ScreenRecord fetchRequest];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

- (void)addScreenRecord:(NSString *)fileName{
    NSManagedObjectContext *context = [self createPrivateMOC];
    [context performBlock: ^{
        ScreenRecord *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"ScreenRecord" inManagedObjectContext:context];
        newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.screenRecordDir,newVideo.videoFile]];
        AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
        newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
        newVideo.creationTime = asset.creationDate.dateValue;
        NSLog(@"creationTime:%@",asset.creationDate);
        newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
        NSLog(@"sec:::::%@",newVideo.secs);
        [self saveContext:context];
    }];
}

- (void)newAddScreenRecord:(NSString *)filePath WithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler{
    [ZHFileManager.sharedManager newCopyScreenRecord:[NSURL fileURLWithPath:filePath] withCompletionHandler:^(BOOL success, NSError *error, NSString *fileName) {
        if (success) {
            NSManagedObjectContext *context = [self createPrivateMOC];
            [context performBlock: ^{
                ScreenRecord *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"ScreenRecord" inManagedObjectContext:context];
                newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
                NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.screenRecordDir,newVideo.videoFile]];
                AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
                newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
                newVideo.creationTime = asset.creationDate.dateValue;
                NSLog(@"creationTime:%@",asset.creationDate);
                newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
                NSLog(@"sec:::::%@",newVideo.secs);
                [self saveContext:context];
                completionHandler(YES, NULL);
            }];
        } else {
            completionHandler(NO, error);
        }
    }];
}

- (void)deleteScreenRecord:(ScreenRecord *)sr{
    NSManagedObjectContext *context = sr.managedObjectContext;
    [context performBlock: ^{
        [ZHFileManager.sharedManager clearScreenRecord:sr];
        [context deleteObject:sr];
        [self saveContext:context];
    }];
}
#pragma mark - Analysis Video Operation
- (NSArray *)getAnalysisVideo{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [AnalysisVideo fetchRequest];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}
- (void)addAnalysisVideo:(NSURL *)videoURL withisFront:(BOOL)isFront completion:(void (^)(AnalysisVideo * ))completionBlock {
    [ZHFileManager.sharedManager copyAnalysisVideo:videoURL withCompletionHandler:^(BOOL success, NSError * _Nonnull error, NSString * _Nonnull fileName) {
        if (fileName == nil){
            completionBlock(NULL);
            return;
        }
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlock: ^{
            AnalysisVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"AnalysisVideo" inManagedObjectContext:context];
            newVideo.videoFile = [NSString stringWithFormat:@"%@.mp4", fileName];
            newVideo.isFront = isFront;
            
            //
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",self->globalVar.analysisVideoDir,newVideo.videoFile]];
            AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
            
            newVideo.shotPicFile = [NSString stringWithFormat:@"%@.jpg", fileName];
            newVideo.creationTime = asset.creationDate.dateValue;
            NSLog(@"creationTime:%@",asset.creationDate);
            newVideo.secs = [self->globalVar durationGetSecs:asset.duration];
            NSLog(@"sec:::::%@",newVideo.secs);
            
            [self saveContext:context];
            NSLog(@"-------+++++++++++%lu", (unsigned long)[self getAnalysisVideo].count);
            if (completionBlock){
                completionBlock(newVideo);
            }
        }];
    }];
}
- (void)deleteAnalysisVideo:(AnalysisVideo *)sr{
    NSManagedObjectContext *context = sr.managedObjectContext;
    [context performBlock: ^{
        [ZHFileManager.sharedManager clearAnalysisVideo:sr];
        [context deleteObject:sr];
        [self saveContext:context];
    }];
}
#pragma mark - Specification
-(NSArray *) getSpecification{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [SpecificationModel fetchRequest];
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"creationTime" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

-(NSArray *) getSpecificationOfUsing{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [SpecificationModel fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state = YES AND isEdit = YES"];
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"creationTime" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

-(NSArray *) getSpecificationOfUsingWith:(NSArray*)keys{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [SpecificationModel fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid IN %@",keys];
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"creationTime" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}

-(void)addSpecification:(NSURL*) picURL completion:(void (^)(SpecificationModel * ))completionBlock{
    [ZHFileManager.sharedManager copySpecification:picURL completion:^(BOOL success, NSError * _Nonnull error, NSString * _Nonnull fileName) {
        if(fileName == nil){
            return;
        }
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlock: ^{
            SpecificationModel *newModel = [NSEntityDescription insertNewObjectForEntityForName:@"SpecificationModel" inManagedObjectContext:context];
            newModel.modelFile =[[fileName lastPathComponent]stringByDeletingPathExtension];
            newModel.shotPicFile = fileName;
            newModel.uuid = NSUUID.UUID.UUIDString;
            newModel.isEdit = NO;
            newModel.isFront = YES;
            newModel.state = YES;
            newModel.creationTime = [NSDate date];
            [self saveContext:context];
            if (completionBlock){
                completionBlock(newModel);
            }
        }];
    }];
}
-(void)addSpecification:(NSURL*) picURL withCanDelete:(BOOL)canDelete completion:(void (^)(SpecificationModel * ))completionBlock{
    [ZHFileManager.sharedManager copySpecification:picURL completion:^(BOOL success, NSError * _Nonnull error, NSString * _Nonnull fileName) {
        if(fileName == nil){
            return;
        }
        NSManagedObjectContext *context = [self createPrivateMOC];
        [context performBlock: ^{
            SpecificationModel *newModel = [NSEntityDescription insertNewObjectForEntityForName:@"SpecificationModel" inManagedObjectContext:context];
            newModel.modelFile =[[fileName lastPathComponent]stringByDeletingPathExtension];
            newModel.shotPicFile = fileName;
            newModel.canDelete = canDelete;
            newModel.isFront = YES;
            newModel.uuid = NSUUID.UUID.UUIDString;
            newModel.creationTime = [NSDate date];
            [self saveContext:context];
            if (completionBlock){
                completionBlock(newModel);
            }
        }];
    }];
}
- (void)deleteSpecification:(SpecificationModel *)sr{
    NSManagedObjectContext *context = sr.managedObjectContext;
    [context performBlock: ^{
        [ZHFileManager.sharedManager clearSpecification:sr];
        [context deleteObject:sr];
        [self saveContext:context];
    }];
}
- (void)updataSpecificationIsEdite:(BOOL)isEdite andIsFront:(BOOL)isFront andName:(NSString*)name withUuid:(NSString*) uuid{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self createPrivateMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [SpecificationModel fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid = '%@'",uuid]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"%lu", (unsigned long)result.count);
        if (error) NSLog(@"查询videos失败%@",error.description);
    }];
    for (SpecificationModel *model in result) {
        model.isEdit = isEdite;
        model.updataTime = [[[NSDate alloc]init]dateToString];
        model.name = name;
        model.isFront = isFront;
    }
    [self saveContext:context];
}
- (void)updataSpecificationState:(BOOL)state withUuid:(NSString*) uuid{
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [self createPrivateMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [SpecificationModel fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid = '%@'",uuid]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"%lu", (unsigned long)result.count);
        if (error) NSLog(@"查询videos失败%@",error.description);
    }];
    for (SpecificationModel *model in result) {
        model.state = state;
    }
    [self saveContext:context];
}
- (void)setISFrontForSpecification:(SpecificationModel *)spec andISFront:(BOOL *)isFront {
    NSManagedObjectContext *context = spec.managedObjectContext;
    [context performBlock: ^{
        spec.isFront = isFront;
        [self saveContext:context];
    }];
    NSLog(@"Save isFront YES Or NO");
}
#pragma mark - Golfer Operation
- (NSMutableArray *)getGolfers{
    __block NSMutableArray *result = nil;
    NSManagedObjectContext *context = [self mainMOC];
    [context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [Golfer fetchRequest];
        NSError *error = nil;
        result = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
        if (error) NSLog(@"查询golfer list 失败%@",error.description);
    }];
    return result;
}



@end
