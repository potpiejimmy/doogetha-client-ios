//
//  DGDoogethaFriendsController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.09.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGDoogethaFriendsController : UITableViewController {
    @private NSArray* _data;
}
@property (strong, nonatomic) NSString* checkingMail;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addManual:(id)sender;

@end
