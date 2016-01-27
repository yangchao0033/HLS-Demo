//
//  VideoDownloader.m
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoDownloader.h"

@implementation VideoDownloader
@synthesize totalprogress,playlist,delegate;


-(id)initWithM3U8List:(M3U8Playlist *)list
{
    self = [super init];
    if(self != nil)
    {
        self.playlist = list;
        totalprogress = 0.0;
    }
    return  self;
}

-(void)startDownloadVideo
{
//    NSLog(@"start download video");
    if(downloadArray == nil)
    {
        downloadArray = [[NSMutableArray alloc]init];
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"id%d",i];
            M3U8SegmentInfo* segment = [self.playlist getSegment:i];
            SegmentDownloader* sgDownloader = [[SegmentDownloader alloc]initWithUrl:segment.locationUrl andFilePath:self.playlist.uuid andFileName:filename];
            sgDownloader.delegate = self;
            [downloadArray addObject:sgDownloader];
            [sgDownloader release];
        }
    }
    for(SegmentDownloader* obj in downloadArray)
    {
        [obj start];
    }
    bDownloading = YES;
    
}

-(void)cleanDownloadFiles
{
//    NSLog(@"cleanDownloadFiles");
     for(int i = 0;i< self.playlist.length;i++)
    {
        NSString* filename = [NSString stringWithFormat:@"id%d",i];
        NSString* tmpfilename = [filename stringByAppendingString:kTextDownloadingFileSuffix];
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.playlist.uuid];
        NSString* fullpath = [savePath stringByAppendingPathComponent:filename];
        NSString* fullpath_tmp = [savePath stringByAppendingPathComponent:tmpfilename];
    
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        
        if ([fileManager fileExistsAtPath:fullpath]) {
            NSError *removeError = nil;
            [fileManager removeItemAtPath:fullpath error:&removeError];
            if (removeError) 
            {
//                NSLog(@"delete file=%@ err,err is %@",fullpath,removeError);
            }
        }

        if ([fileManager fileExistsAtPath:fullpath_tmp]) {
            NSError *removeError = nil;
            [fileManager removeItemAtPath:fullpath_tmp error:&removeError];
            if (removeError) 
            {
//                NSLog(@"delete file=%@ err, err is %@",fullpath_tmp,removeError);
            }
        }

    }
    
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
    [super dealloc];
}


#pragma mark - SegmentDownloadDelegate
-(void)segmentDownloadFailed:(SegmentDownloader *)request
{
    if(delegate && [delegate respondsToSelector:@selector(videoDownloaderFailed:)])
    {
        [delegate videoDownloaderFailed:self];
    }
}

-(void)segmentDownloadFinished:(SegmentDownloader *)request
{    
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
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:playlist.uuid];
        NSString *fullpath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
//        NSLog(@"createLocalM3U8file:%@",fullpath);
        
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
     
        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",playlist.uuid];
        //填充片段数据
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"id%d",i];
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
    
        BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
        if(bSucc)
        {
//            NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
            return  fullpath;
        }
        else
        {
//            NSLog(@"create m3u8file failed");
            return  nil;
        }
    }
    return nil;
}



@end
