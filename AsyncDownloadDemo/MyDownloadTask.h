//
//  MyDownloadTask.h
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyCell;

@interface MyDownloadTask : NSObject<NSCoding>

typedef enum TASK_STATE{
    //正在下载
    DownloadingState = 1,
    //正在等待
    WaitingState = 2,
    //暂停中
    PausingState = 3,
    //已完成
    FinishedState = 4
} TaskState;

//当前task的状态
@property(nonatomic,assign) TaskState  taskState;
//下载文件存储路径
@property(nonatomic,copy) NSString  * saveFilePath;
//下载文件存储名称
@property(nonatomic,copy) NSString * saveFileName;
//下载文件的URL
@property(nonatomic,copy) NSString * taskUrl;
//下载文件任务的task
@property(nonatomic,strong) NSURLSessionDownloadTask * downloadTask;
//下载task对应的cell，用来更新UI用
@property(nonatomic,strong) MyCell * cell;
//下载task对应的下载进度，用来更新UI用
@property(nonatomic) NSNumber* progress;

@end
