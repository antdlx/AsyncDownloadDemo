//
//  AppDelegate.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AsyncDownloadTaskManager.h"
#import "Configs.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *rootView = [[ViewController alloc] init];
    self.window.rootViewController = rootView;
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    //获取Document完整路径
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *datas_path = [documentsDirectory stringByAppendingPathComponent:BACKUP_DATAS_FILE];
    BACKUP_DATAS_PATH = datas_path;
    NSLog(@"%@",BACKUP_DATAS_PATH);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    NSLog(@"did enter background");
    AsyncDownloadTaskManager * manager = [AsyncDownloadTaskManager shared];
    NSInteger allTaskCount = [manager.downloadingTaskArray count];
    [manager pauseAllTaskAndFiles:^(){
        
        if ([NSThread isMainThread]) {
            [manager.conditionLock lockWhenCondition:allTaskCount];
            
            //先删除历史plist，防止以前的plist作出干扰
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:BACKUP_DATAS_PATH error:nil];
       
            NSMutableData * backupData = [NSMutableData data];
            NSKeyedArchiver * arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:backupData];
            [arch encodeObject:manager.resumeDataDictionary forKey:BACKUP_RESUME];
            [arch encodeObject:manager.waitingTaskArray forKey:BACKUP_WAITING];
            [arch encodeObject:manager.finishedTaskArray forKey:BACKUP_FINISHED];
            [arch encodeObject:manager.datas forKey:BACKUP_DATAS];
            [arch finishEncoding];
            
            [backupData writeToFile:BACKUP_DATAS_PATH atomically:YES];
            
            [manager.conditionLock unlock];
        }
    }];

 }

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}

@end
