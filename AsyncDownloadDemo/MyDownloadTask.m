//
//  MyDownloadTask.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "MyDownloadTask.h"

@implementation MyDownloadTask

//对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:_taskState forKey:@"taskState"];
    [aCoder encodeObject:_saveFileName forKey:@"saveFileName"];
    [aCoder encodeObject:_saveFilePath forKey:@"saveFilePath"];
    [aCoder encodeObject:_taskUrl forKey:@"taskURL"];
    [aCoder encodeObject:_progress forKey:@"progress"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSInteger i = [aDecoder decodeIntegerForKey:@"taskState"];
    switch (i) {
        case 1:
            _taskState = DownloadingState;
            break;
        case 2:
            _taskState = WaitingState;
            break;
        case 3:
            _taskState = PausingState;
            break;
        default:
            _taskState = FinishedState;
            break;
    }
    _saveFileName = [aDecoder decodeObjectForKey:@"saveFileName"];
    _saveFilePath = [aDecoder decodeObjectForKey:@"saveFilePath"];
    _taskUrl = [aDecoder decodeObjectForKey:@"taskURL"];
    _progress = [aDecoder decodeObjectForKey:@"progress"];
    
    return self;
}

@end
