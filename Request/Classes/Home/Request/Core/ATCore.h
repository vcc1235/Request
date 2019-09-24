//
//  ATCore.h
//  Pods-Request_Tests
//
//  Created by alete on 2019/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ResponseTask)(id _Nullable resObject,NSError * _Nullable error);
typedef void(^Response)(id _Nullable object);
typedef void(^Fail)(NSError * _Nullable error);
typedef void(^Progress)(double  progress);
@class FormData ;
@interface ATCore : NSObject

/**
 是否开启SSL

 @param ssl ssl description
 */
+(void)setSecuritySSL:(BOOL)ssl ;

/**
 设置请求头

 @param value <#value description#>
 @param field <#field description#>
 */
+(void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field ;

/** 开启网络监听 **/
+ (void)networkReachabilityMonitoring ;

/**
 GET 请求
 @param urlStr urlStr description
 @param params params description
 @param success success description
 @param failure failure description
 @return return value description
 */
+(NSURLSessionDataTask *)getWithURLString:(NSString *)urlStr params:(NSDictionary *)params success:(Response)success failure:(Fail)failure ;


/**
 POST

 @param urlStr urlStr description
 @param params params description
 @param success success description
 @param failure failure description
 @return return value description
 */
+(NSURLSessionDataTask *)postWithURLString:(NSString *)urlStr params:(NSDictionary *)params success:(Response)success failure:(Fail)failure;

/**
 下载

 @param urlStr url
 @param path 下载路径
 @param success success description
 @param failure failure description
 @param progress progress description
 @return return value description
 */
+(NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlStr path:(NSURL *(^)(NSString *name))path success:(Response)success failure:(Fail)failure progress:(Progress)progress ;


/**
 上传

 @param urlStr urlStr description
 @param params params description
 @param formData formData description
 @param success success description
 @param failure failure description
 @param progress progress description
 @return return value description
 */
+ (NSURLSessionDataTask *)uploadFileWithURLString:(NSString *)urlStr params:(NSDictionary *)params FormData:(FormData *)formData success:(Response)success failure:(Fail)failure progress:(Progress)progress ;
@end

// 用来封装文件数据的模型
@interface FormData : NSObject
/**
 *  文件数据
 */
@property (nonatomic, strong) NSData *data;
/**
 *  参数名
 */
@property (nonatomic, copy) NSString *name;
/**
 *  文件名 带有后缀的
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *mimeType;


- (instancetype)initWithImageData:(NSData *)imageData;

@end


NS_ASSUME_NONNULL_END
