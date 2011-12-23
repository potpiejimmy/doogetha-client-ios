//
//  DGSurveyConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGSurveyConfirmController.h"

@implementation DGSurveyConfirmController

@synthesize surveyName = _surveyName;
@synthesize surveyDescription = _surveyDescription;
@synthesize confirmTable = _confirmTable;
@synthesize okButton = _okButton;
@synthesize cancelButton = _cancelButton;
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
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGSurveyConfirmController");
    
    self.surveyName.text = [self.survey objectForKey:@"name"];
    self.surveyDescription.text = [self.survey objectForKey:@"description"];
    float oldHeight = self.surveyDescription.frame.size.height;
    [self.surveyDescription sizeToFit];
    float moreHeight = self.surveyDescription.frame.size.height - oldHeight;
    [self.view sizeToFit];
    
    CGRect frame = self.confirmTable.frame;
    frame.origin.y += moreHeight;
    self.confirmTable.frame = frame;
    
    self.confirmTable.rowHeight = 32;

}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnLoad DGSurveyConfirmController");

    [self setSurveyName:nil];
    [self setSurveyDescription:nil];
    [self setConfirmTable:nil];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setConfirmTable:nil];
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
    return [[self.survey objectForKey:@"surveyItems"] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:.9 green:1.0 blue:.9 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"confirmRowItem"];
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[[self.survey objectForKey:@"surveyItems"] objectAtIndex:row] objectForKey:@"name"];
    
//    cell.detailTextLabel.text = @"Jetzt abstimmen";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
