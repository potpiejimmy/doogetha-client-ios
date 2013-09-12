//
//  DGEventEditParticipantsController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface DGEventEditParticipantsController : UITableViewController<ABPeoplePickerNavigationControllerDelegate,UIGestureRecognizerDelegate>
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *participantsTable;
@property (strong, nonatomic) NSIndexPath* removingUser;

@end
