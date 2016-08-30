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

//第二次跳转回来的时候就不会再执行ViewDidLoad方法了，所以要在这里刷新一下列表
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * index = @"cell";
    MyCell * cell = [tableView dequeueReusableCellWithIdentifier:index];
    if (cell == nil) {
        cell = [[MyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:index];
        cell.identify = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    }
    
    NSInteger count = indexPath.row;
    MyDatas* thisData = _datas[count];
    
    MyDownloadTask * thisTask = [_manager bindCell:cell WithTaskURL:thisData.url];
    [cell GenerateCellWithModel:thisData andTask:thisTask];
    //删除的监听器 
    cell.CancelHandlerBlock = ^(){
        //添加alert确认是否删除视频源文件
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除" message:@"请问是否删除视频源文件？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertaction){
            [_manager cancelDownloadTask:thisTask DeleteFile:YES complete:nil];
            [_datas removeObject:thisData];
            [_tableView reloadData];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertaction){
            [_manager cancelDownloadTask:thisTask DeleteFile:NO complete:nil];
            [_datas removeObject:thisData];
            [_tableView reloadData];
        }];
        [alert addAction:action];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    //状态变化的按钮的监听器，开始、暂停、等待中
    __weak typeof(cell) weakcell = cell;
    cell.StateHandlerBlock = ^(){
        __strong typeof(weakcell) strongCell = weakcell;
        switch (thisTask.taskState) {
            case DownloadingState:{
                //点击时正在下载，说明执行暂停逻辑
                [_manager pauseDownloadTask:thisTask complete:^(){
                    [strongCell.btn setTitle:@"开始" forState:UIControlStateNormal];
                }];
                break;
            }
            case PausingState:
            {
                //执行下载逻辑
                [_manager restartDownloadTask:thisTask complete:^(){
                    [strongCell.btn setTitle:@"暂停" forState:UIControlStateNormal];
                }Fail:nil];
                break;
            }
            case WaitingState:
                [strongCell.btn setTitle:@"等待中" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    };
    
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
