//
//  DGSurveyEditController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 29.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSurveyEditController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *description;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)backgroundTouched:(id)sender;

@end
