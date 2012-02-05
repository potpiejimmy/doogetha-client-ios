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
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:millis/1000];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    if ([components hour]==0 && [components minute]==0)
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    else
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

+ (void) alert:          (NSString*) message
{
    [self alert:message withTitle:nil];
}

+ (void) alert:          (NSString*) message   withTitle: (NSString*) title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
                                              message:message
                                              delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alert show];
}

+ (void) alertYesNo:     (NSString*) message   delegate: (id) delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                              message:message
                                              delegate:delegate 
                                              cancelButtonTitle:@"Ja"
                                              otherButtonTitles:@"Nein",nil];
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
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -pixels : pixels);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}

+ (void) insertSpaceInView: (UIView*) view pixels: (int) pixels at: (int) pos
{
    for (UIView* child in [view subviews])
    {
        CGRect rect = child.frame;
        if (rect.origin.y >= pos) {
            rect.origin.y += pixels;
            child.frame = rect;
        }
    }
}

@end
