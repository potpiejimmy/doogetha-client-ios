//
//  DGUtils.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGApp.h"

@interface DGUtils : NSObject

+ (DGApp*) app;

+ (UILabel*) label: (CGRect) rect withText: (NSString*) label size: (CGFloat) size;
+ (UIButton*) button: (CGRect) rect withText: (NSString*) label target: (id) target action: (SEL) action;

+ (NSString*) dateTimeStringForMillis: (long long) millis;

+ (void) alert:          (NSString*) message;
+ (void) alertWaitStart: (NSString*) message;
+ (void) alertWaitEnd;

+ (void) slideView: (UIView*) view pixels: (int) pixels up: (BOOL) up;
+ (void) insertSpaceInView: (UIView*) view pixels: (int) pixels at: (int) pos;

@end
