//
//  DGEventEditBasicsController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGEventEditBasicsController : UIViewController
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *description;
- (IBAction)backgroundTouched:(id)sender;

@end
