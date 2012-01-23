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
@synthesize refreshButton = _refreshButton;
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

    NSLog(@"View did load: DGMainController");
    [DGUtils app].mainController = self;

    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:.0 green:.2 blue:.0 alpha:1.0]];
    UIImage *logo = [UIImage imageNamed:@"button_currentactivities.png"];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:logo]];
    
    _startingSession = YES;
    [self.activityIndicator startAnimating];
    [[DGUtils app] startSession:self];
}

- (void)viewDidUnload
{
    [self setEventsTable:nil];
    [self setActivityIndicator:nil];
    [self setRefreshButton:nil];
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

    if (!_startingSession)
        [self reload];
}

-(void)sessionCreated
{
    _startingSession = NO;
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:.9 green:1.0 blue:.9 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventItem"];

    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[self.events objectAtIndex:row] objectForKey:@"name"];
   
    NSNumber* eventDate = [[self.events objectAtIndex:row] objectForKey:@"eventtime"];
    long long eventTime = eventDate.longLongValue;
    
    if (eventTime > 0) {
        cell.detailTextLabel.text = [DGUtils dateTimeStringForMillis:eventTime];
    } else {
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DGEventConfirmController* ecc = [self.storyboard instantiateViewControllerWithIdentifier:@"eventConfirmController"];
    NSDictionary* selEvent = [self.events objectAtIndex:[indexPath row]];
    ecc.event = selEvent;
    [self.navigationController pushViewController:ecc animated:YES];
}

- (IBAction)reload:(id)sender {
    [self reload];
}


+(BOOL) hasOpenSurveys:(id) event {
    BOOL hasOpenSurveys = NO;
    for (NSDictionary* survey in [event objectForKey:@"surveys"])
    {
        if ([[survey objectForKey:@"state"] intValue] == 0) hasOpenSurveys = YES;
    }
    return hasOpenSurveys;
}

@end
