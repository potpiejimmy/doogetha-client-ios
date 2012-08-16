//
//  DGSurveyEditController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGSurveyEditBaseController.h"

@interface DGSurveyEditController : DGSurveyEditBaseController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate> {
    @private int _deletingItemIndex;
}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UITableView *surveyItemsTable;
@property (weak, nonatomic) IBOutlet UISwitch *surveyMode;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)addItem:(id)sender;

@end
