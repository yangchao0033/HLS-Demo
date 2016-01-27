# HLS-Demo
IOS 视屏直播样例

主要展示 HLS 详细流程，用于iOS视屏直播。

# HTTP Live Streaming (HLS) 

苹果官方对于视频直播服务提出了 HLS 解决方案，该方案主要适用范围在于：

* 使用 iPhone 、iPod touch、 iPad 以及 Apple TV 进行流媒体直播功能。（MAC 也能用）
* 不使用特殊的服务软件进行流媒体直播。
* 需要通过加密和鉴定（authentication）的视频点播服务。

首先，需要大家先对 HLS 的概念进行预览。

HLS 的目的在于，让用户可以在苹果设备（包括MAC OS X）上通过普通的网络服务完成流媒体的播放。 HLS 同时支持流媒体的**实时广播**和**点播服务**。同时也支持不同 bit 速率的**多个备用流**（平时根据当前网速去自适应视频的清晰度），这样客户端也好根据当前网络的带宽去只能调整当前使用的视频流。安全方面，HLS 提供了通过 HTTPS 加密对媒体文件进行加密 并 对用户进行验证，允许视频发布者去保护自己的网络。

![HLS架构](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/art/transport_stream_2x.png)

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
