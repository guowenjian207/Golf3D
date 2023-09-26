//
//  ZHFileManager.h
//  MatchItUp
//
//  Created by 安子和 on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import "SharedInstance.h"
#import "NSDate+String.h"
#import "GlobalVar.h"
#import "CoreDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHFileManager : NSObject

SingleH(Manager)

- (void)cutVideo:(NSURL *)sourceFile withStartTime:(Float32)startTime endTime:(Float32)endTime remindView:(MBProgressHUD *)hudView angle: (Float32)angle completion:(nullable void (^)(NSURL *))completionBlock;
- (void)copyVideo:(NSURL *)sourceFile withAngle:(Float32)angle completion:(nullable void (^)(NSURL *))completionBlock;
- (void)cutTmpVideo:(NSTimeInterval)interval With:(nullable void (^)(void))completion;
- (void)deleteTmpVideo;
- (void)copyScreenRecord:(NSURL *)sourceFile;

//新 coredata 调用file manager
- (void)copyVideo:(NSURL *)sourceFile completion:(void (^)(NSString * nullable))completionBlock;
- (void)cutVideo:(NSURL *)sourceFile startTime:(CMTime)start endTime:(CMTime)end completion:(void (^)(NSString * nullable))completionBlock;

- (void)newCopyScreenRecord:(NSURL *)fileURL withCompletionHandler:(void (^)(BOOL success, NSError *error, NSString *fileName))completionHandler;

-(void)copyAnalysisVideo:(NSURL *)fileURL withCompletionHandler:(void (^)(BOOL success, NSError *error, NSString *fileName))completionHandler;

- (void)clearVideo:(Video *)video;
- (void)clearScreenRecord:(ScreenRecord *)sr;
- (void)clearAnalysisVideo:(AnalysisVideo *)sr;

-(void)copySpecification:(NSURL*)sourceURL completion:(nullable void (^)(BOOL success, NSError *error,NSString *fileName))completionBlock;
- (void)clearSpecification:(SpecificationModel *)model;



+ (BOOL)resultExistsWithId:(NSString*)videoId option:(NSUInteger)option;

- (void)mergeVideosToOne:(NSArray*)array;

- (void)firstInitSpecifications;
@end

NS_ASSUME_NONNULL_END
