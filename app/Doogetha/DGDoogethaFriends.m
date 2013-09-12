//
//  DGDoogethaFriends.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 12.09.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DGDoogethaFriends.h"
#import "DGUtils.h"
#import "DGContactsUtils.h"
#import "TLUtils.h"

@implementation DGDoogethaFriends

-(DGDoogethaFriends*)init
{
    self = [super init];
    if (self) {
        _friends = [[NSMutableArray alloc] init];
        _lookupMap = [[NSMutableDictionary alloc] init];
        
        // load:
        [self load];
    }
    return self;
}

-(void)load
{
    NSString* fs = [[DGUtils app] userDefaultValueForKey:@"doogethaFriends"];
    if (!fs) return;
    
    NSError* error;
    NSDictionary* res = [NSJSONSerialization 
                         JSONObjectWithData:[fs dataUsingEncoding:NSUTF8StringEncoding]
                         options:NSJSONReadingMutableContainers 
                         error:&error];
    NSArray* users = [res objectForKey:@"users"];
    for (NSDictionary* user in users) {
        [_friends addObject:user];
        [_lookupMap setValue:user forKey:[user objectForKey:@"email"]];
    }
}

-(void) save
{
    NSMutableDictionary* users = [[NSMutableDictionary alloc] init];
    [users setValue:_friends forKey:@"users"];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization
                        dataWithJSONObject:users
                        options:0
                        error:&error];
    NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[DGUtils app] setUserDefaultValue:result forKey:@"doogethaFriends"];
}

-(NSMutableArray*)friends
{
    return _friends;
}

-(void)setFriends:(NSMutableArray*)friends
{
    _friends = friends;

    [_lookupMap removeAllObjects];;
    for (NSDictionary* friend in friends)
        [_lookupMap setValue:friend forKey:[friend objectForKey:@"email"]];
}

-(void)sortFriends
{
    // Sort list by display name
    [_friends sortUsingComparator:^(id a, id b) {
        NSString* n1 = [DGContactsUtils userDisplayName:a]; 
        NSString* n2 = [DGContactsUtils userDisplayName:b];
        return [n1 compare:n2];
    }];
}

-(void)addFriend:(NSDictionary*)friend
{
    if ([[friend objectForKey:@"email"] isEqualToString:[[DGUtils app] userDefaultValueForKey:@"email"]])
        return; // don't add myself
    
    if ([_lookupMap objectForKey:[friend objectForKey:@"email"]])
        return; // don't add duplicates
    
    [_friends addObject:friend];
    [_lookupMap setObject:friend forKey:[friend objectForKey:@"email"]];
    
    [self sortFriends];
}

-(void)synchronizeWithServer
{
    // maps email hash strings to email addresses:
    NSMutableDictionary* userMap = [[NSMutableDictionary alloc] init];
    
    // get the current list:
    NSArray* currentUsers = [[[DGUtils app] doogethaFriends] friends];
    // put all current users in the hash list:
    if (currentUsers)
        for (NSDictionary* user in currentUsers)
            [userMap setValue:[user objectForKey:@"email"] forKey:[TLUtils encodeBase64WithData:[TLUtils md5:[user objectForKey:@"email"]]]];
    
    // also put all mail addresses from the address book in the map:
    NSArray* addressBookMails = [DGContactsUtils fetchAllEmails];
    for (NSString* mail in addressBookMails) 
        if (![mail isEqualToString:[[DGUtils app] userDefaultValueForKey:@"email"]])
            [userMap setValue:mail forKey:[TLUtils encodeBase64WithData:[TLUtils md5:mail]]];
    
    NSMutableString* hashes = [[NSMutableString alloc] init];
    for (NSString* hash in [userMap keyEnumerator]) {
        if ([hashes length] > 0) [hashes appendString:@","];
        [hashes appendString:hash];
    }
    
    // now send comma separated list of hashes to server:
    [DGUtils app].webRequester.delegate = self;
    [[DGUtils app].webRequester post:[NSString stringWithFormat:@"%@users",DOOGETHA_URL] msg:hashes reqid:@"synchronize"];
}

- (void)webRequestFail:(NSString*)reqid 
{
    [[DGUtils app] startupMainView];
}

- (void)webRequestDone:(NSString*)reqid 
{
    NSData* result = [[DGUtils app].webRequester resultData];
    
    NSError* error;
    NSDictionary* res = [NSJSONSerialization 
                         JSONObjectWithData:result
                         options:NSJSONReadingMutableContainers 
                         error:&error];
    
    NSMutableArray* syncedFriends = [res objectForKey:@"users"];
    NSLog(@"Got %d synced friends.",[syncedFriends count]);
    
    // fetch display names from address book:
    for (NSDictionary* friend in syncedFriends)
        [DGContactsUtils fillUserInfo:friend];
    
    [self setFriends:syncedFriends];
    [self sortFriends];
    [self save];
    
    [[DGUtils app] startupMainView];
}

@end
