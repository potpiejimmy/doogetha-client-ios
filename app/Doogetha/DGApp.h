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
#import "DGDateTimeSelectController.h"

#define WIZARD_PROCEED_STAY   0
#define WIZARD_PROCEED_NEXT   1
#define WIZARD_PROCEED_CANCEL 2

extern NSString* const DOOGETHA_URL;

@interface DGApp : UIResponder <UIApplicationDelegate> {
    @private BOOL _inactive;
    @private DGDateTimeSelectController* _dateTimeSelector;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TLWebRequest *webRequester;
@property (strong, nonatomic) NSString *sessionKey;

@property int wizardHint;

@property (strong, nonatomic) NSMutableDictionary* currentEvent;
@property (strong, nonatomic) NSMutableDictionary* currentSurvey;

@property (strong, nonatomic) DGMainController *mainController;
@property (strong, nonatomic) DGMainController *mainControllerMyActs;

@property (strong, nonatomic) id sessionCallback;

@property BOOL gotSession;

@property int pendingEventToOpen;

-(NSString*)authToken;
-(int)userId;
-(void)register:(NSString*)authToken;
-(void)unregister;
-(void)startSession:(id)sessionCallback;
-(void)makeMeFirst:(NSDictionary*) event;
-(NSDictionary*)findMe:(NSDictionary*) event;
-(BOOL)isCurrentEventMyEvent;

-(NSString*)userDefaultValueForKey:(NSString*)key;
-(void)setUserDefaultValue:(NSString*)value forKey:(NSString*)key;

-(NSString*)loginToken;
-(void)setLoginToken:(NSString*)loginToken;

-(void)refreshActivities;

-(DGDateTimeSelectController*) dateTimeSelector;

-(void)checkApnsServerSynced;
-(void)handlePendingEventToOpen;

@end

// Callback protocol:
@interface NSObject(DGAppSessionCallback)
- (void)sessionCreated;
@end
