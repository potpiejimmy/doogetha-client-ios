//
//  DGDoogethaFriendsController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.09.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DGDoogethaFriendsController.h"
#import "DGUtils.h"
#import "DGContactsUtils.h"
#import "TLUtils.h"

@implementation DGDoogethaFriendsController
@synthesize friendsTable = _friendsTable;

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
    
    _data = [[[DGUtils app] doogethaFriends] friends];
    
    self.tableView.allowsMultipleSelection = YES;

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidUnload
{
    [self setFriendsTable:nil];
    [super viewDidUnload];

    [self setCheckingMail:nil];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"doogethaFriendItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [DGContactsUtils userDisplayName:[_data objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [[_data objectAtIndex:indexPath.row] objectForKey:@"email"];
    
    BOOL selected = FALSE;
    for (NSIndexPath* path in [tableView indexPathsForSelectedRows]) {
        if (path.row == indexPath.row) selected = TRUE;
    }
    cell.imageView.image = [UIImage imageNamed:(selected ? @"checkbox_checked.png" : @"checkbox_unchecked.png")];
    
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
    return @"Deine Freunde bei Doogetha";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    //tableViewCell.accessoryView.hidden = NO; 
    //tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    tableViewCell.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    //tableViewCell.accessoryView.hidden = YES;
    //tableViewCell.accessoryType = UITableViewCellAccessoryNone;
    tableViewCell.imageView.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
}

- (void)dismiss
{
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.toolbarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    NSMutableArray* selectedUsers = [[NSMutableArray alloc] init];
    for (NSIndexPath* i in [self.friendsTable indexPathsForSelectedRows])
        [selectedUsers addObject:[_data objectAtIndex:i.row]];
    [DGUtils app].currentUserSelection = selectedUsers;
    [self dismiss];
}

- (IBAction)cancel:(id)sender
{
    [DGUtils app].currentUserSelection = nil;
    [self dismiss]; 
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
    DGDoogethaFriends* dgfriends = [[DGUtils app] doogethaFriends];
    NSMutableDictionary* newUser = [[NSMutableDictionary alloc] init];
    [newUser setValue:self.checkingMail forKey:@"email"];
    [dgfriends addFriend:newUser];
    [dgfriends save];
    
    _data = [dgfriends friends];
    
    [self.friendsTable reloadData];
}

- (void)checkMail: (NSString*)mail
{
    self.checkingMail = mail;
    DGApp* app = [DGUtils app];
    app.webRequester.delegate = self;
    [app.webRequester get:[NSString stringWithFormat:@"%@users/%@",DOOGETHA_URL,[TLUtils bytesToHex:[TLUtils md5:mail]]] reqid:@"checkuser"];
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

- (IBAction)addManual:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Freund hinzufügen" message:@"Bitte gib die E-Mail-Adresse deines Freundes ein:" delegate:self cancelButtonTitle:@"Hinzufügen" otherButtonTitles:@"Abbrechen",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [alert show];
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

@end
