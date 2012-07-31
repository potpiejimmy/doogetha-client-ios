//
//  DGSurveyEditBaseController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 31.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGSurveyEditBaseController.h"

#import "DGUtils.h"
#import "TLUtils.h"

@implementation DGSurveyEditBaseController

- (void)addButtonClicked:(id)sender
{
    NSDictionary* survey = [DGUtils app].currentSurvey;
    int surveyType = [[survey objectForKey:@"type"] intValue];
    if (surveyType == 0)
    {
        /* generic surveys */
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Auswahl hinzufügen" message:@"Bitte gib eine neue Auswahlmöglichkeit ein:" delegate:self cancelButtonTitle:@"Hinzufügen" otherButtonTitles:@"Abbrechen",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        _editingItem = YES;
        [alert show];
    }
    else
    {
        /* date time surveys */
        _selectingDate = YES;
        [[DGUtils app].dateTimeSelector.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.navigationController pushViewController:[DGUtils app].dateTimeSelector animated:NO];
    }
}

- (void)handleItemAdded: (NSString*)newItemText;
{
    /* overridden by subclasses DGSurveyEditController or DGSurveyConfirmController */
}

- (void)doAddItem: (NSString*) newItemText
{
    NSLog(@"Entered: %@",newItemText);
    
    if ([newItemText length]>0)
    {
        NSDictionary* survey = [DGUtils app].currentSurvey;
        
        BOOL alreadyExists = false;
        for (NSDictionary* item in [survey objectForKey:@"surveyItems"])
        {
            if ([[item objectForKey:@"name"] isEqualToString:newItemText]) {
                alreadyExists = true;
                break;
            }
        }
        if (!alreadyExists) {
            NSMutableDictionary* newItem = [[NSMutableDictionary alloc] init];
            [newItem setValue:newItemText forKey:@"name"];
            NSMutableArray* currentItems = [survey objectForKey:@"surveyItems"];
            [currentItems addObject:newItem];
            [self handleItemAdded:newItem];  
        }
    }
}

- (void)handleDateTimeSelection
{
    NSDate* selectedDate = [[DGUtils app] dateTimeSelector].selectedDate;
    if (selectedDate) {
        long long ts = selectedDate.timeIntervalSince1970*1000;
        [self doAddItem:[NSString stringWithFormat:@"%llu", ts]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectingDate = NO;
    _selectingTime = NO;
    _editingItem = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_selectingDate)
    {
        /* user just returned from entering a date */
        int surveyType = [[[DGUtils app].currentSurvey objectForKey:@"type"] intValue];
        if (surveyType == 2) /* date and time: start selecting time now */
        {
            /* date time surveys */
            if ([[DGUtils app] dateTimeSelector].selectedDate) /* if not cancelled */
            {
                _selectingTime = YES;
                [[DGUtils app].dateTimeSelector.datePicker setDatePickerMode:UIDatePickerModeTime];
                [self.navigationController pushViewController:[DGUtils app].dateTimeSelector animated:NO];
            }
        }
        else
        {
            [self handleDateTimeSelection];
        }
        _selectingDate = NO;
    }
    else if (_selectingTime)
    {
        /* user just returned from entering a time */
        [self handleDateTimeSelection];
        _selectingTime = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _editingItem = NO;
    if (buttonIndex == 0) /* clicked OK */
    {
        NSString* newItemText = [TLUtils trim:[[alertView textFieldAtIndex:0] text]];
        [self doAddItem:newItemText];
    }
}

@end
