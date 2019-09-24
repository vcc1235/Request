//
//  SocketClient.h
//  Pods-Request_Tests
//
//  Created by alete on 2019/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, WebSocketConnectType) {
    
    WebSocketDefault = 0 ,
    WebSocketConnect ,
    WebSocketDisconnect
    
};

@protocol WebSocketManagerDelegate <NSObject>

-(void)webSocketDidConnectd ;

-(void)webSocketConnectFail ;

-(void)webSocketManagerDidReceiveMessageWithString:(NSDictionary *__nullable)data;

@end

@interface SocketClient : NSObject

@property (nonatomic, weak) id <WebSocketManagerDelegate> delegate;

@property (nonatomic, assign) WebSocketConnectType connectType ;

@property (nonatomic, strong) NSString *socketURL ;

-(void)connectServer ;

-(void)reconnectServer ;

-(void)closeServer ;

-(void)sendDataToServer:(NSString *)data ;

@end

NS_ASSUME_NONNULL_END
