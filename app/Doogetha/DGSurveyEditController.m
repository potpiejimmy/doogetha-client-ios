//
//  DGSurveyEditController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGSurveyEditController.h"

#import "DGUtils.h"
#import "TLUtils.h"

@implementation DGSurveyEditController
@synthesize name = _name;
@synthesize description = _description;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setName:nil];
    [self setDescription:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) validateInput
{
    return [[TLUtils trim: self.name.text] length] > 0;
}

- (void)dismiss
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)save: (id)sender
{
    if (![self validateInput]) {
        [DGUtils alert:@"Bitte gib einen Namen für die Aktivität ein."];
        return;
    }
    
//    [self write];
    [self dismiss]; 
}

- (IBAction)cancel:(id)sender
{
    [DGUtils alertYesNo:@"Änderungen verwerfen?" delegate:self];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [DGUtils slideView:self.view pixels:84 up:YES];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [DGUtils slideView:self.view pixels:84 up:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    
    return YES;
}

- (IBAction)backgroundTouched:(id)sender {
    [self.name resignFirstResponder];
    [self.description resignFirstResponder];
}

@end
