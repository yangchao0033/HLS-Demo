//
//  VideoDownloader.h
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SegmentDownloader.h"
#import "M3U8Playlist.h"


@interface VideoDownloader : NSObject<SegmentDownloadDelegate>
{
    NSMutableArray *downloadArray;
    M3U8Playlist* playlist;
    float totalprogress;
    NSInteger downloadPart;
    float currentProgress;
    id<VideoDownloadDelegate> delegate;
    BOOL bDownloading;
    BOOL clearCaches; // 判断是否清除缓存文件
}


@property(nonatomic, retain)id<VideoDownloadDelegate> delegate;
@property(nonatomic, retain)M3U8Playlist* playlist;
@property(nonatomic, assign)float totalprogress;
@property(nonatomic, assign)NSInteger downloadPart; // 已经下载的片段
@property(nonatomic, assign)float currentProgress; // 当前的下载进度
@property(nonatomic, assign)BOOL clearCaches;

-(id)initWithM3U8List:(M3U8Playlist*)list;

//开始下载
-(void)startDownloadVideo;

//暂停下载
-(void)stopDownloadVideo;

//取消下载，而且清楚下载的部分文件
-(void)cancelDownloadVideo;

-(NSString*)createLocalM3U8file;

// 清理缓存文件
-(void)cleanDownloadFiles;





@end
