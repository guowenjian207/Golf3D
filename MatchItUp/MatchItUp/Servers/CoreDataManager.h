//
//  CoreDataManager.h
//  MatchItUp
//
//  Created by 安子和 on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "NSFileManager+Category.h"
#import "Swing+CoreDataClass.h"
#import "Video+CoreDataClass.h"
#import "Golfer+CoreDataClass.h"
#import "ScreenRecord+CoreDataClass.h"
#import "AnalysisVideo+CoreDataClass.h"
#import "SpecificationModel+CoreDataClass.h"
#import "SharedInstance.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataManager : NSObject{
    /// 托管对象模型
    NSManagedObjectModel *mom;
    /// 持久化存储协调器
    NSPersistentStoreCoordinator *psc;
    ///操作Video的context
    NSManagedObjectContext *videoMOC;
    ///操作Swing的context
    NSManagedObjectContext *swingMOC;
    ///操作Golfer的context
    NSManagedObjectContext *golferMOC;
}

/// 根上下文 用于在后台线程处理所有子上下文提交的操作
@property(nonatomic,strong,readonly) NSManagedObjectContext *rootMOC;
///主上下文 用于主线程协作
@property(nonatomic,strong,readonly) NSManagedObjectContext *mainMOC;


SingleH(Manager)


- (NSArray *)getVideosWithPosted:(BOOL)isPosted andTrashed:(BOOL)isTrashed;
- (NSArray *)getAnalysisVideo;
- (void)addVideo:(NSString *)fileName withAngle:(int)angle;
- (void)addScreenRecord:(NSString *)fileName;
- (void)newAddScreenRecord:(NSString *)filePath WithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
- (void)addAnalysisVideo:(NSURL *)videoURL withisFront:(BOOL)isFront completion:(void (^)(AnalysisVideo * _Nonnull))completionBlock;

- (void)addVideo:(NSURL *)videoURL withAngle:(int)angle completion:(nullable void (^)(Video *))completionBlock;
- (void)addVideo:(NSURL *)videoURL withAngle:(int)angle startTime:(CMTime)start endTime:(CMTime)end andisFront:(BOOL)isFront completion:(void (^)(Video * _Nonnull))completionBlock;
- (void)deleteVideo:(Video *)video;
- (NSArray *)getVideosWithKey:(NSString *)key andValue:(NSString *)value;

- (NSArray *)getScreenRecords;

- (void)saveContext:(NSManagedObjectContext *)context;

- (Swing *)getSwingWithBriefInfo:(NSDictionary *)info;
- (Swing *)getSwingWithInfo:(NSDictionary *)info;
- (NSMutableArray<Swing*> *)getLocalSwingListWith:(nullable NSString *)golferID binFlag:(BOOL)deleted;
- (void)deleteScreenRecord:(ScreenRecord *)sr;
- (void)deleteAnalysisVideo:(AnalysisVideo *)sr;
- (NSMutableArray *)getGolfers;

- (void)changeFrontForVideo:(Video *)video;
- (void)changeUseForVideo:(Video *)video;
- (void)changeEditeForVideo:(Video *)video ;
- (void)changeNameForVideo:(Video *)video andName:(NSString *)name;

-(NSArray *) getSpecification;
-(NSArray *) getSpecificationOfUsing;
-(NSArray *) getSpecificationOfUsingWith:(NSArray*)keys;
-(void)addSpecification:(NSURL*) picURL completion:(void (^)(SpecificationModel * ))completionBlock;
-(void)addSpecification:(NSURL*) picURL withCanDelete:(BOOL)canDelete andISFront:(BOOL)isFront completion:(void (^)(SpecificationModel * ))completionBlock;
- (void)deleteSpecification:(SpecificationModel *)sr;
- (void)updataSpecificationIsEdite:(BOOL)isEdite andIsFront:(BOOL)isFront andName:(NSString*)name withUuid:(NSString*) uuid;
- (void)updataSpecificationState:(BOOL)state  withUuid:(NSString*) uuid;
- (void)setISFrontForSpecification:(SpecificationModel *)spec andISFront:(BOOL *)isFront;
@end

NS_ASSUME_NONNULL_END
