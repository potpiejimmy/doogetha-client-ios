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
#import "DGContactsUtils.h"
#import "DGEventConfirmController.h"

#import <Foundation/NSJSONSerialization.h>

@implementation DGMainController

@synthesize eventsTable = _eventsTable;
@synthesize buttonNewActivity = _buttonNewActivity;
@synthesize events = _events;
@synthesize checkVersionAfterReload = _checkVersionAfterReload;
@synthesize refreshNeeded = _refreshNeeded;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)setUIEnabled: (BOOL) enabled
{
    for (id item in self.tabBarController.tabBar.items)
        [item setEnabled:enabled];
    [self.view setUserInteractionEnabled:enabled];
    [self.buttonNewActivity setEnabled:enabled];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"View did load: DGMainController");
    if (self.tabBarController.tabBar.selectedItem.tag == 1)
        [DGUtils app].mainController = self; // set main controller
    else if (self.tabBarController.tabBar.selectedItem.tag == 2)
        [DGUtils app].mainControllerMyActs = self; // set main controller for my activities
    
    UIColor* dgColor = [UIColor colorWithRed:.0 green:.2 blue:.0 alpha:1.0];
    [self.navigationController.navigationBar setTintColor:dgColor];
    [self.navigationController.toolbar setTintColor:dgColor];
    UIImage *logo = [UIImage imageNamed:@"title.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:logo];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationItem setTitleView:imageView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.eventsTable addGestureRecognizer:lpgr];

    if ([[DGUtils app] gotSession]) {
        // session already started - just refresh on viewDidAppear
        _refreshNeeded = [[DGUtils app] gotSession];
    } else {
        // application just started up: start a session:
        [self setUIEnabled:NO];
        [self showReloadAnimationAnimated:NO];
        [[DGUtils app] startSession:[DGUtils app]];
    }
}

- (void)viewDidUnload
{
    [self setEventsTable:nil];
    [self setButtonNewActivity:nil];
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
    
    if (_refreshNeeded) {
        _checkVersionAfterReload = NO;
        [self reload];
    } else {
        [self.eventsTable reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)reload
{
    if (self.tabBarController.tabBar.selectedItem.tag > 2) return;
    
    DGApp* app = [DGUtils app];
    app.webRequester.delegate = self;
    [self showReloadAnimationAnimated:NO];
    NSString* url;
    if (self.tabBarController.tabBar.selectedItem.tag == 1)
        url = @"%@events";
    else if (self.tabBarController.tabBar.selectedItem.tag == 2)
        url = @"%@events?mine=true";

    [app.webRequester get:[NSString stringWithFormat:url,DOOGETHA_URL] reqid:@"load"];
    [self setUIEnabled:NO];
}

- (void) openPendingEvent
{
    for (NSMutableDictionary* event in self.events) {
        if ([[event objectForKey:@"id"] intValue] == [DGUtils app].pendingEventToOpen) {
            [DGUtils app].currentEvent = event;
            [self performSegueWithIdentifier:@"eventConfirmSegue" sender:self];
            break;
        }
    }
    [DGUtils app].pendingEventToOpen = 0; // only try once
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
    [self setUIEnabled:YES];
    [self dataSourceDidFinishLoadingNewData]; // DGPullRefreshTableViewController

    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid
{
    [self setUIEnabled:YES];
    [self dataSourceDidFinishLoadingNewData]; // DGPullRefreshTableViewController
    if ([reqid isEqualToString:@"load"])
    {
        _refreshNeeded = NO;
        [self dataSourceDidFinishLoadingNewData]; // DGPullRefreshTableViewController

        NSData* result = [[DGUtils app].webRequester resultData];
    
        NSError* error;
        NSDictionary* res = [NSJSONSerialization 
                          JSONObjectWithData:result
                          options:NSJSONReadingMutableContainers 
                          error:&error];
    
        self.events = [res objectForKey:@"events"];
        NSLog(@"Got %d events",[self.events count]);
    
//        self.tabBarController.tabBar.selectedItem.badgeValue = [NSString stringWithFormat:@"%d",[self.events count]];
        
        // add mail addresses to friends list:
        for (NSDictionary* event in self.events) {
            for (NSDictionary* user in [event objectForKey:@"users"]) {
                [[[DGUtils app] doogethaFriends] addFriend:user];
            }
        }
        [[[DGUtils app] doogethaFriends] save];
    
        [self.eventsTable reloadData];
        
        if ([DGUtils app].pendingEventToOpen > 0)
        {
            [self openPendingEvent];
        }
        else
        {
            if (_checkVersionAfterReload)
            {
                _checkVersionAfterReload = NO;
                [self checkVersion];
            }
            else
            {
                [[DGUtils app] checkApnsServerSynced];
            }
        }
    }
    else if ([reqid isEqualToString:@"version"])
    {
        NSData* versionData = [[DGUtils app].webRequester resultData];
        
        NSError* error;
        NSDictionary* res = [NSJSONSerialization 
                             JSONObjectWithData:versionData
                             options:NSJSONReadingMutableContainers 
                             error:&error];
        
        NSString* serverVersion = [res objectForKey:@"clientVersionCode"];
        int protocolVersion = [[res objectForKey:@"protocolVersion"] intValue];
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* myVersion = [infoDict objectForKey:@"CFBundleVersion"];

        if (protocolVersion != DOOGETHA_PROTOCOL_VERSION) {
            [DGUtils alert:@"Diese Version von Doogetha ist veraltet und nicht mehr mit dem Server kompatibel. Bitte aktualisiere deine Installation." withTitle:@"Doogetha"];
        } else if (![myVersion isEqualToString:serverVersion]) {
            [DGUtils alert:@"Es steht eine neue Version von Doogetha zur Verfügung.\nBitte lade diese herunter\n\nhttp://doogetha.com/beta/\n\nund installiere sie über iTunes" withTitle:@"Doogetha Beta Program"];
        }

        [[DGUtils app] checkApnsServerSynced];
    }
    else if ([reqid isEqualToString:@"delete"])
    {
        [[DGUtils app] refreshActivities];
        [self reload];
    }
}

- (void) checkVersion
{
    [DGUtils app].webRequester.delegate = self;
    [[DGUtils app].webRequester get:[NSString stringWithFormat:@"%@version?os=ios",DOOGETHA_URL] reqid:@"version"];
    [self setUIEnabled:NO];
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

- (UITableView*) tableView
{
    return self.eventsTable;
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
    
    ((UILabel*)[cell viewWithTag:3]).text = [event objectForKey:@"name"];
   
    NSNumber* eventDate = [event objectForKey:@"eventtime"];
    long long eventTime = eventDate.longLongValue;
    
    if (eventTime > 0) {
        ((UILabel*)[cell viewWithTag:2]).text = [DGUtils dateTimeStringForMillis:eventTime];
    } else {
        ((UILabel*)[cell viewWithTag:2]).text = @"";
    }
    
    if ([DGMainController hasOpenSurveys:event])
        ((UIImageView*)[cell viewWithTag:1]).image = [UIImage imageNamed:@"question_mark.png"];
    else {
        NSDictionary* myConfirmation = [[DGUtils app] findMe:event];
        int myConfirmationState = [[myConfirmation objectForKey:@"state"] intValue];
        [DGMainController setConfirmImage:((UIImageView*)[cell viewWithTag:1]) forState:myConfirmationState];
    }
    
    // participant names:
    NSMutableString* participantsText = [[NSMutableString alloc] init];
    NSString* participants = [DGContactsUtils participantNames:event];
    if (participants) {
        [participantsText appendString:@"mit "];
        [participantsText appendString:participants];
    } else {
        [participantsText appendString:@"keine Teilnehmer"];
    }
    ((UILabel*)[cell viewWithTag:4]).text = participantsText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* selEvent = [self.events objectAtIndex:[indexPath row]];
    [DGUtils app].currentEvent = selEvent;
    [self performSegueWithIdentifier:@"eventConfirmSegue" sender:self];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.eventsTable];
        NSIndexPath *indexPath = [self.eventsTable indexPathForRowAtPoint:p];

        if (indexPath == nil) return;
        
        if (self.tabBarController.tabBar.selectedItem.tag == 2)
        {
            NSMutableDictionary* selEvent = [self.events objectAtIndex:[indexPath row]];
            [DGUtils app].currentEvent = selEvent;
            [DGUtils alertYesNo:[NSString stringWithFormat:@"Möchtest du die Aktivität \"%@\" wirklich löschen?",[selEvent objectForKey:@"name"]] delegate:self];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) /* clicked OK */
    {
        NSLog(@"DELETE!!!");
        int eventId = [[[DGUtils app].currentEvent objectForKey:@"id"] intValue];
        DGApp* app = [DGUtils app];
        app.webRequester.delegate = self;
        [app.webRequester del:[NSString stringWithFormat:@"%@events/%d",DOOGETHA_URL,eventId] reqid:@"delete"];
        [self setUIEnabled:NO];
    }
}

- (IBAction)newButtonClicked:(id)sender {
    
    NSLog(@"creating new activity");
    
    DGApp* app = [DGUtils app];
    app.currentEvent = [[NSMutableDictionary alloc] init];
    NSDictionary* myself = [[NSMutableDictionary alloc] init];
    [myself setValue:[NSNumber numberWithInt:[app userId]] forKey:@"id"];
    [myself setValue:[app userDefaultValueForKey:@"email"] forKey:@"email"];
    [app.currentEvent setValue:myself forKey:@"owner"];
    [app.currentEvent setValue:[[NSMutableArray alloc] initWithObjects:myself, nil] forKey:@"users"];

    [self performSegueWithIdentifier:@"newClickedSegue" sender:self];
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
