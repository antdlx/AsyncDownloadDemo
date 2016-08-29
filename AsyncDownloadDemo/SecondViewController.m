//
//  SecondViewController.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "SecondViewController.h"
#import "MyDatas.h"
#import "MyCell.h"
#import "AsyncDownloadTaskManager.h"
#import "MyDownloadTask.h"
#import "ViewController.h"

@interface SecondViewController() <UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic,strong) MyDatas * datas;
@property(nonatomic,strong) AsyncDownloadTaskManager * manager;
@property(nonatomic,strong) ViewController * firstVC;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton * btn;

@end

@implementation SecondViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 698, 414, 38)];
    [_btn addTarget:self action:@selector(TransmitionHandler:) forControlEvents:UIControlEventTouchDown];
    [_btn setTitle:@"Back" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_btn];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, 414, 679)];
    [self.view addSubview:_tableView];
    
    _firstVC = [[ViewController alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _manager = [AsyncDownloadTaskManager shared];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * index = @"cell";
    MyCell * cell = [tableView dequeueReusableCellWithIdentifier:index];
    if (cell == nil) {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:index];
        cell.identify = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    }
    
    NSInteger count = indexPath.row;
    MyDatas * data = _datas[count];
    
    MyDownloadTask * thisTask = [_manager bindCell:cell WithTaskURL:data.url];
    [cell GenerateCellWithModel:data andTableView:tableView andTask:thisTask];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (void)TransmitionHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
