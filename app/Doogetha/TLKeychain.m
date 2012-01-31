//
// Keychain.h
//
// Based on code by Michael Mayo at http://overhrd.com/?p=208
//
// Created by Frank Kim on 1/3/11.
//

#import "TLKeychain.h"
#import <Security/Security.h>

@implementation TLKeychain

+ (void)saveString:(NSString *)value forKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");
	NSAssert(value != nil, @"Invalid value");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
	
	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
	if (error == errSecSuccess) {
		// update
		NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] 
																	  forKey:(__bridge id)kSecValueData];
		
		error = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
		NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %d", error);
	} else if (error == errSecItemNotFound) {
		// insert
		[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		
		error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
		NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %d", error);
	} else {
		NSAssert1(NO, @"SecItemCopyMatching failed: %d", error);
	}
}

+ (NSString *)getStringForKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");
	
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];

	CFDataRef dataFromKeychain = nil;

	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&dataFromKeychain);
	NSData* data = (__bridge_transfer NSData*) dataFromKeychain; 
    
	NSString *stringToReturn = nil;
	if (error == errSecSuccess) {
		stringToReturn = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return stringToReturn;
}

+ (void)deleteStringForKey:(NSString *)key {
	NSAssert(key != nil, @"Invalid key");

	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
		
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status != errSecSuccess) {
		NSLog(@"SecItemDelete failed: %ld", status);
	}
}

@end