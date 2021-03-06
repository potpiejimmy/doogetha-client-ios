//
//  DGDateTimeSelectController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGDateTimeSelectController : UIViewController

@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UIDatePicker* datePicker;
@property (strong, nonatomic) NSDate* selectedDate;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
