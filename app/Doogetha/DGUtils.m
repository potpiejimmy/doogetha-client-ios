//
//  DGUtils.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGUtils.h"

@implementation DGUtils

+ (DGApp*) app
{
    return [[UIApplication sharedApplication] delegate];
}

+ (UILabel*) label: (CGRect) rect withText: (NSString*) label size: (CGFloat) size
{
    UILabel* l = [[UILabel alloc] initWithFrame:rect];
    l.font = [UIFont systemFontOfSize:size];
    l.backgroundColor = [UIColor clearColor];
    l.numberOfLines = 0;
    l.text = label;
    [l sizeToFit];
    return l;
}

+ (UIButton*) button: (CGRect) rect withText: (NSString*) label target: (id) target action: (SEL) action
{
    UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame = rect;
    b.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [b setTitle:label forState:UIControlStateNormal];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [b sizeToFit];
    [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}

+ (NSString*) dateTimeStringForMillis: (long long) millis
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:millis/1000]];
}

@end
