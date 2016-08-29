//
//  ViewController.m
//  AsyncDownloadDemo
//
//  Created by antdlxding on 8/25/16.
//  Copyright © 2016 antdlxding. All rights reserved.
//

#import "ViewController.h"
#import "AsyncDownloadTaskManager.h"
#import "MyDatas.h"
#import "SecondViewController.h"
#import "UIView+Toast.h"

@interface ViewController ()

@property(nonatomic,copy) NSString * cachesPath;
@property(nonatomic,strong) SecondViewController * secVC;
@property(nonatomic,strong) UIButton *btn1;
@property(nonatomic,strong) UIButton *btn2;
@property(nonatomic,strong) UIButton *btn3;
@property(nonatomic,strong) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btn1 = [[UIButton alloc]initWithFrame:CGRectMake(67, 51, 97, 83)];
    [_btn1 addTarget:self action:@selector(Handler1:) forControlEvents:UIControlEventTouchDown];
    [_btn1 setTitle:@"download 1" forState:UIControlStateNormal];
    [_btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_btn1];
    
    _btn2 = [[UIButton alloc]initWithFrame:CGRectMake(241, 51, 97, 83)];
    [_btn2 addTarget:self action:@selector(Handler2:) forControlEvents:UIControlEventTouchDown];
    [_btn2 setTitle:@"download 2" forState:UIControlStateNormal];
    [_btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_btn2];
    
    _btn3 = [[UIButton alloc]initWithFrame:CGRectMake(67, 174, 97, 90)];
    [_btn3 addTarget:self action:@selector(Handler3:) forControlEvents:UIControlEventTouchDown];
    [_btn3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btn3 setTitle:@"download 3" forState:UIControlStateNormal];
    [self.view addSubview:_btn3];
    
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 698, 414, 38)];
    [_btn addTarget:self action:@selector(TransmitionHandlerToSec:) forControlEvents:UIControlEventTouchDown];
    [_btn setTitle:@"GoToSec" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_btn];
    
    
    _manager = [AsyncDownloadTaskManager shared];
    _secVC = [[SecondViewController alloc] init];
    _secVC.datas = [NSMutableArray array];
    _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
}
- (void)Handler1:(id)sender {
    
    NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo1.mp4",
                           @"title":@"download operation 1"};
    MyDatas * data = [MyDatas CellWithDict:dic];
    for (MyDatas * d in _secVC.datas) {
        if ([d.url isEqualToString:data.url]) {
            [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
            return;
        }
    }
    [_secVC.datas addObject:data];
    
    [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video1.mp4"];
    [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
    
}

- (void)Handler2:(id)sender {
    
    NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo2.mp4",
                           @"title":@"download operation 2"};
    MyDatas * data = [MyDatas CellWithDict:dic];
    for (MyDatas * d in _secVC.datas) {
        if ([d.url isEqualToString:data.url]) {
            [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
            return;
        }
    }
    [_secVC.datas addObject:data];
    [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video2.mp4"];
    [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
}

- (void)Handler3:(id)sender {
    
    NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo3.mp4",
                           @"title":@"download operation 3"};
    MyDatas * data = [MyDatas CellWithDict:dic];
    for (MyDatas * d in _secVC.datas) {
        if ([d.url isEqualToString:data.url]) {
            [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
            return;
        }
    }
    [_secVC.datas addObject:data];
    [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video3.mp4"];
   [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
}

- (void)TransmitionHandlerToSec:(id)sender {
    [self presentViewController:_secVC animated:YES completion:nil];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
