# HLS-Demo
IOS 视屏直播样例

主要展示 HLS 详细流程，用于iOS视屏直播。

**使用demo前请注意下面的问题。**

```objc
//#warning 注意，不要直接使用切换流的主索引，当前代码的协议只提供对.ts定位的子索引的下载和播放，而且其中只有点播协议那一小段是可以下载的，直播协议只能播放，无法下载，无法下载的原因是因为m3u8的那个库中只对特定的一种m3u8的格式做了解析，而m3u8的格式有很多种，所以无法加息出来，该demo只做演示，不会对所有格式进行全解析，如果大家感兴趣的话可以对m3u8的库进行扩展，在github 上 pull request 我做一个补充扩展😁，我会及时在博客中进行更新。博客地址：superyang.gitcafe.io或yangchao0033.github.io 同简书：http://www.jianshu.com/users/f37a8f0ba6f8/latest_articles

/** 点播协议 (只有这个是可以下载的，但是苦于太短，没办法播放出来，正在寻找可以下载并播放的新的点播或直播源,希望有读者可以帮忙提供哈，不甚感激~)*/
//#define TEST_HLS_URL @"http://m3u8.tdimg.com/147/806/921/3.m3u8"
/** 视频直播协议 */
/** 父索引(无法下载，只作为结构分析) */
//#define TEST_HLS_URL @"http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5.m3u8"
/** 子索引(无法下载，只作为结构分析) */
//#define TEST_HLS_URL @"http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5_1024/index.m3u8?Dnion_vsnae=34338_PVMT5"
/** wwcd视频，果然苹果自己就用这个协议(无法下载，只作为结构分析) */
//#define TEST_HLS_URL @"http://devstreaming.apple.com/videos/wwdc/2015/413eflf3lrh1tyo/413/hls_vod_mvp.m3u8"
```

## demo简介：

如果觉得文章有用的话，请读者在github上点个star😁，或者在[简书](http://www.jianshu.com/users/f37a8f0ba6f8/latest_articles)上点个赞。

Demo配置原理：

1、 需要导入第三方库：ASIHttpRequest，CocoaHTTPServer，m3u8（其中ASI用于网络请求，CocoaHTTPServer用于在ios端搭建服务器使用，m3u8是用来对返回的索引文件进行解析的）
<!--more-->
![ASI配置注意事项](https://github.com/yangchao0033/HLS-Demo/blob/master/%E9%85%8D%E7%BD%AE%E7%8E%AF%E5%A2%831.png?raw=true)

![MRC报错处理](https://github.com/yangchao0033/HLS-Demo/blob/master/%E9%85%8D%E7%BD%AE%E7%8E%AF%E5%A2%832.png?raw=true)

2、导入系统库：libsqlite3.dylib、libz.dylib、libxml2.dylib、CoreTelephony.framework、SystemConfiguration.framework、MobileCoreServices.framework、Security.framework、CFNetwork.framework、MediaPlayer.framework

3、添加头文件

```c
YCHLS-Demo.h
```

4、demo介绍
![demo样式](https://github.com/yangchao0033/yangchao0033.github.io/blob/source/images/ios/2016/2/HLS_demo_UI.png?raw=true)

* __播放：__直接播放在线的直播链接，是由系统的MPMoviePlayer完成的，它自带解析HLS直播链的功能。
* __下载：__遵循HLS的协议，通过索引文件的资源路径下载相关的视频切片并保存到手机本地。
* __播放本地视频：__使用下载好的视频文件片段进行连续播放。
* __清除缓存：__删除下载好的视频片段

原理：

1. 通过ASI请求链接，通过m3u8库解析返回的m3u8索引文件。
2. 再通过ASI下载解析出的视频资源地址，仿照HLS中文件存储路径存储。
3. 利用CocoaHTTPServer在iOS端搭建本地服务器，并开启服务，端口号为：12345（高位端口即可）。配置服务器路径与步骤二存储路径一致。
4. 设置播放器直播链接为本地服务器地址，直接播放，由于播放器遵守HLS协议，所以能够解析我们之前使用HLS协议搭建的本地服务器地址。
5. 点击在线播放，校验是否与本地播放效果一致。

![HLS协议文件存储结构](https://github.com/yangchao0033/yangchao0033.github.io/blob/source/images/ios/2016/2/HLS%E5%8D%8F%E8%AE%AE%E6%96%87%E4%BB%B6%E5%AD%98%E5%82%A8%20.png?raw=true)

上面是HLS中服务器存储视频文件切片和索引文件的结构图

整个操作流程就是：

1. 先点击下载，通过解析m3u8的第三方库解析资源。（m3u8的那个库只能解析一种特定格式的m3u8文件，代码里会有标注）
2. 点击播放本地视频播放下载好的资源。
3. 点击播放是用来预览直播的效果，与整个流程无关。
4. 其中进度条用来显示下载进度。

> 总结：
> 整个Demo并不只是让我们搭建一个Hls服务器或者一个支持Hls的播放器。目的在于了解Hls协议的具体实现，以及服务器端的一些物理架构。通过Demo的学习，可以详细的了解Hls直播具体的实现流程。

部分源码贴出：

开启本地服务器：

```objc
- (void)openHttpServer
{
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    // 获取本地Library/Cache路径下downloads路径
    NSString *webPath = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
    NSLog(@"-------------\nSetting document root: %@\n", webPath);
    // 设置服务器路径
    [self.httpServer setDocumentRoot:webPath];
    NSError *error;
    if(![self.httpServer start:&error])
    {
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
    }
```

视频下载：

```objc
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
```
播放本地视频：


```objc
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
```

播放在线视频

```objc
- (IBAction)playLiveStreaming {
    
    NSURL *url = [[NSURL alloc] initWithString:TEST_HLS_URL];
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:player];
}
```

当然，《芈月传》的直播链接到现在也还没有找到，各位热心读者如果有链接的话可以留言给我，也让这篇文章能实至名归了，能对得文章的标题了😁。

# HTTP Live Streaming (HLS) 

苹果官方对于视频直播服务提出了 HLS 解决方案，该方案主要适用范围在于：

* 使用 iPhone 、iPod touch、 iPad 以及 Apple TV 进行流媒体直播功能。（MAC 也能用）
* 不使用特殊的服务软件进行流媒体直播。
* 需要通过加密和鉴定（authentication）的视频点播服务。

首先，需要大家先对 HLS 的概念进行预览。

HLS 的目的在于，让用户可以在苹果设备（包括MAC OS X）上通过普通的网络服务完成流媒体的播放。 HLS 同时支持流媒体的**实时广播**和**点播服务**。同时也支持不同 bit 速率的**多个备用流**（平时根据当前网速去自适应视频的清晰度），这样客户端也好根据当前网络的带宽去只能调整当前使用的视频流。安全方面，HLS 提供了通过 HTTPS 加密对媒体文件进行加密 并 对用户进行验证，允许视频发布者去保护自己的网络。

HLS 是苹果公司QuickTime X和iPhone软件系统的一部分。它的工作原理是把整个流分成一个个小的基于HTTP的文件来下载，每次只下载一些。当媒体流正在播放时，客户端可以选择从许多不同的备用源中以不同的速率下载同样的资源，允许流媒体会话适应不同的数据速率。在开始一个流媒体会话时，客户端会下载一个包含元数据的extended M3U (m3u8) playlist文件，用于寻找可用的媒体流。

HLS只请求基本的HTTP报文，与实时传输协议（RTP)不同，HLS可以穿过任何允许HTTP数据通过的防火墙或者代理服务器。它也很容易使用内容分发网络来传输媒体流。

苹果对于自家的 HLS 推广也是采取了强硬措施，当你的直播内容持续十分钟
或者每五分钟内超过 5 MB 大小时，你的 APP 直播服务必须采用 HLS 架构，否则不允许上架。（[详情](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/UsingHTTPLiveStreaming/UsingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH102-SW5)）

# 相关服务支持环境 （重要组成）
* `Adobe Flash Media Server`：从4.5开始支持HLS、Protected HLS（PHLS）。5.0改名为Adobe Media Server
* [Flussonic Media Server](http://www.flussonic.com/)：2009年1月21日，版本3.0开始支持VOD、HLS、时移等。
* RealNetworks的 `Helix Universal Server` ：2010年4月，版本15.0开始支持iPhone, iPad和iPod的HTTP直播、点播H.264/AAC内容，最新更新在2012年11月。
* 微软的IIS Media Services：从4.0开始支持HLS。
* `Nginx RTMP Module`：支持直播模式的HLS。
* [Nimber Streamer](https://wmspanel.com/nimble)
* [Unified Streaming Platform](http://www.unified-streaming.com/)
* [VLC Media Player](https://zh.wikipedia.org/wiki/VLC_Media_Player)：从2.0开始支持直播和点播HLS。
* Wowza Media Server：2009年12月9日发布2.0，开始全面支持HLS。
* VODOBOX Live Server：始支持HLS。
* [Gstreamill](http://github.com/i4tv/gstreamill)是一个支持hls输出的，基于gstreamer的实时编码器。

# 相关客户端支持环境
* iOS从3.0开始成为标准功能。
* Adobe Flash Player从11.0开始支持HLS。
* Google的Android自Honeycomb（3.0）开始支持HLS。
* VODOBOX HLS Player (Android,iOS, Adobe Flash Player)
* JW Player (Adobe Flash player)
* Windows 10 的 EDGE 浏览器开始支持HLS。

![HLS架构](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/art/transport_stream_2x.png)

其中输入视频源是由摄像机预先录制好的。之后这些源会被编码 `MPEG-4`（H.264 video 和 AAC audio）格式然后用硬件打包到 `MPEG-2` 的传输流中。`MPEG-2` 传输流会被分散为小片段然后保存为一个或多个系列的 .ts 格式的媒体文件。这个过程需要借助编码工具来完成，比如 Apple stream segmenter。

纯音频会被编码为一些音频小片段，通常为 ADTS头的AAC、MP3、或者 AC-3格式。

同时上面提到的那个切片器（segmenter）也会创建一个索引文件，通常会包含这些媒体文件的一个列表，也能包含元数据。他一般都是一个.M38U 个hi的列表。列表元素会关联一个 URL 用于客户端访问。然后按序去请求这些 URL。

###服务器端

服务端可以采用硬件编码和软件编码两种形式，其功能都是按照上文描述的规则对现有的媒体文件进行切片并使用索引文件进行管理。而软件切片通常会使用 Apple 公司提供的工具或者第三方的集成工具。

####媒体编码
媒体编码器获取到音视频设备的实时信号，将其编码后压缩用于传输。而编码格式必须配置为客户端所支持的格式，比如 H.264 视频和HE-AAC 音频。当前，支持 用于视频的 MPEG-2 传输流和 纯音频 MPEG 基本流。编码器通过本地网络将 MPEG-2 传输流分发出去，送到流切片器那里。标准传输流和压缩传输流无法混合使用。传输流可以被打包成很多种不同的压缩格式，这里有两个表详细列举了支持的压缩格式类型。
* [Audio Technologies](https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/iPhoneOSTechOverview/MediaLayer/MediaLayer.html#//apple_ref/doc/uid/TP40007898-CH9-SW2)
* [Vedio Technologies](https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/iPhoneOSTechOverview/MediaLayer/MediaLayer.html#//apple_ref/doc/uid/TP40007898-CH9-SW6)

#####[重点]在编码中图，不要修改视频编码器的设置，比如视频大小或者编码解码器类型。如果避免不了，那修改动作必须发生在一个片段边界。并且需要早之后相连的片段上用 `EXT-X-DISCONTINUITY` 进行标记。

####流切片器
流切片器（通常是一个软件）会通过本地网络从上面的媒体编码器中读取数据，然后将着这些数据一组相等时间间隔的 `小` 媒体文件。虽然没一个片段都是一个单独的文件，但是他们的来源是一个连续的流，切完照样可以无缝重构回去。

切片器在切片同时会创建一个索引文件，索引文件会包含这些切片文件的引用。每当一个切片文件生成后，索引文件都会进行更新。索引用于追踪切片文件的有效性和定位切片文件的位置。切片器同时也可以对你的媒体片段进行加密并且创建一个密钥文件作为整个过程的一部分。

####文件切片器（相对于上面的流切片器）
如果已近有编码后的文件（而不是编码流），你可以使用文件切片器，通过它对编码后的媒体文件进行 MPEG-2 流的封装并且将它们分割为等长度的小片段。切片器允许你使用已经存在的音视频库用于 HLS 服务。它和流切片器的功能相似，但是处理的源从流替换流为了文件。

### 媒体片段文件
媒体片段是由切片器生成的，基于编码后的媒体源，并且是由一系列的 `.ts` 格式的文件组成，其中包含了你想通过 MPEG-2 传送流携带的 H.264 视频 和 AAC
/MP3/AC-3 音频。对于纯音频的广播，切片器可以生产 MPEG 基础音频流，其中包含了 ADTS头的AAC、MP3、或者AC3等音频。

### 索引文件（PlayLists）
通常由切片器附带生成，保存为 `.M3U8` 格式，`.m3u` 一般用于 MP3 音频的索引文件。
[Note]()如果你的扩展名是.m3u,并且系统支持.mp3文件，那客户的软件可能要与典型的 MP3 playList 保持一致来完成 流网络音频的播放。

下面是一个 `.M3U8` 的 playlist 文件样例，其中包含了三个没有加密的十秒钟的媒体文件：


```
#EXT-X-VERSION:3
#EXTM3U
#EXT-X-TARGETDURATION:10
#EXT-X-MEDIA-SEQUENCE:1
 
# Old-style integer duration; avoid for newer clients.
#EXTINF:10,
http://media.example.com/segment0.ts
 
# New-style floating-point duration; use for modern clients.
#EXTINF:10.0,
http://media.example.com/segment1.ts
#EXTINF:9.5,
http://media.example.com/segment2.ts
#EXT-X-ENDLIST
```
为了更精确，你可以在 version 3 或者之后的协议版本中使用 float 数来标记媒体片段的时长，并且要明确写明版本号，如果没有版本号，则必须与 version 1 协议保持一致。你可以使用官方提供的切片器去生产各种各样的 playlist 索引文件，详见 [媒体文件切片器](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/UsingHTTPLiveStreaming/UsingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH102-SW7)

### 分布式部分
分布式系统是一个网络服务或者一个网络缓存系统，用于通过 HTTP 向客户端发送媒体文件和索引文件。不用自定义模块发送内容。通常仅仅需要很简单的网络配置即可使用。而且这种配置一般就是限制指定 .M38U 文件和 .ts 文件的 MIME 类型。详见 [部署 HTTP Live Streaming](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/DeployingHTTPLiveStreaming/DeployingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH2-SW3)

### 客户端部分
客户端开始时回去抓取 索引文件(.m3u8/.m3u)，其中用URL来标记不同的流。索引文件可以指定可用媒体文件的位置，解密的密钥，以及任何可以切换的流。对于选中的流，客户端会有序的下载每一个可获得的文件。每一个文件都包含流中的连环碎片。一旦下载到足够量的数据，客户端会开始向用户展示重新装配好的媒体资源。

客户端负责抓取任何解密密钥，认证或者展示一个用于认证的界面，之后再解密需要的文件。

这个过程会一直持续知道出现 结束标记 `#EXT-X-ENDLIST`。如果结束标记不出现，该索引就是用于持续广播的。客户端会定期的加载一些新的索引文件。客户端会从新更新的索引文件中去查找加密密钥并且将关联的URL加入到请求队列中去。

### HLS 的使用
使用 HLS 需要使用一些工具，当然大部分工具都是服务器端使用的，这里简单了解一下就行，包括 media stream segmenter, a media file segmenter, a stream validator, an id3 tag generator, a variant playlist generator.这些工具用英文注明是为了当你在[苹果开发中心](https://developer.apple.com/)中寻找时方便一些。

### 会话模式
通常包含 Live 和 VOD （点播）两种

**点播VOD**的特点就是可以获取到一个静态的索引文件，其中那个包含一套完整的资源文件地址。这种模式允许客户端访问全部节目。VOD点播拥有先进的下载技术，包括加密认证技术和动态切换文件传输速率的功能（通常用于不同分辨率视频之间的切换）。

**Live** 会话就是实时事件的录制展示。它的索引文件一直处于动态变化的，你需要不断的更新索引文件 playlist 然后移除旧的索引文件。这种类型通过向索引文件添加媒体地址可以很容易的转化为VOD类型。在转化时不要移除原来旧的源，而是通过添加一个 `#ET-X-ENDLIST` 标记来终止实时事件。转化时如果你的索引文件中包含 `EXT-X-PLAYLIST-TYPE` 标签，你需要将值从 `EVENT` 改为 `VOD`。

ps:自己抓了一个直播的源，从索引中看到的结果是第一次回抓到代表不同带宽的playList(抓取地址：`http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5.m3u8`)

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:PROGRAM-ID=1,PUBLISHEDTIME=1453914627,CURRENTTIME=1454056509,BANDWIDTH=700000,RESOLUTION=1280x720
34338_PVMT5_700/index.m3u8?Dnion_vsnae=34338_PVMT5
#EXT-X-STREAM-INF:PROGRAM-ID=1,PUBLISHEDTIME=1453914627,CURRENTTIME=1454056535,BANDWIDTH=400000
34338_PVMT5_400/index.m3u8?Dnion_vsnae=34338_PVMT5
#EXT-X-STREAM-INF:PROGRAM-ID=1,PUBLISHEDTIME=1453914627,CURRENTTIME=1454056535,BANDWIDTH=1024000
34338_PVMT5_1024/index.m3u8?Dnion_vsnae=34338_PVMT5
```
这里面的链接不是视频源URL，而是一个用于流切换的主索（下面会有介绍）引我猜想是需要对上一次的抓包地址做一个拼接

组合的结果就是：`http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5_1024/index.m3u8?Dnion_vsnae=34338_PVMT5`(纯属小学智力题😂。。。)将它作为抓取地址再一次的结果

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:134611
#EXT-X-TARGETDURATION:10
#EXTINF:9.960,
35/1454056634183_128883.ts?Dnion_vsnae=34338_PVMT5
#EXTINF:9.960,
35/1454056644149_128892.ts?Dnion_vsnae=34338_PVMT5
#EXTINF:9.960,
35/1454056654075_128901.ts?Dnion_vsnae=34338_PVMT5
```

同理，继续向下抓：（拼接地址：`http://dlhls.cdn.zhanqi.tv/zqlive/34338_PVMT5_1024/index.m3u8?Dnion_vsnae=34338_PVMT5/35/1454056634183_128883.ts?Dnion_vsnae=34338_PVMT5/36/1454059958599_131904.ts?Dnion_vsnae=34338_PVMT5`）
抓取结果：

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:134984
#EXT-X-TARGETDURATION:10
#EXTINF:9.280,
36/1454059988579_131931.ts?Dnion_vsnae=34338_PVMT5
#EXTINF:9.960,
36/1454059998012_131940.ts?Dnion_vsnae=34338_PVMT5
#EXTINF:9.960,
36/1454060007871_131949.ts?Dnion_vsnae=34338_PVMT5
```
相比于第二次又获取了一个片段的索引，而且只要是第二次之后，资源地址都会包含 `.ts`，说明里面是有视频资源URL的，不过具体的截取方法还是需要查看前面提到的IETF的那套标准的HLS的协议，利用里面的协议应该就能拼接出完整的资源路径进行下载。反正我用苹果自带的MPMoviePlayerController直接播放是没有问题的，的确是直播资源。与之前说过的苹果自带的QuickTime类似，都遵循了HLS协议用于流媒体播放。而每次通过拼接获取下一次的索引，符合协议里提到的不断的更替索引的动作。

### 内容加密
如果内容需要加密，你可以在索引文件中找到密钥的相关信息。如果索引文件中包含了一个密钥文件的信息，那接下来的媒体文件就必须使用密钥解密后才能解密打开了。当前的 HLS 支持使用16-octet 类型密钥的 AES-128 加密。这个密钥格式是一个由着在二进制格式中的16个八进制组的数组打包而成的。

加密的配置模式通常包含三种：
1. 模式一：允许你在磁盘上制定一个密钥文件路径，切片器会在索引文件中插入存在的密钥文件的 URL。所有的媒体文件都使用该密钥进行加密。
2. 模式二：切片器会生成一个随机密钥文件，将它保存在指定的路径，并在索引文件中引用它。所有的媒体文件都会使用这个随机密钥进行加密。
3. 模式三：每 n 个片段生成一个随机密钥文件，并保存到指定的位置，在索引中引用它。这个模式的密钥处于轮流加密状态。每一组 n 个片段文件会使用不同的密钥加密。
> 理论上，不定期的碎片个数生成密钥会更安全，但是定期的生成密钥不会对系统的性能产生太大的影响。

你可以通过 HTTP 或者 HTTPS 提供密钥。也可以选择使用你自己的基于会话的认证安排去保护发送的key。更多详情可以参考 [通过 HTTPS 安全的提供预约](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/DeployingHTTPLiveStreaming/DeployingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH2-SW2)

密钥文件需要一个 initialization vector (IV) 去解码加密的媒体文件。IV 可以随着密钥定期的改变。

### 缓存和发送协议
HTTPS通常用于发送密钥，同时，他也可以用于平时的媒体片段和索引文件的传输。但是当扩展性更重要时，这样做是不推荐的。HTTPS 请求通常都是绕开 web 服务缓存，导致所有内容请求都是通过你的服务进行转发，这有悖于分布式网络连接系统的目的。

处于这个原因，确保你发送的网络内容都明白非常重要。当处于实况广播模式时索引文件不会像分片媒体文件一样长时间的被缓存，他会动态不停地变化。

### 流切换
如果你的视频具备流切换功能，这对于用户来说是一个非常棒的体验，处于不同的带宽、不同的网速播放不同清晰度的视频流，这样只能的流切换可以保证用户感觉到非常流畅的观影体验，同时不同的设备也可以作为选择的条件，比如视网膜屏可以再网速良好的情况下播放清晰度更高的视频流。

这种功能的实现在于，索引文件的特殊结构

![流切换索引文件结构](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/art/indexing_2x.png)

有别于普通的索引，具备流热切换的索引通常由主索引和链接不同带宽速率的资源的子索引，由子索引再链接对引得.ts视频切片文件。其中主索引只下载一次，而子索引则会不停定期的下载，通常会先使用主索引中列出的第一个子索引，之后才会根据当时的网络情况去动态切换合适的流。客户端会在任何时间去切换不同的流。比如连入或者退出一个 wifi 热点。所有的切换都会使用相同的音频文件（换音频没多大意思相对于视频）在不同的流之间平滑的进行切换。
这一套不同速率的视频都是有工具生成的，使用`variantplaylistcreator` 工具并且为 `mediafilesegmenter` 或者 `mediastreamsegmenter` 指定 -generate-variant-playlist 选项,详情参考 [下载工具](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/UsingHTTPLiveStreaming/UsingHTTPLiveStreaming.html#//apple_ref/doc/uid/TP40008332-CH102-SW3)


概念先写到这吧，前面的知识够对HSL的整体结构做一个初步的了解。

下面贴一份针对 HLS 测试的一份源码，下载地址：[https://github.com/yangchao0033/HLS-Demo](https://github.com/yangchao0033/HLS-Demo)

随后的博客会对代码进行解释


####参考文献：

[苹果官方文档](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/HTTPStreamingArchitecture/HTTPStreamingArchitecture.html#//apple_ref/doc/uid/TP40008332-CH101-SW4)

[维基百科](https://zh.wikipedia.org/wiki/HTTP_Live_Streaming#.E5.AE.A2.E6.88.B7.E7.AB.AF.E6.94.AF.E6.8C.81)

[http://my.oschina.net/CgShare/blog/302303](http://my.oschina.net/CgShare/blog/302303)

[http://blog.csdn.net/woaifen3344/article/details/40837803](http://blog.csdn.net/woaifen3344/article/details/40837803)
