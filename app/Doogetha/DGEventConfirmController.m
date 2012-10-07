//
//  DGEventConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGEventConfirmController.h"
#import "DGMainController.h"
#import "DGSurveyConfirmController.h"
#import "DGUtils.h"
#import "DGContactsUtils.h"

@implementation DGEventConfirmController
@synthesize eventName = _eventName;
@synthesize eventDescription = _eventDescription;
@synthesize surveyTable = _surveyTable;
@synthesize scroller = _scroller;
@synthesize confirmButton = _confirmButton;
@synthesize declineButton = _declineButton;
@synthesize editButton = _editButton;
@synthesize commentsPreviewer = _commentsPreviewer;

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


- (NSDictionary*) surveyResultItem: (NSDictionary*) survey
{
    for (NSDictionary* item in [survey objectForKey:@"surveyItems"])
    {
        int itemState = [[item objectForKey:@"state"] intValue];
        if (itemState == 1) /* close item */
            return item;
    }
    return nil;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void) updateCommentsPreviewer
{
    [self.commentsPreviewer updateWithComments:[[DGUtils app].currentEvent objectForKey:@"comments"]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _isEditing = NO;
    
    NSLog(@"viewDidLoad DGEventConfirmController");
    
    if ([[DGUtils app] isCurrentEventMyEvent])
        self.navigationItem.rightBarButtonItem = self.editButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    int viewWidth = self.scroller.frame.size.width;
    
    int itery = 0;
    
    NSDictionary* event = [DGUtils app].currentEvent;
    
    // Label and description
    self.eventName = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[event objectForKey:@"name"] size:18.0f];
    itery += self.eventName.frame.size.height;
    
    [self.scroller addSubview:self.eventName];
    
    itery += 5;
    
    self.eventDescription = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[event objectForKey:@"description"] size:14.0f];
    itery += self.eventDescription.frame.size.height;
    
    [self.scroller addSubview:self.eventDescription];
    
    itery += 10;

    self.surveyTable.frame = CGRectMake(0, itery, viewWidth, [[event objectForKey:@"surveys"] count] * 32);
    self.surveyTable.rowHeight = 32;
    itery += self.surveyTable.frame.size.height;
    
    itery += 10;
    
    self.confirmButton = [DGUtils button:CGRectMake(0, itery, 1, 1) withText:@" Ich nehme teil" target:self action:@selector(confirm:)];
    self.declineButton = [DGUtils button:CGRectMake(self.confirmButton.frame.size.width + 5, itery, 1, 1) withText:@" Ich nehme nicht teil" target:self action:@selector(decline:)];
    
    [self.confirmButton setImage:[UIImage imageNamed:@"dot-green.png"] forState:UIControlStateNormal];
    [self.declineButton setImage:[UIImage imageNamed:@"dot-red.png"] forState:UIControlStateNormal];
    
    [self.scroller addSubview:self.confirmButton];
    [self.scroller addSubview:self.declineButton];
    
    BOOL hasOpenSurveys = [DGMainController hasOpenSurveys:event];
    
    if (hasOpenSurveys)
    {
        self.confirmButton.hidden = YES;
        self.declineButton.hidden = YES;
    }
    else
    {
        itery += self.confirmButton.frame.size.height;
    }
    
    itery += 15;
    
    UILabel* participantsLabel = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:@"Teilnehmer" size:17.0f];
    itery += participantsLabel.frame.size.height;
    
    [self.scroller addSubview:participantsLabel];
    
    itery += 10;
    
    [[DGUtils app] makeMeFirst:event];
    for (NSDictionary* user in [event objectForKey:@"users"])
    {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, itery, 1, 1)];
        [DGMainController setConfirmImage:imageView forState:[[user objectForKey:@"state"] intValue]];
        [imageView sizeToFit];
        
        [self.scroller addSubview:imageView];
        
        [DGContactsUtils fillUserInfo:user];
        
        NSString* participantName = [DGContactsUtils userDisplayName:user];
        UILabel* participant = [DGUtils label:CGRectMake(imageView.frame.size.width + 5, itery, self.scroller.frame.size.width, 1) withText:participantName size:15.0f];
        
        CGRect rect = imageView.frame;
        rect.origin.y += (participant.frame.size.height - imageView.frame.size.height)/2;
        imageView.frame = rect;
        
        [self.scroller addSubview:participant];
        
        itery += imageView.frame.size.height;
        itery += 8;
    }

    self.scroller.contentSize=CGSizeMake(viewWidth,itery);

    [self updateCommentsPreviewer];
}

- (void)viewDidUnload
{
    [self setEventName:nil];
    [self setEventDescription:nil];
    [self setEventDescription:nil];
    [self setEventDescription:nil];
    [self setSurveyTable:nil];
    [self setConfirmButton:nil];
    [self setDeclineButton:nil];
    [self setScroller:nil];
    [self setEditButton:nil];
    [self setCommentsPreviewer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"View did appear: DGEventConfirmController");
    
    if (_isEditing) {
        _isEditing = NO;
        
        // just returned from editing - dismiss view and make sure event
        // is reloaded (even on cancel to revert all modifications)
        [[DGUtils app] refreshActivities];
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self.surveyTable reloadData];
    }
    
    [self updateCommentsPreviewer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[DGUtils app].currentEvent objectForKey:@"surveys"] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:.9 green:1.0 blue:.9 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"surveyItem"];
    
    NSDictionary* survey = [[[DGUtils app].currentEvent objectForKey:@"surveys"] objectAtIndex:[indexPath row]];
    int surveyState = [[survey objectForKey:@"state"] intValue];

    cell.textLabel.text = [survey objectForKey:@"name"];
    
    if (surveyState == 0) /* open */
    {
        cell.detailTextLabel.text = @"Jetzt abstimmen";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (surveyState == 1) /* closed */
    {
        cell.detailTextLabel.text = [DGUtils formatSurvey:survey item:[self surveyResultItem:survey]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* event = [DGUtils app].currentEvent;
    NSMutableDictionary* selSurvey = [[event objectForKey:@"surveys"] objectAtIndex:[indexPath row]];
    [[DGUtils app] makeMeFirst:event]; // XXX shouldn't call here on each selection
    [DGUtils app].currentSurvey = selSurvey;
    [self performSegueWithIdentifier:@"surveyConfirmSegue" sender:self];
}

// ----------

- (void) doConfirm: (int)state
{
    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;
    
    int eventId = [[[DGUtils app].currentEvent objectForKey:@"id"] intValue];
    
    NSString* url = [NSString stringWithFormat:@"%@events/%d?confirm=%d",DOOGETHA_URL,eventId,state];
    NSLog(@"Confirming event: %@", url);
    [DGUtils alertWaitStart:@"Bitte warten..."];
    [webRequester get:url reqid:@"confirm"];
}

- (IBAction) confirm:(id)sender
{
    [self doConfirm:1]; /* confirm */
}

- (IBAction) decline:(id)sender
{
    [self doConfirm:2]; /* decline */
}

- (IBAction)edit:(id)sender
{
    //NSLog(@"edit event");
    _isEditing = YES;
    [self performSegueWithIdentifier:@"editSegue" sender:self];
}

- (IBAction)commentsPreviewerTouchDown:(id)sender
{
    self.commentsPreviewer.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)commentsPreviewerTouchUpOutside:(id)sender
{
    self.commentsPreviewer.backgroundColor = [UIColor whiteColor];
}

- (IBAction)commentsPreviewerTouchUpInside:(id)sender
{
    self.commentsPreviewer.backgroundColor = [UIColor whiteColor];
    [self performSegueWithIdentifier:@"commentsSegue" sender:self];
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void) webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);
    [[DGUtils app] refreshActivities];
    [self.navigationController popViewControllerAnimated: YES];
}

@end
