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
    _isCreatingNewSurvey = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;

    if (_isEditingSurvey) {
        /* user just returned from editing a survey */
        _isEditingSurvey = NO;
        if (_isCreatingNewSurvey) {
            _isCreatingNewSurvey = NO;
            if ([DGUtils app].currentSurvey) { /* not cancelled */
                // new survey was edited and submitted, add it to the list
                [self addSurvey];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.surveysTable reloadData];
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
    return @"Abstimmungen";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"surveyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary* survey = [[[[DGUtils app] currentEvent] objectForKey:@"surveys"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [survey objectForKey:@"name"];
    cell.detailTextLabel.text = [survey objectForKey:@"description"];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)addSurveyWithType: (int)type
{
    _isEditingSurvey = YES;
    _isCreatingNewSurvey = YES;
    
    /* create a new survey */
    NSMutableDictionary* survey = [[NSMutableDictionary alloc] init];
    [survey setValue:[NSMutableArray array] forKey:@"surveyItems"];
    [survey setValue:@"" forKey:@"name"];
    [survey setValue:@"" forKey:@"description"];
    [DGUtils app].currentSurvey = survey;
    
    [self performSegueWithIdentifier:@"surveyEditSegue" sender:self];
}

- (IBAction)save:(id)sender
{
    [DGUtils app].wizardHint = WIZARD_PROCEED_NEXT;
    [self dismiss]; 
}

- (IBAction)addSurveyFree:(id)sender
{
    [self addSurveyWithType:0];
}

- (IBAction)addSurveyDate:(id)sender
{
    [self addSurveyWithType:1];
}

- (IBAction)addSurveyDateAndTime:(id)sender
{
    [self addSurveyWithType:2];
}

@end
