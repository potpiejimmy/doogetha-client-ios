//
//  DGEventConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGEventConfirmController.h"

@implementation DGEventConfirmController
@synthesize eventName = _eventName;
@synthesize eventDescription = _eventDescription;
@synthesize okButton = _okButton;
@synthesize event = _event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGEventConfirmController");
    
    self.eventName.text = [self.event objectForKey:@"name"];
    self.eventDescription.text = [self.event objectForKey:@"description"];
    float oldHeight = self.eventDescription.frame.size.height;
    [self.eventDescription sizeToFit];
    float moreHeight = self.eventDescription.frame.size.height - oldHeight;
    [self.view sizeToFit];
    
//    for (UIView* view in self.view.subviews) {
//        [view removeFromSuperview];
//    }
    
    CGRect frame = self.okButton.frame;
    frame.origin.y += moreHeight;
    self.okButton.frame = frame;
//    [self.view addSubview:self.eventName];
//    [self.view addSubview:self.eventDescription];
//    [self.view addSubview:self.okButton];
}

- (void)viewDidUnload
{
    [self setEventName:nil];
    [self setEventDescription:nil];
    [self setEventDescription:nil];
    [self setEventDescription:nil];
    [self setOkButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
