//
//  SegmentDownloader.h
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "DownloadDelegate.h"
#import "ASIProgressDelegate.h"

typedef enum 
{
    ERUNNING = 0,
    ESTOPPED = 1,
}eTaskStatus;

#define kPathDownload @"Downloads"
#define kTextDownloadingFileSuffix @"_etc"


@interface SegmentDownloader : NSObject<ASIProgressDelegate>
{
    float progress;
    eTaskStatus status;
    NSString* filePath;
    NSString* fileName;
    NSString* tmpFileName;
    NSString* downloadUrl;
    
    id<SegmentDownloadDelegate> delegate;
    ASIHTTPRequest* request;
}

@property(nonatomic,copy)NSString* fileName;
@property(nonatomic,copy)NSString* filePath;
@property(nonatomic,copy)NSString* tmpFileName;
@property(nonatomic,copy)NSString* downloadUrl;
@property(nonatomic,retain)id<SegmentDownloadDelegate>delegate;
@property(nonatomic,assign)eTaskStatus status;
@property(nonatomic,assign)float progress;

-(void)start;
-(void)stop;
-(void)clean;
-(id)initWithUrl:(NSString*)url andFilePath:(NSString*)path  andFileName:(NSString*)fileName;

@end
