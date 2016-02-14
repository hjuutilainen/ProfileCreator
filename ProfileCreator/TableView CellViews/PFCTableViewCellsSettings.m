//
//  PFCTableViewCellsSettings.m
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

#import "PFCTableViewCellsSettings.h"
#import "PFCProfileEditor.h"
#import "PFCTableViewCellsSettingsTableView.h"
#import "PFCFileInfoProcessors.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCLog.h"
#import "NSColor+PFCColors.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsCheckbox *)populateCellViewSettingsCheckbox:(CellViewSettingsCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[PFCManifestKeyTitle] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[PFCSettingsKeyValue] != nil ) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if ( manifest[PFCManifestKeyDefaultValue] ) {
        checkboxState = [manifest[PFCManifestKeyDefaultValue] boolValue];
    } else if ( settingsLocal[PFCSettingsKeyValue] ) {
        checkboxState = [settingsLocal[PFCSettingsKeyValue] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsCheckbox:manifest:settings:settingsLocal:row:sender

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckboxNoDescription
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsCheckboxNoDescription

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsCheckboxNoDescription *)populateCellViewSettingsCheckboxNoDescription:(CellViewSettingsCheckboxNoDescription *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[PFCManifestKeyTitle] ?: @""];
    
    // ---------------------------------------------------------------------
    //  FontWeight of the Title
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyFontWeight] isEqualToString:PFCFontWeightBold] ) {
        [[cellView settingCheckbox] setFont:[NSFont boldSystemFontOfSize:13]];
    } else {
        [[cellView settingCheckbox] setFont:[NSFont systemFontOfSize:13]];
    }
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[PFCSettingsKeyValue] != nil ) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if ( manifest[PFCManifestKeyDefaultValue] ) {
        checkboxState = [manifest[PFCManifestKeyDefaultValue] boolValue];
    } else if ( settingsLocal[PFCSettingsKeyValue] ) {
        checkboxState = [settingsLocal[PFCSettingsKeyValue] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsCheckboxNoDescription:manifest:settings:settingsLocal:row:sender

@end



// REVIEWING


////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsDatePicker
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsDatePicker

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsDatePicker *)populateCellViewDatePicker:(CellViewSettingsDatePicker *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
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
    if ( settings[PFCSettingsKeyValue] != nil ) {
        date = settings[PFCSettingsKeyValue] ?: [NSDate date];
    } else if ( manifest[PFCManifestKeyDefaultValue] ) {
        date = manifest[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if ( settingsLocal[PFCSettingsKeyValue] ) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:120];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
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
    if (
        manifest[PFCManifestKeyMinValueOffsetDays] != nil ||
        manifest[PFCManifestKeyMinValueOffsetHours] != nil ||
        manifest[PFCManifestKeyMinValueOffsetMinutes] != nil) {
        
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
    if ( [manifest[PFCManifestKeyShowDateTime] boolValue] ) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }
    
    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyShowDateInterval] boolValue] ) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[(PFCProfileEditor *)sender dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }
    
    return cellView;
} // populateCellViewDatePicker

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsDatePickerNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsDatePickerNoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if ( settings[PFCSettingsKeyValue] != nil ) {
        date = settings[PFCSettingsKeyValue] ?: [NSDate date];
    } else if ( manifest[PFCManifestKeyDefaultValue] ) {
        date = manifest[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if ( settingsLocal[PFCSettingsKeyValue] ) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:120];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
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
    if (
        manifest[PFCManifestKeyMinValueOffsetDays] != nil ||
        manifest[PFCManifestKeyMinValueOffsetHours] != nil ||
        manifest[PFCManifestKeyMinValueOffsetMinutes] != nil) {
        
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
    if ( [manifest[PFCManifestKeyShowDateTime] boolValue] ) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }
    
    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyShowDateInterval] boolValue] ) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[(PFCProfileEditor *)sender dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }
    
    return cellView;
} // populateCellViewCheckbox:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsEnabled

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = NO;
    if ( manifest[PFCManifestKeyRequired] != nil ) {
        required = [manifest[PFCManifestKeyRequired] boolValue];
    } else if ( manifest[PFCManifestKeyRequiredHost] != nil ) {
        required = [manifest[PFCManifestKeyRequiredHost] boolValue];
    } else if ( manifest[PFCManifestKeyRequiredPort] != nil ) {
        required = [manifest[PFCManifestKeyRequiredPort] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setAction:@selector(checkbox:)];
    [[cellView settingEnabled] setTarget:sender];
    [[cellView settingEnabled] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:required];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:enabled];
    
    return cellView;
} // populateCellViewEnabled:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsFile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsFile

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setInfoForFileAtURL:(NSURL *)fileURL withFileInfoProcessor:(NSString *)fileInfoProcessor {
    
    if ( ! _fileInfoProcessor ) {
        [self setFileInfoProcessor:[PFCFileInfoProcessors fileInfoProcessorWithName:fileInfoProcessor fileURL:fileURL]];
    } else {
        [_fileInfoProcessor setFileURL:fileURL];
    }
    
    // ---------------------------------------------------------------------
    //  Retrieve file info from the processor
    // ---------------------------------------------------------------------
    NSDictionary *fileInfo = [_fileInfoProcessor fileInfo];
    if ( [fileInfo count] != 0 ) {
        [_settingFileTitle setStringValue:fileInfo[PFCFileInfoTitle] ?: [fileURL lastPathComponent]];
        
        if ( fileInfo[PFCFileInfoDescription1] != nil ) {
            [_settingFileDescriptionLabel1 setStringValue:fileInfo[PFCFileInfoLabel1] ?: @""];
            [_settingFileDescription1 setStringValue:fileInfo[PFCFileInfoDescription1] ?: @""];
            
            [_settingFileDescriptionLabel1 setHidden:NO];
            [_settingFileDescription1 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel1 setHidden:YES];
            [_settingFileDescription1 setHidden:YES];
        }
        
        if ( fileInfo[PFCFileInfoDescription2] != nil ) {
            [_settingFileDescriptionLabel2 setStringValue:fileInfo[PFCFileInfoLabel2] ?: @""];
            [_settingFileDescription2 setStringValue:fileInfo[PFCFileInfoDescription2] ?: @""];
            
            [_settingFileDescriptionLabel2 setHidden:NO];
            [_settingFileDescription2 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel2 setHidden:YES];
            [_settingFileDescription2 setHidden:YES];
        }
        
        if ( fileInfo[PFCFileInfoDescription3] != nil ) {
            [_settingFileDescriptionLabel3 setStringValue:fileInfo[PFCFileInfoLabel3] ?: @""];
            [_settingFileDescription3 setStringValue:fileInfo[PFCFileInfoDescription3] ?: @""];
            
            [_settingFileDescriptionLabel3 setHidden:NO];
            [_settingFileDescription3 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel3 setHidden:YES];
            [_settingFileDescription3 setHidden:YES];
        }
    }
    
}

- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Button Title
    // ---------------------------------------------------------------------
    NSString *buttonTitle = manifest[PFCManifestKeyButtonTitle] ?: @"Add File...";
    [[cellView settingButtonAdd] setTitle:buttonTitle ?: @"Add File..."];
    [[cellView settingButtonAdd] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Button Action
    // ---------------------------------------------------------------------
    [[cellView settingButtonAdd] setAction:@selector(selectFile:)];
    [[cellView settingButtonAdd] setTarget:sender];
    [[cellView settingButtonAdd] setTag:row];
    
    // ---------------------------------------------------------------------
    //  File View Prompt Message
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setStringValue:manifest[PFCManifestKeyFilePrompt] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Add Border to file view
    // ---------------------------------------------------------------------
    [[cellView settingFileView] setWantsLayer:YES];
    [[[cellView settingFileView] layer] setMasksToBounds:YES];
    [[[cellView settingFileView] layer] setBorderWidth:0.5f];
    [[[cellView settingFileView] layer] setBorderColor:[[NSColor grayColor] CGColor]];
    
    // ---------------------------------------------------------------------
    //  Show prompt if no file is selected
    // ---------------------------------------------------------------------
    if ( [settings[PFCSettingsKeyFilePath] length] == 0 ) {
        [[cellView settingFileViewPrompt] setHidden:NO];
        [[cellView settingFileIcon] setHidden:YES];
        [[cellView settingFileTitle] setHidden:YES];
        [[cellView settingFileDescriptionLabel1] setHidden:YES];
        [[cellView settingFileDescription1] setHidden:YES];
        [[cellView settingFileDescriptionLabel2] setHidden:YES];
        [[cellView settingFileDescription2] setHidden:YES];
        [[cellView settingFileDescriptionLabel3] setHidden:YES];
        [[cellView settingFileDescription3] setHidden:YES];
        return cellView;
    }
    
    // ---------------------------------------------------------------------
    //  Check that file exist
    // ---------------------------------------------------------------------
    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:settings[PFCSettingsKeyFilePath]];
    if ( ! [fileURL checkResourceIsReachableAndReturnError:&error] ) {
        DDLogError(@"%@", [error localizedDescription]);
    }
    
    // ---------------------------------------------------------------------
    //  File Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[fileURL path]];
    if ( icon ) {
        [[cellView settingFileIcon] setImage:icon];
    }
    
    // ---------------------------------------------------------------------
    //  File Info
    // ---------------------------------------------------------------------
    if ( [fileURL checkResourceIsReachableAndReturnError:nil] ) {
        [self setInfoForFileAtURL:fileURL withFileInfoProcessor:manifest[PFCManifestKeyFileInfoProcessor]];
    }
    
    // ---------------------------------------------------------------------
    //  Show file info
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setHidden:YES];
    [[cellView settingFileIcon] setHidden:NO];
    [[cellView settingFileTitle] setHidden:NO];
    
    return cellView;
} // populateCellViewSettingsFile:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPadding
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPadding
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpButton
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUpButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUpButton *)populateCellViewPopUpButton:(CellViewSettingsPopUpButton *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
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
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewPopUpButton:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpButtonLeft
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUpButtonLeft

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUpButtonLeft *)populateCellViewSettingsPopUpButtonLeft:(CellViewSettingsPopUpButtonLeft *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
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
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewPopUpButtonLeft:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpButtonNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUpButtonNoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUpButtonNoTitle *)populateCellViewSettingsPopUpButtonNoTitle:(CellViewSettingsPopUpButtonNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsPopUpButtonNoTitle:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsSegmentedControl
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsSegmentedControl

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView manifest:(NSDictionary *)manifest row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Reset Segmented Control
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSegmentCount:0];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = manifest[PFCManifestKeyAvailableValues] ?: @[];
    [[cellView settingSegmentedControl] setSegmentCount:[availableSelections count]];
    [availableSelections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[cellView settingSegmentedControl] setLabel:obj forSegment:idx];
    }];
    
    // ---------------------------------------------------------------------
    //  Select saved selection or 0 if never saved
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSelected:YES forSegment:[manifest[PFCSettingsKeyValue] integerValue] ?: 0];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setAction:@selector(segmentedControl:)];
    [[cellView settingSegmentedControl] setTarget:sender];
    [[cellView settingSegmentedControl] setTag:row];
    
    return cellView;
} // populateCellViewSettingsSegmentedControl:manifest:row:sender

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (void)controlTextDidChange:(NSNotification *)sender {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a text field
    // ---------------------------------------------------------------------
    if ( ! [[[sender object] class] isSubclassOfClass:[NSTextField class]] ) {
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get text field's row in the table view
    // ---------------------------------------------------------------------
    NSTextField *textField = [sender object];
    NSNumber *textFieldTag = @([textField tag]);
    if ( textFieldTag == nil ) {
        DDLogError(@"TextField: %@ has no tag", textFieldTag);
        return;
    }
    NSInteger row = [textFieldTag integerValue];
    
    NSString *columnIdentifier = [(CellViewTextField *)[textField superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Get current text and current cell dict
    // ---------------------------------------------------------------------
    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
    NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:row] mutableCopy];
    
    // ---------------------------------------------------------------------
    //  Another verification of text field type
    // ---------------------------------------------------------------------
    if ( [[[textField superview] class] isSubclassOfClass:[CellViewTextField class]] ) {
        if ( textField == [[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] textField] ) {
            NSMutableDictionary *columnDict = cellDict[columnIdentifier];
            columnDict[PFCSettingsKeyValue] = [inputText copy];
            cellDict[columnIdentifier] = columnDict;
        } else {
            return;
        }
        
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
    }
} // controlTextDidChange

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tableViewContent count];
} // numberOfRowsInTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Verify the table view content array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if ( [_tableViewContent count] < row || [_tableViewContent count] == 0 ) {
        return nil;
    }
    
    NSDictionary *settings = _tableViewContent[(NSUInteger)row];
    NSString *tableColumnIdentifier = [tableColumn identifier];
    NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnIdentifier];
    NSString *cellType = tableColumnCellViewDict[@"CellType"];
    
    if ( [cellType isEqualToString:@"TextField"] ) {
        CellViewTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewTextField" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewTextField:cellView settings:settings[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        CellViewPopUpButton *cellView = [tableView makeViewWithIdentifier:@"CellViewPopUpButton" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewPopUpButton:cellView settings:settings[tableColumnIdentifier]  columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        CellViewCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewCheckbox" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewCheckbox:cellView settings:settings[tableColumnIdentifier]  columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        CellViewTextFieldNumber *cellView = [tableView makeViewWithIdentifier:@"CellViewTextFieldNumber" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewTextFieldNumber:cellView settings:settings[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
    }
    
    return nil;
} // tableView:viewForTableColumn:row

- (NSInteger)insertRowInTableView:(NSDictionary *)rowDict {
    NSInteger index = [_settingTableView selectedRow];
    index++;
    [_settingTableView beginUpdates];
    [_settingTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationSlideDown];
    [_settingTableView scrollRowToVisible:index];
    [_tableViewContent insertObject:rowDict atIndex:(NSUInteger)index];
    [_settingTableView endUpdates];
    return index;
} // insertRowInTableView

- (void)updateTableViewSavedContent {
    if ( _sender && [_senderIdentifier length] != 0 ) {
        NSMutableDictionary *settings = [[(PFCProfileEditor *)_sender settingsManifest][_senderIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        settings[PFCSettingsKeyTableViewContent] = [_tableViewContent copy];
        [(PFCProfileEditor *)_sender settingsManifest][_senderIdentifier] = [settings mutableCopy];
    }
} // updateTableViewSavedContent

- (IBAction)segmentedControlButton:(id)sender {
    switch ( [sender selectedSegment] ) {
        case 0:
            [self buttonAdd];
            break;
            
        case 1:
            [self buttonRemove];
            break;
        default:
            break;
    }
} // segmentedControlButton

- (void)buttonAdd {
    
    if ( ! _tableViewContent ) {
        _tableViewContent = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *newRowDict = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnKeys = [_tableViewColumnCellViews allKeys];
    for ( NSString *tableColumnKey in tableColumnKeys ) {
        NSMutableDictionary *tableColumnDict = [[NSMutableDictionary alloc] init];
        NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnKey];
        NSString *cellType = tableColumnCellViewDict[@"CellType"];
        
        if ( [cellType isEqualToString:@"TextField"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
        } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
            tableColumnDict[@"AvailableValues"] = tableColumnCellViewDict[@"AvailableValues"] ?: @[];
        }
        newRowDict[tableColumnKey] = tableColumnDict;
    }
    
    [self insertRowInTableView:[newRowDict copy]];
    [self updateTableViewSavedContent];
} // buttonAdd

- (void)buttonRemove {
    NSIndexSet *indexes = [_settingTableView selectedRowIndexes];
    [_tableViewContent removeObjectsAtIndexes:indexes];
    [_settingTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
    [self updateTableViewSavedContent];
} // buttonRemove

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // ---------------------------------------------------------------------
    if ( ! [[[popUpButton superview] class] isSubclassOfClass:[CellViewPopUpButton class]] ) {
        DDLogError(@"PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get popup button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *popUpButtonTag = @([popUpButton tag]);
    if ( popUpButtonTag == nil ) {
        DDLogError(@"PopUpButton: %@ has no tag", popUpButton);
        return;
    }
    NSInteger row = [popUpButtonTag integerValue];
    
    NSString *columnIdentifier = [(CellViewPopUpButton *)[popUpButton superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if ( popUpButton == [(CellViewPopUpButton *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] popUpButton] ) {
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSString *selectedTitle = [popUpButton titleOfSelectedItem];
        NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = selectedTitle;
        cellDict[columnIdentifier] = columnDict;
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [_settingTableView beginUpdates];
        [_settingTableView reloadData];
        [_settingTableView endUpdates];
    }
} // popUpButtonSelection

- (void)checkbox:(NSButton *)checkbox {
    
    // ---------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        DDLogError(@"Checkbox: %@ has no tag", checkbox);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    NSString *columnIdentifier = [(CellViewCheckbox *)[checkbox superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if ( checkbox == [(CellViewCheckbox *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] checkbox] ) {
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        BOOL state = [checkbox state];
        NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = @(state);
        cellDict[columnIdentifier] = columnDict;
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [_settingTableView beginUpdates];
        [_settingTableView reloadData];
        [_settingTableView endUpdates];
    }
} // checkbox


- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal sender:(id)sender {
    
    // -------------------------------------------------------------------------
    //  Set sender and sender properties to be used later
    // -------------------------------------------------------------------------
    [self setSender:sender];
    [self setSenderIdentifier:manifest[PFCManifestKeyIdentifier] ?: @""];
    
    // -------------------------------------------------------------------------
    //  Set TableColumn DataSource and Delegate to self
    // -------------------------------------------------------------------------
    [[cellView settingTableView] setDataSource:self];
    [[cellView settingTableView] setDelegate:self];
    
    // -------------------------------------------------------------------------
    //  Initialize the TableView content from settings
    // -------------------------------------------------------------------------
    if ( ! _tableViewContent ) {
        if ( [settings[PFCSettingsKeyTableViewContent] count] != 0 ) {
            _tableViewContent = [settings[PFCSettingsKeyTableViewContent] mutableCopy] ?: [[NSMutableArray alloc] init];
        } else {
            _tableViewContent = [settingsLocal[PFCSettingsKeyTableViewContent] mutableCopy] ?: [[NSMutableArray alloc] init];
        }
    }
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // -------------------------------------------------------------------------
    //  Add columns from manifest
    // -------------------------------------------------------------------------
    
    // Remove the current columns if there are any
    for ( NSTableColumn *tableColumn in [[[cellView settingTableView] tableColumns] copy] ) {
        [[cellView settingTableView] removeTableColumn:tableColumn];
    }
    
    // Add columns from manifest
    NSMutableDictionary *tableColumnsCellViews = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnsArray = manifest[PFCManifestKeyTableViewColumns] ?: @[];
    for ( NSDictionary *tableColumnDict in tableColumnsArray ) {
        NSString *tableColumnTitle = tableColumnDict[PFCManifestKeyTableViewColumnTitle] ?: @"";
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:tableColumnTitle];
        [tableColumn setTitle:tableColumnTitle];
        [[cellView settingTableView] addTableColumn:tableColumn];
        tableColumnsCellViews[tableColumnTitle] = tableColumnDict;
    }
    [self setTableViewColumnCellViews:[tableColumnsCellViews copy]];
    
    // ---------------------------------------------------------------------
    //  If only one column, remove header view
    // ---------------------------------------------------------------------
    if ( [tableColumnsArray count] <= 1 ) {
        [[cellView settingTableView] setHeaderView:nil];
    } else {
        [[cellView settingTableView] setHeaderView:[[NSTableHeaderView alloc] init]];
    }
    
    // ---------------------------------------------------------------------
    //  Update table view content
    // ---------------------------------------------------------------------
    [[cellView settingTableView] beginUpdates];
    [[cellView settingTableView] sizeToFit];
    [[cellView settingTableView] reloadData];
    [[cellView settingTableView] endUpdates];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTableView] setEnabled:enabled];
    [[cellView settingSegmentedControlButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if ( [value length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
            value = manifest[PFCManifestKeyDefaultValue] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @""
                                                              attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    
    if ( [valueAttributed length] != 0 ) {
        [[cellView settingTextField] setAttributedStringValue:valueAttributed];
    } else {
        [[cellView settingTextField] setStringValue:value];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValue] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ( required && [value length] == 0 ) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }
    
    return cellView;
} // populateCellViewTextField:settings:row

- (void)showRequired:(BOOL)show {
    if ( show ) {
        [_constraintTextFieldTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTextFieldCheckbox *)populateCellViewSettingsTextFieldCheckbox:(CellViewSettingsTextFieldCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[PFCManifestKeyTitle] ?: @""];
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  ValueCheckbox
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[PFCSettingsKeyValueCheckbox] != nil ) {
        checkboxState = [settings[PFCSettingsKeyValueCheckbox] boolValue];
    } else if ( manifest[PFCManifestKeyDefaultValueCheckbox] ) {
        checkboxState = [manifest[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if ( settingsLocal[PFCSettingsKeyValueCheckbox] ) {
        checkboxState = [settingsLocal[PFCSettingsKeyValueCheckbox] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];
    
    // ---------------------------------------------------------------------
    //  ValueTextField
    // ---------------------------------------------------------------------
    NSString *valueTextField;
    NSAttributedString *valueTextFieldAttributed = nil;
    if ( [settings[PFCSettingsKeyValueTextField] length] != 0 ) {
        valueTextField = settings[PFCSettingsKeyValueTextField];
    } else if ( [manifest[PFCManifestKeyDefaultValueTextField] length] != 0 ) {
        valueTextField = manifest[PFCManifestKeyDefaultValueTextField];
    } else if ( [settingsLocal[PFCSettingsKeyValueTextField] length] != 0 ) {
        valueTextFieldAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueTextField] ?: @""
                                                          attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
    }
    
    if ( [valueTextFieldAttributed length] != 0 ) {
        [[cellView settingTextField] setAttributedStringValue:valueTextFieldAttributed];
    } else {
        [[cellView settingTextField] setStringValue:valueTextField ?: @""];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    
    // ---------------------------------------------------------------------
    //  Placeholder Value TextField
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValueTextField] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueTextField] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextField] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:@"value" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ( required && [valueTextField length] == 0 ) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

- (void)showRequired:(BOOL)show {
    if ( show ) {
        [_constraintTextFieldPortTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldPortTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldDaysHoursNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldDaysHoursNoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addObserver:self forKeyPath:@"stepperValueRemovalIntervalDays" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"stepperValueRemovalIntervalHours" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
} // initWithCoder

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"stepperValueRemovalIntervalDays"];
    [self removeObserver:self forKeyPath:@"stepperValueRemovalIntervalHours"];
} // dealloc

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id) __unused object change:(NSDictionary *) __unused change context:(void *) __unused context {
    if ( ( _sender != nil && [_cellIdentifier length] != 0 ) && ( [keyPath isEqualToString:@"stepperValueRemovalIntervalDays"] || [keyPath isEqualToString:@"stepperValueRemovalIntervalHours"] )) {
        int seconds = ( ( [_stepperValueRemovalIntervalDays intValue] * 86400 ) + ( [_stepperValueRemovalIntervalHours intValue] * 60 ) );
        NSMutableDictionary *settingsDict = [[(PFCProfileEditor *)_sender settingsManifest] mutableCopy];
        if ( seconds == 0 ) {
            [settingsDict removeObjectForKey:_cellIdentifier];
        } else {
            NSMutableDictionary *cellDict = [settingsDict[_cellIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            cellDict[PFCSettingsKeyValue] = @(seconds);
            settingsDict[_cellIdentifier] = cellDict;
        }
        [(PFCProfileEditor *)_sender setSettingsManifest:settingsDict];
    }
} // observeValueForKeyPath

- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // -------------------------------------------------------------------------
    //  Set sender and sender properties to be used later
    // -------------------------------------------------------------------------
    [self setSender:sender];
    [self setCellIdentifier:manifest[PFCManifestKeyIdentifier] ?: @""];
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Initialize text fields from settings
    // -------------------------------------------------------------------------
    if ( _stepperValueRemovalIntervalHours == nil || _stepperValueRemovalIntervalHours == nil ) {
        NSNumber *seconds;
        if ( settings[PFCSettingsKeyValue] != nil ) {
            seconds = settings[PFCSettingsKeyValue] ?: @0;
        } else {
            seconds = settingsLocal[PFCSettingsKeyValue] ?: @0;
        }
        
        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier: @"en_US"]];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour;
        
        NSDate *startDate = [NSDate date];
        NSDate *endDate = [startDate dateByAddingTimeInterval:[seconds doubleValue]];
        
        NSDateComponents *components = [calendarUS components:unitFlags fromDate:startDate toDate:endDate options:0];
        [self setStepperValueRemovalIntervalDays:@([components day]) ?: @0];
        [self setStepperValueRemovalIntervalHours:@([components hour]) ?: @0];
    }
    
    // ---------------------------------------------------------------------
    //  Days
    // ---------------------------------------------------------------------
    [[cellView settingDays] setEnabled:enabled];
    [[cellView settingDays] setTag:row];
    [[cellView settingDays] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalDays" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepperDays] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalDays" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Hours
    // ---------------------------------------------------------------------
    [[cellView settingHours] setEnabled:enabled];
    [[cellView settingHours] setTag:row];
    [[cellView settingHours] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalHours" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepperHours] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalHours" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldHostPort
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldHostPort

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTextFieldHostPort *)populateCellViewSettingsTextFieldHostPort:(CellViewSettingsTextFieldHostPort *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL requiredHost;
    if ( manifest[PFCManifestKeyRequiredHost] != nil ) {
        requiredHost = [manifest[PFCManifestKeyRequiredHost] boolValue];
    } else {
        requiredHost = [manifest[PFCManifestKeyRequired] boolValue];
    }
    
    BOOL requiredPort;
    if ( manifest[PFCManifestKeyRequiredPort] != nil ) {
        requiredPort = [manifest[PFCManifestKeyRequiredPort] boolValue];
    } else {
        requiredPort = [manifest[PFCManifestKeyRequired] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ( ! requiredHost || ! requiredPort ) && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settings[PFCSettingsKeyValueHost] ?: @"";
    NSAttributedString *valueHostAttributed = nil;
    if ( [valueHost length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValueHost] length] != 0 ) {
            valueHost = manifest[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValueHost] length] != 0 ) {
            valueHostAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @""
                                                              attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    if ( [valueHostAttributed length] != 0 ) {
        [[cellView settingTextFieldHost] setAttributedStringValue:valueHostAttributed];
    } else {
        [[cellView settingTextFieldHost] setStringValue:valueHost];
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValueHost] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueHost] ?: @""];
    } else if ( requiredHost ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settings[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valuePortAttributed = nil;
    if ( [valuePort length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValuePort] length] != 0 ) {
            valuePort = manifest[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValuePort] length] != 0 ) {
            valuePortAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @""
                                                              attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    
    if ( [valuePortAttributed length] != 0 ) {
        [[cellView settingTextFieldPort] setAttributedStringValue:valuePortAttributed];
    } else {
        [[cellView settingTextFieldPort] setStringValue:valuePort];
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValuePort] length] != 0 ) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValuePort] ?: @""];
    } else if ( requiredPort ) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else if ( optional ) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Opt"];
    } else {
        [[cellView settingTextFieldPort] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextFieldHost] setEnabled:enabled];
    [[cellView settingTextFieldPort] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ( requiredHost && [valueHost length] == 0 ) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

- (void)showRequired:(BOOL)show {
    if ( show ) {
        [_constraintTextFieldPortTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldPortTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldHostPortCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldHostPortCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTextFieldHostPortCheckbox *)populateCellViewSettingsTextFieldHostPortCheckbox:(CellViewSettingsTextFieldHostPortCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL requiredHost;
    if ( manifest[PFCManifestKeyRequiredHost] != nil ) {
        requiredHost = [manifest[PFCManifestKeyRequiredHost] boolValue];
    } else {
        requiredHost = [manifest[PFCManifestKeyRequired] boolValue];
    }
    
    BOOL requiredPort;
    if ( manifest[PFCManifestKeyRequiredPort] != nil ) {
        requiredPort = [manifest[PFCManifestKeyRequiredPort] boolValue];
    } else {
        requiredPort = [manifest[PFCManifestKeyRequired] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ( ! requiredHost || ! requiredPort ) && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[PFCManifestKeyTitle] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Checkbox
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[PFCSettingsKeyValueCheckbox] != nil ) {
        checkboxState = [settings[PFCSettingsKeyValueCheckbox] boolValue];
    } else if ( manifest[PFCManifestKeyDefaultValueCheckbox] ) {
        checkboxState = [manifest[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if ( settingsLocal[PFCSettingsKeyValueCheckbox] ) {
        checkboxState = [settingsLocal[PFCSettingsKeyValueCheckbox] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];
    
    // ---------------------------------------------------------------------
    //  Target Action Checkbox
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settings[PFCSettingsKeyValueHost] ?: @"";
    NSAttributedString *valueHostAttributed = nil;
    if ( [valueHost length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValueHost] length] != 0 ) {
            valueHost = manifest[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValueHost] length] != 0 ) {
            valueHostAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @""
                                                              attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    
    if ( [valueHostAttributed length] != 0 ) {
        [[cellView settingTextFieldHost] setAttributedStringValue:valueHostAttributed];
    } else {
        [[cellView settingTextFieldHost] setStringValue:valueHost];
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value Host
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValueHost] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueHost] ?: @""];
    } else if ( requiredHost ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settings[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valuePortAttributed = nil;
    if ( [valuePort length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValuePort] length] != 0 ) {
            valuePort = manifest[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValuePort] length] != 0 ) {
            valuePortAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @""
                                                                  attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    
    if ( [valueHostAttributed length] != 0 ) {
        [[cellView settingTextFieldPort] setAttributedStringValue:valuePortAttributed];
    } else {
        [[cellView settingTextFieldPort] setStringValue:valuePort];
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValuePort] length] != 0 ) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValuePort] ?: @""];
    } else if ( requiredPort ) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else if ( optional ) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Opt"];
    } else {
        [[cellView settingTextFieldPort] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField's 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextFieldHost] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingTextFieldPort] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:@"value" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    [[cellView settingTextFieldHost] setEnabled:enabled];
    [[cellView settingTextFieldPort] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ( requiredHost && [valueHost length] == 0 ) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

- (void)showRequired:(BOOL)show {
    if ( show ) {
        [_constraintTextFieldPortTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldPortTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldNoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if ( [value length] == 0 ) {
        if ( [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
            value = manifest[PFCManifestKeyDefaultValue] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @""
                                                              attributes:@{ NSForegroundColorAttributeName : [NSColor localSettingsColor] }];
        }
    }
    
    if ( [valueAttributed length] != 0 ) {
        [[cellView settingTextField] setAttributedStringValue:valueAttributed];
    } else {
        [[cellView settingTextField] setStringValue:value];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValue] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ( required && [value length] == 0 ) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }
    
    return cellView;
} // populateCellViewTextField:settings:row

- (void)showRequired:(BOOL)show {
    if ( show ) {
        [_constraintTextFieldTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNumber
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldNumber

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewSettingsTextFieldNumber *)populateCellViewSettingsTextFieldNumber:(CellViewSettingsTextFieldNumber *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Unit
    // ---------------------------------------------------------------------
    [[cellView settingUnit] setStringValue:manifest[PFCManifestKeyUnit] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        if ( manifest[PFCManifestKeyDefaultValue] != nil ) {
            value = manifest[PFCManifestKeyDefaultValue];
        } else if ( settingsLocal[PFCSettingsKeyValue] != nil ) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value ?: @0 stringValue]];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( manifest[PFCManifestKeyPlaceholderValue] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[manifest[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifest[PFCManifestKeyMinValue] ?: @0];
    [[cellView settingStepper] setMinValue:[manifest[PFCManifestKeyMinValue] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifest[PFCManifestKeyMaxValue] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifest[PFCManifestKeyMaxValue] doubleValue] ?: 99999.0];
    
    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [[cellView settingStepper] setValueWraps:NO];
    if ( _stepperValue == nil ) {
        [self setStepperValue:value];
    }
    [[cellView settingTextField] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    [[cellView settingStepper] setEnabled:enabled];
    
    return cellView;
} // populateCellViewTextField:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNumberLeft
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldNumberLeft

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewSettingsTextFieldNumberLeft *)populateCellViewSettingsTextFieldNumberLeft:(CellViewSettingsTextFieldNumberLeft *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        if ( manifest[PFCManifestKeyDefaultValue] != nil ) {
            value = manifest[PFCManifestKeyDefaultValue];
        } else if ( settingsLocal[PFCSettingsKeyValue] != nil ) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value ?: @0 stringValue]];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( manifest[PFCManifestKeyPlaceholderValue] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[manifest[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifest[PFCManifestKeyMinValue] ?: @0];
    [[cellView settingStepper] setMinValue:[manifest[PFCManifestKeyMinValue] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifest[PFCManifestKeyMaxValue] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifest[PFCManifestKeyMaxValue] doubleValue] ?: 99999.0];
    
    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [[cellView settingStepper] setValueWraps:NO];
    if ( _stepperValue == nil ) {
        [self setStepperValue:settings[PFCSettingsKeyValue] ?: @0];
    }
    [[cellView settingTextField] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    [[cellView settingStepper] setEnabled:enabled];
    
    return cellView;
} // populateCellViewTextField:settings:row

@end


















































// FIXME - CellViews below are still being tested

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTemplates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTemplates

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTemplates *)populateCellViewTemplates:(CellViewSettingsTemplates *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settings[PFCSettingsKeyValue] ?: manifest[PFCManifestKeyDefaultValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // CellViewSettingsTemplates

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsMinOS
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsMinOS
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect
@end
