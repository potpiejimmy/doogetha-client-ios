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
@synthesize currentReqId = _currentReqId;
@synthesize authorization = _authorization;
@synthesize delegate = _delegate;
@synthesize lastError = _lastError;

-(TLWebRequest*)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

-(void)postOrPut:(NSString*)method url:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    self.currentReqId = reqid;
    NSData *postData = [msg dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
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

-(void)post:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    [self postOrPut:@"POST" url:url msg:msg reqid:reqid];
}

-(void)put:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    [self postOrPut:@"PUT" url:url msg:msg reqid:reqid];
}

-(void)get:(NSString*)url reqid:(NSString*)reqid
{
    self.currentReqId = reqid;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (self.authorization) {
        [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
        //NSLog(@"Authorization: %@",self.authorization);
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
    self.lastError = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
                               [error localizedDescription],
                               [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    
    NSLog(@"%@",self.lastError);
    [self.delegate webRequestFail:self.currentReqId];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[self.resultData length]);
    [self.delegate webRequestDone:self.currentReqId];
}

-(NSString*)resultString
{
    return [[NSString alloc] initWithData:self.resultData encoding:NSUTF8StringEncoding];
}

// ----------- accept all HTTPs certs (for now)

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}


@end
