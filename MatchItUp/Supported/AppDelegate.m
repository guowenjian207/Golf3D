//
//  AppDelegate.m
//  MatchItUp
//
//  Created by 安子和 on 2020/12/25.
//

#import "AppDelegate.h"
#import "sys/utsname.h"
#import <UserNotifications/UNUserNotificationCenter.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AFNetworking/AFNetworking.h>
#import <SSZipArchive/SSZipArchive.h>
#import "scoreTool.h"
#import "ClearCacheTool.h"
#import "SpecificationAsset.h"
#import "SpecificationTool.h"
#import "CoreDataManager.h"
#import "ZHFileManager.h"
@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate {
    NSNumber *framesKey;
    NSString *videoURLString;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
//    return UIInterfaceOrientationMaskPortrait;
    if (self.allowRotation == YES) {
           //横屏
           return UIInterfaceOrientationMaskLandscapeRight;
           
       }else{
           //竖屏
           return UIInterfaceOrientationMaskPortrait;
           
       }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //设备型号及系统版本
    NSString *deviceType = [self getDeviceType];
    NSLog(@"%@", deviceType);
    [[NSUserDefaults standardUserDefaults]setObject:deviceType forKey:@"deviceType"];
    NSLog(@"%@", [[UIDevice currentDevice] systemVersion]);
    
    //注册通知
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"注册通知%@", granted ? @"成功" : @"失败");
        if (error){
            NSLog(@"注册 error : %@", error.localizedDescription);
        }
    }];
    
    [UIApplication.sharedApplication registerForRemoteNotifications];
    
    //app版本
    NSString *currentBundleVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey: (NSString *)kCFBundleVersionKey];
    NSString *bundleVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleVersion"];
    if (currentBundleVersion != bundleVersion){
        if (bundleVersion == nil){
            NSLog(@"首次安装");
            [[NSFileManager defaultManager] checkDirectory];
            [[NSUserDefaults standardUserDefaults]setInteger:2 forKey:@"speechRecognizer"];
        }else{
            NSLog(@"%@更新到%@",bundleVersion,currentBundleVersion);
        }
        [NSUserDefaults.standardUserDefaults setObject:currentBundleVersion forKey:@"bundleVersion"];
        [NSUserDefaults.standardUserDefaults synchronize];
        [ZHFileManager.sharedManager firstInitSpecifications];
    }
    NSString *path = NSTemporaryDirectory();
    NSLog(@"temp大小:%@",[ClearCacheTool getCacheSizeWithFilePath:path]);
    [ClearCacheTool clearCacheWithFilePath:path];
    return YES;
}


#pragma mark - UISceneSession lifecycle


#pragma mark - notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        if (![deviceToken isKindOfClass:[NSData class]]) {
            //记录获取token失败的描述
            return;
        }
        const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
        NSString *strToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"deviceToken1:%@", strToken);
    } else {
        NSString *token = [NSString
                       stringWithFormat:@"%@",deviceToken];
        token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"deviceToken2 is: %@", token);
    }
    
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken:%@",hexToken);
    
    [NSUserDefaults.standardUserDefaults setObject:hexToken forKey:@"deviceToken"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    } else {
        // Fallback on earlier versions
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSLog(@"%@", userInfo);
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    } else {
        // Fallback on earlier versions
    }
    NSNumber *videoId = userInfo[@"video_id"];
    framesKey = userInfo[@"frames_key"];
    if (videoId) { // 预测13帧完成的推送
        NSLog(@"收到了推送消息:%@", videoId);
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"keyFramesPredictFailed%@", videoId] object:nil]];
//        [self downLoadFramesIdxWithVideoId:videoId];
    }
    else if (framesKey) { // 画线推送
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"LinesPredictFailed%@", framesKey] object:nil]];
        // 请求下载数据
//        [self downLoadZIPDataWithFramesKey:framesKey];
    }
}

- (void)downLoadFramesIdxWithVideoId:(NSNumber *)videoId isFromInit:(BOOL)isFromInit{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://s11.bupt.cc:37578/progolf/keyframes" parameters:@{@"video_id" : videoId} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"status"] isEqual:@"success"]) {
            NSArray *frameList = responseObject[@"data"][@"framesList"];
            // 保存到userdefaults
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:frameList forKey:[NSString stringWithFormat:@"%@", videoId]];
            [def synchronize];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"keyFramesPredictForVideo%@", videoId] object:nil]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!isFromInit) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"keyFramesPredictFailed%@", videoId] object:nil]];
        }
        NSLog(@"%@", error);
        NSLog(@"请求失败");
    }];
}

- (void)deleteFramesKey {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@", framesKey]];
    NSURL *videoURL = [NSURL URLWithString:videoURLString];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *framesKeySavePath = [filePath stringByAppendingPathComponent:@"framesKeyData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:framesKeySavePath error:nil]) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败");
    }
}

- (void)downLoadZIPDataWithFramesKey:(NSNumber *)frameskey andFront:(BOOL)isFront{
    framesKey = frameskey;
    videoURLString = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@", framesKey]];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://s11.bupt.cc:37578/progolf/linedata" parameters:@{@"businessType" : @1, @"videoId" : @-1, @"framesKey" : framesKey} error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *destinationPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", framesKey]];
    
    // 如果文件已存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [SSZipArchive unzipFileAtPath:[[location absoluteString] substringFromIndex:15] toDestination:destinationPath overwrite:YES password:NULL progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                NSLog(@"解压中");
            } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [self convertZIP2RealData:isFront];
                } else {
                    NSLog(@"%@", error);
                    NSLog(@"解压失败");
                }
            }];
        }
        else {
            NSLog(@"下载zip文件出错");
        }
    }];
    [downloadTask resume];
}

- (void)convertZIP2RealData:(BOOL)isFront {
    NSURL *videoURL = [NSURL URLWithString:videoURLString];
    // 通知homeVC
    NSMutableArray *frameDataArray = [[NSMutableArray alloc] init];
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *destinationPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", framesKey]];
    
    NSString *destinationPathNew = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/zhiye_muban_line_data", framesKey]];
    
    NSString *alignedImagePath = [destinationPath stringByAppendingPathComponent:@"aligned"];
    for (int i = 0; i < 13; i++) {
        NSString *path = [alignedImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", i]];
        NSData *data = [NSData dataWithContentsOfFile:path];
        [frameDataArray addObject:data];
    }
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[[videoURL relativeString] lastPathComponent] stringByDeletingPathExtension]];
    NSString *frameIdxSavePath = [filePath stringByAppendingPathComponent:@"frameIndex"];
    if ([frameDataArray writeToFile:frameIdxSavePath atomically:NO]) {
        NSLog(@"图片写入成功");
    }
    else {
        NSLog(@"图片写入失败");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"%@updateFrames", videoURL] object:nil]];
    });
    
    // 解析mp4
    NSString *videoPath = [destinationPath stringByAppendingPathComponent:@"out_up.mp4"];
    NSData *dataVideo = [NSData dataWithContentsOfFile:videoPath];
    NSString *videoSavePath = [filePath stringByAppendingPathComponent:@"out_up.mp4"];
    if(dataVideo){
        if([dataVideo writeToFile:videoSavePath atomically:NO]){
            NSLog(@"视频1写入成功");
        }else{
            NSLog(@"视频1写入失败");
        }
    }
    NSString *videoPath2 = [destinationPath stringByAppendingPathComponent:@"out_down.mp4"];
    NSData *dataVideo2 = [NSData dataWithContentsOfFile:videoPath2];
    NSString *videoSavePath2 = [filePath stringByAppendingPathComponent:@"out_down.mp4"];
    if(dataVideo2){
        if([dataVideo2 writeToFile:videoSavePath2 atomically:NO]){
            NSLog(@"视频2写入成功");
        }else{
            NSLog(@"视频2写入失败");
        }
    }
    // 解析json，绘制scoreTools并通知
    NSString *jsonPath = [destinationPath stringByAppendingPathComponent:@"line_data.json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if(data){
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }

//    NSLog(@"\r\n==========================\r\n%@\r\n==========================", dataArray);
    NSString *jsonPath2 = [destinationPath stringByAppendingPathComponent:@"out_up.json"];
    NSData *data2 = [NSData dataWithContentsOfFile:jsonPath2];
    NSArray *dataArray2;
    if(data2){
        dataArray2 = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
//        NSLog(@"\r\n==========================\r\n%@\r\n==========================", dataArray2);
    }
   
    NSString *jsonPath3 = [destinationPath stringByAppendingPathComponent:@"out_down.json"];
    NSData *data3 = [NSData dataWithContentsOfFile:jsonPath3];
    NSArray *dataArray3 ;
    if(data3){
        dataArray3 = [NSJSONSerialization JSONObjectWithData:data3 options:0 error:nil];
//        NSLog(@"\r\n==========================\r\n%@\r\n==========================", dataArray3);
    }
    
    NSString *didSelectSpecSavePath = [filePath stringByAppendingPathComponent:@"didSelectSpec"];
    NSDictionary *selectModels = [NSDictionary dictionaryWithContentsOfFile:didSelectSpecSavePath];
    NSArray *keys = [selectModels allKeys];
    NSMutableDictionary *zhiyeModelData = [[NSMutableDictionary alloc]init];
    for (NSString *uuid in keys) {
        NSString *jsonPath = [destinationPathNew stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",uuid]];
        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
        NSArray *dataArray;
        if(data){
            dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        NSString *specPath = [GlobalVar.sharedInstance.specificationDocDir stringByAppendingPathComponent:[selectModels objectForKey:uuid]];
        NSString *toolsSavePath = [specPath stringByAppendingPathComponent:@"toolsData"];
        NSArray *tmpToolsArray = [NSKeyedUnarchiver unarchiveObjectWithFile:toolsSavePath];
        for (int i=0; i<6; i++){
            for (SpecificationTool *tmpTool in tmpToolsArray[i]) {
                int jsonIdx;
                NSString *jsonName;
                NSString *position = @"positions";
                if ([tmpTool.name isEqual:@"Head_Height"]) {
                    jsonName = @"Head_Height";
                }
                else if ([tmpTool.name isEqual:@"Head_Position"]) {
                    jsonName = @"Head_Position";
                }else if ([tmpTool.name isEqual:@"Head_Frame"]) {
                    jsonName = @"Head_Frame";
                }else if ([tmpTool.name isEqual:@"Lead_Forearm_Line"]) {
                    jsonName = @"Lead_Forearm_Line";
                }else if ([tmpTool.name isEqual:@"Lower_Body_Position"]) {
                    jsonName = @"Lower_Body_Position";
                }else if ([tmpTool.name isEqual:@"Trail_Leg_Angle"]) {
                    jsonName = @"Trail_Leg_Angle";
                }else if ([tmpTool.name isEqual:@"Lead_Leg_Angle"]) {
                    jsonName = @"Lead_Leg_Angle";
                }else if ([tmpTool.name isEqual:@"Trail_Elbow_Angle"]) {
                    jsonName = @"Trail_Elbow_Angle";
                }else if ([tmpTool.name isEqual:@"Lead_Elbow_Angle"]) {
                    jsonName = @"Lead_Elbow_Angle";
                }else if ([tmpTool.name isEqual:@"Shaft_Line"]) {
                    jsonName = @"Shaft_Line";
                }else if ([tmpTool.name isEqual:@"Shoulder_Tilt"]) {
                    jsonName = @"Shoulder_Tilt";
                }else if ([tmpTool.name isEqual:@"Shaft_Line_To_Armpit"]){
                    jsonName = @"Shaft_Line_To_Armpit";
                }else if ([tmpTool.name isEqual:@"Hip_Depth"]) {
                    jsonName = @"Hip_Depth";
                }else if ([tmpTool.name isEqual:@"Elbow_Hosel_Line"]) {
                    jsonName = @"Elbow_Hosel_Line";
                }else if ([tmpTool.name isEqual:@"Knees_Gaps"]) {
                    jsonName = @"Knees_Gaps";
                }
                jsonIdx = [tmpTool.frame intValue];
                
                if (dataArray[jsonIdx][jsonName]) {
                    if ([jsonName isEqual:@"Lead_Forearm_Line"]) {
                        tmpTool.x1 = dataArray[jsonIdx][jsonName][position][1][0];
                        tmpTool.x2 = dataArray[jsonIdx][jsonName][position][0][0];
                        tmpTool.y1 = dataArray[jsonIdx][jsonName][position][1][1];
                        tmpTool.y2 = dataArray[jsonIdx][jsonName][position][0][1];
                        
                    }
                    else if ([jsonName isEqual:@"Head_Frame"]) {
                        tmpTool.x1 = dataArray[jsonIdx][jsonName][position][0][0];
                        tmpTool.x2 = dataArray[jsonIdx][jsonName][position][2][0];
                        tmpTool.y1 = dataArray[jsonIdx][jsonName][position][0][1];
                        tmpTool.y2 = dataArray[jsonIdx][jsonName][position][2][1];
                        
                    }
                    else if ([jsonName isEqual:@"Lower_Body_Position"]) {
                        tmpTool.x1 = dataArray[jsonIdx][jsonName][position][0][0];
                        tmpTool.x2 = dataArray[jsonIdx][jsonName][position][1][0];
                        tmpTool.x3 = dataArray[jsonIdx][jsonName][position][2][0];
                        tmpTool.x4 = dataArray[jsonIdx][jsonName][position][3][0];
                        tmpTool.y1 = dataArray[jsonIdx][jsonName][position][0][1];
                        tmpTool.y2 = dataArray[jsonIdx][jsonName][position][1][1];
                        tmpTool.y3 = dataArray[jsonIdx][jsonName][position][2][1];
                        tmpTool.y4 = dataArray[jsonIdx][jsonName][position][3][1];
                    }
                    else if ([jsonName isEqual:@"Trail_Elbow_Angle"]|| [jsonName isEqual:@"Lead_Elbow_Angle"]|| [jsonName isEqual:@"Trail_Leg_Angle"]|| [jsonName isEqual:@"Lead_Leg_Angle"] || [jsonName isEqual:@"Head_Position"]) {
                        tmpTool.x1 = dataArray[jsonIdx][jsonName][position][0][0];
                        tmpTool.x2 = dataArray[jsonIdx][jsonName][position][1][0];
                        tmpTool.x3 = dataArray[jsonIdx][jsonName][position][2][0];
                        tmpTool.y1 = dataArray[jsonIdx][jsonName][position][0][1];
                        tmpTool.y2 = dataArray[jsonIdx][jsonName][position][1][1];
                        tmpTool.y3 = dataArray[jsonIdx][jsonName][position][2][1];
                    }
                    else {
                        tmpTool.x1 = dataArray[jsonIdx][jsonName][position][0][0];
                        tmpTool.x2 = dataArray[jsonIdx][jsonName][position][1][0];
                        tmpTool.y1 = dataArray[jsonIdx][jsonName][position][0][1];
                        tmpTool.y2 = dataArray[jsonIdx][jsonName][position][1][1];
                    }
                }
            }
        }
        
        [zhiyeModelData setObject:tmpToolsArray forKey:uuid];
    }
    
    // 写入文件
    NSString *zhiyeModelDataSavePath = [filePath stringByAppendingPathComponent:@"zhiyeModelData"];
    if ([NSKeyedArchiver archiveRootObject:zhiyeModelData toFile:zhiyeModelDataSavePath]) {
        NSLog(@"zhiyeModelData写入成功");
    }
    else {
        NSLog(@"zhiyeModelData写入失败");
    }
    
    // 删除framesKey相关信息
    [self deleteFramesKey];
    
    // 通知
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"发起通知%@", [NSString stringWithFormat:@"LinesPredictForFrames%@", self->framesKey]);
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"LinesPredictForFrames%@", self->framesKey] object:nil]];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ChangeEditeStateYes" object:nil]];
    });
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentCloudKitContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentCloudKitContainer alloc] initWithName:@"MatchItUp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - get info

- (NSString *)getDeviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return [platform deviceType];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSError *error = nil;
        if ([self.persistentContainer.viewContext hasChanges] && ![self.persistentContainer.viewContext save:&error]) {
            NSLog(@"无法保存未保存的更改: %@", error);
        }
}

@end
