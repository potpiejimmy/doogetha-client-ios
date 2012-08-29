//
//  DGEventEditController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGEventEditBaseController.h"

@interface DGEventEditController : DGEventEditBaseController<UITableViewDelegate,UITableViewDataSource>
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *editTableView;

@end
