//
//  DGAppDelegate.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLWebRequest.h"
#import "DGMainController.h"

extern NSString* const DOOGETHA_URL;

@interface DGApp : UIResponder <UIApplicationDelegate> {
    @private BOOL _inBackground;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *loginToken;
@property (strong, nonatomic) TLWebRequest *webRequester;
@property (strong, nonatomic) NSString *sessionKey;

@property BOOL wizardNext;

@property (strong, nonatomic) NSMutableDictionary* currentEvent;
@property (strong, nonatomic) NSMutableDictionary* currentSurvey;

@property (weak, nonatomic) DGMainController *mainController;

@property (strong, nonatomic) id sessionCallback;

-(NSString*)authToken;
-(int)userId;
-(void)register:(NSString*)authToken;
-(void)unregister;
-(void)startSession:(id)sessionCallback;
-(void)makeMeFirst:(NSDictionary*) event;
-(NSDictionary*)findMe:(NSDictionary*) event;

-(NSString*)userDefaultValueForKey:(NSString*)key;
-(void)setUserDefaultValue:(NSString*)value forKey:(NSString*)key;

@end

// Callback protocol:
@interface NSObject(DGAppSessionCallback)
- (void)sessionCreated;
@end
