//
//  DGAppDelegate.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGApp.h"
#import "TLUtils.h"

NSString* const DOOGETHA_URL = @"http://www.potpiejimmy.de/doogetha/res/";

@implementation DGApp

@synthesize window = _window;
@synthesize mainController = _mainController;
@synthesize loginToken = _loginToken;
@synthesize webRequester = _webRequester;
@synthesize sessionKey = _sessionKey;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainController = [board instantiateViewControllerWithIdentifier:@"mainController"];
    if ([self authToken]) {
        NSLog(@"Got auth token: %@", [self authToken]);
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"navigationController"];
        [self startSession];
    } else {
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"registerController"];
    }
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)webRequestDone:(NSNotification*)notification 
{
    NSString* sessionKey = [self.webRequester resultString];
    sessionKey = [sessionKey substringWithRange:NSMakeRange(1, [sessionKey length]-2)];
    NSLog(@"Session key: Basic %@",sessionKey);
    self.sessionKey = [TLUtils encodeBase64WithString:sessionKey];
    
    [self.mainController reload];
}

-(void)startSession
{
    // start session:
    self.webRequester = [[TLWebRequest alloc] initWithObserver:self];
    [self.webRequester post:[NSString stringWithFormat:@"%@login",DOOGETHA_URL] msg:[self authToken] name:@"session"];
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
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject : authToken forKey : @"authtoken"];
    [settings synchronize];
}

-(NSString*)authToken
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings stringForKey : @"authtoken"];
}

@end
