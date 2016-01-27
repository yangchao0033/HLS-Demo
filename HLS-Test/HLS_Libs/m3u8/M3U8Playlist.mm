//
//  M3U8Playlist.m
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "M3U8Playlist.h"
@implementation M3U8Playlist
@synthesize segments;
@synthesize length;
@synthesize uuid;

- (id)initWithSegments:(NSMutableArray *)segmentList
{
    self = [super init];
    if(self != nil)
    {
        self.segments = segmentList;
        self.length = [segmentList count];        
    }
    return self;
}
- (M3U8SegmentInfo *)getSegment:(NSInteger)index 
{
    if( index >=0 && index < self.length)
    {
        return (M3U8SegmentInfo *)[self.segments objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}
-(void)dealloc
{
    [segments release];
    [super dealloc];
}
@end
