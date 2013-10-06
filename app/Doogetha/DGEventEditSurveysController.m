//
//  DGEventEditSurveysController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditSurveysController.h"

#import "DGUtils.h"

@implementation DGEventEditSurveysController
@synthesize surveysTable = _surveysTable;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isEditingSurvey = NO;
    _deletingIndex = -1;

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.surveysTable addGestureRecognizer:lpgr];
}

- (void)viewDidUnload
{
    [self setSurveysTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Abstimmungen";
    
    if (_isEditingSurvey) {
        /* user just returned from editing a survey */
        _isEditingSurvey = NO;
        if ([DGUtils app].currentSurvey) { /* not cancelled */
            if (_editingIndex < 0) { /* new survey */
                // new survey was edited and submitted, add it to the list
                [self addSurvey];
            } else {
                // survey was edited, just replace it
                [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] setObject:[DGUtils app].currentSurvey atIndex:_editingIndex];
            }
        }
        [self.surveysTable reloadData];
    }
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"Abstimmungen" : @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] count];
    else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: (indexPath.section == 0 ? @"surveyCell" : @"actionCell")];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        NSDictionary* survey = [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] objectAtIndex:indexPath.row];
        cell.textLabel.text = [survey objectForKey:@"name"];
        cell.detailTextLabel.text = [survey objectForKey:@"description"];
    } else {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Neue Abstimmung (frei)";
                break;
            case 1:
                cell.textLabel.text = @"Neue Abstimmung (Datum)";
                break;
            case 2:
                cell.textLabel.text = @"Neue Abstimmung (Datum und Uhrzeit)";
                break;
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        _isEditingSurvey = YES;
        _editingIndex = indexPath.row;
        NSMutableDictionary* survey = [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] objectAtIndex:indexPath.row];
        [DGUtils app].currentSurvey = (__bridge_transfer NSMutableDictionary*)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge_retained CFDictionaryRef)survey, kCFPropertyListMutableContainers);
        [self performSegueWithIdentifier:@"surveyEditSegue" sender:self];
    } else {
        [self addSurveyWithType:indexPath.row];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.surveysTable];
        NSIndexPath *indexPath = [self.surveysTable indexPathForRowAtPoint:p];
        if (indexPath == nil) return;
        
        NSDictionary* selSurvey = [[[DGUtils app].currentEvent objectForKey:@"surveys"] objectAtIndex:indexPath.row];
        _deletingIndex = indexPath.row;
        [DGUtils alertYesNo:[NSString stringWithFormat:@"Möchtest du die Abstimmung \"%@\" wirklich löschen?",[selSurvey objectForKey:@"name"]] delegate:self];
    }
}

- (void)addSurvey
{
    NSMutableArray* surveys = [[DGUtils app].currentEvent objectForKey:@"surveys"];
    if (!surveys) {
        surveys = [NSMutableArray arrayWithObjects:[DGUtils app].currentSurvey, nil];
        [[DGUtils app].currentEvent setValue:surveys forKey:@"surveys"];
    } else {
        [surveys addObject:[DGUtils app].currentSurvey];
    }
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addSurveyWithType: (int)type
{
    _isEditingSurvey = YES;
    _editingIndex = -1; /* new survey, set index -1 */
    
    /* create a new survey */
    NSMutableDictionary* survey = [[NSMutableDictionary alloc] init];
    [survey setValue:[NSMutableArray array] forKey:@"surveyItems"];
    [survey setValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [DGUtils app].currentSurvey = survey;
    
    [self performSegueWithIdentifier:@"surveyEditSegue" sender:self];
}

- (IBAction)save:(id)sender
{
    [DGUtils app].wizardHint = WIZARD_PROCEED_NEXT;
    [self dismiss]; 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_deletingIndex >= 0) { /* deleting an item */
        if (buttonIndex == 0) /* clicked OK */
        {
            // remove the survey:
            [[[DGUtils app].currentEvent objectForKey:@"surveys"] removeObjectAtIndex:_deletingIndex];
            [self.surveysTable reloadData];
        }
        _deletingIndex = -1;
    }
}
@end
