//
//  DGAppDelegate.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGApp.h"
#import "DGUtils.h"
#import "DGContactsUtils.h"
#import "TLUtils.h"
#import "TLKeychain.h"

NSString* const DOOGETHA_URL = @"https://www.doogetha.com/beta/res/";
//NSString* const DOOGETHA_URL = @"http://localhost:8080/beta/res/";

@implementation DGApp

@synthesize window = _window;
@synthesize webRequester = _webRequester;
@synthesize sessionKey = _sessionKey;
@synthesize sessionCallback = _sessionCallback;
@synthesize mainController = _mainController;
@synthesize mainControllerMyActs = _mainControllerMyActs;
@synthesize wizardHint = _wizardHint;
@synthesize currentEvent = _currentEvent;
@synthesize currentSurvey = _currentSurvey;
@synthesize gotSession = _gotSession;
@synthesize pendingEventToOpen = _pendingEventToOpen;
@synthesize operationQueue = _operationQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.webRequester = [[TLWebRequest alloc] initWithDelegate:self];
    if ([self isRegistered]) {
        //NSLog(@"Got auth token: %@", [self authToken]);
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"tabBarController"];
    } else {
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"welcomeController"];
    }
    [self.window makeKeyAndVisible];
    _inactive = NO;
    _gotSession = NO;
    _pendingEventToOpen = 0;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    // Register for Apple Push Notification Services:
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* registrationId = 
        [[[[deviceToken description] 
          stringByReplacingOccurrencesOfString:@" " withString:@""]
          stringByReplacingOccurrencesOfString:@"<" withString:@""]
          stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"APNS Registration Device Token:%@", registrationId);
    
    NSString* oldRegistrationId = [self userDefaultValueForKey:@"apnsDeviceToken"];
    if (oldRegistrationId == nil || ![oldRegistrationId isEqualToString:registrationId]) {
        // device token has changed, update it:
        [self setUserDefaultValue:registrationId forKey:@"apnsDeviceToken"];
        [self setUserDefaultValue:@"false" forKey:@"apnsServerSynced"];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to register for APNS: %@", [error userInfo]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"UserInfo:%@", userInfo);
    NSString* type = [userInfo objectForKey:@"type"];
    NSString* textKey = [NSString stringWithFormat:@"notification.%@.text",type];
    if ([@"eventconfirm" isEqualToString:type]) {
        NSString* accepted = [userInfo objectForKey:@"state"];
        if ([@"1" isEqualToString:accepted])
            textKey = [NSString stringWithFormat:@"%@.accepted",textKey];
        else
            textKey = [NSString stringWithFormat:@"%@.declined",textKey];
    }
    
    NSString* eventName = [userInfo objectForKey:@"eventName"];
    NSString* eventId = [userInfo objectForKey:@"eventId"];
    NSString* email = [userInfo objectForKey:@"user"];
    NSMutableDictionary* userVo = [NSMutableDictionary dictionaryWithObject:email forKey:@"email"];
    [DGContactsUtils fillUserInfo:userVo];
    NSString* userDisplayName = [DGContactsUtils userDisplayName:userVo];
    NSString* text = [NSString stringWithFormat:NSLocalizedString(textKey, nil), userDisplayName];
    [DGUtils alert:text withTitle:eventName];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if (eventId) {
        self.pendingEventToOpen = [eventId intValue];
        [self handlePendingEventToOpen];
    }
}

-(void)handlePendingEventToOpen
{
    if (self.pendingEventToOpen > 0) {
        if (self.mainController && self.gotSession) {
            if (self.mainController.navigationController.visibleViewController == self.mainController ||
                self.mainController.navigationController.visibleViewController == self.mainControllerMyActs) {
                // app currently active and one of the lists open, force a reload:
                [self.mainController reload];
            } else {
                // for now, don't do anything if user is in the middle of something:
                self.pendingEventToOpen = 0;
            }
        }
    }
}

-(void)checkApnsServerSynced
{
    if ([@"false" isEqualToString:[self userDefaultValueForKey:@"apnsServerSynced"]] &&
        [self userDefaultValueForKey:@"apnsDeviceToken"]) {
        // register device token with Doogetha server:
        NSLog(@"Device not synced yet, send device token to server.");
        self.webRequester.delegate = self;
        [self.webRequester post:[NSString stringWithFormat:@"%@devices/2",DOOGETHA_URL] msg:[self userDefaultValueForKey:@"apnsDeviceToken"] reqid:@"deviceregister"];
    }
}

- (void)webRequestFail:(NSString*)reqid 
{
    if (self.mainController) [self.mainController dataSourceDidFinishLoadingNewData];
//    [DGUtils alert:self.webRequester.lastError];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doogetha" 
                                                    message:@"Die Verbindung zum Server konnte nicht hergestellt werden."
                                                   delegate:self 
                                          cancelButtonTitle:@"Wiederholen"
                                          otherButtonTitles:@"Zurücksetzen", nil];
    [alert show];
}

- (void)webRequestDone:(NSString*)reqid 
{
    if ([reqid isEqualToString:@"session"]) {
        NSString* sessionKey = [self.webRequester resultString];
        sessionKey = [sessionKey substringWithRange:NSMakeRange(1, [sessionKey length]-2)];
        //NSLog(@"Session key: Basic %@",sessionKey);
        self.sessionKey = [TLUtils encodeBase64WithString:sessionKey];
        [self.sessionCallback sessionCreated];
    } else if ([reqid isEqualToString:@"deviceregister"]) {
        NSLog(@"Device %@ successfully registered.", [self userDefaultValueForKey:@"apnsDeviceToken"]);
        [self setUserDefaultValue:@"true" forKey:@"apnsServerSynced"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Starting session failed: "Wiederholen"
        [self.mainController showReloadAnimationAnimated:NO];
        [self startSession:self];
    } else if (buttonIndex == 1) {
        // Starting session failed: "Zuruecksetzen"
        [self unregister];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.window.rootViewController = [board instantiateViewControllerWithIdentifier:@"welcomeController"];
        [self.window makeKeyAndVisible];
    }
}

-(void)startSession:(id)sessionCallback
{
    // start session:
    self.sessionCallback = sessionCallback;
    self.webRequester.delegate = self;
    [self.webRequester post:[NSString stringWithFormat:@"%@login",DOOGETHA_URL] msg:[[[self loginToken] componentsSeparatedByString:@":"] objectAtIndex:0] reqid:@"session"];
}

-(void)sessionCreated
{
    _gotSession = YES;
    if (self.mainController) {
        [self.mainController setCheckVersionAfterReload:YES];
        [self.mainController reload];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    _inactive = YES;
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (_inactive) {
        // entered foreground: trigger a refresh
        if (self.mainController) [self.mainController setCheckVersionAfterReload:YES];
        [self refreshActivities];
        [self handlePendingEventToOpen];
        _inactive = NO;
    } else {
        // application startup: start a session:
        if (self.mainController) {
            [self.mainController setUIEnabled:NO];
            [self.mainController showReloadAnimationAnimated:NO];
            [self startSession:self];
        }
    }

// XXX
//    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:@"eventconfirm" forKey:@"type"];
//    [userInfo setObject:@"Ganz neue Aktivität mit Abstimmungen" forKey:@"eventName"];
//    [userInfo setObject:@"226" forKey:@"eventId"];
//    [userInfo setObject:@"thorsten@potpiejimmy.de" forKey:@"user"];
//    [userInfo setObject:@"1" forKey:@"state"];
//    [[DGUtils app] application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)refreshActivities
{
    if (self.mainController) self.mainController.refreshNeeded = YES;
    if (self.mainControllerMyActs) self.mainControllerMyActs.refreshNeeded = YES;
}

-(void)setRegistered
{
    [self setUserDefaultValue:@"true" forKey:@"registered"];
}

-(BOOL)isRegistered
{
    return [self userDefaultValueForKey:@"registered"] != nil;
}

-(void)unregister
{
    [self setUserDefaultValue:nil forKey:@"registered"];
    [self setUserDefaultValue:nil forKey:@"loginToken"];
    // also remove current session key
    self.sessionKey = nil;
    _gotSession = NO;
    // set push server sync false so token is reregistered on next login
    [self setUserDefaultValue:@"false" forKey:@"apnsServerSynced"];
}

-(NSString*)userDefaultValueForKey:(NSString*)key
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings stringForKey : key];
}

-(void)setUserDefaultValue:(NSString*)value forKey:(NSString*)key
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (value)
        [settings setObject : value forKey : key];
    else
        [settings removeObjectForKey: key];
    [settings synchronize];
}

-(NSString*)loginToken
{
    return [self userDefaultValueForKey:@"loginToken"];
}

-(void)setLoginToken:(NSString*)loginToken
{
    [self setUserDefaultValue:loginToken forKey:@"loginToken"];
}

-(int)userId
{
    return [[self userDefaultValueForKey:@"userId"] intValue];
}

-(void)setUserId:(int)userId
{
    [self setUserDefaultValue:[NSString stringWithFormat:@"%d",userId] forKey:@"userId"];
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

-(BOOL)isCurrentEventMyEvent
{
    if (!self.currentEvent) return NO;
    int eventOwner = [[[self.currentEvent objectForKey:@"owner"] objectForKey:@"id"] intValue];
    return (eventOwner == self.userId);
}

-(DGDateTimeSelectController*) dateTimeSelector
{
    if (!_dateTimeSelector)
        _dateTimeSelector = [[DGDateTimeSelectController alloc] init];
    return _dateTimeSelector;
}

@end
