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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad DGSurveyConfirmController");

    self.scroller.contentSize=CGSizeMake(320,758);
    
    self.surveyName.text = [self.survey objectForKey:@"name"];
    self.surveyDescription.text = [self.survey objectForKey:@"description"];
    float oldHeight = self.surveyDescription.frame.size.height;
    [self.surveyDescription sizeToFit];
    float moreHeight = self.surveyDescription.frame.size.height - oldHeight;
    [self.view sizeToFit];
    
    CGRect frame = self.scroller.frame;
    frame.origin.y += moreHeight;
    frame.size.height -= moreHeight;
    self.scroller.frame = frame;
    
    NSArray* surveyItems = [self.survey objectForKey:@"surveyItems"];
    int i=0;
    for (NSDictionary* surveyItem in surveyItems) {
        UILabel* test = [[UILabel alloc] initWithFrame:CGRectMake(0, 30*i, 100, 30)];
        test.text = [surveyItem objectForKey:@"name"];
        test.font = [UIFont systemFontOfSize:10.0f];
        [test sizeToFit];
        [self.scroller addSubview:test];
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 30*i, 1, 1)];
        image.image = [UIImage imageNamed:@"survey_neutral.png"];
        [image sizeToFit];
        [self.scroller addSubview:image];
        i++;
    }
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


@end
