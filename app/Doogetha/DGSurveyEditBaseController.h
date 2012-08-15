//
//  DGSurveyEditBaseController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 31.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSurveyEditBaseController : UIViewController {
    @protected BOOL _selectingDate;
    @protected BOOL _selectingTime;
    @protected BOOL _editingItem;
    @protected int _editingIndex;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)addButtonClicked:(id)sender;
- (void)startEditingAtIndex: (int)index;

- (void)handleItemAdded: (NSDictionary*)newItem;

@end
