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

//UI
@property(nonatomic,strong) UIProgressView * progressView;
@property(nonatomic,strong) UILabel * titleLabel;
@property(nonatomic,strong) UILabel * percentLabel;
@property(nonatomic,strong) UIButton * btn;
@property(nonatomic,strong) UIButton * btnCancel;
//Cell上按钮的监听器
@property (nonatomic,copy) void (^CancelHandlerBlock)();
@property (nonatomic,copy) void (^StateHandlerBlock)();

//渲染cell的UI
-(void)GenerateCellWithModel:(MyDatas *)data andTask:(MyDownloadTask *)task;

@end
