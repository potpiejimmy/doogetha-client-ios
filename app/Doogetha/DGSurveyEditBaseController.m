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

- (void)startEditingAtIndex: (int)index {
    _editingIndex = index;
    NSDictionary* survey = [DGUtils app].currentSurvey;
    int surveyType = [[survey objectForKey:@"type"] intValue];
    if (surveyType == 0)
    {
        /* generic surveys */
        UIAlertView * alert = (index < 0) ? 
            [[UIAlertView alloc] initWithTitle:@"Auswahl hinzufügen" message:@"Bitte gib eine neue Auswahlmöglichkeit ein:" delegate:self cancelButtonTitle:@"Hinzufügen" otherButtonTitles:@"Abbrechen",nil] :
            [[UIAlertView alloc] initWithTitle:@"Auswahl bearbeiten" message:@"Bitte bearbeite die Auswahlmöglichkeit:" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Abbrechen",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        if (index >= 0)
            [alert textFieldAtIndex:0].text = [[[survey objectForKey:@"surveyItems"] objectAtIndex:index] objectForKey:@"name"];
        _editingItem = YES;
        [alert show];
    }
    else
    {
        /* date time surveys */
        _selectingDate = YES;
        [[DGUtils app].dateTimeSelector.datePicker setDatePickerMode:UIDatePickerModeDate];
        if (index >= 0) {
            long long ts = [[[[NSNumberFormatter alloc] init] numberFromString:[[[survey objectForKey:@"surveyItems"] objectAtIndex:index] objectForKey:@"name"]] longLongValue];
            [DGUtils app].dateTimeSelector.datePicker.date = [NSDate dateWithTimeIntervalSince1970:ts/1000];
        }
        [self.navigationController pushViewController:[DGUtils app].dateTimeSelector animated:NO];
    }
}

- (void)addButtonClicked:(id)sender
{
    [self startEditingAtIndex:-1]; /* new item, set index -1 */
}

- (void)handleItemAdded: (NSDictionary*)newItem;
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
            NSMutableArray* currentItems = [survey objectForKey:@"surveyItems"];
            NSMutableDictionary* item;
            if (_editingIndex < 0) {
                /* create a new item and add it */
                item = [[NSMutableDictionary alloc] init];
                [currentItems addObject:item];
            } else {
                /* item edited */
                item = [currentItems objectAtIndex:_editingIndex];
            }
            [item setValue:newItemText forKey:@"name"];
            [self handleItemAdded:item];  
        } else {
            [DGUtils alert:@"Diese Auswahlmöglichkeit existiert bereits."];
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
