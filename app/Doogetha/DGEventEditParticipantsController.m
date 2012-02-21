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
@synthesize checkingMail = _checkingMail;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidUnload
{
    [self setParticipantsTable:nil];
    [self setCheckingMail:nil];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    [DGUtils alert:@"Sorry, die eingegebene E-Mail-Adresse ist noch nicht bei Doogetha registriert."];
}

- (void) webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    NSLog(@"Got result: %@", [[[DGUtils app] webRequester] resultString]);

    // add new user:
    DGApp* app = [DGUtils app];
    NSDictionary* event = app.currentEvent;
    NSMutableArray* users = [event objectForKey:@"users"];
    NSDictionary* newUser = [[NSMutableDictionary alloc] init];
    [newUser setValue:self.checkingMail forKey:@"email"];
    [DGContactsUtils fillUserInfo:newUser];
    [users addObject:newUser];
    
    [self.participantsTable reloadData];
}

- (void)dismiss
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)checkMail: (NSString*)mail
{
    self.checkingMail = mail;
    DGApp* app = [DGUtils app];
    app.webRequester.delegate = self;
    [app.webRequester get:[NSString stringWithFormat:@"%@users/%@",DOOGETHA_URL,mail] reqid:@"checkuser"];
    [DGUtils alertWaitStart:@"Adresse wird überprüft..."];
}

- (void)checkNewParticipant:(NSString*)mail
{
    if ([mail length]>0)
    {
        NSDictionary* event = [DGUtils app].currentEvent;
        
        for (NSDictionary* item in [event objectForKey:@"users"])
        {
            if ([[item objectForKey:@"email"] caseInsensitiveCompare:mail] == NSOrderedSame) {
                [DGUtils alert:@"Der Teilnehmer ist bereits hinzugefügt"];
                return;
            }
        }
        
        // check mail address:
        [self checkMail:mail];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) /* clicked OK */
    {
        NSString* newItemText = [TLUtils trim:[[alertView textFieldAtIndex:0] text]];
        NSLog(@"Entered: %@",newItemText);
        [self checkNewParticipant:newItemText];
    }
}

- (IBAction)addManual:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Teilnehmer hinzufügen" message:@"Bitte gib die E-Mail-Adresse des Teilnehmers ein:" delegate:self cancelButtonTitle:@"Hinzufügen" otherButtonTitles:@"Abbrechen",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)addAddressBook:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)save:(id)sender
{
    [DGUtils app].wizardHint = WIZARD_PROCEED_NEXT;
    [self dismiss]; 
}

// -----

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	ABMultiValueRef mailProperty = ABRecordCopyValue(person,property);
	NSString *mail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(mailProperty,identifier);
    [peoplePicker dismissModalViewControllerAnimated:YES];
    // check mail address:
    [self checkNewParticipant:mail];
    return NO;
}

@end
