//
//  TLKeychain.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLKeychain : NSObject {
}

+ (void)saveString:(NSString *)value forKey:(NSString *)key;
+ (NSString *)getStringForKey:(NSString *)key;
+ (void)deleteStringForKey:(NSString *)key;

@end