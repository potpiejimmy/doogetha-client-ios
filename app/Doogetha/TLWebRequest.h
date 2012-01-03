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

-(void)post:(NSString*)url msg:(NSString*)msg name:(NSString*)name;
-(void)put:(NSString*)url msg:(NSString*)msg name:(NSString*)name;
-(void)get:(NSString*)url name:(NSString*)name;

-(NSString*)resultString;

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) NSMutableData *resultData;
@property (strong, nonatomic) NSString *currentName;
@property (strong, nonatomic) NSString *authorization;

@end

// Callback protocol:
@interface NSObject(TLWebRequestDelegateMethods)
- (void)webRequestDone:(NSString*)name;
@end
