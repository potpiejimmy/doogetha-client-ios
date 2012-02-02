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

+ (NSString*) fillUserInfo: (NSMutableDictionary*) userVo
{
    NSString* searchString = [userVo objectForKey:@"email"];
    
    NSArray *all = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(ABAddressBookCreate());

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
                
                [userVo setObject:firstName forKey:@"firstname"];
                [userVo setObject:lastName forKey:@"lastname"];
            }
        }
    }
    
    return nil;
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

@end
