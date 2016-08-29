//
//  MyDatas.m
//  AsyncDownloadDemo
//
//  Created by 丁龙翔 on 16/8/26.
//  Copyright © 2016年 antdlxding. All rights reserved.
//

#import "MyDatas.h"

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

@end
