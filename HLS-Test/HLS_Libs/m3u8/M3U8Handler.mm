//
//  M3U8Handler.m
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "M3U8Handler.h"
#import "M3U8Playlist.h"
@implementation M3U8Handler
@synthesize delegate,playlist;


-(void)dealloc
{
    [delegate release];
    [playlist release];
    [super dealloc];
}


//解析m3u8的内容
-(void)praseUrl:(NSString *)urlstr
{
//    if([urlstr hasSuffix:@".m3u8"] == FALSE)
//    {
//        NSLog(@" Invalid url");
//        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)])
//        {
//            [self.delegate praseM3U8Failed:self];
//        }
//        return;
//    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlstr];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *data = [[NSString alloc] initWithContentsOfURL:url
                                                     usedEncoding:&encoding 
                                                            error:&error];
    
    if(data == nil)
    {
//        NSLog(@"data is nil");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)])
        {
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
    
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSString* remainData =data;
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    
    while (segmentRange.location != NSNotFound)
    {
        M3U8SegmentInfo * segment = [[M3U8SegmentInfo alloc]init];
        // 读取片段时长
        NSRange commaRange = [remainData rangeOfString:@","];
        NSString* value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        
        remainData = [remainData substringFromIndex:commaRange.location];
        // 读取片段url
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        NSString* linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.locationUrl = linkurl;

        [segments addObject:segment];
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    
    M3U8Playlist * thePlaylist = [[M3U8Playlist alloc] initWithSegments:segments];
    [segments release];
    self.playlist = thePlaylist;
    [thePlaylist release];
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Finished:)])
    {
        [self.delegate praseM3U8Finished:self];
    }
}


/* m3u8文件格式示例
 
 #EXTM3U
 #EXT-X-TARGETDURATION:30
 #EXT-X-VERSION:2
 #EXT-X-DISCONTINUITY
 #EXTINF:10,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_0.ts?KM=14eb49fe4969126c6&start=0&end=10&ts=10&html5=1&seg_no=0&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_1.ts?KM=14eb49fe4969126c6&start=10&end=30&ts=20&html5=1&seg_no=1&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_2.ts?KM=14eb49fe4969126c6&start=30&end=50&ts=20&html5=1&seg_no=2&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_3.ts?KM=14eb49fe4969126c6&start=50&end=70&ts=20&html5=1&seg_no=3&seg_time=0
 #EXTINF:24,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_4.ts?KM=14eb49fe4969126c6&start=70&end=98&ts=24&html5=1&seg_no=4&seg_time=0
 #EXT-X-ENDLIST
 */


@end
