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

@implementation DGEventConfirmController
@synthesize eventName = _eventName;
@synthesize eventDescription = _eventDescription;
@synthesize surveyTable = _surveyTable;
@synthesize confirmButton = _confirmButton;
@synthesize declineButton = _declineButton;
@synthesize event = _event;

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
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGEventConfirmController");
    
    self.eventName.text = [self.event objectForKey:@"name"];
    self.eventDescription.text = [self.event objectForKey:@"description"];
    float oldHeight = self.eventDescription.frame.size.height;
    [self.eventDescription sizeToFit];
    float moreHeight = self.eventDescription.frame.size.height - oldHeight;
    [self.view sizeToFit];
    
    CGRect frame = self.surveyTable.frame;
    frame.origin.y += moreHeight;
    self.surveyTable.frame = frame;
    
    self.surveyTable.rowHeight = 32;
    
    BOOL hasOpenSurveys = [DGMainController hasOpenSurveys:self.event];
    self.confirmButton.hidden = hasOpenSurveys;
    self.declineButton.hidden = hasOpenSurveys;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.event objectForKey:@"surveys"] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:.9 green:1.0 blue:.9 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"surveyItem"];
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[[self.event objectForKey:@"surveys"] objectAtIndex:row] objectForKey:@"name"];
    
    cell.detailTextLabel.text = @"Jetzt abstimmen";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DGSurveyConfirmController* scc = [self.storyboard instantiateViewControllerWithIdentifier:@"surveyConfirmController"];
    NSDictionary* selSurvey = [[self.event objectForKey:@"surveys"] objectAtIndex:[indexPath row]];
    [[DGUtils app] makeMeFirst:self.event]; // XXX shouldn't call here on each selection
    scc.event = self.event;
    scc.survey = selSurvey;
    [self.navigationController pushViewController:scc animated:YES];
}

@end
