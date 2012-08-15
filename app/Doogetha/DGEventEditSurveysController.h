//
//  DGEventEditSurveysController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGEventEditSurveysController : UITableViewController {
    @private BOOL _isEditingSurvey;
    @private BOOL _isCreatingNewSurvey;
}
@property (weak, nonatomic) IBOutlet UITableView *surveysTable;
- (IBAction)save:(id)sender;

- (void)addSurvey;
- (void)addSurveyWithType: (int)type;

@end
