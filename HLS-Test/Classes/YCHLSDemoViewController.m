//
//  YCHLSDemoViewController.m
//  HLS-Test
//
//  Created by 超杨 on 16/1/27.
//  Copyright © 2016年 杨超. All rights reserved.
//

#import "YCHLSDemoViewController.h"
#import "YCHLS-Demo.h"
#import <MediaPlayer/MediaPlayer.h>
@interface YCHLSDemoViewController ()

/** 本地服务器对象 */
@property (nonatomic, strong)HTTPServer * httpServer;
/** 下载管理对象 */
@property (nonatomic, strong)VideoDownloader *downloader;

@end
@implementation YCHLSDemoViewController
#pragma mark - 打开本地服务器

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playLiveStreaming];
}

- (void)openHttpServer

{
    
    self.httpServer = [[HTTPServer alloc] init];
    
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    
    
    // 获取本地Documents路径
    
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    
    
    
    // 获取本地Documents路径下downloads路径
    
    NSString *webPath = [pathPrefix stringByAppendingPathComponent:kPathDownload];
    
    NSLog(@"-------------\nSetting document root: %@\n", webPath);
    
    
    
    // 设置本地服务器路径
    
    [self.httpServer setDocumentRoot:webPath];
    
    NSError *error;
    
    
    
    if(![self.httpServer start:&error])
        
    {
        
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
        
    }
    
}

- (void)playLiveStreaming {
    // 优酷视频m3u8新地址格式如下:http://pl.youku.com/playlist/m3u8?vid=XNzIwMDE5NzI4&type=mp4
    
    // 如果上面的链接不可用，那么使用这个链接http://v.youku.com/player/getM3U8/vid/XNzIwMDE5NzI4/type/flv
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://v.youku.com/player/getM3U8/vid/XNzIwMDE5NzI4/type/mp4"];
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    
    [self presentMoviePlayerViewControllerAnimated:player];

}

@end
