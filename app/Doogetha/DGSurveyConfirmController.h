//
//  DGSurveyConfirmController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSurveyConfirmController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *surveyName;
@property (weak, nonatomic) IBOutlet UILabel *surveyDescription;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView *confirmTable;

@property (strong, nonatomic) NSDictionary *survey;

@end
