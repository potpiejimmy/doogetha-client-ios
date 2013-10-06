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
@synthesize surveyMode = _surveyMode;

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
    self.surveyMode.on =   [[s objectForKey:@"mode"] intValue] == 1;
}

- (void) write
{
    NSDictionary* s = [DGUtils app].currentSurvey;
    [s setValue:[TLUtils trim: self.name.text]  forKey:@"name"];
    [s setValue:self.description.text           forKey:@"description"];
    [s setValue:(self.surveyMode.on ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) forKey:@"mode"];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _deletingItemIndex = -1;

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.surveyItemsTable addGestureRecognizer:lpgr];
}


- (void)viewDidUnload
{
    [self setName:nil];
    [self setDescription:nil];
    [self setSurveyItemsTable:nil];
    [self setSurveyMode:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Abstimmung bearbeiten";
    
    [self read];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self write];
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"·",[DGUtils formatSurvey:[DGUtils app].currentSurvey item:surveyItem]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self startEditingAtIndex:indexPath.row];
}

// ----------

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.surveyItemsTable];
        NSIndexPath *indexPath = [self.surveyItemsTable indexPathForRowAtPoint:p];
        if (indexPath == nil) return;
        
        NSDictionary* selItem = [[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] objectAtIndex:indexPath.row];
        _deletingItemIndex = indexPath.row;
        [DGUtils alertYesNo:[NSString stringWithFormat:@"Möchtest du die Auswahl \"%@\" wirklich entfernen?",[selItem objectForKey:@"name"]] delegate:self];
    }
}

- (void)handleItemAdded: (NSDictionary*)newItem
{
    [self.surveyItemsTable reloadData];
}

- (BOOL) validateInput
{
    if ([[TLUtils trim: self.name.text] length] == 0) {
        [DGUtils alert:@"Bitte gib ein Thema für die Abstimmung ein."];
        return NO;
    }
    if ([[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] count] < 2) {
        [DGUtils alert:@"Bitte gib mindestens zwei Auswahlmöglichkeiten ein."];
        return NO;
    }
    return YES;
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save: (id)sender
{
    if (![self validateInput]) return;
    
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
    if (_deletingItemIndex >= 0) { /* deleting an item */
        if (buttonIndex == 0) /* clicked OK */
        {
            // remove the item:
            [[[DGUtils app].currentSurvey objectForKey:@"surveyItems"] removeObjectAtIndex:_deletingItemIndex];
            [self.surveyItemsTable reloadData];
        }
        _deletingItemIndex = -1;
    }
    else if (_editingItem) { /* editing an item, handled in super controller */
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else { /* leaving the view via cancel button */
        if (buttonIndex == 0) /* clicked OK (really cancel)*/
        {
            [DGUtils app].currentSurvey = nil;
            [self dismiss];
        }
    }
}
@end
