//
//  TLUtils.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLUtils : NSObject

+ (NSString*) bytesToHex:   (NSData*)data;
+ (NSData*)   hexToBytes:   (NSString*)hexString;
+ (NSString*) xorHexString: (NSString*)a with:(NSString*)b;
+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;

@end
