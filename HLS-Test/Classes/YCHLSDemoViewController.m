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
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#define VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



#warning 注意，不要直接使用切换流的主索引，当前代码的协议只提供对.ts定位的子索引的下载和播放，而且其中只有点播协议那一小段是可以下载的，直播协议只能播放，无法下载。崩溃bug正在找，会及时在博客中进行更新。博客地址：superyang.gitcafe.io或yangchao0033.github.io
//#define TEST_HLS_URL @"http://m3u8.tdimg.com/147/806/921/3.m3u8"
/** 视频直播协议 */
/** 父索引 */
//#define TEST_HLS_URL @"http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5.m3u8"
/** 子索引 */
//#define TEST_HLS_URL @"http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5_1024/index.m3u8?Dnion_vsnae=34338_PVMT5"
/** wwcd视频，果然苹果自己就用这个协议 */
//#define TEST_HLS_URL @"http://devstreaming.apple.com/videos/wwdc/2015/413eflf3lrh1tyo/413/hls_vod_mvp.m3u8"

/** 点播协议 */
//#define TEST_HLS_URL @"http://devstreaming.apple.com/videos/wwdc/2015/413eflf3lrh1tyo/413/0640/0640.m3u8"
/** 新增芈月传点播~ */
#define TEST_HLS_URL @"http://yangchao0033.github.io/hlsSegement/0640.m3u8"

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
}

#pragma mark - 打开本地服务器

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self.URLString isEqualToString:@""] || !self.URLString) {
        self.URLString = TEST_HLS_URL;
    }
    
    /** 打开本地服务器 */
    [self openHttpServer];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownload"] boolValue]) {
        [self.downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
        self.downloadButton.enabled = NO;
        self.clearButton.enabled = YES;
        self.progressView.progress = 1;
        self.progressLabel.text = @"100%";
        /** 配置MSU8解析器 */
        M3U8Handler *handler = [[M3U8Handler alloc] init];
        [handler praseUrl:[NSString stringWithFormat:@"%@", self.URLString]];
        /** @"XNjUxMTE4NDAw"就是一个唯一标示符，没有其他含义，下面遇到同理 */
        handler.playlist.uuid = @"0640";
        if (self.downloader != nil) {
            [self.downloader removeObserver:self forKeyPath:@"clearCaches" context:nil];
            [self.downloader removeObserver:self forKeyPath:@"currentProgress"];
            self.downloader = nil;
        }
        /** 初始化下载对象 */
        self.downloader = [[VideoDownloader alloc] initWithM3U8List:handler.playlist];
        [self.downloader addObserver:self forKeyPath:@"clearCaches" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil]; // 判断是否清理缓存
        [self.downloader addObserver:self forKeyPath:@"currentProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.downloader stopDownloadVideo];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isDownload"] boolValue]) {
        self.downloadButton.enabled = YES;
        [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    }
}
- (void)openHttpServer
{
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    // 获取本地Library/Cache路径下downloads路径
//    NSString *webPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    
    NSString *webPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    
    webPath = WebBasePath;
    
    NSLog(@"-------------\nSetting document root: %@\n", webPath);
    // 设置服务器路径
    [self.httpServer setDocumentRoot:webPath];
    NSError *error;
    if(![self.httpServer start:&error])
    {
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
    }
}


#pragma mark - 清理缓存
- (IBAction)clearCaches:(id)sender {
    [self.downloader cleanDownloadFiles];
}


#pragma mark - 在线流媒体播放
- (IBAction)playLiveStreaming {
    
    NSURL *url = [[NSURL alloc] initWithString:self.URLString];
    if (VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [[AVPlayer alloc] initWithURL:url];
        [self presentViewController:playerVC animated:YES completion:^{
            [playerVC.player play];
        }];
    } else {
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        [self presentMoviePlayerViewControllerAnimated:player];
    }
}

#pragma mark - 视频下载
- (IBAction)downloadStreamingMedia:(id)sender {
    
    
    [self.downloadButton setTitle:@"下载中" forState:UIControlStateNormal];
    self.downloadButton.enabled = NO;
    
    UIButton *downloadButton = sender;
    // 获取本地Library/Cache路径
    NSString *localDownloadsPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    
    // 获取视频本地路径
    NSString *filePath = [localDownloadsPath stringByAppendingPathComponent:@"0640/0640.m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断视频是否缓存完成，如果完成则播放本地缓存
    if ([fileManager fileExistsAtPath:filePath]) {
        [downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
        downloadButton.enabled = NO;
    }else{
        M3U8Handler *handler = [[M3U8Handler alloc] init];
        handler.delegate = self;
        // 解析m3u8视频地址
        [handler praseUrl:self.URLString];
        // 开启网络指示器
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

#pragma mark - 视频解析完成
-(void)praseM3U8Finished:(M3U8Handler*)handler
{
    handler.playlist.uuid = @"0640";
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
        self.downloadButton.enabled = YES;
        [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        self.downloadButton.enabled = YES;
        self.clearButton.enabled = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isDownload"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.progressView.progress = 0.0;
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", 0.0];
    }else{
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", 100 * [[change objectForKey:@"new"] floatValue]];
        self.progressView.progress = [[change objectForKey:@"new"] floatValue];
        if (self.progressView.progress == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isDownload"];
            [self.downloadButton setTitle:@"已完成" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.clearButton.enabled = YES;
            self.downloadButton.enabled = NO;
        } else {
//            [self.downloadButton setTitle:@"下载中" forState:UIControlStateNormal];
//            self.downloadButton.enabled = NO;
        }
    }
    
}

#pragma mark - 视频解析失败
-(void)praseM3U8Failed:(M3U8Handler*)handler error:(NSError *)error
{
    NSLog(@"视频解析失败-failed -- %@",handler);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频解析失败" message:error.domain delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [alertView show];
}


#pragma mark --------------视频下载完成----------------

-(void)videoDownloaderFinished:(VideoDownloader*)request

{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
//    self.downloadButton.enabled = YES;
    
    [request createLocalM3U8file];
    
    NSLog(@"----------视频下载完成-------------");
    
}



#pragma mark --------------视频下载失败----------------

-(void)videoDownloaderFailed:(VideoDownloader*)request

{
    [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    self.downloadButton.enabled = YES;
    NSLog(@"----------视频下载失败-----------");
    
}

#pragma mark - 播放本地视频
- (IBAction)playVideoFromLocal:(id)sender {
    
    NSString * playurl = [NSString stringWithFormat:@"http://127.0.0.1:12345/0640/0640.m3u8"];
    NSLog(@"本地视频地址-----%@", playurl);
    
    // 获取本地Library/Cache路径
    NSString *localDownloadsPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    // 获取视频本地路径
//    NSString *filePath = [localDownloadsPath stringByAppendingPathComponent:@"0640/0640.m3u8"];
    NSString *filePath = [WebBasePath stringByAppendingPathComponent:@"0640/0640.m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断视频是否缓存完成，如果完成则播放本地缓存
    if ([fileManager fileExistsAtPath:filePath]) {
        if (VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
            playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString: playurl]];
            [self presentViewController:playerVC animated:YES completion:^{
                [playerVC.player play];
            }];
        } else {
            MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString: playurl]];
            [self presentMoviePlayerViewControllerAnimated:playerViewController];
        }
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
