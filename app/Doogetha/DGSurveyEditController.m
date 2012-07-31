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
#import <QuartzCore/QuartzCore.h>

@implementation DGSurveyEditController
@synthesize name = _name;
@synthesize description = _description;
@synthesize surveyItemsTable = _surveyItemsTable;

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
    NSDictionary* s = [DGUtils app].currentSurvey;
    self.name.text =        [s objectForKey:@"name"];
    self.description.text = [s objectForKey:@"description"];
}

- (void) write
{
    NSDictionary* s = [DGUtils app].currentSurvey;
    [s setValue:[TLUtils trim: self.name.text]  forKey:@"name"];
    [s setValue:self.description.text           forKey:@"description"];
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
    [self setName:nil];
    [self setDescription:nil];
    [self setSurveyItemsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self read];
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
//---
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] count];
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.backgroundColor = [UIColor colorWithRed:.9 green:1.0 blue:.9 alpha:1];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath called");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"surveyItemCell"];
    
    NSDictionary* surveyItem = [[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [DGUtils formatSurvey:[DGUtils app].currentSurvey item:surveyItem];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSMutableDictionary* selSurveyItem = [[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] objectAtIndex:[indexPath row]];
}

// ----------

- (void)handleItemAdded: (NSDictionary*)newItem
{
    [self.surveyItemsTable reloadData];
}

- (BOOL) validateInput
{
    return [[TLUtils trim: self.name.text] length] > 0;
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save: (id)sender
{
    if (![self validateInput]) {
        [DGUtils alert:@"Bitte gib ein Thema für die Abstimmung ein."];
        return;
    }
    
    [self write];
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

- (IBAction)addItem:(id)sender
{
    [self addButtonClicked:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_editingItem) {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else {
        if (buttonIndex == 0) /* clicked OK (cancel)*/
        {
            [DGUtils app].currentSurvey = nil;
            [self dismiss];
        }
    }
}
@end
