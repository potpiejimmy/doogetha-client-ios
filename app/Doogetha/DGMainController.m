//
//  DGViewController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGMainController.h"
#import "DGApp.h"
#import "DGUtils.h"
#import "DGEventConfirmController.h"

#import "SBJsonParser.h"

@implementation DGMainController

@synthesize eventsTable = _eventsTable;
@synthesize activityIndicator = _activityIndicator;
@synthesize events = _events;

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
    [self setActivityIndicator:nil];
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
    
    if (!_currentDetail) {
        [self.activityIndicator startAnimating];
        [[DGUtils app] startSession:self];
    }
}

-(void)sessionCreated
{
    [self.activityIndicator stopAnimating];
    [self reload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)reload
{
    DGApp* app = [DGUtils app];
    NSLog(@"Got session key %@",app.sessionKey);
    app.webRequester.authorization = [NSString stringWithFormat:@"Basic %@",app.sessionKey];
    app.webRequester.delegate = self;
    [self.activityIndicator startAnimating];
    [app.webRequester get:[NSString stringWithFormat:@"%@events",DOOGETHA_URL] name:@"get"];
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

- (void)webRequestDone:(NSString*)name
{
    [self.activityIndicator stopAnimating];
    NSString* result = [[DGUtils app].webRequester resultString];
    NSLog(@"Got result: %@",result);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* res = [parser objectWithString:result];
    self.events = [res objectForKey:@"events"];
    NSLog(@"Got %d events",[self.events count]);
    
    
    for (UITabBarItem* item in self.tabBarController.tabBar.items) {
        if (item.tag == 1) {
            item.badgeValue = [NSString stringWithFormat:@"%d",[self.events count]];
        }
    }
    
    [self.eventsTable reloadData];
}


#pragma mark -
#pragma mark Table View Data Source Methods
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem"];

    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[self.events objectAtIndex:row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.events objectAtIndex:row] objectForKey:@"description"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DGEventConfirmController* ecc = [self.storyboard instantiateViewControllerWithIdentifier:@"eventConfirmController"];
    NSDictionary* selEvent = [self.events objectAtIndex:[indexPath row]];
    _currentDetail = selEvent;
    ecc.event = selEvent;
    [self.navigationController pushViewController:ecc animated:YES];
}

@end
