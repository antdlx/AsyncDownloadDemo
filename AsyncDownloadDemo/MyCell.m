//
//  MyCell.m
//  AsyncDownloadDemo
//
//  Created by 丁龙翔 on 16/8/26.
//  Copyright © 2016年 antdlxding. All rights reserved.
//

#import "MyCell.h"
#import "MyDatas.h"
#import "MyDownloadTask.h"
#import "AsyncDownloadTaskManager.h"
#import "SecondViewController.h"

@interface MyCell ()

@end

@implementation MyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,8, 215, 27)];
    _titleLabel.text = @"title init";
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.backgroundColor  = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_titleLabel];
    
    _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,8, 64, 27)];
    _percentLabel.text = @"-50 %";
    _percentLabel.font = [UIFont systemFontOfSize:17];
    _percentLabel.textAlignment = NSTextAlignmentLeft;
    _percentLabel.backgroundColor  = [UIColor clearColor];
    _percentLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_percentLabel];
    
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(340, 25, 46, 30)];
    _btn.backgroundColor = [UIColor clearColor];
    //设置文字
    _btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btn.titleLabel.font = [UIFont systemFontOfSize:15];
    //注意：设置按钮字体颜色不能使用button.titleLabel.textColor方式
    [_btn setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
    //设置边框
    [_btn.layer setMasksToBounds:YES];
    [_btn.layer setCornerRadius:5.0];
    [_btn.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0, 0, 1, 1 });
    //这里不支持UIColor，所以只能使用调色板自己用RGBA设置
    [_btn.layer setBorderColor:colorref];
    
    [self.contentView addSubview:_btn];
    
    _btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(392, 27, 21, 25)];
    _btnCancel.backgroundColor = [UIColor clearColor];
    //设置文字
    _btnCancel.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
    //注意：设置按钮字体颜色不能使用button.titleLabel.textColor方式
    [_btnCancel setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
    [_btnCancel setTitle:@"X" forState:UIControlStateNormal];
    [self.contentView addSubview:_btnCancel];
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(14, 53, 308, 2)];
    [_progressView setProgress:0.2];
    [self.contentView addSubview:_progressView];
    
    return self;
}

-(void)GenerateCellWithModel:(MyDatas *)data andTableView:(UITableView *)tableview andTask:(MyDownloadTask *)task{
//    _data = data;
    self.titleLabel.text = data.title;
    self.downloadTask = task;
    [self.btn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchDown];
    switch (self.downloadTask.taskState) {
        case DownloadingState:
            [self.btn setTitle:@"暂停" forState:UIControlStateNormal];
            break;
        case PausingState:
            [self.btn setTitle:@"开始" forState:UIControlStateNormal];
            break;
        case WaitingState:
            [self.btn setTitle:@"等待中" forState:UIControlStateNormal];
            break;
        default:
            [self.btn setTitle:@"EBtn" forState:UIControlStateNormal];
            break;
    }
}

-(void)btnHandler:(id)sender{
    AsyncDownloadTaskManager * manager = [AsyncDownloadTaskManager shared];
    switch (self.downloadTask.taskState) {
        case DownloadingState:{
            //点击时正在下载，说明执行暂停逻辑
            [manager pauseDownloadTask:_downloadTask complete:^(){
                [self.btn setTitle:@"开始" forState:UIControlStateNormal];
            }];
            break;
        }
        case PausingState:
        {
            //执行下载逻辑
            [manager restartDownloadTask:_downloadTask complete:^(){
                [self.btn setTitle:@"暂停" forState:UIControlStateNormal];
            }Fail:nil];
            
            break;
        }
        case WaitingState:
            [self.btn setTitle:@"等待中" forState:UIControlStateNormal];
            break;
        default:
            //TODO
            break;
    }
    
}

//-(void)btnCancelHandler:(id)sender{
//    AsyncDownloadTaskManager * manager = [AsyncDownloadTaskManager shared];
//    [manager cancelDownloadTask:self.downloadTask DeleteFile:YES complete:nil];
//
//    [_datas removeObject:_data];

//    ???
//    [_tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [_tableView reloadData];
//}
//
//-(void)bindTableView:(UITableView *)tableView cellAndIndexPath:(NSIndexPath *)path andDatas:(NSMutableArray *)datas{
//    _tableView = tableView;
//    _indexPath = path;
//    _datas = datas;
//}

@end
