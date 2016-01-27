//
//  M3U8SegmentInfo.h
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8SegmentInfo : NSObject
{
    NSInteger duration;
	NSString *locationUrl;
}

@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,copy)NSString* locationUrl;

@end
