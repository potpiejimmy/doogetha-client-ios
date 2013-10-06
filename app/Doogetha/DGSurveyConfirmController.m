//
//  DGSurveyConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGSurveyConfirmController.h"
#import "DGUtils.h"
#import "TLUtils.h"
#import "DGContactsUtils.h"

const int COLUMN1_WIDTH = 120;
const int COLUMN_WIDTH  =  40;
const int HEADER_HEIGHT = 100;

@implementation DGSurveyConfirmController

@synthesize tableScroller = _tableScroller;
@synthesize surveyName = _surveyName;
@synthesize surveyDescription = _surveyDescription;
@synthesize okButton = _okButton;
@synthesize cancelButton = _cancelButton;
@synthesize addButton = _addButton;
@synthesize scroller = _scroller;

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
    NSLog(@"localView DGSurveyConfirmController");
}
*/

- (void)setButtonImage:(UIButton*)button forUser:(int)userId item:(NSDictionary*)surveyItem {
    // find user status:
    [button setBackgroundImage:[UIImage imageNamed:@"survey_neutral.png"] forState:UIControlStateNormal];
    for (NSDictionary* confirmation in [surveyItem objectForKey:@"confirmations"]) {
        if ([[confirmation objectForKey:@"userId"] intValue] == userId) {
            switch ([[confirmation objectForKey:@"state"] intValue]) {
    				case 0:
                        [button setBackgroundImage:[UIImage imageNamed:@"survey_neutral.png"] forState:UIControlStateNormal];
    		    		break;
    				case 1:
                        [button setBackgroundImage:[UIImage imageNamed:@"survey_confirm.png"] forState:UIControlStateNormal];
    		    		break;
    				case 2:
                        [button setBackgroundImage:[UIImage imageNamed:@"survey_deny.png"] forState:UIControlStateNormal];
    		    		break;
            }
        }
    }
}

- (int) addSurveyToggleRow: (NSDictionary*) surveyItem at: (int) currentY
{
    NSDictionary* event =  [DGUtils app].currentEvent;
    NSDictionary* survey = [DGUtils app].currentSurvey;
    
    int oldY = currentY; // remember initial Y
    
    int viewWidth = self.scroller.frame.size.width;
    int surveyState = [[survey objectForKey:@"state"] intValue];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, viewWidth, 2)];
    line.backgroundColor = [UIColor colorWithRed:0 green:.4 blue:0 alpha:1];
    currentY += line.frame.size.height;
    
    [self.tableScroller addSubview:line];
    
    currentY += 10;

    // my event & survey is open: add close buttons
    BOOL needCloseButton = surveyState == 0 /* open survey */ && [[DGUtils app] isCurrentEventMyEvent] /* my event */;
    
    int closeButtonSpace = 0;
    if (needCloseButton) {
        // my event: reserve some extra space in first column for close buttons:
        closeButtonSpace = 20;
    }
    
    UILabel* itemLabel = [DGUtils label:CGRectMake(closeButtonSpace, currentY, COLUMN1_WIDTH - 10 - closeButtonSpace, 1) withText:[DGUtils formatSurvey:survey item:surveyItem] size:11.0f];
    
    [self.tableScroller addSubview:itemLabel];
    
    if (needCloseButton) {
        // now that we know the height of the current row (the itemLabel's height), add the close button:
        UIButton* closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, currentY, 1, 1)];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton sizeToFit];
        closeButton.tag = [[surveyItem objectForKey:@"id"] intValue];
        // now vertically align the button in center:
        CGRect buttonFrame = closeButton.frame;
        buttonFrame.origin.y += (itemLabel.frame.size.height - closeButton.frame.size.height) / 2;
        closeButton.frame = buttonFrame;
        [self.tableScroller addSubview:closeButton];
    }
    
    int i = 0;
    for (NSDictionary* user in [event objectForKey:@"users"]) {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(COLUMN1_WIDTH + i*COLUMN_WIDTH, currentY, 1, 1)];
        [self setButtonImage:button forUser:[[user objectForKey:@"id"] intValue] item:surveyItem];
        [button sizeToFit];
        button.tag = [[surveyItem objectForKey:@"id"] intValue];
        if (i == 0 && surveyState == 0)
            [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        else
            button.enabled = false;
        
        // center align vertically and horizontally:
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.y += (itemLabel.frame.size.height - button.frame.size.height) / 2;
        buttonFrame.origin.x += (COLUMN_WIDTH - button.frame.size.width) / 2;
        button.frame = buttonFrame;
        
        [self.tableScroller addSubview:button];
        i++;
    }
    
    currentY += itemLabel.frame.size.height;
    
    currentY += 10;
    
    return (currentY - oldY); // return additional height used by new row
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _closingWithItem = nil;
    
    NSLog(@"viewDidLoad DGSurveyConfirmController");
    
    NSDictionary* event =  [DGUtils app].currentEvent;
    NSDictionary* survey = [DGUtils app].currentSurvey;

    int surveyState = [[survey objectForKey:@"state"] intValue];
    
    int viewWidth = self.scroller.frame.size.width;
    
    int itery = 0;
    
    // Label and description
    self.surveyName = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[survey objectForKey:@"name"] size:18.0f];
    itery += self.surveyName.frame.size.height;
    
    [self.scroller addSubview:self.surveyName];
    
    itery += 5;

    self.surveyDescription = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[survey objectForKey:@"description"] size:14.0f];
    itery += self.surveyDescription.frame.size.height;

    [self.scroller addSubview:self.surveyDescription];
    
    itery += 20;
    
    self.tableScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, itery, viewWidth, 1)];
    int tableitery = 0;
    
    // confirmation table
    NSArray* surveyItems = [survey objectForKey:@"surveyItems"];
    
    int userCount = 0;
    
    // header
    for (NSDictionary* user in [event objectForKey:@"users"]) {
        
        UILabel* userName = [[UILabel alloc] initWithFrame:CGRectMake(COLUMN1_WIDTH - (HEADER_HEIGHT-COLUMN_WIDTH)/2 + userCount*COLUMN_WIDTH, tableitery, HEADER_HEIGHT, HEADER_HEIGHT)];
        userName.font = [UIFont systemFontOfSize:11.0f];
        userName.numberOfLines = 0;
        userName.text = [DGContactsUtils userDisplayName:user];
        userName.backgroundColor = [UIColor clearColor];
        userName.transform = CGAffineTransformMakeRotation( -M_PI/2 );
        
        [self.tableScroller addSubview:userName];

        userCount++;
    }
    tableitery += HEADER_HEIGHT;
    tableitery += 10;
    
    // body
    for (NSDictionary* surveyItem in surveyItems) {
        tableitery += [self addSurveyToggleRow:surveyItem at:tableitery];
    }
    
    self.tableScroller.frame = CGRectMake(0, itery, viewWidth, tableitery);
    self.tableScroller.contentSize = CGSizeMake(COLUMN1_WIDTH + userCount*COLUMN_WIDTH, tableitery);
    itery += tableitery;
    
    [self.scroller addSubview:self.tableScroller];
    
    itery += 5;
    
    // buttons
    if (surveyState == 0) /* open survey */
    {
        int surveyMode = [[survey objectForKey:@"mode"] intValue];
        if (surveyMode == 1) /* editable survey */
        {
//            int surveyType = [[survey objectForKey:@"type"] intValue];
//            if (surveyType == 0) /* XXX for now, only allow editing of generic surveys */
//            {
                UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, itery, 1, 1)];
                [button setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
                [button sizeToFit];
                [button addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                itery += button.frame.size.height;
                [self.scroller addSubview:button];
                itery += 10;
//            }
        }
        
        // save button:
        self.okButton = [DGUtils button:CGRectMake(0, itery, 1, 1) withText:@"Speichern" target:self action:@selector(confirm:)];
        itery += self.okButton.frame.size.height;
        [self.scroller addSubview:self.okButton];
    }
    
    self.scroller.contentSize=CGSizeMake(viewWidth,itery);
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnLoad DGSurveyConfirmController");

    [self setSurveyName:nil];
    [self setSurveyDescription:nil];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setScroller:nil];
    
    _closingWithItem = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)toggleConfirmation:(NSDictionary*)item forView:(UIButton*)button {
    NSDictionary* itemUser = nil;
    int myUserId = [[DGUtils app] userId];
    for (NSDictionary* confirmation in [item objectForKey:@"confirmations"]) {
        if ([[confirmation objectForKey:@"userId"] intValue] == myUserId)
            itemUser = confirmation;
    }
    if (!itemUser) {
        itemUser = [[NSMutableDictionary alloc] init];
        [itemUser setValue:[NSNumber numberWithInt:myUserId] forKey:@"userId"];
        if (![item objectForKey:@"confirmations"]) {
            [item setValue:[NSMutableArray arrayWithObject:itemUser] forKey:@"confirmations"];
        } else {
            [[item objectForKey:@"confirmations"] addObject:itemUser];
        }
    }
    int state = [[itemUser objectForKey:@"state"] intValue];
    state = (state + 1) % 3;
    [itemUser setValue:[NSNumber numberWithInt:state] forKey:@"state"];
    [self setButtonImage:button forUser:myUserId item:item];
}

- (NSMutableDictionary*) findItemForId: (int)id
{
    NSArray* surveyItems = [[DGUtils app].currentSurvey objectForKey:@"surveyItems"];
    for (NSMutableDictionary* surveyItem in surveyItems) {
        if ([[surveyItem objectForKey:@"id"] intValue] == id) {
            return surveyItem;
        }
    }
    return nil;
}

- (void)onClick:(id)sender
{
    NSMutableDictionary* surveyItem = [self findItemForId:[sender tag]];
    if (surveyItem) [self toggleConfirmation:surveyItem forView:sender];
}

- (void)onClickClose:(id)sender
{
    NSMutableDictionary* surveyItem = [self findItemForId:[sender tag]];
    if (surveyItem) {
        _closingWithItem = surveyItem;
        [DGUtils alertYesNo:[NSString stringWithFormat:@"Abstimmung jetzt schließen mit dem Ergebnis \"%@\"?",[DGUtils formatSurvey:[DGUtils app].currentSurvey item:surveyItem]] delegate:self];
    }
}

- (void)handleItemAdded: (NSDictionary*)newItem
{
    NSDictionary* survey = [DGUtils app].currentSurvey;
    NSMutableArray* currentItems = [survey objectForKey:@"surveyItems"];
    [newItem setValue:[NSNumber numberWithInt:-[currentItems count]] forKey:@"id"]; // initialize with negative ID for toggling
            
    // update table
    int newRowHeight = [self addSurveyToggleRow:newItem at:self.tableScroller.frame.size.height];
    
    // increase table scroller content size:
    CGSize csize = self.tableScroller.contentSize;
    csize.height += newRowHeight;
    self.tableScroller.contentSize = csize;

    // increase table scroller size to match content (scroll horizontally only):
    CGRect crect = self.tableScroller.frame;
    crect.size.height += newRowHeight;
    self.tableScroller.frame = crect;

    // add row:
    [DGUtils insertSpaceInView:self.scroller pixels:newRowHeight at:self.tableScroller.frame.origin.y + 1];
    
    // increase the overall content size:
    csize = self.scroller.contentSize;
    csize.height += newRowHeight;
    self.scroller.contentSize = csize;
}

- (IBAction)confirm:(id)sender
{
    NSDictionary* survey = [DGUtils app].currentSurvey;

    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;
    
    NSArray* surveyItems = [survey objectForKey:@"surveyItems"];
    for (NSMutableDictionary* item in surveyItems)
    {
        // reset negative IDs to nil (added items)
        if ([[item objectForKey:@"id"] intValue] < 0)
            [item removeObjectForKey:@"id"];
    }
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:survey 
                                            options:0 error:&error];
    NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    int surveyId = [[survey objectForKey:@"id"] intValue];
    NSLog(@"Trying to post: %@", result);
    [DGUtils alertWaitStart:@"Speichern. Bitte warten..."];
    [webRequester put:[NSString stringWithFormat:@"%@surveys/%d",DOOGETHA_URL,surveyId] msg:result reqid:@"confirm"];
}

- (void)closeSurveyWithItem:(NSMutableDictionary*)closeItem
{
    [[DGUtils app].currentSurvey setObject:[NSNumber numberWithInt:1] forKey:@"state"]; /* survey state: 1 = closed */
    NSArray* surveyItems = [[DGUtils app].currentSurvey objectForKey:@"surveyItems"];
    for (NSMutableDictionary* surveyItem in surveyItems)
        [surveyItem setObject:[NSNumber numberWithInt:0] forKey:@"state"]; // reset all other to 0
    [closeItem setObject:[NSNumber numberWithInt:1] forKey:@"state"]; // close reason (1)
    
    // now save the view:
    [self confirm:nil];
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    _closingWithItem = nil;
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);
    [[DGUtils app] refreshActivities];
    
    if (_closingWithItem) {
        // closing - send the close request now:
        TLWebRequest* webRequester = [[DGUtils app] webRequester];
        webRequester.delegate = self;

        NSDictionary* survey = [DGUtils app].currentSurvey;
        int surveyId = [[survey objectForKey:@"id"] intValue];
        int surveyItemId = [[_closingWithItem objectForKey:@"id"] intValue];
        _closingWithItem = nil;
        NSLog(@"Closing survey %d with item %d", surveyId, surveyItemId);
        [DGUtils alertWaitStart:@"Abstimmung wird geschlossen. Bitte warten..."];
        [webRequester get:[NSString stringWithFormat:@"%@surveys/%d?close=%d",DOOGETHA_URL,surveyId,surveyItemId] reqid:@"close"];
    } else {
        // leave view:
        [self.navigationController popViewControllerAnimated: YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_editingItem) { /* editing an item, handled in super controller */
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else {
        // alert: really close survey?
        if (buttonIndex == 0) /* clicked OK */ {
            [self closeSurveyWithItem:_closingWithItem];
            // keep _closingWithItem until saved
        } else {
            _closingWithItem = nil;
        }
    }
}

@end
