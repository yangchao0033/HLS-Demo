//
//  VideoDownloader.m
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoDownloader.h"
#import "YCHLS-Demo.h"

@implementation VideoDownloader
@synthesize totalprogress,playlist,delegate,downloadPart,currentProgress, clearCaches;


-(id)initWithM3U8List:(M3U8Playlist *)list
{
    self = [super init];
    if(self != nil)
    {
        self.playlist = list;
        totalprogress = 0.0;
        self.downloadPart = 0;
        self.currentProgress = 0.0;
        self.clearCaches = NO;
    }
    return  self;
}

-(void)startDownloadVideo
{
    NSLog(@"start download video");
    if(downloadArray == nil)
    {
        downloadArray = [[NSMutableArray alloc]init];
        NSLog(@"-- self.playlist.length = %ld", (long)self.playlist.length); // self.playlist.length 表示的视频片段的总数
        if (self.playlist) {
            playlist =self.playlist;
        }
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"id%d.ts",i];
            M3U8SegmentInfo* segment = [self.playlist getSegment:i];
            SegmentDownloader* sgDownloader = [[SegmentDownloader alloc]initWithUrl:segment.locationUrl andFilePath:self.playlist.uuid andFileName:filename];
            sgDownloader.delegate = self;
            [downloadArray addObject:sgDownloader];
            [sgDownloader release];
        }
    }
    for(SegmentDownloader* obj in downloadArray)
    {
        [obj start];  // 开始下载片段
    }
    
    bDownloading = YES;
    
}

-(void)cleanDownloadFiles
{
//    NSLog(@"cleanDownloadFiles");
    
    // 直接删除缓存的文件夹，不用一个一个文件删除
    NSString *savePath = [[kLibraryCache stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.playlist.uuid];
    savePath = [WebBasePath stringByAppendingPathComponent:self.playlist.uuid];
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
    if ([fileManager fileExistsAtPath:savePath]) {
        NSError *removeError = nil;
        if ([fileManager removeItemAtPath:savePath error:&removeError]) {
            self.clearCaches = YES; // 缓存清除成功
        }
        if (removeError)
        {
            NSLog(@"删除文件 file=%@ 失败 err,err is %@",savePath,removeError);
        }
    }

    
    /* // 这种方式是一个一个文件进行删除
     for(int i = 0; i< self.playlist.length; i++)
    {
        NSString* filename = [NSString stringWithFormat:@"id%d",i];
        NSString* tmpfilename = [filename stringByAppendingString:kTextDownloadingFileSuffix];
        NSString *savePath = [[kLibraryCache stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.playlist.uuid];
        NSString* fullpath = [savePath stringByAppendingPathComponent:filename];
        NSString* fullpath_tmp = [savePath stringByAppendingPathComponent:tmpfilename];
    
        NSString *m3u8Path = [savePath stringByAppendingPathComponent:@"movie.m3u8"];
        
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        
        if ([fileManager fileExistsAtPath:fullpath]) {
            NSError *removeError = nil;
            [fileManager removeItemAtPath:fullpath error:&removeError];
            if ([fileManager removeItemAtPath:fullpath error:&removeError]) {
                
            }
            if (removeError) 
            {
                NSLog(@"delete file=%@ err,err is %@",fullpath,removeError);
            }
        }

        if ([fileManager fileExistsAtPath:fullpath_tmp]) {
            NSError *removeError = nil;
            [fileManager removeItemAtPath:fullpath_tmp error:&removeError];
            if (removeError) 
            {
                NSLog(@"delete file=%@ err, err is %@",fullpath_tmp,removeError);
            }
        }
        if ([fileManager fileExistsAtPath:m3u8Path]) {
            NSError *removeError = nil;
            [fileManager removeItemAtPath:fullpath error:&removeError];
            if (removeError)
            {
                NSLog(@"delete m3u8 file=%@ err,err is %@",fullpath,removeError);
            }

        }

    }
    */
    
}


-(void)stopDownloadVideo
{
//    NSLog(@"stop Download Video");
    if(bDownloading && downloadArray != nil)
    {
        for(SegmentDownloader *obj in downloadArray)
        {
            [obj stop];
        }
        bDownloading = NO;
    }
}

-(void)cancelDownloadVideo
{
//    NSLog(@"cancel download video");
    if(bDownloading && downloadArray != nil)
    {
        for(SegmentDownloader *obj in downloadArray)
        {
            [obj clean];
        }
    }
    [self cleanDownloadFiles];
}


-(void)dealloc
{
    [playlist release];
    [delegate release];
    [downloadArray release];
    [downloadArray removeObject:self.delegate];
    [super dealloc];
    if ([self.delegate respondsToSelector:@selector(instanceDelloc)]) {
        [self.delegate instanceDelloc];
    }
}


#pragma mark - SegmentDownloadDelegate
-(void)segmentDownloadFailed:(SegmentDownloader *)request
{
    if(delegate && [delegate respondsToSelector:@selector(videoDownloaderFailed:)])
    {
        [delegate videoDownloaderFailed:self];
    }
}

#pragma mark - 每下载一个片段执行一次
-(void)segmentDownloadFinished:(SegmentDownloader *)request
{
    self.downloadPart ++;
    self.currentProgress = self.downloadPart / (float)self.playlist.length;
    NSLog(@"当前进度 %f", self.currentProgress);
    [downloadArray removeObject:request];
    if([downloadArray count] == 0)
    {
        totalprogress = 1;
      
        if(delegate && [delegate respondsToSelector:@selector(videoDownloaderFinished:)])
        {
           [delegate videoDownloaderFinished:self];
        }
    }    
}


-(NSString*)createLocalM3U8file
{
    if(playlist !=nil)
    {
//        NSString *downloadDic = [kLibraryCache stringByAppendingPathComponent:kPathDownload];
        NSString *downloadDic = WebBasePath;
        
        NSString *saveTo = [downloadDic stringByAppendingPathComponent:playlist.uuid];
        NSString *fullpath = [saveTo stringByAppendingPathComponent:@"0640.m3u8"];
        NSLog(@"createLocalM3U8file:%@",fullpath);
        
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDic]) {
//            BOOL createSuc;
            /** 创建 */
           NSError *error1;
           BOOL createSuc1 = [[NSFileManager defaultManager] createDirectoryAtPath:downloadDic withIntermediateDirectories:YES attributes:nil error:&error1];
            if (![[NSFileManager defaultManager] fileExistsAtPath:saveTo]) {
                /** 创建 */
                NSError *error2;
                BOOL createSuc2 = [[NSFileManager defaultManager] createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:&error2];
                if (!createSuc2) {
                    NSLog(@"创建失败:%@", error2);
                    return nil;
                }
            }
            if (!createSuc1) {
                NSLog(@"创建失败:%@", error1);
                return nil;
            }
        }
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
     
        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",playlist.uuid];
        //填充片段数据
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"id%d.ts",i];
            M3U8SegmentInfo* segInfo = [self.playlist getSegment:i];
            NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            NSString* url = [segmentPrefix stringByAppendingString:filename];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    
//        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Containers/Data/Application/72554C1F-83C6-49DA-BDF7-1CB9DC178FBF/Library/Caches/Downloads/XNjUxMTE4NDAw"]) {
//        BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
        NSError *error;
        BOOL bSucc =[writer writeToFile:fullpath options:(NSDataWritingAtomic )  error:&error];
        
        
        if(bSucc)
        {
            NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
            return  fullpath;
        }
        else
        {
            NSLog(@"create m3u8file failed:%@", error);
            return  nil;
        }
    }
        
//    }
    return nil;
}



@end
