//
//  DGEventEditSurveysController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGEventEditSurveysController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate> {
    @private BOOL _isEditingSurvey;
    @private int _editingIndex;
    @private int _deletingIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *surveysTable;
- (IBAction)save:(id)sender;

- (void)addSurvey;
- (void)addSurveyWithType: (int)type;

@end
