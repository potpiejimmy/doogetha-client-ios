//
//  DGEventEditDateTimeController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditDateTimeController.h"
#import "DGUtils.h"

@implementation DGEventEditDateTimeController
@synthesize datePicker;
@synthesize dateTimeLabel;

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

- (void)updateDateTimeLabel
{
    long long ts = self.datePicker.date.timeIntervalSince1970 * 1000;
    self.dateTimeLabel.text = [DGUtils dateTimeStringForMillis:ts];
}

- (void) read
{
    NSDictionary* e = [DGUtils app].currentEvent;
    self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:[[e objectForKey:@"eventtime"] intValue]/1000];
    
    [self updateDateTimeLabel];
}

- (void) write
{
    NSDictionary* e = [DGUtils app].currentEvent;
    [e setValue:[NSNumber numberWithInt:self.datePicker.date.timeIntervalSince1970*1000] forKey:@"eventtime"];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateDateTimeLabel];
}


- (void)viewDidUnload
{
    [self setDateTimeLabel:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)datePickerValueChanged:(id)sender 
{
    [self updateDateTimeLabel];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveDate:(id)sender
{
    [self write];
    [DGUtils app].wizardNext = YES; /* go to next wizard step if invoked from wizard */
    [self dismissModalViewControllerAnimated:YES]; 
}
@end
