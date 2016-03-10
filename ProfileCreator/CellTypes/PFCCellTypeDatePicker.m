//
//  PFCCellTypeDatePicker.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCAvailability.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCDatePickerCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingDateDescription;

@end

@implementation PFCDatePickerCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCDatePickerCellView *)populateCellView:(PFCDatePickerCellView *)cellView
                                   manifest:(NSDictionary *)manifest
                                   settings:(NSDictionary *)settings
                              settingsLocal:(NSDictionary *)settingsLocal
                                displayKeys:(NSDictionary *)displayKeys
                                        row:(NSInteger)row
                                     sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if (settings[PFCSettingsKeyValue] != nil) {
        date = settings[PFCSettingsKeyValue] ?: [NSDate date];
    } else if (manifest[PFCManifestKeyDefaultValue]) {
        date = manifest[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:120];
    } else if (manifest[PFCManifestKeyIndentLevel] != nil) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@112];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:112];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];

    // ---------------------------------------------------------------------
    //  Set minimum value selectable by offset from now
    // ---------------------------------------------------------------------
    if (manifest[PFCManifestKeyMinValueOffsetDays] != nil || manifest[PFCManifestKeyMinValueOffsetHours] != nil || manifest[PFCManifestKeyMinValueOffsetMinutes] != nil) {

        NSInteger days = [manifest[PFCManifestKeyMinValueOffsetDays] integerValue] ?: 0;
        NSInteger hours = [manifest[PFCManifestKeyMinValueOffsetHours] integerValue] ?: 0;
        NSInteger minutes = [manifest[PFCManifestKeyMinValueOffsetMinutes] integerValue] ?: 0;

        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:days];
        [offsetComponents setHour:hours];
        [offsetComponents setMinute:minutes];
        NSDate *dateTomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        [[cellView settingDatePicker] setMinDate:dateTomorrow];
    }

    // ---------------------------------------------------------------------
    //  Set date picker elements
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyShowDateTime] boolValue]) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }

    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyShowDateInterval] boolValue]) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[PFCGeneralUtility dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }

    return cellView;
} // populateCellViewDatePicker

@end

@interface PFCDatePickerNoTitleCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;

@end

@implementation PFCDatePickerNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCDatePickerNoTitleCellView *)populateCellView:(PFCDatePickerNoTitleCellView *)cellView
                                          manifest:(NSDictionary *)manifest
                                          settings:(NSDictionary *)settings
                                     settingsLocal:(NSDictionary *)settingsLocal
                                       displayKeys:(NSDictionary *)displayKeys
                                               row:(NSInteger)row
                                            sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if (settings[PFCSettingsKeyValue] != nil) {
        date = settings[PFCSettingsKeyValue] ?: [NSDate date];
    } else if (manifest[PFCManifestKeyDefaultValue]) {
        date = manifest[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:120];
    } else if (manifest[PFCManifestKeyIndentLevel] != nil) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@112];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:112];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];

    // ---------------------------------------------------------------------
    //  Set minimum value selectable by offset from now
    // ---------------------------------------------------------------------
    if (manifest[PFCManifestKeyMinValueOffsetDays] != nil || manifest[PFCManifestKeyMinValueOffsetHours] != nil || manifest[PFCManifestKeyMinValueOffsetMinutes] != nil) {

        NSInteger days = [manifest[PFCManifestKeyMinValueOffsetDays] integerValue] ?: 0;
        NSInteger hours = [manifest[PFCManifestKeyMinValueOffsetHours] integerValue] ?: 0;
        NSInteger minutes = [manifest[PFCManifestKeyMinValueOffsetMinutes] integerValue] ?: 0;

        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:days];
        [offsetComponents setHour:hours];
        [offsetComponents setMinute:minutes];
        NSDate *dateTomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        [[cellView settingDatePicker] setMinDate:dateTomorrow];
    }

    // ---------------------------------------------------------------------
    //  Set date picker elements
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyShowDateTime] boolValue]) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }

    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyShowDateInterval] boolValue]) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[PFCGeneralUtility dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }

    return cellView;
} // populateCellViewCheckbox:settings:row

@end
