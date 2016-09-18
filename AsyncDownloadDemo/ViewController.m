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
#import "Reachability.h"

@interface ViewController ()

@property(nonatomic,copy) NSString * cachesPath;
@property(nonatomic,strong) SecondViewController * secVC;
@property(nonatomic,strong) UIButton *btn1;
@property(nonatomic,strong) UIButton *btn2;
@property(nonatomic,strong) UIButton *btn3;
@property(nonatomic,strong) UIButton *btn4;
@property(nonatomic,strong) UIButton *btn;
@property(nonatomic,assign) NSInteger single;

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
    
    _btn4 = [[UIButton alloc]initWithFrame:CGRectMake(241, 174, 97, 90)];
    [_btn4 addTarget:self action:@selector(Handler4:) forControlEvents:UIControlEventTouchDown];
    [_btn4 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_btn4 setTitle:@"download 4" forState:UIControlStateNormal];
    [self.view addSubview:_btn4];
    
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 698, 414, 38)];
    [_btn addTarget:self action:@selector(TransmitionHandlerToSec:) forControlEvents:UIControlEventTouchDown];
    [_btn setTitle:@"GoToSec" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:_btn];
    
    
    _manager = [AsyncDownloadTaskManager shared];
    _secVC = [[SecondViewController alloc] init];
    _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    _single = 0;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    // 通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    //Reachability实例调用startNotifier方法启动网络状态监测
    [reach startNotifier];
    
}

-(void)reachabilityChanged:(NSNotification *) notification{
    //不知道为什么，会被调用两次，所以只显示一次
    _single++;
    if (_single % 2 == 1) {
        Reachability *reach = [notification object];
        
        switch ([reach currentReachabilityStatus]) {
            case NotReachable:
                [self.view makeToast:@"NotReachable" duration:1.0 position:CSToastPositionCenter];
                [_manager pauseAllTaskAndFiles:nil];
                NSLog(@"NotReachable");
                break;
            case ReachableViaWiFi:
                [self.view makeToast:@"ReachableViaWiFi" duration:1.0 position:CSToastPositionCenter];
                NSLog(@"ReachableViaWiFi");
                //need a restart all task func, and u need to finish this func in AsyncDownloadTaskManager class
                break;
            case ReachableViaWWAN:
                [self.view makeToast:@"ReachableViaWWAN" duration:1.0 position:CSToastPositionCenter];
                NSLog(@"ReachableViaWWAN");
                [_manager pauseAllTaskAndFiles:nil];
                break;
            default:
                break;
        }
        
    }
}


- (void)Handler1:(id)sender {
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    if ([reach currentReachabilityStatus]==ReachableViaWiFi) {
        
        NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo1.mp4",
                               @"title":@"download operation 1"};
        MyDatas * data = [MyDatas CellWithDict:dic];
        for (MyDatas * d in _manager.datas) {
            if ([d.url isEqualToString:data.url]) {
                [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
                return;
            }
        }
        [_manager.datas addObject:data];
        
        [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video1.mp4" complete:nil];
        [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"无网络"];
    }
    
}

- (void)Handler2:(id)sender {
    
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    if ([reach currentReachabilityStatus]==ReachableViaWiFi) {
        NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo2.mp4",
                               @"title":@"download operation 2"};
        MyDatas * data = [MyDatas CellWithDict:dic];
        for (MyDatas * d in _manager.datas) {
            if ([d.url isEqualToString:data.url]) {
                [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
                return;
            }
        }
        [_manager.datas addObject:data];
        [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video2.mp4" complete:nil];
        [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"无网络"];
    }
    
}

- (void)Handler3:(id)sender {
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    if ([reach currentReachabilityStatus]==ReachableViaWiFi) {
        
        NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo3.mp4",
                               @"title":@"download operation 3"};
        MyDatas * data = [MyDatas CellWithDict:dic];
        for (MyDatas * d in _manager.datas) {
            if ([d.url isEqualToString:data.url]) {
                [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
                return;
            }
        }
        [_manager.datas addObject:data];
        [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video3.mp4" complete:nil];
        [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"无网络"];
    }
    
}

- (void)Handler4:(id)sender {
    NSLog(@"button 4");
   
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.antdlx.com"];
    if ([reach currentReachabilityStatus]==ReachableViaWiFi) {
        
        NSDictionary * dic = @{@"url":@"http://www.antdlx.com/testVideo4.mp4",
                               @"title":@"download operation 4"};
        MyDatas * data = [MyDatas CellWithDict:dic];
        for (MyDatas * d in _manager.datas) {
            if ([d.url isEqualToString:data.url]) {
                [self.view makeToast:@"已加入下载队列" duration:2.0 position:CSToastPositionCenter];
                return;
            }
        }
        [_manager.datas addObject:data];
        [_manager download:dic[@"url"] savePath:_cachesPath saveName:@"video4.mp4" complete:nil];
        [self.view makeToast:@"加入下载队列" duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"无网络"];
    }
}

- (void)TransmitionHandlerToSec:(id)sender {
    [self presentViewController:_secVC animated:YES completion:nil];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
