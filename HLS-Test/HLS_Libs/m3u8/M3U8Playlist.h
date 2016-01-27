//
//  M3U8Playlist.h
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfo.h"

@interface M3U8Playlist : NSObject
{
    NSMutableArray *segments;
	NSInteger length;
    NSString* uuid;
}

@property (nonatomic, retain) NSMutableArray *segments;
@property (assign) NSInteger length;
@property (nonatomic,copy)NSString* uuid;

- (id)initWithSegments:(NSMutableArray *)segmentList;
- (M3U8SegmentInfo *)getSegment:(NSInteger)index;


@end
