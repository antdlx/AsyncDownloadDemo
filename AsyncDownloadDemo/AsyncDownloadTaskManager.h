//
//  AsyncDownloadTaskManager.h
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MyDownloadTask;
@class MyCell;

@interface AsyncDownloadTaskManager : NSObject<NSURLSessionDownloadDelegate>

//最大同时并发量
@property(nonatomic,assign) NSInteger MaxAsyncNum;
//并发任务队列
@property(nonatomic,strong,nonnull) NSOperationQueue *asyncQueue;
//共用Session
@property(nonatomic,strong,nonnull) NSURLSession *session;
//记录正在下载的任务的Array，FIFO
@property(atomic,strong,nonnull) NSMutableArray *downloadingTaskArray;
//记录正在等待或者暂停的任务的Array，FIFO
@property(atomic,strong,nonnull) NSMutableArray *waitingTaskArray;
//记录下载完成的任务的Array，FIFO
@property(atomic,strong,nonnull) NSMutableArray *finishedTaskArray;
//记录用来恢复暂停的下载的resumeData
@property(atomic,strong,nonnull) NSMutableDictionary *resumeDataDictionary;
//是否允许蜂窝网络
@property(nonatomic,assign) BOOL allowCellularAccess;
//用来记录有哪些Cell与Task已经绑定，用于防止cell错位的情况
@property(nonatomic,strong,nonnull) NSMutableArray * bindCellArray;
//Mycell的数据集合
@property (strong, nonatomic,nonnull) NSMutableArray * datas;
//显示toast或者警告的UiView
@property(strong,nonatomic,nonnull) UIView *alertView;
//互斥锁，确保外部调用者获得的是全部子task都暂停之后的结果
@property(strong,atomic,nonnull)NSConditionLock * conditionLock;



//一些成功和失败的回调函数
typedef void (^ restartBlock)();
typedef void (^ pauseBlock)();
typedef void (^ cancelBlock)();
typedef void (^ restartFailBlock)();

+(nonnull instancetype)shared;

//添加下载任务
-(void)download:(nonnull NSString *)url savePath:(nonnull NSString *)savepath saveName:(nonnull NSString *)saveName;
//绑定alertView
-(void)bindAlertView:(nonnull UIView * )view;
//删除所有下载任务
-(void)cancelAllTaskAndFiles:(BOOL)isDelet;
//根据URL删除特定下载任务，是否删除文件，完成的回调block
-(void)cancelDownloadTaskWithURL:(nonnull NSString *)url DeleteFile:(BOOL)isDelete complete:(nullable cancelBlock) block;
//根据task删除特定下载任务，是否删除文件，完成的回调block
-(void)cancelDownloadTask:(nonnull MyDownloadTask *)task DeleteFile:(BOOL)isDelete complete:(nullable cancelBlock) block;
//暂停所有下载任务
-(void)pauseAllTaskAndFiles:(nullable pauseBlock) block;
//根据URL暂停特定下载任务，是否删除文件，完成的回调block
-(void)pauseDownloadTaskWithURL:(nonnull NSString *)url complete:(nullable pauseBlock) block;
//根据task暂停特定下载任务，是否删除文件，完成的回调block
-(void)pauseDownloadTask:(nonnull MyDownloadTask *)task complete:(nullable pauseBlock) block;
//根据URL重启特定任务，完成的回调和失败的回调
-(void)restartDownloadTaskWithURL:(nonnull NSString *)url complete:(nullable restartBlock) block Fail:(nullable restartFailBlock)blockFail;
//根据task重启特定任务，完成的回调和失败的回调
-(void)restartDownloadTask:(nonnull MyDownloadTask *)task complete:(nullable restartBlock) block Fail:(nullable restartFailBlock)blockFail;
//在下载队列和等待队列中根据URL寻找task
-(nonnull MyDownloadTask *)findTaskWithURL:(nonnull NSString *)url;
//将task与自定义cell进行绑定，用来更新UI等操作
-(nonnull MyDownloadTask *)bindCell:(nonnull MyCell *)cell WithTaskURL:(nonnull NSString *)url;

@end
