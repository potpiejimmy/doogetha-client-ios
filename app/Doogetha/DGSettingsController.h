//
//  DGSettingsController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSettingsController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;

- (void)unregister;

@end
