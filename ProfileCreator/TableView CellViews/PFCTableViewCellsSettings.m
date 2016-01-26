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
#import "PFCProfileCreationWindowController.h"
#import "PFCTableViewCellsSettingsTableView.h"
#import "PFCFileInfoProcessors.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"

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
        CGFloat constratingConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel]];
        [[cellView constraintLeading] setConstant:constratingConstant];
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
        CGFloat constratingConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel]];
        [[cellView constraintLeading] setConstant:constratingConstant];
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
    } else {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Set minimum value selectable to tomorrow
    // ---------------------------------------------------------------------
    // FIXME - The time is set to 23:00, should probably investigate the format
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *dateTomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    [[cellView settingDatePicker] setMinDate:dateTomorrow];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    //[[cellView settingDatePicker] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
    [[cellView settingDateDescription] setStringValue:[(PFCProfileCreationWindowController *)sender dateIntervalFromNowToDate:datePickerDate] ?: @""];
    
    return cellView;
} // populateCellViewDatePicker

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
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[PFCManifestKeyTitle] ?: @""];
    
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
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  ValueTextField
    // ---------------------------------------------------------------------
    NSString *valueTextField;
    if ( [settings[PFCSettingsKeyValueTextField] length] != 0 ) {
        valueTextField = settings[PFCSettingsKeyValueTextField];
    } else if ( [manifest[PFCManifestKeyDefaultValueTextField] length] != 0 ) {
        valueTextField = manifest[PFCManifestKeyDefaultValueTextField];
    } else if ( [settingsLocal[PFCSettingsKeyValueTextField] length] != 0 ) {
        valueTextField = settingsLocal[PFCSettingsKeyValueTextField];
    }
    [[cellView settingTextField] setStringValue:valueTextField ?: @""];
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value TextField
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyPlaceholderValueTextField] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueTextField] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:PFCManifestKeyRequired];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextField] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:@"value" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsTextFieldCheckbox:manifest:settings:settingsLocal:row:sender

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
#pragma mark CellViewSettingsTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL optional = [manifest[@"Optional"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    if ( [value length] == 0 ) {
        if ( [manifest[@"DefaultValue"] length] != 0 ) {
            value = manifest[@"DefaultValue"] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
            value = settingsLocal[PFCSettingsKeyValue] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValue"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[@"PlaceholderValue"] ?: @""];
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
}

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
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Unit
    // ---------------------------------------------------------------------
    [[cellView settingUnit] setStringValue:manifest[@"ValueUnit"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        if ( manifest[@"DefaultValue"] != nil ) {
            value = manifest[@"DefaultValue"];
        } else if ( settingsLocal[PFCSettingsKeyValue] != nil ) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value ?: @0 stringValue]];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifest[@"MinValue"] ?: @0];
    [[cellView settingStepper] setMinValue:[manifest[@"MinValue"] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifest[@"MaxValue"] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifest[@"MinValue"] doubleValue] ?: 99999.0];
    
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
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    [[cellView settingStepper] setEnabled:enabled];
    
    return cellView;
} // populateCellViewTextField:settings:row

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
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL optional = [manifest[@"Optional"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    if ( [value length] == 0 ) {
        if ( [manifest[@"DefaultValue"] length] != 0 ) {
            value = manifest[@"DefaultValue"] ?: @"";
        } else if ( [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
            value = settingsLocal[PFCSettingsKeyValue] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValue"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifest[@"PlaceholderValue"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if ( optional ) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [manifest[@"Indent"] boolValue] ) {
        [[cellView constraintLeading] setConstant:16];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];
    
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
}

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
    
    BOOL requiredHost;
    if ( manifest[@"RequiredHost"] != nil ) {
        requiredHost = [manifest[@"RequiredHost"] boolValue];
    } else {
        requiredHost = [manifest[@"Required"] boolValue];
    }
    
    BOOL requiredPort;
    if ( manifest[@"RequiredPort"] != nil ) {
        requiredPort = [manifest[@"RequiredPort"] boolValue];
    } else {
        requiredPort = [manifest[@"Required"] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ( ! requiredHost || ! requiredPort ) && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    BOOL optional = [manifest[@"Optional"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifest[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  ValueCheckbox
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[@"ValueCheckbox"] != nil ) {
        checkboxState = [settings[@"ValueCheckbox"] boolValue];
    } else if ( manifest[@"DefaultValueCheckbox"] ) {
        checkboxState = [manifest[@"DefaultValueCheckbox"] boolValue];
    } else if ( settingsLocal[@"ValueCheckbox"] ) {
        checkboxState = [settingsLocal[@"ValueCheckbox"] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settings[@"ValueHost"] ?: @"";
    if ( [valueHost length] == 0 ) {
        if ( [manifest[@"DefaultValueHost"] length] != 0 ) {
            valueHost = manifest[@"DefaultValueHost"] ?: @"";
        } else if ( [settingsLocal[@"ValueHost"] length] != 0 ) {
            valueHost = settingsLocal[@"ValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[@"PlaceholderValueHost"] ?: @""];
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
    NSString *valuePort = settings[@"ValuePort"] ?: @"";
    if ( [valuePort length] == 0 ) {
        if ( [manifest[@"DefaultValuePort"] length] != 0 ) {
            valuePort = manifest[@"DefaultValuePort"] ?: @"";
        } else if ( [settingsLocal[@"ValuePort"] length] != 0 ) {
            valuePort = settingsLocal[@"ValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[@"PlaceholderValuePort"] ?: @""];
    } else if ( requiredPort ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Req"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
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
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

@end

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
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settings[PFCSettingsKeyValue] ?: manifest[@"DefaultValue"]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // populateCellViewPopUp:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUp
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUp

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[@"AvailableValues"] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[@"DefaultValue"] length] != 0 ) {
        selectedItem = manifest[@"DefaultValue"];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // populateCellViewPopUp:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUpNoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUpNoTitle *)populateCellViewSettingsPopUpNoTitle:(CellViewSettingsPopUpNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[@"AvailableValues"] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[@"DefaultValue"] length] != 0 ) {
        selectedItem = manifest[@"DefaultValue"];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [manifest[@"Indent"] boolValue] ) {
        [[cellView constraintLeading] setConstant:16];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // populateCellViewSettingsPopUpNoTitle:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpLeft
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPopUpLeft

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsPopUpLeft *)populateCellViewSettingsPopUpLeft:(CellViewSettingsPopUpLeft *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[@"AvailableValues"] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[@"DefaultValue"] length] != 0 ) {
        selectedItem = manifest[@"DefaultValue"];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // populateCellViewPopUp:settings:row

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
    
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        if ( manifest[@"DefaultValue"] != nil ) {
            value = manifest[@"DefaultValue"];
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
    if ( manifest[@"PlaceholderValue"] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[manifest[@"PlaceholderValue"] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifest[@"MinValue"] ?: @0];
    [[cellView settingStepper] setMinValue:[manifest[@"MinValue"] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifest[@"MaxValue"] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifest[@"MinValue"] doubleValue] ?: 99999.0];
    
    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [[cellView settingStepper] setValueWraps:NO];
    if ( _stepperValue == nil ) {
        [self setStepperValue:settings[PFCSettingsKeyValue] ?: @0];
    }
    [[cellView settingTextField] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    return cellView;
} // populateCellViewTextField:settings:row

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
    if ( manifest[@"Required"] != nil ) {
        required = [manifest[@"Required"] boolValue];
    } else if ( manifest[@"RequiredHost"] != nil ) {
        required = [manifest[@"RequiredHost"] boolValue];
    } else if ( manifest[@"RequiredPort"] != nil ) {
        required = [manifest[@"RequiredPort"] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:enabled];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:required];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setAction:@selector(checkbox:)];
    [[cellView settingEnabled] setTarget:sender];
    [[cellView settingEnabled] setTag:row];
    
    return cellView;
} // populateCellViewEnabled:settings:row

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
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if ( settings[PFCSettingsKeyValue] != nil ) {
        date = settings[PFCSettingsKeyValue] ?: [NSDate date];
    } else {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Set minimum value selectable to tomorrow
    // ---------------------------------------------------------------------
    // FIXME - The time is set to 23:00, should probably investigate the format
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *dateTomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    [[cellView settingDatePicker] setMinDate:dateTomorrow];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    //[[cellView settingDatePicker] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
    [[cellView settingDateDescription] setStringValue:[(PFCProfileCreationWindowController *)sender dateIntervalFromNowToDate:datePickerDate] ?: @""];
    
    return cellView;
} // populateCellViewCheckbox:settings:row

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
        NSMutableDictionary *settingsDict = [[(PFCProfileCreationWindowController *)_sender settingsManifest] mutableCopy];
        if ( seconds == 0 ) {
            [settingsDict removeObjectForKey:_cellIdentifier];
        } else {
            NSMutableDictionary *cellDict = [settingsDict[_cellIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            cellDict[PFCSettingsKeyValue] = @(seconds);
            settingsDict[_cellIdentifier] = cellDict;
        }
        [(PFCProfileCreationWindowController *)_sender setSettingsManifest:settingsDict];
    }
} // observeValueForKeyPath

- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    [self setSender:sender];
    [self setCellIdentifier:manifest[@"Identifier"] ?: @""];
    
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
    
    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

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
        NSLog(@"[ERROR] TextField: %@ tag is nil", textFieldTag);
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
        NSMutableDictionary *settings = [[(PFCProfileCreationWindowController *)_sender settingsManifest][_senderIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        NSLog(@"settingsRetrieved=%@", settings);
        settings[@"TableViewContent"] = [_tableViewContent copy];
        NSLog(@"settingsToSave=%@", settings);
        [(PFCProfileCreationWindowController *)_sender settingsManifest][_senderIdentifier] = [settings mutableCopy];
        NSLog(@"settingsAfterSave=%@", [(PFCProfileCreationWindowController *)_sender settingsManifest][_senderIdentifier]);
    }
}

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
}

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
            tableColumnDict[PFCSettingsKeyValue] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
        } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
            tableColumnDict[PFCSettingsKeyValue] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
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
        NSLog(@"[ERROR] PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get popup button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *popUpButtonTag = @([popUpButton tag]);
    if ( popUpButtonTag == nil ) {
        NSLog(@"[ERROR] PopUpButton: %@ tag is nil", popUpButton);
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
}

- (void)checkbox:(NSButton *)checkbox {
    
    // ---------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        NSLog(@"[ERROR] Checkbox: %@ tag is nil", checkbox);
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
    if ( ! _tableViewContent ) {
        if ( [settings[@"TableViewContent"] count] != 0 ) {
            _tableViewContent = [settings[@"TableViewContent"] mutableCopy] ?: [[NSMutableArray alloc] init];
        } else {
            _tableViewContent = [settingsLocal[@"TableViewContent"] mutableCopy] ?: [[NSMutableArray alloc] init];
        }
    }
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    [self setSender:sender];
    [self setSenderIdentifier:manifest[@"Identifier"]];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  TableColumn set DataSource and Delegate to self
    // ---------------------------------------------------------------------
    [[cellView settingTableView] setDataSource:self];
    [[cellView settingTableView] setDelegate:self];
    
    // ---------------------------------------------------------------------
    //  TableColumn add columns from settingsDict
    // ---------------------------------------------------------------------
    for ( NSTableColumn *tableColumn in [[[cellView settingTableView] tableColumns] copy] ) {
        [[cellView settingTableView] removeTableColumn:tableColumn];
    }
    
    NSMutableDictionary *tableColumnsCellViews = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnsArray = manifest[@"TableViewColumns"] ?: @[];
    for ( NSDictionary *tableColumnDict in tableColumnsArray ) {
        NSString *tableColumnTitle = tableColumnDict[@"Title"] ?: @"";
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
    
    [[cellView settingTableView] beginUpdates];
    [[cellView settingTableView] sizeToFit];
    [[cellView settingTableView] reloadData];
    [[cellView settingTableView] endUpdates];
    
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
#pragma mark CellViewSettingsFile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsFile

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setInfoForFileAtURL:(NSURL *)fileURL withFileInfoProcessor:(NSString *)fileInfoProcessor {
    
    if ( [fileInfoProcessor isEqualToString:@"FileInfoProcessorFont"] ) {
        if ( ! _fileInfoProcessor ) {
            [self setFileInfoProcessor:[[PFCFileInfoProcessorFont alloc] initWithFileURL:fileURL]];
        } else {
            [_fileInfoProcessor setFileURL:fileURL];
        }
        
        NSDictionary *fileInfo = [_fileInfoProcessor fileInfo];
        if ( [fileInfo count] != 0 ) {
            [_settingFileTitle setStringValue:fileInfo[@"Title"] ?: [fileURL lastPathComponent]];
            
            if ( fileInfo[@"Description1"] != nil ) {
                [_settingFileDescriptionLabel1 setStringValue:fileInfo[@"DescriptionLabel1"] ?: @""];
                [_settingFileDescription1 setStringValue:fileInfo[@"Description1"] ?: @""];
                
                [_settingFileDescriptionLabel1 setHidden:NO];
                [_settingFileDescription1 setHidden:NO];
            } else {
                [_settingFileDescriptionLabel1 setHidden:YES];
                [_settingFileDescription1 setHidden:YES];
            }
            
            if ( fileInfo[@"Description2"] != nil ) {
                [_settingFileDescriptionLabel2 setStringValue:fileInfo[@"DescriptionLabel2"] ?: @""];
                [_settingFileDescription2 setStringValue:fileInfo[@"Description2"] ?: @""];
                
                [_settingFileDescriptionLabel2 setHidden:NO];
                [_settingFileDescription2 setHidden:NO];
            } else {
                [_settingFileDescriptionLabel1 setHidden:YES];
                [_settingFileDescription1 setHidden:YES];
            }
            
            if ( fileInfo[@"Description3"] != nil ) {
                [_settingFileDescriptionLabel3 setStringValue:fileInfo[@"DescriptionLabel3"] ?: @""];
                [_settingFileDescription3 setStringValue:fileInfo[@"Description3"] ?: @""];
                
                [_settingFileDescriptionLabel3 setHidden:NO];
                [_settingFileDescription3 setHidden:NO];
            } else {
                [_settingFileDescriptionLabel3 setHidden:YES];
                [_settingFileDescription3 setHidden:YES];
            }
            
        } else {
            
            // ---------------------------------------------------------------------
            //  If no file info was returned, just set file title and size
            // ---------------------------------------------------------------------
            NSString *title = [fileURL lastPathComponent];
            [_settingFileTitle setStringValue:title];
        }
    }
    
}

- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = [manifest[@"Required"] boolValue];
    BOOL enabled = YES;
    if ( ! required && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Button Title
    // ---------------------------------------------------------------------
    NSString *buttonTitle = manifest[@"ButtonTitle"] ?: @"";
    [[cellView settingButtonAdd] setEnabled:enabled];
    if ( [buttonTitle length] != 0 ) {
        [[cellView settingButtonAdd] setTitle:buttonTitle];
    }
    
    // ---------------------------------------------------------------------
    //  Button Action
    // ---------------------------------------------------------------------
    [[cellView settingButtonAdd] setAction:@selector(selectFile:)];
    [[cellView settingButtonAdd] setTarget:sender];
    [[cellView settingButtonAdd] setTag:row];
    
    // ---------------------------------------------------------------------
    //  File View Prompt Message
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setStringValue:manifest[@"FilePrompt"] ?: @""];
    
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
    if ( [settings[@"FilePath"] length] == 0 ) {
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
    NSURL *fileURL = [NSURL fileURLWithPath:settings[@"FilePath"]];
    if ( ! [fileURL checkResourceIsReachableAndReturnError:&error] ) {
        NSLog(@"%@", [error localizedDescription]);
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
        
        if ( manifest[@"FileInfoProcessor"] != nil ) {
            [self setInfoForFileAtURL:fileURL withFileInfoProcessor:manifest[@"FileInfoProcessor"]];
        } else {
            
            // ---------------------------------------------------------------------
            //  If no FileInfoProcessor is available, just set file title and size
            // ---------------------------------------------------------------------
            NSString *title = [fileURL lastPathComponent];
            [[cellView settingFileTitle] setStringValue:title];
            [[cellView settingFileDescriptionLabel1] setStringValue:@""];
            [[cellView settingFileDescription1] setStringValue:@""];
            [[cellView settingFileDescriptionLabel2] setStringValue:@""];
            [[cellView settingFileDescription2] setStringValue:@""];
            [[cellView settingFileDescriptionLabel3] setStringValue:@""];
            [[cellView settingFileDescription3] setStringValue:@""];
        }
    }
    
    if ( enabled ) {
        [[cellView settingFileTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingFileTitle] setTextColor:[NSColor grayColor]];
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
#pragma mark CellViewSettingsSegmentedControl
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsSegmentedControl

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView manifest:(NSDictionary *)manifest row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Reset Segmented Control
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSegmentCount:0];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = manifest[@"AvailableValues"] ?: @[];
    [[cellView settingSegmentedControl] setSegmentCount:[availableSelections count]];
    [availableSelections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[cellView settingSegmentedControl] setLabel:obj forSegment:idx];
    }];
    
    // ---------------------------------------------------------------------
    //  Select saved selection or 0 if never saved
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSelected:YES forSegment:[manifest[PFCSettingsKeyValue] integerValue] ?: 0];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Action
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setAction:@selector(segmentedControl:)];
    [[cellView settingSegmentedControl] setTarget:sender];
    [[cellView settingSegmentedControl] setTag:row];
    
    return cellView;
}

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
    
    BOOL requiredHost;
    if ( manifest[@"RequiredHost"] != nil ) {
        requiredHost = [manifest[@"RequiredHost"] boolValue];
    } else {
        requiredHost = [manifest[@"Required"] boolValue];
    }
    
    BOOL requiredPort;
    if ( manifest[@"RequiredPort"] != nil ) {
        requiredPort = [manifest[@"RequiredPort"] boolValue];
    } else {
        requiredPort = [manifest[@"Required"] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ( ! requiredHost || ! requiredPort ) && settings[@"Enabled"] != nil ) {
        enabled = [settings[@"Enabled"] boolValue];
    }
    
    BOOL optional = [manifest[@"Optional"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settings[@"ValueHost"] ?: @"";
    if ( [valueHost length] == 0 ) {
        if ( [manifest[@"DefaultValueHost"] length] != 0 ) {
            valueHost = manifest[@"DefaultValueHost"] ?: @"";
        } else if ( [settingsLocal[@"ValueHost"] length] != 0 ) {
            valueHost = settingsLocal[@"ValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[@"PlaceholderValueHost"] ?: @""];
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
    NSString *valuePort = settings[@"ValuePort"] ?: @"";
    if ( [valuePort length] == 0 ) {
        if ( [manifest[@"DefaultValuePort"] length] != 0 ) {
            valuePort = manifest[@"DefaultValuePort"] ?: @"";
        } else if ( [settingsLocal[@"ValuePort"] length] != 0 ) {
            valuePort = settingsLocal[@"ValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifest[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifest[@"PlaceholderValuePort"] ?: @""];
    } else if ( requiredPort ) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else {
        [[cellView settingTextFieldPort] setPlaceholderString:@""];
    }
    
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
}

@end