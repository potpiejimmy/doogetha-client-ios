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
#import "DGDoogethaFriends.h"

#define WIZARD_PROCEED_STAY   0
#define WIZARD_PROCEED_NEXT   1
#define WIZARD_PROCEED_CANCEL 2

#define DOOGETHA_PROTOCOL_VERSION 2

extern NSString* const DOOGETHA_URL;

@interface DGApp : UIResponder <UIApplicationDelegate> {
    @private BOOL _inactive;
    @private DGDateTimeSelectController* _dateTimeSelector;
    @private DGDoogethaFriends* _friends;
}

@property (retain) NSOperationQueue * operationQueue;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TLWebRequest *webRequester;
@property (strong, nonatomic) NSString *sessionKey;

@property int wizardHint;

@property (strong, nonatomic) NSMutableDictionary* currentEvent;
@property (strong, nonatomic) NSMutableDictionary* currentSurvey;
@property (strong, nonatomic) NSMutableArray* currentUserSelection;

@property (strong, nonatomic) DGMainController *mainController;
@property (strong, nonatomic) DGMainController *mainControllerMyActs;

@property (strong, nonatomic) id sessionCallback;

@property BOOL gotSession;

@property int pendingEventToOpen;

-(int)userId;
-(void)setUserId:(int)userId;
-(void)setRegistered;
-(BOOL)isRegistered;
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

-(DGDoogethaFriends*)doogethaFriends;

-(void)startupMainView;
@end

// Callback protocol:
@interface NSObject(DGAppSessionCallback)
- (void)sessionCreateOk;
- (void)sessionCreateFail;
@end
