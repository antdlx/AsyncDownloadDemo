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
//用于绑定cell和task的唯一标识，每个cell都不一样，采用0,1,2的方案，为Manager中管理cell和Task绑定关系的bindCellArray做下标，即下标用这里的0，1，2，内容是Task的URL
<<<<<<< HEAD
@property(nonatomic,assign) NSInteger identify;
=======
//@property(nonatomic,assign) NSInteger identify;
>>>>>>> parent of 5e538c8... v1.1 task不再持有cell，改为通过block更新UI
//@property (nonatomic,strong) MyDownloadTask * downloadTask;
//Cell上按钮的监听器
@property (nonatomic,copy) void (^CancelHandlerBlock)();
@property (nonatomic,copy) void (^StateHandlerBlock)();

//渲染cell的UI
-(void)GenerateCellWithModel:(MyDatas *)data andTask:(MyDownloadTask *)task;

@end
