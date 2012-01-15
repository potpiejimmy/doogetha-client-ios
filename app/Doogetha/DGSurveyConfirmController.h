//
//  DGSurveyConfirmController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSurveyConfirmController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (strong, nonatomic) UILabel *surveyName;
@property (strong, nonatomic) UILabel *surveyDescription;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) NSDictionary *survey;
- (IBAction)confirm:(id)sender;

@end
