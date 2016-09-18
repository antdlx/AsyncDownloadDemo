//
//  Configs.h
//  AsyncDownloadDemo
//
//  Created by antdlxding on 9/14/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configs : NSObject

extern NSString * const BACKUP_DATAS_FILE;
extern NSString * BACKUP_DATAS_PATH;
extern NSString * const BACKUP_RESUME;
extern NSString * const BACKUP_WAITING;
extern NSString * const BACKUP_FINISHED;
extern NSString * const BACKUP_DATAS;
extern NSString * const BACKUP_URL;
extern NSString * const BACKUP_TITLE;
extern NSString * const TOAST_DOWNLOADING_ARRAY_FULL;
extern NSInteger const MAX_ASYNC_NUM;

@end
