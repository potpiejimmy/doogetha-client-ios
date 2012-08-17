//
//  DGSurveyConfirmController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DGSurveyEditBaseController.h"

@interface DGSurveyConfirmController : DGSurveyEditBaseController {
    @private NSMutableDictionary* _closingWithItem;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (strong, nonatomic) UIScrollView* tableScroller;
@property (strong, nonatomic) UILabel *surveyName;
@property (strong, nonatomic) UILabel *surveyDescription;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *addButton;

- (IBAction)confirm:(id)sender;
- (void)closeSurveyWithItem:(NSMutableDictionary*)closeItem;

@end
