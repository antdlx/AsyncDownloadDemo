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
#import "UIView+Toast.h"
#import "Configs.h"

static const BOOL ALLOW_CELLULAR_ACCESS = NO;

@interface AsyncDownloadTaskManager()

@property (nonatomic,strong) NSFileManager *fg;
//互斥条件
@property(assign,atomic)NSInteger condition;

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
    
    //恢复数据
    NSData *tmpData = [NSData dataWithContentsOfFile:BACKUP_DATAS_PATH];
    NSKeyedUnarchiver *unarch = [[NSKeyedUnarchiver alloc]initForReadingWithData:tmpData];
    _datas = [unarch decodeObjectForKey:BACKUP_DATAS];
    _resumeDataDictionary = [unarch decodeObjectForKey:BACKUP_RESUME];
    _waitingTaskArray = [unarch decodeObjectForKey:BACKUP_WAITING];
    _finishedTaskArray = [unarch decodeObjectForKey:BACKUP_FINISHED];
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    if (!_waitingTaskArray) {
        _waitingTaskArray = [NSMutableArray array];
    }
    if (!_finishedTaskArray) {
        _finishedTaskArray = [NSMutableArray array];
    }
    if (!_resumeDataDictionary) {
         _resumeDataDictionary = [NSMutableDictionary dictionary];
    }
    NSLog(@"===datas is %@",_datas);
    NSLog(@"===resume is %@",_resumeDataDictionary);
    NSLog(@"===waiting is %@",_waitingTaskArray);
    NSLog(@"===finished is %@",_finishedTaskArray);
    [unarch finishDecoding];
    
    _allowCellularAccess = ALLOW_CELLULAR_ACCESS;
    _fg = [NSFileManager defaultManager];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 5.0f;
    _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:_asyncQueue];
    _conditionLock = [[NSConditionLock alloc]init];
    _condition = 0;
    
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


-(void)download:(NSString *)url savePath:(NSString *)savepath saveName:(NSString *)saveName complete:(nullable startBlock)block{
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
    if (block) {
        block();
    }
}

-(void)downloadwithTask:(MyDownloadTask * )task complete:(nullable startBlock)block{
     task.downloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:task.taskUrl]];
    if ([_downloadingTaskArray count] < MAX_ASYNC_NUM) {
        [task.downloadTask resume];
        task.taskState = DownloadingState;
        [_downloadingTaskArray addObject:task];
    }else{
        task.taskState = WaitingState;
        [_waitingTaskArray addObject:task];
        [_alertView makeToast:TOAST_DOWNLOADING_ARRAY_FULL duration:1.0 position:CSToastPositionCenter];
    }
    if (block) {
        block();
    }
}

#pragma mark pauseFuncs

-(void)pauseAllTaskAndFiles:(pauseBlock) block{
    
   
    [_downloadingTaskArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MyDownloadTask * task = obj;
        if (task.taskState == DownloadingState) {

            //下面是调用了子线程的方法
            __weak typeof(self) weakSelf = self;
            [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                 //条件锁同步线程，确保外部调用者获得的是全部子task都暂停之后的结果
                 [_conditionLock lock];
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(resumeData){
                    task.taskState = PausingState;
                    [_downloadingTaskArray removeObject:task];
                    [_waitingTaskArray addObject:task];
                    
                    [strongSelf.resumeDataDictionary setObject:resumeData forKey:task.taskUrl];
                    _condition = _condition + 1;
                }
                [_conditionLock unlockWithCondition:_condition];
            }];
        }
    }];

    if (block) {
        block();
    }
}

-(void)pauseDownloadTaskWithURL:(NSString *)url complete:(nullable pauseBlock)block{
    MyDownloadTask * thisTask = [self findTaskWithURL:url];
    if (thisTask) {
        if (thisTask.taskState == DownloadingState) {
                __weak typeof(self) weakSelf = self;
            [thisTask.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(resumeData){
                    thisTask.taskState = PausingState;
                    [_downloadingTaskArray removeObject:thisTask];
                    [_waitingTaskArray addObject:thisTask];
                    [strongSelf.resumeDataDictionary setObject:resumeData forKey:thisTask.taskUrl];
                }
                if (block) {
                    block();
                }
            }];
            [self startNextWaitingTask];
        }
    }
}


-(void)pauseDownloadTask:(MyDownloadTask *)task complete:(nullable pauseBlock)block{
    
    if (task) {
        if (task.taskState == DownloadingState) {
                __weak typeof(self) weakSelf = self;
            [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(resumeData){
                    task.taskState = PausingState;
                    [_downloadingTaskArray removeObject:task];
                    [_waitingTaskArray addObject:task];

                    [strongSelf.resumeDataDictionary setObject:resumeData forKey:task.taskUrl];
                    if (block) {
                        block();
                    }
                    [self startNextWaitingTask];
                }
            }];
            
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
    }else{
        //pop alert to notice
        if(blockFail){
            blockFail();
        }
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
    }else{
          [_alertView makeToast:TOAST_DOWNLOADING_ARRAY_FULL duration:1.0 position:CSToastPositionCenter];
        //pop alert to notice
        if(blockFail){
            blockFail();
        }
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
}

-(void)cancelDownloadTaskWithURL:(NSString *)url DeleteFile:(BOOL)isDelete complete:(nullable cancelBlock)block{
    MyDownloadTask * thisTask = [self findTaskWithURL:url];
    
    BOOL isExist = [_fg fileExistsAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]]];
    
    switch (thisTask.taskState) {
        case DownloadingState:
            [thisTask.downloadTask cancel];
            [_downloadingTaskArray removeObject:thisTask];
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                
                [_fg removeItemAtPath:[thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]] error:nil];
                
            }
            break;
        case WaitingState:
            [_waitingTaskArray removeObject:thisTask];
            [_resumeDataDictionary removeObjectForKey:thisTask.taskUrl];
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
            [self startNextWaitingTask];
            if (isDelete && isExist) {
                [_fg removeItemAtPath:[task.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",task.saveFileName]] error:nil];
            }
            break;
        case WaitingState:
            [_waitingTaskArray removeObject:task];
            [_resumeDataDictionary removeObjectForKey:task.taskUrl];
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
-(void)saveBeforeExit{
    NSInteger allTaskCount = [_downloadingTaskArray count];
    [self pauseAllTaskAndFiles:^(){
        
        if ([NSThread isMainThread]) {
            [_conditionLock lockWhenCondition:allTaskCount];
            
            //先删除历史plist，防止以前的plist作出干扰
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:BACKUP_DATAS_PATH error:nil];
            
            NSMutableData * backupData = [NSMutableData data];
            NSKeyedArchiver * arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:backupData];
            [arch encodeObject:_resumeDataDictionary forKey:BACKUP_RESUME];
            [arch encodeObject:_waitingTaskArray forKey:BACKUP_WAITING];
            [arch encodeObject:_finishedTaskArray forKey:BACKUP_FINISHED];
            [arch encodeObject:_datas forKey:BACKUP_DATAS];
            [arch finishEncoding];
            
            [backupData writeToFile:BACKUP_DATAS_PATH atomically:YES];
            
            [_conditionLock unlock];
        }
    }];

}

-(void)bindAlertView:(UIView *)view{
    _alertView = view;
}

-(void)unbindAlertView{
    if (_alertView) {
        _alertView = NULL;
    }
}

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

//开启等待队列中的正在等待的对象,自动启动waiting，不自动启动pausing
-(void)startNextWaitingTask{
    //如果还有别的等待下载的任务，就开启它
    //建立一个临时数组用来遍历用，因为不能同时对一个数组遍历和修改
    NSArray * tempArray = [NSArray arrayWithArray:_waitingTaskArray];
    for(MyDownloadTask * t in tempArray){
        if (t.taskState == WaitingState && [_downloadingTaskArray count] < MAX_ASYNC_NUM) {
                [t.downloadTask resume];
                t.taskState = DownloadingState;
                [_waitingTaskArray removeObject:t];
                [_downloadingTaskArray addObject:t];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                t.updateBtnBlock(@"暂停");
            }];
        }
    }
    
}

#pragma mark Delegate

//每次写入沙盒完毕后会调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //回到主线程操作UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        //通过URL获取task绑定的cell，然后操作cell中的进度条等控件
        MyDownloadTask * thisTask = [self findTaskWithURL:[[downloadTask.originalRequest URL]absoluteString]];
        if (thisTask.updateProgressBlock != nil) {
            thisTask.progress = [NSNumber numberWithDouble:(float)totalBytesWritten/totalBytesExpectedToWrite*100];
            thisTask.updateProgressBlock(thisTask.progress);
            //? can not to 100%
            NSLog(@"percent is%@",[NSString stringWithFormat:@"%.2f %%",(double)totalBytesWritten/totalBytesExpectedToWrite*100]);
        }
        //?100%?
        NSLog(@"2 percent is%@",[NSString stringWithFormat:@"%.2f %%",(double)totalBytesWritten/totalBytesExpectedToWrite*100]);
    }];
  }

//恢复下载的时候调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    NSLog(@"RESUME");
}

//这里是NSURLSession的代理方法，用于监听是否在下载过程中产生了错误，取决于error
-(void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    if (error) {
        NSLog(@"seesion delegate : finish with error %@",error);
        //-999错误代码是我们自己Cancel掉的，不能算是网络或者资源错误
        if (_alertView && error.code != -999) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^(){
                 [_alertView makeToast:@"网络或资源错误，请重新下载" duration:1.0 position:CSToastPositionCenter];
            }];
        }
    }else{
        NSLog(@"seesion delegate : finish success");
    }
    
}

//下载完毕的时候会调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    MyDownloadTask * thisTask = [self findTaskWithURL:[downloadTask.originalRequest.URL absoluteString]];
    [_downloadingTaskArray removeObject:thisTask];
    [_finishedTaskArray addObject:thisTask];
    thisTask.taskState = FinishedState;
    
    if (thisTask.updateProgressBlock != nil  && thisTask.updateBtnBlock!=nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            thisTask.updateBtnBlock(@"完成");
            //手动置100%，因为最后将要结束的时候更新UI会有延迟，比如说停在99.54%
            thisTask.updateProgressBlock([NSNumber numberWithInt:100]);
        }];
    }

    NSString * filename = [thisTask.saveFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@",thisTask.saveFileName]];
    NSLog(@"uri is %@",filename);
    [_fg moveItemAtPath:location.path toPath:filename error:nil];
    
    [self startNextWaitingTask];
    
}



@end
