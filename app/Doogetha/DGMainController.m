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

#import <Foundation/NSJSONSerialization.h>

@implementation DGMainController

@synthesize eventsTable = _eventsTable;
@synthesize events = _events;
@synthesize checkVersionAfterReload = _checkVersionAfterReload;

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
    UIImage *logo = [UIImage imageNamed:@"logo.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:logo];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationItem setTitleView:imageView];
    
    _startingSession = YES;
    _checkVersionAfterReload = YES;
    [self showReloadAnimationAnimated:NO];
    [[DGUtils app] startSession:self];
}

- (void)viewDidUnload
{
    [self setEventsTable:nil];
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
    {
        _checkVersionAfterReload = NO;
        [self reload];
    }
}

-(void)sessionCreated
{
    _startingSession = NO;
    _checkVersionAfterReload = YES;
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
    [self showReloadAnimationAnimated:NO];
    [app.webRequester get:[NSString stringWithFormat:@"%@events",DOOGETHA_URL] reqid:@"load"];
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

- (void)webRequestFail:(NSString*)reqid
{
    [self dataSourceDidFinishLoadingNewData]; // DGPullRefreshTableViewController

    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid
{
    if ([reqid isEqualToString:@"load"])
    {
        [self dataSourceDidFinishLoadingNewData]; // DGPullRefreshTableViewController

        NSData* result = [[DGUtils app].webRequester resultData];
    
        NSError* error;
        NSDictionary* res = [NSJSONSerialization 
                          JSONObjectWithData:result
                          options:NSJSONReadingMutableContainers 
                          error:&error];
    
        self.events = [res objectForKey:@"events"];
        NSLog(@"Got %d events",[self.events count]);
    
        for (UITabBarItem* item in self.tabBarController.tabBar.items) {
            if (item.tag == 1) {
                item.badgeValue = [NSString stringWithFormat:@"%d",[self.events count]];
            }
        }
    
        [self.eventsTable reloadData];
    
        if (_checkVersionAfterReload)
        {
            _checkVersionAfterReload = NO;
            [self checkVersion];
        }
    }
    else if ([reqid isEqualToString:@"version"])
    {
        NSString* serverVersion = [[DGUtils app].webRequester resultString];
        if (serverVersion && [serverVersion length]>2)
            serverVersion = [serverVersion substringWithRange:NSMakeRange(1, [serverVersion length]-2)];
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* myVersion = [infoDict objectForKey:@"CFBundleVersion"];
        
        if (![myVersion isEqualToString:serverVersion]) {
            [DGUtils alert:@"Es steht eine neue Version von Doogetha zur Verfügung.\nBitte lade diese herunter\n\nhttp://potpiejimmy.de/doogetha/\n\nund installiere sie über iTunes" withTitle:@"Doogetha Beta Program"];
        }
    }
}

- (void) checkVersion
{
    [DGUtils app].webRequester.delegate = self;
    [[DGUtils app].webRequester get:[NSString stringWithFormat:@"%@version?os=ios",DOOGETHA_URL] reqid:@"version"];
}

+ (void)setConfirmImage: (UIImageView*)imageView forState:(int)state
{
    switch (state) {
        case 0:
            imageView.image = [UIImage imageNamed:@"dot-gray.png"];
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"dot-green.png"];
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"dot-red.png"];
            break;
   }
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
    
    NSDictionary* event = [self.events objectAtIndex:row];
    
    cell.textLabel.text = [event objectForKey:@"name"];
   
    NSNumber* eventDate = [event objectForKey:@"eventtime"];
    long long eventTime = eventDate.longLongValue;
    
    if (eventTime > 0) {
        cell.detailTextLabel.text = [DGUtils dateTimeStringForMillis:eventTime];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    if ([DGMainController hasOpenSurveys:event])
        cell.imageView.image = [UIImage imageNamed:@"question_mark.png"];
    else {
        NSDictionary* myConfirmation = [[DGUtils app] findMe:event];
        int myConfirmationState = [[myConfirmation objectForKey:@"state"] intValue];
        [DGMainController setConfirmImage:cell.imageView forState:myConfirmationState];
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

- (void) reload:(id)sender {
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

- (void)reloadTableViewDataSource
{
    // called by DGPullRefreshTableViewController when pulled
	[self reload];
}

@end
