//
//  MyCell.h
//  AsyncDownloadDemo
//
//  Created by 丁龙翔 on 16/8/26.
//  Copyright © 2016年 antdlxding. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyDownloadTask;
@class MyDatas;

@interface MyCell : UITableViewCell

@property(nonatomic,copy) NSString * identify;
@property(nonatomic,strong) UIProgressView * progressView;
@property(nonatomic,strong) UILabel * titleLabel;
@property(nonatomic,strong) UILabel * percentLabel;
@property(nonatomic,strong) UIButton * btn;
@property(nonatomic,strong) UIButton * btnCancel;
@property (nonatomic,strong) MyDownloadTask * downloadTask;
//@property(nonatomic,strong) UITableView * tableView;
//@property(nonatomic,strong) NSIndexPath * indexPath;
//@property (nonatomic,strong) MyDatas * data;
//@property (nonatomic,strong) NSMutableArray * datas;

//渲染cell的UI
-(void)GenerateCellWithModel:(MyDatas *)data andTableView:(UITableView *)tableview andTask:(MyDownloadTask *)task;

-(void)bindTableView:(UITableView *)tableView cellAndIndexPath:(NSIndexPath *)path andDatas:(NSMutableArray *)datas;

@end
