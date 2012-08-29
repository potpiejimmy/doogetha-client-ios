//
//  DGEventEditBaseController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditBaseController.h"

#import "DGUtils.h"

@implementation DGEventEditBaseController

- (void) dismiss
{
    // overridden by subclasses
}

- (void) saveEvent
{
    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[DGUtils app].currentEvent
                                                       options:0 error:&error];
    NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Trying to post: %@", result);
    [DGUtils alertWaitStart:@"Speichern. Bitte warten..."];
    
    NSNumber* eid = [[DGUtils app].currentEvent objectForKey:@"id"];
    if (eid) {
        // save existing
        [webRequester put:[NSString stringWithFormat:@"%@events/%d",DOOGETHA_URL,[eid intValue]] msg:result reqid:@"save"];
    } else {
        // insert a new one
        [webRequester post:[NSString stringWithFormat:@"%@events",DOOGETHA_URL] msg:result reqid:@"save"];
    }
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void) webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);
    [[DGUtils app] refreshActivities];
    [self dismiss];
}

@end
