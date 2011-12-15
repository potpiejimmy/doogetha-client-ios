//
//  DGViewController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGMainController.h"
#import "DGApp.h"

@implementation DGMainController

@synthesize eventsTable = _eventsTable;
@synthesize webRequester = _webRequester;
@synthesize resultTextfield = _resultTextfield;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setEventsTable:nil];
    [self setResultTextfield:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"View did appear: DGMainController");
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)reload
{
    if (!self.webRequester)
        self.webRequester = [[TLWebRequest alloc] initWithObserver:self];

    DGApp* app = [[UIApplication sharedApplication] delegate];
    NSLog(@"Got session key %@",app.sessionKey);
    self.webRequester.authorization = [NSString stringWithFormat:@"Basic %@",app.sessionKey];
    [self.webRequester get:[NSString stringWithFormat:@"%@events",DOOGETHA_URL] name:@"get"];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)webRequestDone:(NSNotification*)notification
{
    NSString* result = [self.webRequester resultString];
    NSLog(@"Got result: %@",result);
    
    self.resultTextfield.text = [NSString stringWithFormat:@"Result: %@",result];
}

@end
