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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGSurveyConfirmController");
    
    int viewWidth = self.scroller.frame.size.width;
    
    int itery = 0;
    
    // Label and description
    self.surveyName = [[UILabel alloc] initWithFrame:CGRectMake(0, itery, viewWidth, 1)];
    self.surveyName.font = [UIFont systemFontOfSize:18.0f];
    self.surveyName.backgroundColor = [UIColor clearColor];
    self.surveyName.numberOfLines = 0;
    self.surveyName.text = [self.survey objectForKey:@"name"];
    [self.surveyName sizeToFit];
    itery += self.surveyName.frame.size.height;
    
    [self.scroller addSubview:self.surveyName];
    
    itery += 5;

    self.surveyDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, itery, viewWidth, 1)];
    self.surveyDescription.font = [UIFont systemFontOfSize:14.0f];
    self.surveyDescription.backgroundColor = [UIColor clearColor];
    self.surveyDescription.numberOfLines = 0;
    self.surveyDescription.text = [self.survey objectForKey:@"description"];
    [self.surveyDescription sizeToFit];
    itery += self.surveyDescription.frame.size.height;

    [self.scroller addSubview:self.surveyDescription];
    
    itery += 20;
    
    // confirmation table
    int myUserId = [[DGUtils app] userId];
    NSArray* surveyItems = [self.survey objectForKey:@"surveyItems"];
    for (NSDictionary* surveyItem in surveyItems) {
        
        itery += 10;
        
        UILabel* test = [[UILabel alloc] initWithFrame:CGRectMake(0, itery, 110, 1)];
        test.font = [UIFont systemFontOfSize:11.0f];
        test.numberOfLines = 0;
        test.text = [surveyItem objectForKey:@"name"];
        test.backgroundColor = [UIColor clearColor];
        [test sizeToFit];
        
        [self.scroller addSubview:test];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(120, itery, 1, 1)];
        [self setButtonImage:button forUser:myUserId item:surveyItem];
        [button sizeToFit];
        button.tag = [[surveyItem objectForKey:@"id"] intValue];
        [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.y += (test.frame.size.height - button.frame.size.height) / 2;
        button.frame = buttonFrame;
        
        [self.scroller addSubview:button];

        itery += test.frame.size.height;
        
        itery += 10;
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, itery, viewWidth, 2)];
        line.backgroundColor = [UIColor colorWithRed:0 green:.4 blue:0 alpha:1];
        
        itery += line.frame.size.height;
        
        [self.scroller addSubview:line];
    }
    
    itery += 10;
    
    // buttons
    self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.okButton.frame = CGRectMake(0, itery, 1, 1);
    [self.okButton setTitle:@"Speichern" forState:UIControlStateNormal];
    [self.okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.okButton sizeToFit];
    [self.okButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    itery += self.okButton.frame.size.height;
    
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
    [webRequester put:[NSString stringWithFormat:@"%@surveys/%d",DOOGETHA_URL,surveyId] msg:result name:@"confirm"];
}

- (void)webRequestDone:(NSString*)name
{
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);
    [self.navigationController popViewControllerAnimated: YES];
}

@end
