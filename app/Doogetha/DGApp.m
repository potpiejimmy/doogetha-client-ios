//
//  DGAppDelegate.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGApp.h"
#import "DGUtils.h"
#import "TLUtils.h"
#import "TLKeychain.h"

NSString* const DOOGETHA_URL = @"https://www.potpiejimmy.de/doogetha/res/";

@implementation DGApp

@synthesize window = _window;
@synthesize loginToken = _loginToken;
@synthesize webRequester = _webRequester;
@synthesize sessionKey = _sessionKey;
@synthesize sessionCallback = _sessionCallback;
@synthesize mainController = _mainController;
@synthesize wizardNext = _wizardNext;
@synthesize currentEvent = _currentEvent;
@synthesize currentSurvey = _currentSurvey;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.webRequester = [[TLWebRequest alloc] initWithDelegate:self];
    if ([self authToken]) {
        //NSLog(@"Got auth token: %@", [self authToken]);
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"tabBarController"];
    } else {
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"welcomeController"];
    }
    [self.window makeKeyAndVisible];
    _inBackground = NO;

    return YES;
}

- (void)webRequestFail:(NSString*)reqid 
{
    [DGUtils alert:self.webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid 
{
    NSString* sessionKey = [self.webRequester resultString];
    sessionKey = [sessionKey substringWithRange:NSMakeRange(1, [sessionKey length]-2)];
    //NSLog(@"Session key: Basic %@",sessionKey);
    self.sessionKey = [TLUtils encodeBase64WithString:sessionKey];
    [self.sessionCallback sessionCreated];
}

-(void)startSession:(id)sessionCallback
{
    // start session:
    self.sessionCallback = sessionCallback;
    self.webRequester.delegate = self;
    [self.webRequester post:[NSString stringWithFormat:@"%@login",DOOGETHA_URL] msg:[self authToken] reqid:@"session"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    _inBackground = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if (_inBackground) {
        if (self.mainController) {
            self.mainController.checkVersionAfterReload = YES;
            [self.mainController reload];
        }
        _inBackground = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)register:(NSString *)authToken
{
    [TLKeychain saveString:authToken forKey:@"authToken"];
}

-(NSString*)authToken
{
    return [TLKeychain getStringForKey:@"authToken"];
}

-(void)unregister
{
    [TLKeychain deleteStringForKey:@"authToken"];
    // also remove current session key
    self.sessionKey = nil;
}

-(NSString*)userDefaultValueForKey:(NSString*)key
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings stringForKey : key];
}

-(void)setUserDefaultValue:(NSString*)value forKey:(NSString*)key
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject : value forKey : key];
    [settings synchronize];
}

-(int)userId
{
    return [[[[self authToken] componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
}

-(void)makeMeFirst:(NSDictionary*) event
{
    NSMutableArray* users = [event objectForKey:@"users"];
    int found = -1;
    int index = 0;
    for (NSDictionary* user in users) {
        if ([[user objectForKey:@"id"] intValue] == self.userId)
            found = index;
        index++;
    }
    if (found > 0) {
        id swap = [users objectAtIndex:found];
        [users replaceObjectAtIndex:found withObject:[users objectAtIndex:0]];
        [users replaceObjectAtIndex:0 withObject:swap];
    }
}

-(NSDictionary*)findMe:(NSDictionary*) event
{
    NSArray* users = [event objectForKey:@"users"];
    for (NSDictionary* user in users) {
        if ([[user objectForKey:@"id"] intValue] == self.userId)
            return user;
    }
    return nil;
}

@end
