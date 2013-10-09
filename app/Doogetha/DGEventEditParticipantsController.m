//
//  DGEventEditParticipantsController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGEventEditParticipantsController.h"
#import "DGUtils.h"
#import "DGContactsUtils.h"
#import "TLUtils.h"

@implementation DGEventEditParticipantsController
@synthesize participantsTable = _participantsTable;
@synthesize removingUser = _removingUser;

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
    [self setRemovingUser:nil];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.participantsTable addGestureRecognizer:lpgr];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [self setParticipantsTable:nil];
    [self setRemovingUser:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Teilnehmer";
}

- (void)viewDidAppear:(BOOL)animated
{
    // adapt the currently selected users:
    if ([DGUtils app].currentUserSelection) {
        NSMutableArray* users = [[[DGUtils app] currentEvent] objectForKey:@"users"];
        for (NSDictionary* user in [[DGUtils app] currentUserSelection]) {
            BOOL found = false;
            for (NSDictionary* u in users)
                if ([[u objectForKey:@"email"] caseInsensitiveCompare:[user objectForKey:@"email"]] == NSOrderedSame)
                    found = TRUE;

            if (!found) // just ignore duplicates
                [users addObject:user];
        }
        [DGUtils app].currentUserSelection = nil;
        [self.participantsTable reloadData];
    } 
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[[DGUtils app] currentEvent] objectForKey:@"users"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"participantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* user = [[[[DGUtils app] currentEvent] objectForKey:@"users"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [DGContactsUtils userDisplayName:user];
    cell.detailTextLabel.text = [user objectForKey:@"email"];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return @"Teilnehmer";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.participantsTable deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.participantsTable];
        NSIndexPath *indexPath = [self.participantsTable indexPathForRowAtPoint:p];
        
        if (indexPath == nil) return;
        
        if (indexPath.row > 0)
        {
            NSMutableDictionary* selUser = [[[[DGUtils app] currentEvent] objectForKey:@"users"] objectAtIndex:[indexPath row]];
            self.removingUser = indexPath;
            [DGUtils alertYesNo:[NSString stringWithFormat:@"Möchtest du den Teilnehmer \"%@\" wirklich entfernen?",[DGContactsUtils userDisplayName:selUser]] delegate:self];
        }
    }
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) /* clicked OK */
    {
        if (self.removingUser) {
            [[[[DGUtils app] currentEvent] objectForKey:@"users"] removeObjectAtIndex:self.removingUser.row];
            self.removingUser = nil;
            [self.participantsTable reloadData];
        }
    }
    else 
    {
        self.removingUser = nil;
    }
}

- (IBAction)save:(id)sender
{
    [DGUtils app].wizardHint = WIZARD_PROCEED_NEXT;
    [self dismiss]; 
}

// ----- Old select-from-addressbook code ----

//- (IBAction)addAddressBook:(id)sender
//{
//    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
//    picker.peoplePickerDelegate = self;
//    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
//    [self presentModalViewController:picker animated:YES];
//}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
//	ABMultiValueRef mailProperty = ABRecordCopyValue(person,property);
//	NSString *mail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(mailProperty,identifier);
//    CFRelease(mailProperty);
//    [peoplePicker dismissModalViewControllerAnimated:YES];
//    // check mail address:
//    [self checkNewParticipant:mail];
    return NO;
}

@end
