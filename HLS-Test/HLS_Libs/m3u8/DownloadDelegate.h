//
//  DownloadObjectDelegate.h
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@class SegmentDownloader;
@protocol SegmentDownloadDelegate <NSObject>
@optional
-(void)segmentDownloadFinished:(SegmentDownloader *)request;
-(void)segmentDownloadFailed:(SegmentDownloader *)request;

@end


@class VideoDownloader;
@protocol VideoDownloadDelegate <NSObject>
@optional
-(void)videoDownloaderFinished:(VideoDownloader*)request;
-(void)videoDownloaderFailed:(VideoDownloader*)request;
- (void)instanceDelloc;
@end