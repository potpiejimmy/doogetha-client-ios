//
//  DGUtils.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 16.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGUtils.h"

UIAlertView* _currentAlert;

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

+ (void) alert:          (NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                              message:message
                                              delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alert show];
}

+ (void) alertWaitStart: (NSString*) message
{
    _currentAlert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [_currentAlert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(_currentAlert.bounds.size.width / 2, _currentAlert.bounds.size.height - 50);
    [indicator startAnimating];
    [_currentAlert addSubview:indicator];
}

+ (void) alertWaitEnd
{
    [_currentAlert dismissWithClickedButtonIndex:0 animated:YES];
}

+ (void) slideView:   (UIView*) view pixels: (int) pixels up: (BOOL) up
{
    const int movementDistance = 160; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}


@end
