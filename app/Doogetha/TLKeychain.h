//
//  TLKeychain.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

size_t encodeASN1Length(unsigned char * buf, size_t length);

@interface TLKeychain : NSObject {
}

+ (void)saveString:(NSString *)value forKey:(NSString *)key;
+ (NSString *)getStringForKey:(NSString *)key;
+ (void)deleteStringForKey:(NSString *)key;

+ (void)generateKeyPair;
+ (NSData*)encodedPublicKey;
+ (void)sign:(NSData*)data;

@end