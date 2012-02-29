//
//  DGEventEditDateTimeController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGEventEditDateTimeController : UIViewController

@property BOOL timeSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateTimeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
- (IBAction)datePickerValueChanged:(id)sender;
- (IBAction)timePickerValueChanged:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)saveDate:(id)sender;
- (IBAction)saveDateTime:(id)sender;
- (IBAction)saveNoTime:(id)sender;
- (IBAction)dateTimeSwitched:(id)sender;

@end
