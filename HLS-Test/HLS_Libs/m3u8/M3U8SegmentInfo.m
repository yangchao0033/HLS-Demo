//
//  M3U8SegmentInfo.m
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "M3U8SegmentInfo.h"

@implementation M3U8SegmentInfo
@synthesize locationUrl;
@synthesize duration;

-(void)dealloc
{
    [locationUrl release];
    [super dealloc];
}

@end
