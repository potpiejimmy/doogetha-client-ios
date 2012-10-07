//
//  DGEventConfirmController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGCommentsPreviewerView.h"

@interface DGEventConfirmController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    @private BOOL _isEditing;
}

@property (weak, nonatomic) IBOutlet UITableView *surveyTable;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (strong, nonatomic) UILabel *eventName;
@property (strong, nonatomic) UILabel *eventDescription;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet DGCommentsPreviewerView *commentsPreviewer;

- (IBAction)confirm:(id)sender;
- (IBAction)decline:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)commentsPreviewerTouchDown:(id)sender;
- (IBAction)commentsPreviewerTouchUpInside:(id)sender;
- (IBAction)commentsPreviewerTouchUpOutside:(id)sender;

@end
