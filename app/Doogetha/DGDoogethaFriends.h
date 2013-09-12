//
//  DGDoogethaFriends.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 12.09.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGDoogethaFriends : NSObject {
@private NSMutableArray* _friends;
@private NSMutableDictionary* _lookupMap;
}
-(DGDoogethaFriends*)init;
-(void)load;
-(void)save;
-(void)synchronizeWithServer;
-(NSMutableArray*)friends;
-(void)setFriends:(NSMutableArray*)friends;
@end
