//
//  TLWebRequest.h
//  Letsdoo
//
//  Created by Kerstin Nicklaus on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLWebRequest : NSObject

-(TLWebRequest*)initWithDelegate:(id)delegate;

-(void)post:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid;
-(void)put:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid;
-(void)get:(NSString*)url reqid:(NSString*)reqid;
-(void)del:(NSString*)url reqid:(NSString*)reqid;

-(NSString*)resultString;

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) NSMutableData *resultData;
@property (strong, nonatomic) NSString *currentReqId;
@property (strong, nonatomic) NSString *lastError;
@property (strong, nonatomic) NSString *authorization;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSTimer* timeOutTimer;
@property                     BOOL running;

@end

// Callback protocol:
@interface NSObject(TLWebRequestDelegateMethods)
- (void)webRequestDone:(NSString*)reqid;
- (void)webRequestFail:(NSString*)reqid;
@end
