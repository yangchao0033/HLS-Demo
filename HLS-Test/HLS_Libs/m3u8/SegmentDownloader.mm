//
//  SegmentDownloader.m
//  XB
//
//  Created by luoxubin on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SegmentDownloader.h"

@implementation SegmentDownloader
@synthesize fileName,tmpFileName,delegate,downloadUrl,filePath,status,progress;


-(void)start
{
    
//    NSLog(@"download segment start, fileName = %@,url = %@",self.fileName,self.downloadUrl);
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setTemporaryFileDownloadPath: self.tmpFileName];
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
//    NSString *saveTo = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
    [request setDownloadDestinationPath:[saveTo stringByAppendingPathComponent:self.fileName]];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    request.allowResumeForFileDownloads = YES;
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request startAsynchronous];
    status = ERUNNING;
}

-(void)stop
{
//    NSLog(@"download stoped");
    if(request && status == ERUNNING)
    {
        request.delegate = nil;
        [request cancelAuthentication];
    }
    status = ESTOPPED;
}

-(void)clean
{
//    NSLog(@"download clean");
    if(request && status == ERUNNING)
    {
        request.delegate = nil;
        [request cancelAuthentication];
        [request removeTemporaryDownloadFile];
        NSError *Error = nil;
        if (![ASIHTTPRequest removeFileAtPath:[request downloadDestinationPath] error:&Error]) {
//            NSLog(@"clean file err:%@",Error);
        }
    }
    status = ESTOPPED;
    progress = 0.0;
}

-(id)initWithUrl:(NSString *)url andFilePath:(NSString *)path andFileName:(NSString *)_fileName{
    self = [super init];
    if(self != nil)
    {
        self.downloadUrl = url;
        self.fileName = _fileName;
        self.filePath = path;
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        NSString *downloadingFileName = [[[NSString alloc] initWithString:[saveTo stringByAppendingPathComponent:[fileName stringByAppendingString:kTextDownloadingFileSuffix]]] autorelease];
        self.tmpFileName = downloadingFileName;
        BOOL isDir = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(!([fm fileExistsAtPath:saveTo isDirectory:&isDir] && isDir))
        {
            [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.progress = 0.0;
        status = ESTOPPED;
        
    }
    return  self;
}

-(void)dealloc
{
    [self stop];
    [fileName release];
    [tmpFileName release];
    [delegate release];
    [downloadUrl release];
    [super dealloc];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"download finished!");
    if(delegate && [delegate respondsToSelector:@selector(segmentDownloadFinished:)])
    {
        [delegate segmentDownloadFinished:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)aRequest
{
    NSError *err = aRequest.error;
    if (err.code != 3) 
    {
        [self stop];
        NSLog(@"Download failed.");
        if(delegate && [delegate respondsToSelector:@selector(segmentDownloadFailed:)])
        {
            [delegate segmentDownloadFailed:self];
        }
    }
}

- (void)setProgress:(float)newProgress
{
    progress = newProgress;
    // NSLog(@"newprogress :%f",newProgress);
}

@end
