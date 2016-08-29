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
    [_btn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchDown];
    
    [self.contentView addSubview:_btn];
    
    _btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(392, 27, 21, 25)];
    _btnCancel.backgroundColor = [UIColor clearColor];
    //设置文字
    _btnCancel.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
    //注意：设置按钮字体颜色不能使用button.titleLabel.textColor方式
    [_btnCancel setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
    [_btnCancel setTitle:@"X" forState:UIControlStateNormal];
    [_btnCancel addTarget:self action:@selector(btnCancelHandler:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:_btnCancel];
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(14, 53, 308, 2)];
    [_progressView setProgress:0.0];
    [self.contentView addSubview:_progressView];
    
    return self;
}

//UI渲染最好在Cell中实现
-(void)GenerateCellWithModel:(MyDatas *)data andTableView:(UITableView *)tableview andTask:(MyDownloadTask *)task{

    self.titleLabel.text = data.title;
    self.downloadTask = task;
    self.percentLabel.text = [NSString stringWithFormat:@"%.2f %%",[task.progress doubleValue]];
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

//监听器最好在ViewController中实现
-(void)btnHandler:(id)sender{
    _StateHandlerBlock();
}

-(void)btnCancelHandler:(id)sender{
    _CancelHandlerBlock();
}



@end
