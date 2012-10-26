//
//  DGCommentsController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGPullRefreshTableViewController.h"

@interface DGCommentsController : DGPullRefreshTableViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *comments;
@property (weak, nonatomic) IBOutlet UITextView *commentTF;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;

- (IBAction)done:(id)sender;
- (IBAction)submit:(id)sender;

- (void)reload;

@end
