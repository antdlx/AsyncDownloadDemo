//
//全局常量类
//  Configs.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 9/14/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "Configs.h"

NSString *const BACKUP_DATAS_FILE = @"backupDatas.archive";
NSString * BACKUP_DATAS_PATH = @"";
NSString * const BACKUP_RESUME = @"resumeDataDictionary";
NSString * const BACKUP_WAITING = @"waitingTaskArray";
NSString * const BACKUP_FINISHED = @"finishedTaskArray";
NSString * const BACKUP_DATAS = @"datas";
NSString * const BACKUP_URL = @"url";
NSString * const BACKUP_TITLE = @"title";
NSString * const TOAST_DOWNLOADING_ARRAY_FULL = @"下载队列已满，请等待其他下载完成";
const NSInteger MAX_ASYNC_NUM = 2;

@implementation Configs

@end
