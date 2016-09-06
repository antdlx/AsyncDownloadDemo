//
//  AsyncDownloadTaskManager.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "AsyncDownloadTaskManager.h"
#import "MyDownloadTask.h"
#import "MyCell.h"
#import "Reachability.h"

static const NSInteger MAX_ASYNC_NUM = 2;
static const BOOL ALLOW_CELLULAR_ACCESS = NO;

@interface AsyncDownloadTaskManager()

@property (nonatomic,strong) NSFileManager *fg;

@end

@implementation AsyncDownloadTaskManager

+(instancetype)shared{
    static AsyncDownloadTaskManager * asyncDownloadmanager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        asyncDownloadmanager = [[AsyncDownloadTaskManager alloc]init];
    });
    return asyncDownloadmanager;
}

-(instancetype)init{
    self = [super init];
    
    _asyncQueue = [NSOperationQueue new];
    _downloadingTaskArray = [NSMutableArray array];
    _waitingTaskArray = [NSMutableArray array];
    _finishedTaskArray = [NSMutableArray array];
    _datas = [NSMutableArray array];
    _resumeDataDictionary = [NSMutableDictionary dictionary];
    _bindCellArray = [NSMutableArray array];
    _allowCellularAccess = ALLOW_CELLULAR_ACCESS;
    _fg = [NSFileManager defaultManager];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 5.0f;
    _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:_asyncQueue];
    
    //监听网络变化
    Reachability* hostReach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [hostReach startNotifier];
    
    return self;
}

-(NSURLSession *)session{
    if (nil == _session) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 5.0f;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:_asyncQueue];
    }
    return _session;
}


-(void)download:(NSString *)url savePath:(NSString *)savepath saveName:(NSString *)saveName{
    MyDownloadTask * task = [[MyDownloadTask alloc]init];
    task.downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:url]];
    task.saveFileName = saveName;
    task.saveFilePath = savepath;
    task.taskUrl = url;
    
    if ([_downloadingTaskArray count] < MAX_ASYNC_NUM) {
        [task.downloadTask resume];
        task.taskState = DownloadingState;
        [_downloadingTaskArray addObject:task];
    }else{
        task.taskState = WaitingState;
        [_waitingTaskArray addObject:task];
    }
    
}

#pragma mark pauseFuncs

-(void)pauseAllTaskAndFiles{
    
    for (MyDownloadTask *t in _downloadingTaskArray) {
        
        if (t.taskState == DownloadingState) {
            t.taskState = WaitingState;
            [_downloadingTaskArray removeObject:t];
            [_waitingTaskArray addObject:t];
            __weak typeof(self) weakSelf = self;
            [t.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.resumeDataDictionary setObject:resumeData forKey:t.taskUrl];
            }];
            
        }
    }
}



-(void)pauseDownloadTaskWithURL:(NSString *)url complete:(nullable pauseBlock)block{
    MyDownloadTask * thisTask = [self findTaskWithURL:url];
    if (thisTask) {
        if (thisTask.taskState == DownloadingState) {
            thisTask.taskState = PausingState;
            [_downloadingTaskArray removeObject:thisTask];
            [_waitingTaskArray addObject:thisTask];
            __weak typeof(self) weakSelf = self;
            [thisTask.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.resumeDataDictionary setObject:resumeData forKey:thisTask.taskUrl];
            }];
            [self startNextWaitingTask];
        }
        if (block) {
            block();
        }
        
    }
}


-(void)pauseDownloadTask:(MyDownloadTask *)task complete:(nullable pauseBlock)block{
    
    if (task) {
        if (task.taskState == DownloadingState) {
            task.taskState = PausingState;
            [_downloadingTaskArray removeObject:task];
            [_waitingTaskArray addObject:task];
            __weak typeof(self) weakSelf = self;
            [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.resumeDataDictionary setObject:resumeData forKey:task.taskUrl];
            }];
            [self startNextWaitingTask];
        }
        if (block) {
            block();
        }
    }
}

#pragma mark restartFuncs

-(void)restartDownloadTaskWithURL:(NSString *)url complete:(nullable restartBlock)block Fail:(nullable restartFailBlock)blockFail{
    if ([_downloadingTaskArray count] < MAX_ASYNC_NUM) {
        MyDownloadTask * thisTask = [self findTaskWithURL:url];
        thisTask.downloadTask = [_session downloadTaskWithResumeData:_resumeDataDictionary[url]];
        [_waitingTaskArray removeObject:thisTask];
        [_downloadingTaskArray addObject:thisTask];
        thisTask.taskState = DownloadingState;
        [thisTask.downloadTask resume];
        if (block) {
            block();
        }
    }
    //pop alert to notice
    if(blockFail){
        blockFail();
    }
}

-(void)restartDownloadTask:(MyDownloadTask *)task complete:(nullable restartBlock)block Fail:(nullable restartFailBlock)blockFail{
    if ([_downloadingTaskArray count] < MAX_ASYNC_NUM) {
        task.downloadTask = [_session downloadTaskWithResumeData:_resumeDataDictionary[task.taskUrl]];
        [_waitingTaskArray removeObject:task];
        [_downloadingTaskArray addObject:task];
        task.taskState = DownloadingState;
        [task.downloadTask resume];
        if (block) {
            block();
        }
    }
    //pop alert to notice
    if(blockFail){
        blockFail();
    }
    
}

#pragma mark cancelFuncs

-(void)cancelAllTaskAndFiles:(BOOL)isDelet{
    NSArray * tempDownTaskArray = [NSArray arrayWithArray:_downloadingTaskArray];
    NSArray * tempWaitTaskArray = [NSArray arrayWithArray:_waitingTaskArray];
    NSArray * tempFinishTaskArray = [NSArray arrayWithArray:_finishedTaskArray];
    for (MyDownloadTask * t in tempDownTaskArray) {
        [t.downloadTask cancel];
        [_downloadingTaskArray removeObject:t];
        if (isDelet) {
            
            BOOL isExist = [_fg fileExistsAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]]];
            
            if (isExist) {
                [_fg removeItemAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]] error:nil];
            }
        }
    }
    for (MyDownloadTask * t in tempWaitTaskArray) {
        
        [_waitingTaskArray removeObject:t];
        if (isDelet) {
            
            BOOL isExist = [_fg fileExistsAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]]];
            
            if (isExist) {
                [_fg removeItemAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]] error:nil];
            }
        }
    }
    for (MyDownloadTask * t in tempFinishTaskArray) {
        
        [_finishedTaskArray removeObject:t];
        if (isDelet) {
            
            BOOL isExist = [_fg fileExistsAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]]];
            
            if (isExist) {
                [_fg removeItemAtPath:[t.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",t.saveFileName]] error:nil];
            }
        }
        
    }
    //删除绑定列表中的cell和task对应关系
    [_bindCellArray removeAllObjects];
}

-(void)cancelDownloadTaskWithURL:(NSString *)url DeleteFile:(BOOL)isDelete complete:(nullable cancelBlock)block{
    MyDownloadTask * thisTask = [self findTaskWithURL:url];
    
    BOOL isExist = [_fg fileExistsAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]]];
    
    switch (thisTask.taskState) {
        case DownloadingState:
            [thisTask.downloadTask cancel];
            [_downloadingTaskArray removeObject:thisTask];
            //删除绑定列表中的cell和task对应关系
            [_bindCellArray removeObject:url];
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                
                [_fg removeItemAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]] error:nil];
                
            }
            break;
        case WaitingState:
            [_waitingTaskArray removeObject:thisTask];
            [_resumeDataDictionary removeObjectForKey:thisTask.taskUrl];
            //删除绑定列表中的cell和task对应关系
            [_bindCellArray removeObject:url];
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                
                [_fg removeItemAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]] error:nil];
                
            }
            break;
        case FinishedState:
            if (isDelete && isExist) {
                
                
                [_fg removeItemAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]] error:nil];
                
            }
            break;
        default:
            break;
    }
    if (block) {
        block();
    }
    
}

-(void)cancelDownloadTask:(MyDownloadTask *)task DeleteFile:(BOOL)isDelete complete:(cancelBlock)block{
    BOOL isExist = [_fg fileExistsAtPath:[task.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",task.saveFileName]]];
    switch (task.taskState) {
        case DownloadingState:
            [task.downloadTask cancel];
            [_downloadingTaskArray removeObject:task];
            //删除绑定列表中的cell和task对应关系
            [_bindCellArray removeObject:task.taskUrl];
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                [_fg removeItemAtPath:[task.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",task.saveFileName]] error:nil];
            }
            break;
        case WaitingState:
            [_waitingTaskArray removeObject:task];
            [_resumeDataDictionary removeObjectForKey:task.taskUrl];
            //删除绑定列表中的cell和task对应关系
            [_bindCellArray removeObject:task.taskUrl];
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                [_fg removeItemAtPath:[task.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",task.saveFileName]] error:nil];
            }
            break;
        case FinishedState:
            if (isDelete && isExist) {
                [_fg removeItemAtPath:[task.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",task.saveFileName]] error:nil];
            }
            break;
        default:
            break;
    }
    if (block) {
        block();
    }
}

#pragma mark toolFuncs

-(MyDownloadTask *)findTaskWithURL:(NSString *)url{
    MyDownloadTask *thisTask = nil;
    
    for (MyDownloadTask * t in _downloadingTaskArray) {
        //string比较一定要用isEqualToString,否则比较的就是内存地址
        if ([t.taskUrl isEqualToString:url]) {
            thisTask = t;
        }
    }
    if (thisTask==nil) {
        for (MyDownloadTask * t in _waitingTaskArray) {
            if (t.taskUrl == url) {
                thisTask = t;
            }
        }
    }
    
    return thisTask;
}

-(MyDownloadTask *)bindCell:(MyCell *)cell WithTaskURL:(NSString *)url{
    NSInteger identify = cell.identify;
    //若cell复用了，则清除之前与task绑定的cell
    if ([_bindCellArray count] > identify) {
        if ([_bindCellArray[identify] length] > 0) {
            MyDownloadTask * thisTask = [self findTaskWithURL:_bindCellArray[identify]];
            thisTask.cell = nil;
        }
    }
    MyDownloadTask * thisTaskx = [self findTaskWithURL:url];
    thisTaskx.cell = cell;
    [_bindCellArray addObject:url];
    return [self findTaskWithURL:url];
}

//开启等待队列中的正在等待的对象,自动启动waiting，不自动启动pausing
-(void)startNextWaitingTask{
    //如果还有别的等待下载的任务，就开启它
    //建立一个临时数组用来遍历用，因为不能同时对一个数组遍历和修改
    NSArray * tempArray = [NSArray arrayWithArray:_waitingTaskArray];
    for(MyDownloadTask * t in tempArray){
        //等待队列处于等待状态数量的大于0 || 等待队列处于暂停状态的数量大于1（防止刚暂停的又开启了）&& 小于最大并行数
        if ((((t.taskState == WaitingState) && [_waitingTaskArray count] > 0) || ((t.taskState == PausingState) && [_waitingTaskArray count] > 1)) && [_downloadingTaskArray count] < MAX_ASYNC_NUM ) {
            if (t.taskState == WaitingState) {
                [t.downloadTask resume];
                t.taskState = DownloadingState;
                [_waitingTaskArray removeObject:t];
                [_downloadingTaskArray addObject:t];
                [t.cell.btn setTitle:@"暂停" forState:UIControlStateNormal];
                
            }
            //  修改：不自动执行暂停的任务
            //            else{
            //                t.downloadTask = [_session downloadTaskWithResumeData:_resumeDataDictionary[t.taskUrl]];
            //                [t.downloadTask resume];
            //            }
        }
    }
    
}

//ReachAbility 监听网络状态的方法
-(void)reachabilityChanged:(NSNotification *) notification{
    Reachability * reachability = [notification object];
    NetworkStatus status  = [reachability currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            //当前网络不可达
            NSLog(@"无网络");
            break;
        case ReachableViaWiFi:
            //wifi
            NSLog(@"WiFi");
            break;
        case ReachableViaWWAN:
            //WWAN 就是蜂窝网络
            NSLog(@"蜂窝网络");
            break;
            
        default:
            
            break;
    }
}

#pragma mark Delegate

//每次写入沙盒完毕后会调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //回到主线程操作UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        //通过URL获取task绑定的cell，然后操作cell中的进度条等控件
        MyDownloadTask * thisTask = [self findTaskWithURL:[[downloadTask.originalRequest URL]absoluteString]];
        if (thisTask.cell) {
            thisTask.progress = [NSNumber numberWithDouble:(float)totalBytesWritten/totalBytesExpectedToWrite*100];
            thisTask.cell.percentLabel.text = [NSString stringWithFormat:@"%.2f %%",[thisTask.progress doubleValue]];
            [thisTask.cell.progressView setProgress:[thisTask.progress doubleValue]/100 animated:YES];
        }
        
        NSLog(@"cell is %ld ; percent is%@",thisTask.cell.identify,[NSString stringWithFormat:@"%.2f %%",(double)totalBytesWritten/totalBytesExpectedToWrite*100]);
    }];
}

//恢复下载的时候调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    NSLog(@"RESUME");
}

//下载完毕的时候会调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    MyDownloadTask * thisTask = [self findTaskWithURL:[downloadTask.originalRequest.URL absoluteString]];
    [_downloadingTaskArray removeObject:thisTask];
    [_finishedTaskArray addObject:thisTask];
    thisTask.taskState = FinishedState;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        [thisTask.cell.btn setTitle:@"完成" forState:UIControlStateNormal];
    }];
    //    NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //    NSString * filename = [caches stringByAppendingString:[NSString stringWithFormat:@"/%@",[downloadTask.originalRequest.URL lastPathComponent]]];
    NSString * filename = [thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]];
    NSLog(@"uri is %@",filename);
    [_fg moveItemAtPath:location.path toPath:filename error:nil];
    
    [self startNextWaitingTask];
    
}



@end
