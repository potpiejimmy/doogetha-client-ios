//
//  DGContactsUtils.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGContactsUtils.h"
#import "DGUtils.h"
#import <AddressBook/AddressBook.h>

@implementation DGContactsUtils

+ (void) fillUserInfo: (NSMutableDictionary*) userVo
{
    @try {
        NSString* searchString = [userVo objectForKey:@"email"];
    
        NSArray *all = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(ABAddressBookCreateWithOptions(NULL, NULL));

        for (int i=0; i< [all count]; i++)
        {
            ABRecordRef person = (__bridge ABRecordRef) [all objectAtIndex:i];

            ABMutableMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            CFIndex emailsCount = ABMultiValueGetCount(emails);
        
            for (int k=0; k<emailsCount; k++)
            {
                NSString* emailValue = (__bridge NSString*) ABMultiValueCopyValueAtIndex(emails, k);
                if ([searchString isEqualToString:emailValue]) {
                    NSString* firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    NSString* lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                
                    NSLog(@"FOUND %@ = %@ %@", searchString, firstName, lastName);
                
                    [userVo setObject:[NSString stringWithFormat:@"%@",firstName] forKey:@"firstname"];
                    [userVo setObject:[NSString stringWithFormat:@"%@",lastName] forKey:@"lastname"];
                    return;
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (NSArray*) fetchAllEmails
{
    NSMutableArray* result = [[NSMutableArray alloc] init];

    @try {
        NSArray *all = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(ABAddressBookCreateWithOptions(NULL, NULL));
        
        for (int i=0; i< [all count]; i++)
        {
            ABRecordRef person = (__bridge ABRecordRef) [all objectAtIndex:i];
            
            ABMutableMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            CFIndex emailsCount = ABMultiValueGetCount(emails);
            
            for (int k=0; k<emailsCount; k++)
            {
                NSString* emailValue = (__bridge NSString*) ABMultiValueCopyValueAtIndex(emails, k);
                [result addObject:emailValue];
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return result;
}

+ (NSString*) userDisplayName: (NSDictionary*) userVo
{
    if ([[userVo objectForKey:@"id"] intValue] == [[DGUtils app] userId])
        return @"Ich";

    NSString* firstName = (NSString*) [userVo objectForKey:@"firstname"];
    NSString* lastName = (NSString*) [userVo objectForKey:@"lastname"];
    NSString* email = (NSString*) [userVo objectForKey:@"email"];
    if (firstName && lastName)
        return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    else if (firstName)
        return firstName;
    else if (lastName)
        return lastName;
    else
        return email;
}

+ (NSString*) participantNames: (NSDictionary*) event
{
    NSMutableString* stb = [[NSMutableString alloc] init];
    int delimiters = [[event objectForKey:@"users"] count] - 2;
    for (NSMutableDictionary* user in [event objectForKey:@"users"]) {
        if ([[user objectForKey:@"email"] caseInsensitiveCompare:[[DGUtils app] userDefaultValueForKey:@"email"]] == NSOrderedSame) continue; // skip myself
        NSMutableDictionary* resolvedUser = [[[DGUtils app] doogethaFriends] resolveUserInfo:user]; // resolve names from friends list
        if ([stb length] > 0) [stb appendString:--delimiters>0 ? @", " : @" und "];
        [stb appendString:[[[DGContactsUtils userDisplayName:resolvedUser] componentsSeparatedByString:@" "] objectAtIndex:0]];
    }
    if ([stb length] > 0) return stb;
    else return nil; // no participants except myself - return nil
}

@end
