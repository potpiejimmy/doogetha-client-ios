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
@synthesize connection = _connection;
@synthesize timeOutTimer = _timeOutTimer;
@synthesize running = _running;

-(TLWebRequest*)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.running = NO;
    }
    return self;
}

-(void)registerTimeout
{
    SEL sel = @selector(cancelByTimer);
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
    [invocation setTarget:self];
    [invocation setSelector:sel];
    
    // manually cancel all requests after 15 seconds
    self.timeOutTimer = [NSTimer timerWithTimeInterval:15 invocation:invocation repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timeOutTimer forMode:NSDefaultRunLoopMode];
}

-(void)runningOn
{
    self.running = YES;
    [self registerTimeout];
}

-(void)runningOff
{
    self.running = NO;
    [self.timeOutTimer invalidate];
}

-(NSMutableURLRequest*)createURLRequest:(NSString*)method url:(NSString*)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (self.authorization) {
        [request setValue:self.authorization forHTTPHeaderField:@"Authorization"];
        //NSLog(@"Authorization: %@",self.authorization);
    }
    [request setTimeoutInterval:20]; // only effective for GET requests :(
    return request;
}

-(void)executeRequest:(NSURLRequest*)request
{
    if (self.running) {
        [self.connection cancel];
        self.connection = nil;
    }
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.connection) {
        NSLog(@"Connection created...");
        self.resultData = [NSMutableData data];
        [self runningOn];
    }
}

-(void)postOrPut:(NSString*)method url:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    self.currentReqId = reqid;
    
    NSData *postData = [msg dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [self createURLRequest:method url:url];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [self executeRequest:request];
}

-(void)post:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    [self postOrPut:@"POST" url:url msg:msg reqid:reqid];
}

-(void)put:(NSString*)url msg:(NSString*)msg reqid:(NSString*)reqid
{
    [self postOrPut:@"PUT" url:url msg:msg reqid:reqid];
}

-(void)getOrDelete:(NSString*)method url:(NSString*)url reqid:(NSString*)reqid
{
    self.currentReqId = reqid;

    NSMutableURLRequest* request = [self createURLRequest:method url:url];

    [self executeRequest:request];
}

-(void)get:(NSString*)url reqid:(NSString*)reqid
{
    [self getOrDelete:@"GET" url:url reqid:reqid];
}

-(void)del:(NSString*)url reqid:(NSString*)reqid
{
    [self getOrDelete:@"DELETE" url:url reqid:reqid];
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
    [self runningOff];
    if (error) {
        self.lastError = [NSString stringWithFormat:@"Es ist ein Fehler aufgetreten: %@ %@",
                               [error localizedDescription],
                               [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    } else {
        self.lastError = @"Die Daten konnten aufgrund einer Zeitüberschreitung nicht geladen werden. Bitte überprüfe die Internetverbindung und versuche es erneut.";
    }
    
    NSLog(@"%@",self.lastError);
    [self.delegate webRequestFail:self.currentReqId];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self runningOff];
    NSLog(@"Succeeded! Received %d bytes of data",[self.resultData length]);
    [self.delegate webRequestDone:self.currentReqId];
}

-(void)cancelByTimer
{
    if (self.running) {
        NSLog(@"Cancelling connection due to timeout");
        self.running = NO;
        [self.connection cancel];
        [self connection:self.connection didFailWithError:nil];
    }
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
