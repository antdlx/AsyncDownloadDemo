//
//  MyDatas.m
//  AsyncDownloadDemo
//
//  Created by 丁龙翔 on 16/8/26.
//  Copyright © 2016年 antdlxding. All rights reserved.
//

#import "MyDatas.h"
#import "Configs.h"

@implementation MyDatas

-(instancetype)initWithDict:(NSDictionary *)dict{
    
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
    
}

+(instancetype)CellWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_url forKey:BACKUP_URL];
    [aCoder encodeObject:_title forKey:BACKUP_TITLE];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    _url = [aDecoder decodeObjectForKey:BACKUP_URL];
    _title = [aDecoder decodeObjectForKey:BACKUP_TITLE];
    
    return self;
}

@end
