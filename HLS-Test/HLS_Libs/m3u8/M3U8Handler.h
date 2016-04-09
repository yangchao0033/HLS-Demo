//
//  M3U8Handler.h
//  XB
//
//  Created by luoxubin on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class M3U8Playlist;
@class M3U8Handler;
@protocol M3U8HandlerDelegate <NSObject>
@optional
-(void)praseM3U8Finished:(M3U8Handler*)handler;
-(void)praseM3U8Failed:(M3U8Handler*)handler error:(NSError *)error;
@end


@interface M3U8Handler : NSObject
{
    id<M3U8HandlerDelegate> delegate;
    M3U8Playlist* playlist;
    NSMutableArray * URLIsFootArray;
}
@property(nonatomic,retain)id<M3U8HandlerDelegate> delegate;
@property(nonatomic,retain)M3U8Playlist* playlist;

-(void)praseUrl:(NSString*)urlstr;
@end
