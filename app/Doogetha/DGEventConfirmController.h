//
//  DGEventConfirmController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGEventConfirmController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventDescription;
@property (weak, nonatomic) IBOutlet UITableView *surveyTable;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (strong, nonatomic) NSDictionary *event;

@end
