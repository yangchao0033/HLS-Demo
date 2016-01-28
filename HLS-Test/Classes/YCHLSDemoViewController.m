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

/** 点播协议 */
#define TEST_HLS_URL @"http://m3u8.tdimg.com/147/806/921/3.m3u8"
/** 视频直播协议 */
//#define TEST_HLS_URL @"http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5.m3u8"
@interface YCHLSDemoViewController () <M3U8HandlerDelegate, VideoDownloadDelegate>

/** 本地服务器对象 */
@property (nonatomic, strong)HTTPServer * httpServer;
/** 下载管理对象 */
@property (nonatomic, strong)VideoDownloader *downloader;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end
@implementation YCHLSDemoViewController

- (void)dealloc {
    [self.downloader removeObserver:self forKeyPath:@"clearCaches" context:nil];
//    [self.downloader removeObserver:self forKeyPath:@"currentProgress" context:nil];
}

#pragma mark - 打开本地服务器

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    /** 打开本地服务器 */
    [self openHttpServer];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownload"] boolValue]) {
        [self.downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
        self.clearButton.enabled = YES;
        self.progressView.progress = 1;
        /** 配置MSU8解析器 */
        M3U8Handler *handler = [[M3U8Handler alloc] init];
//        [handler praseUrl:[NSString stringWithFormat:@"http://v.youku.com/player/getM3U8/vid/XNjUxMTE4NDAw/type/mp4"]];
        [handler praseUrl:[NSString stringWithFormat:TEST_HLS_URL]];
        handler.playlist.uuid = @"XNjUxMTE4NDAw";
        if (self.downloader != nil) {
            [self.downloader removeObserver:self forKeyPath:@"clearCaches" context:nil];
            [self.downloader removeObserver:self forKeyPath:@"currentProgress"];
            self.downloader = nil;
        }
            /** 初始化下载对象 */
            self.downloader = [[VideoDownloader alloc] initWithM3U8List:handler.playlist];
            [self.downloader addObserver:self forKeyPath:@"clearCaches" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil]; // 判断是否清理缓存
    }
}

- (void)openHttpServer

{
    
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    // 获取本地Library/Cache路径下downloads路径
    NSString *webPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    
//    if ([self needCreateWithPath:webPath]) {
//        // 创建文件夹
//        NSLog(@"创建新文件夹：%@", webPath);
//    }
    
    NSLog(@"-------------\nSetting document root: %@\n", webPath);
    
    // 设置服务器路径
    [self.httpServer setDocumentRoot:webPath];
    NSError *error;
    
    if(![self.httpServer start:&error])
    {
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
    }
    
}

//- (BOOL)needCreateWithPath:(NSString *)createPath
//{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:createPath])//判断createPath路径文件夹是否已存在，此处createPath为需要新建的文件夹的绝对路径
//    {
//        return NO;
//    }
//    else
//    {
//        
//        [[NSFileManager defaultManager] createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
//        return YES;
//    }
//}

#pragma mark - 清理缓存
- (IBAction)clearCaches:(id)sender {
    [self.downloader cleanDownloadFiles];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownload"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - 在线流媒体播放
- (IBAction)playLiveStreaming {
    // 优酷视频m3u8新地址格式如下:http://pl.youku.com/playlist/m3u8?vid=XNzIwMDE5NzI4&type=mp4
    
    // 如果上面的链接不可用，那么使用这个链接http://v.youku.com/player/getM3U8/vid/XNzIwMDE5NzI4/type/flv
    
    // 如果上面的两种格式都不行的话，考虑用这个格式，当然如果这个格式不行的话，是上面的，或者直接换个对应的m3u8的地址 http://pl.youku.com/playlist/m3u8?vid=162779600&ts=1407469897&ctype=12&token=3357&keyframe=1&sid=640746989782612d6cc70&ev=1&type=mp4&ep=dCaUHU2LX8YJ4ivdjj8bMyqxJ3APXP8M9BiCiNRiANQnS%2B24&oip=2043219268
//    NSURL *url = [[NSURL alloc] initWithString:@"http://pl.youku.com/playlist/m3u8?vid=162779600&ts=1407469897&ctype=12&token=3357&keyframe=1&sid=640746989782612d6cc70&ev=1&type=flv&ep=dCaUHU2LX8YJ4ivdjj8bMyqxJ3APXP8M9BiCiNRiANQnS%2B24&oip=2043219268"];
    NSURL *url = [[NSURL alloc] initWithString:TEST_HLS_URL];
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    
    [self presentMoviePlayerViewControllerAnimated:player];

}

#pragma mark - 视频下载
- (IBAction)downloadStreamingMedia:(id)sender {
    
    UIButton *downloadButton = sender;
    // 获取本地Library/Cache路径
    NSString *localDownloadsPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    
    // 获取视频本地路径
    NSString *filePath = [localDownloadsPath stringByAppendingPathComponent:@"XNjUxMTE4NDAw/movie.m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断视频是否缓存完成，如果完成则播放本地缓存
    if ([fileManager fileExistsAtPath:filePath]) {
        [downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
        downloadButton.enabled = NO;
    }else{
        M3U8Handler *handler = [[M3U8Handler alloc] init];
        handler.delegate = self;
        // 解析m3u8视频地址
        [handler praseUrl:TEST_HLS_URL];
        // 开启网络指示器
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

#pragma mark - 视频解析完成
-(void)praseM3U8Finished:(M3U8Handler*)handler
{
    handler.playlist.uuid = @"XNjUxMTE4NDAw";
    if (self.downloader != nil) {
        [self.downloader removeObserver:self forKeyPath:@"clearCaches" context:nil];
        [self.downloader removeObserver:self forKeyPath:@"currentProgress"];
        self.downloader = nil;
    }
        self.downloader = [[VideoDownloader alloc]initWithM3U8List:handler.playlist];
        [self.downloader addObserver:self forKeyPath:@"currentProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil]; // 设置观察者用来得到当前下载的进度
        [self.downloader addObserver:self forKeyPath:@"clearCaches" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil]; // 判断是否清理缓存
        self.downloader.delegate = self;
    [self.downloader startDownloadVideo]; // 开始下载
}

#pragma mark - 通过观察者监控下载进度显示/缓存清理
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"clearCaches"]) {
        NSLog(@"%@", change);
//        if (change[@"new"]) {
            self.downloadButton.enabled = YES;
            [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            self.clearButton.enabled = NO;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownload"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.progressView.progress = 0.0;
            self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", 0.0];
//        }
        
    }else{
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", 100 * [[change objectForKey:@"new"] floatValue]];
        self.progressView.progress = [[change objectForKey:@"new"] floatValue];
        if (self.progressView.progress == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isDownload"];
            [self.downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.clearButton.enabled = YES;
            self.downloadButton.enabled = NO;
        }
    }
    
}

#pragma mark - 视频解析失败
-(void)praseM3U8Failed:(M3U8Handler*)handler
{
    NSLog(@"视频解析失败-failed -- %@",handler);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"视频解析失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}


#pragma mark --------------视频下载完成----------------

-(void)videoDownloaderFinished:(VideoDownloader*)request

{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.downloadButton.enabled = YES;
    
    [request createLocalM3U8file];
    
    NSLog(@"----------视频下载完成-------------");
    
}



#pragma mark --------------视频下载失败----------------

-(void)videoDownloaderFailed:(VideoDownloader*)request

{
    
    NSLog(@"----------视频下载失败-----------");
    
}

#pragma mark - 播放本地视频
- (IBAction)playVideoFromLocal:(id)sender {
    
    NSString * playurl = [NSString stringWithFormat:@"http://127.0.0.1:12345/XNjUxMTE4NDAw/movie.m3u8"];
    NSLog(@"本地视频地址-----%@", playurl);
    
    // 获取本地Library/Cache路径
    NSString *localDownloadsPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    // 获取视频本地路径
    NSString *filePath = [localDownloadsPath stringByAppendingPathComponent:@"XNjUxMTE4NDAw/movie.m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断视频是否缓存完成，如果完成则播放本地缓存
    if ([fileManager fileExistsAtPath:filePath]) {
        MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString: playurl]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"当前视频未缓存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)instanceDelloc {
    [self.downloader removeObserver:self forKeyPath:@"clearCaches" context:nil];
}
@end
