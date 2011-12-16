//
//  DGViewController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLWebRequest.h"

@interface DGMainController : UIViewController<UITableViewDelegate,UITableViewDataSource>

-(void)reload;

@property (weak, nonatomic) IBOutlet UITableView *eventsTable;
@property (weak, nonatomic) IBOutlet UITextField *resultTextfield;

@property (strong, nonatomic) NSArray *events;

@end
