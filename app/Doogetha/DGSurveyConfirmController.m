//
//  DGSurveyConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGSurveyConfirmController.h"
#import "DGUtils.h"
#import "SBJsonWriter.h"

@implementation DGSurveyConfirmController

@synthesize surveyName = _surveyName;
@synthesize surveyDescription = _surveyDescription;
@synthesize okButton = _okButton;
@synthesize cancelButton = _cancelButton;
@synthesize scroller = _scroller;
@synthesize event = _event;
@synthesize survey = _survey;

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

- (NSString*)displayName:(NSString*)mail {
    NSArray* tok = [mail componentsSeparatedByString:@"@"];
    return [NSString stringWithFormat:@"%@@ %@",[tok objectAtIndex:0],[tok objectAtIndex:1]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGSurveyConfirmController");
    
    int surveyState = [[self.survey objectForKey:@"state"] intValue];
    
    int viewWidth = self.scroller.frame.size.width;
    
    int itery = 0;
    
    // Label and description
    self.surveyName = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[self.survey objectForKey:@"name"] size:18.0f];
    itery += self.surveyName.frame.size.height;
    
    [self.scroller addSubview:self.surveyName];
    
    itery += 5;

    self.surveyDescription = [DGUtils label:CGRectMake(0, itery, viewWidth, 1) withText:[self.survey objectForKey:@"description"] size:14.0f];
    itery += self.surveyDescription.frame.size.height;

    [self.scroller addSubview:self.surveyDescription];
    
    itery += 20;
    
    UIScrollView* tableScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, itery, viewWidth, 1)];
    int tableitery = 0;
    
    // confirmation table
    int myUserId = [[DGUtils app] userId];
    NSArray* surveyItems = [self.survey objectForKey:@"surveyItems"];
    const int COLUMN1_WIDTH = 120;
    const int COLUMN_WIDTH  =  40;
    const int HEADER_HEIGHT = 100;
    
    int userCount = 0;
    
    // header
    for (NSDictionary* user in [self.event objectForKey:@"users"]) {
        
        UILabel* userName = [[UILabel alloc] initWithFrame:CGRectMake(COLUMN1_WIDTH - (HEADER_HEIGHT-COLUMN_WIDTH)/2 + userCount*COLUMN_WIDTH, tableitery, HEADER_HEIGHT, HEADER_HEIGHT)];
        userName.font = [UIFont systemFontOfSize:11.0f];
        userName.numberOfLines = 0;
        userName.text = [[user objectForKey:@"id"] intValue] == myUserId ? @"Ich" : [self displayName:[user objectForKey:@"email"]];
        userName.backgroundColor = [UIColor clearColor];
        userName.transform = CGAffineTransformMakeRotation( -M_PI/2 );
        
        [tableScroller addSubview:userName];

        userCount++;
    }
    tableitery += HEADER_HEIGHT;
    tableitery += 10;
    
    // body
    for (NSDictionary* surveyItem in surveyItems) {
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, tableitery, viewWidth, 2)];
        line.backgroundColor = [UIColor colorWithRed:0 green:.4 blue:0 alpha:1];
        tableitery += line.frame.size.height;
        
        [tableScroller addSubview:line];

        tableitery += 10;
        
        UILabel* itemLabel = [DGUtils label:CGRectMake(0, tableitery, COLUMN1_WIDTH - 10, 1) withText:[surveyItem objectForKey:@"name"] size:11.0f];
        
        [tableScroller addSubview:itemLabel];
        
        int i = 0;
        for (NSDictionary* user in [self.event objectForKey:@"users"]) {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(COLUMN1_WIDTH + i*COLUMN_WIDTH, tableitery, 1, 1)];
            [self setButtonImage:button forUser:[[user objectForKey:@"id"] intValue] item:surveyItem];
            [button sizeToFit];
            button.tag = [[surveyItem objectForKey:@"id"] intValue];
            if (i == 0 && surveyState == 0)
                [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            else
                button.enabled = false;
        
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.y += (itemLabel.frame.size.height - button.frame.size.height) / 2;
            buttonFrame.origin.x += (COLUMN_WIDTH - button.frame.size.width) / 2;
            button.frame = buttonFrame;
        
            [tableScroller addSubview:button];
            i++;
        }

        tableitery += itemLabel.frame.size.height;
        
        tableitery += 10;
    }
    
    tableScroller.frame = CGRectMake(0, itery, viewWidth, tableitery);
    tableScroller.contentSize = CGSizeMake(COLUMN1_WIDTH + userCount*COLUMN_WIDTH, tableitery);
    itery += tableitery;
    
    [self.scroller addSubview:tableScroller];
    
    itery += 10;
    
    // buttons
    self.okButton = [DGUtils button:CGRectMake(0, itery, 1, 1) withText:@"Speichern" target:self action:@selector(confirm:)];
    itery += self.okButton.frame.size.height;
    
    if (surveyState == 0)
        [self.scroller addSubview:self.okButton];
    
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)onClick:(id)sender {
    
    int surveyItemId = [sender tag];
    NSLog(@"Button clicked: %d", surveyItemId);
    
    NSArray* surveyItems = [self.survey objectForKey:@"surveyItems"];
    for (NSDictionary* surveyItem in surveyItems) {
        if ([[surveyItem objectForKey:@"id"] intValue] == surveyItemId) {
            [self toggleConfirmation:surveyItem forView:sender];
        }
    }
}

- (IBAction)confirm:(id)sender {
    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;
    SBJsonWriter* writer = [[SBJsonWriter alloc] init];
    NSString* result = [writer stringWithObject:self.survey];
    int surveyId = [[self.survey objectForKey:@"id"] intValue];
    NSLog(@"Trying to post: %@", result);
    [DGUtils alertWaitStart:@"Speichern. Bitte warten..."];
    [webRequester put:[NSString stringWithFormat:@"%@surveys/%d",DOOGETHA_URL,surveyId] msg:result reqid:@"confirm"];
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);
    [self.navigationController popViewControllerAnimated: YES];
}

@end
