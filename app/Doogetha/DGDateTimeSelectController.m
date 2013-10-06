//
//  DGDateTimeSelectController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGDateTimeSelectController.h"

@implementation DGDateTimeSelectController

@synthesize label = _label;
@synthesize datePicker = _datePicker;
@synthesize selectedDate = _selectedDate;

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

- (void)loadView
{
    NSLog(@"DGDateTimeSelectController.loadView called");
    [super loadView];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:screenBounds];
	self.view.backgroundColor = [UIColor blackColor];
    
    const int LABELHEIGHT = 40;

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, LABELHEIGHT)];
    self.label.font = [UIFont systemFontOfSize:15.0f];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.text = @"Bitte wähle einen Zeitpunkt:";
    
    [self.view addSubview:self.label];
                 
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, LABELHEIGHT, 1, 1)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker sizeToFit];
    
    [self.view addSubview:self.datePicker];
}


- (void)viewDidLoad
{
    NSLog(@"DGDateTimeSelectController.viewDidLoad called");
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;

    UIBarButtonItem* ok     = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Abbrechen" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    
    [self setToolbarItems:[NSArray arrayWithObjects:ok, cancel, nil] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)save:(id)sender
{
    self.selectedDate = self.datePicker.date;
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)cancel:(id)sender
{
    self.selectedDate = nil;
    [self.navigationController popViewControllerAnimated:NO];
}

@end
