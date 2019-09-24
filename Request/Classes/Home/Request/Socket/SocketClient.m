//
//  SocketClient.m
//  Pods-Request_Tests
//
//  Created by alete on 2019/7/16.
//

#import "SocketClient.h"
#import "SRWebSocket.h"
#import <AFNetworking/AFNetworking.h>

@interface SocketClient ()<SRWebSocketDelegate>

@property (nonatomic, strong)  SRWebSocket *socket ;
@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器
@property (nonatomic, strong) NSTimer *netWorkTestingTimer; //没有网络的时候检测网络定时器
@property (nonatomic, assign) NSTimeInterval reConnectTime; //重连时间
@property (nonatomic, strong) NSMutableArray *sendDataArray; //存储要发送给服务端的数据
@property (nonatomic, assign) BOOL isActivelyClose;  //用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法


@end


@implementation SocketClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reConnectTime = 0 ;
        self.isActivelyClose = false ;
        self.sendDataArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)connectServer{
    
    self.socket.delegate = nil ;
    [self.socket close];
    _socket = nil ;
    self.socket = [[SRWebSocket alloc]initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.socketURL]]];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;//zc read:并发数为1==>串行队列
    [self.socket setDelegateOperationQueue:queue];
    self.socket.delegate = self ;
    [self.socket open];
    
}

-(void)sendPing:(id)sender{
    [self.socket sendPing:nil];
}

-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
    NSLog(@"%s",__func__);
    self.connectType = WebSocketConnect ;
    if ([self.delegate respondsToSelector:@selector(webSocketDidConnectd)]) {
        [self.delegate webSocketDidConnectd];
    }
    [self initHeartBeat];
    
}
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"%s",__func__);
    self.connectType = WebSocketDisconnect ;
    if ([self.delegate respondsToSelector:@selector(webSocketConnectFail)]) {
        [self.delegate webSocketConnectFail];
    }
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self noNetWorkStartTestingTimer];
    }else{
        [self reconnectServer]; /// 重新连接
    }
    
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    if ([message isKindOfClass:NSData.class]) {
        message = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:nil];
    }else{
        NSString *msg = message ;
        message = [NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    [self receiveSocketMessageWith:message];
}
- (void)receiveSocketMessageWith:(NSArray *)args {
    if ([args isKindOfClass:NSArray.class]) {
        
    }else{
        NSDictionary *dic = (NSDictionary *)args ;
        if ([dic.allKeys containsObject:@"list"]) {
            NSArray *list = [dic valueForKey:@"list"];
            for (NSDictionary *dict in list) {
                if ([self.delegate respondsToSelector:@selector(webSocketManagerDidReceiveMessageWithString:)]) {
                    [self.delegate webSocketManagerDidReceiveMessageWithString:dict];
                }
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(webSocketManagerDidReceiveMessageWithString:)]) {
                [self.delegate webSocketManagerDidReceiveMessageWithString:dic];
            }
        }
    }
    
}
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    if (self.isActivelyClose) {
        self.connectType = WebSocketDefault ;
        return ;
    }else{
        self.connectType = WebSocketDisconnect ;
    }
    [self destoryHeartBeat];
    
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self noNetWorkStartTestingTimer];
    }else{
        _socket = nil ;
        [self reconnectServer];
    }
    
}
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"%s",__func__);
}

/// 初始化心跳
-(void)initHeartBeat{
    if (self.heartBeatTimer) {
        return ;
    }
    [self destoryHeartBeat];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartBeatTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop]addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
    });
    
}
//重新连接
- (void)reconnectServer{
    if(self.socket.readyState == SR_OPEN){
        return;
    }
    
    if(self.reConnectTime > 1024){ //重连10次 2^10 = 1024
        self.reConnectTime = 0;
        return;
    }
    
    __weak typeof(self) weakSelf = self ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(weakSelf.socket.readyState == SR_OPEN && weakSelf.socket.readyState == SR_CONNECTING) {
            return;
        }
        
        [weakSelf connectServer];
        //    CTHLog(@"正在重连......");
        
        if(weakSelf.reConnectTime == 0){ //重连时间2的指数级增长
            weakSelf.reConnectTime = 2;
        }else{
            weakSelf.reConnectTime *= 2;
        }
    });
    
}
-(void)closeServer{
    self.isActivelyClose = true ;
    [self.socket close];
}

//发送心跳
- (void)senderheartBeat{
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    __weak typeof(self) weakSelf = self ;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.socket.readyState == SR_OPEN){
            [weakSelf sendPing:nil];
        }
    });
}
//没有网络的时候开始定时 -- 用于网络检测
- (void)noNetWorkStartTestingTimer{
    __weak typeof(self) weakSelf = self ;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.netWorkTestingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(noNetWorkStartTesting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.netWorkTestingTimer forMode:NSDefaultRunLoopMode];
    });
}
//定时检测网络
- (void)noNetWorkStartTesting{
    //有网络
    if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        //关闭网络检测定时器
        [self destoryNetWorkStartTesting];
        //开始重连
        [self reconnectServer];
    }
}
//取消网络检测
- (void)destoryNetWorkStartTesting{
    __weak typeof(self) weakSelf = self ;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.netWorkTestingTimer)
        {
            [weakSelf.netWorkTestingTimer invalidate];
            weakSelf.netWorkTestingTimer = nil;
        }
    });
}
//取消心跳
- (void)destoryHeartBeat{
    __weak typeof(self) weakSelf = self ;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.heartBeatTimer)
        {
            [weakSelf.heartBeatTimer invalidate];
            weakSelf.heartBeatTimer = nil;
        }
    });
}
//关闭长连接
- (void)RMWebSocketClose{
    self.isActivelyClose = YES;
    
    self.connectType = WebSocketDefault;
    if(self.socket)
    {
        [self.socket close];
        _socket = nil;
    }
    
    //关闭心跳定时器
    [self destoryHeartBeat];
    
    //关闭网络检测定时器
    [self destoryNetWorkStartTesting];
}
//发送数据给服务器
- (void)sendDataToServer:(NSString *)data{
    //    [self.sendDataArray addObject:data];
    
    //[_webSocket sendString:data error:NULL];
    
    //没有网络
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        //开启网络检测定时器
        [self noNetWorkStartTestingTimer];
    }
    else //有网络
    {
        if(self.socket != nil)
        {
            // 只有长连接OPEN开启状态才能调 send 方法，不然会Crash
            if(self.socket.readyState == SR_OPEN)
            {
                //                if (self.sendDataArray.count > 0)
                //                {
                //                    NSString *data = self.sendDataArray[0];
                [_socket send:data]; //发送数据
                //                    [self.sendDataArray removeObjectAtIndex:0];
                
                //                }
            }
            else if (self.socket.readyState == SR_CONNECTING) //正在连接
            {
                NSLog(@"正在连接中，重连后会去自动同步数据");
            }
            else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED) //断开连接
            {
                //调用 reConnectServer 方法重连,连接成功后 继续发送数据
                [self reconnectServer];
            }
        }
        else
        {
            [self connectServer]; //连接服务器
        }
    }
}


@end
