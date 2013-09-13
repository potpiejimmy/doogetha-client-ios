//
//  DGContactsUtils.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGContactsUtils : NSObject

+ (void) fillUserInfo: (NSDictionary*) userVo;
+ (NSString*) userDisplayName: (NSDictionary*) userVo;
+ (NSArray*) fetchAllEmails;
+ (NSString*) participantNames: (NSDictionary*) event;

@end
