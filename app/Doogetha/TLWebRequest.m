//
//  TLWebRequest.m
//  Letsdoo
//
//  Created by Kerstin Nicklaus on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TLWebRequest.h"

@implementation TLWebRequest

@synthesize resultData = _resultData;
@synthesize currentName = _currentName;
@synthesize authorization = _authorization;

-(TLWebRequest*)initWithObserver:(id)observer
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(webRequestDone:) name:nil object:self];
    }
    return self;
}

-(void)post:(NSString*)url msg:(NSString*)msg name:(NSString*)name
{
    self.currentName = name;
    NSData *postData = [msg dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    if (self.authorization) [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"Connection established");
        self.resultData = [NSMutableData data];
    }
}

-(void)get:(NSString*)url name:(NSString*)name
{
    self.currentName = name;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (self.authorization) {
        [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
        NSLog(@"Authorization: %@",self.authorization);
    }
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        NSLog(@"Connection established");
        self.resultData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.resultData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[self.resultData length]);
    [[NSNotificationCenter defaultCenter] postNotificationName:self.currentName object:self];
}

-(NSString*)resultString
{
    return [[NSString alloc] initWithData:self.resultData encoding:NSUTF8StringEncoding];
}

@end
