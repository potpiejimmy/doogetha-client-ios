//
//  DGEventEditController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditController.h"

#import "DGUtils.h"

@implementation DGEventEditController
@synthesize editTableView;

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
}

- (void)viewDidUnload
{
    [self setEditTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;

    [self.editTableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"Titel und Beschreibung";
        case 1: return @"Zeitpunkt";
        case 2: return @"Teilnehmer";
        case 3: return @"Abstimmungen";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: (indexPath.section == 0 ? @"eventEditCellBasics" : @"eventEditCell")];
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0: {
            cell.textLabel.text = [[DGUtils app].currentEvent objectForKey:@"name"];
            cell.detailTextLabel.text = [[DGUtils app].currentEvent objectForKey:@"description"];
            break;
        }
        case 1: {
            NSNumber* eventDate = [[DGUtils app].currentEvent objectForKey:@"eventtime"];
            long long eventTime = eventDate.longLongValue;
            cell.textLabel.text = eventTime == 0 ? @"<Nicht festgelegt>" : [DGUtils dateTimeStringForMillis:eventTime];
            break;
        }
        case 2: {
            int numParticipants = [[[DGUtils app].currentEvent objectForKey:@"users"] count];
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", numParticipants, @"Teilnehmer"];
            break;
        }
        case 3: {
            int numSurveys = [[[DGUtils app].currentEvent objectForKey:@"surveys"] count];
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", numSurveys, @"Abstimmung(en)"];
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 100.0f : 32.0f;
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
    switch (indexPath.section)
    {
        case 0:
            [self performSegueWithIdentifier:@"editBasicsSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"editDateTimeSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"editParticipantsSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"editSurveysSegue" sender:self];
            break;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dismiss
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)cancel:(id)sender
{
    [self dismiss];
}

- (IBAction)save:(id)sender
{
    [self dismiss];
}
@end
