//
//  MyDatas.h
//  AsyncDownloadDemo
//
//  Created by 丁龙翔 on 16/8/26.
//  Copyright © 2016年 antdlxding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDatas : NSObject

@property (nonatomic,strong) NSString * url;
@property (nonatomic,strong) NSString * title;

-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)CellWithDict:(NSDictionary *)dict;

@end
