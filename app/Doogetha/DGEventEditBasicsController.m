//
//  DGEventEditBasicsController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditBasicsController.h"
#import "DGUtils.h"
#import "TLUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation DGEventEditBasicsController
@synthesize name;
@synthesize description;

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

- (void) read
{
    NSDictionary* e = [DGUtils app].currentEvent;
    self.name.text =        [e objectForKey:@"name"];
    self.description.text = [e objectForKey:@"description"];
}

- (void) write
{
    NSDictionary* e = [DGUtils app].currentEvent;
    [e setValue:[TLUtils trim: self.name.text]  forKey:@"name"];
    [e setValue:self.description.text           forKey:@"description"];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [self.description.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.description.layer setBorderWidth:2.0]; 
    [self.description.layer setCornerRadius:5];
    self.description.clipsToBounds = YES;
    
    [self read];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setDescription:nil];
    [self setName:nil];
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

- (IBAction)save: (id)sender {
    if (![self validateInput]) {
        [DGUtils alert:@"Bitte gib einen Namen für die Aktivität ein."];
        return;
    }
    
    [self write];
    [DGUtils app].wizardHint = WIZARD_PROCEED_NEXT; /* go to next wizard step if invoked from wizard */
    [self dismissModalViewControllerAnimated:YES]; 
}

- (IBAction)cancel:(id)sender {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) /* clicked OK */
    {
        [DGUtils app].wizardHint = WIZARD_PROCEED_CANCEL; /* cancel wizard if invoked from wizard */
        [self dismissModalViewControllerAnimated:YES]; 
    }
}

@end
