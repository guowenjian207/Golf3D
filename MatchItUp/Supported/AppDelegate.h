//
//  AppDelegate.h
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NSString+StringPlus.h"
#import "NSFileManager+Category.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;
@property(nonatomic,assign)BOOL allowRotation;
- (void)saveContext;
- (void)downLoadZIPDataWithFramesKey:(NSNumber *)frameskey andFront:(BOOL)isFront;
- (void)downLoadFramesIdxWithVideoId:(NSNumber *)videoId isFromInit:(BOOL)isFromInit;

@end

