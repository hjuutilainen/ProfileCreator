//
//  PFCTableViewCellsSettings.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsSettings.h"
#import "PFCProfileCreationWindowController.h"
#import "PFCTableViewCellsSettingsTableView.h"

@implementation PFCTableViewCellsSettings
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

- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    BOOL required = [settingDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settingDict[@"Value"] ?: @"";
    if ( [value length] == 0 ) {
        if ( [settingDict[@"DefaultValue"] length] != 0 ) {
            value = settingDict[@"DefaultValue"] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValue"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:settingDict[@"PlaceholderValue"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    return cellView;
} // populateCellViewTextField:settingDict:row

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

- (CellViewSettingsTextFieldNumber *)populateCellViewSettingsTextFieldNumber:(CellViewSettingsTextFieldNumber *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {

    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    BOOL required = [settingDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Unit
    // ---------------------------------------------------------------------
    [[cellView settingUnit] setStringValue:settingDict[@"ValueUnit"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settingDict[@"Value"] ?: @0;
    if ( value == nil ) {
        if ( settingDict[@"DefaultValue"] != nil ) {
            value = settingDict[@"DefaultValue"] ?: @0;
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value stringValue]];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( settingDict[@"PlaceholderValue"] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[settingDict[@"PlaceholderValue"] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:settingDict[@"MinValue"] ?: @0];
    [[cellView settingStepper] setMinValue:[settingDict[@"MinValue"] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:settingDict[@"MaxValue"] ?: @99999];
    [[cellView settingStepper] setMaxValue:[settingDict[@"MinValue"] doubleValue] ?: 99999.0];
    
    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [[cellView settingStepper] setValueWraps:NO];
    if ( _stepperValue == nil ) {
        [self setStepperValue:settingDict[@"Value"] ?: @0];
    }
    [[cellView settingTextField] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:@"value" toObject:self withKeyPath:@"stepperValue" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    return cellView;
} // populateCellViewTextField:settingDict:row

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

- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setStringValue:settingDict[@"Value"] ?: @""];
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [settingDict[@"Indent"] boolValue] ) {
        [[cellView constraintLeading] setConstant:16];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    return cellView;
} // populateCellViewTextField:settingDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTextFieldCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewSettingsTextFieldCheckbox *)populateCellViewSettingsTextFieldCheckbox:(CellViewSettingsTextFieldCheckbox *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    BOOL required = [settingDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:settingDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setState:[settingDict[@"ValueCheckbox"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settingDict[@"ValueTextField"] ?: @"";
    if ( [value length] == 0 ) {
        if ( [settingDict[@"DefaultValueTextField"] length] != 0 ) {
            value = settingDict[@"DefaultValueTextField"] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValue"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:settingDict[@"PlaceholderValue"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextField] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:@"value" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    return cellView;
} // populateCellViewTextField:settingDict:row

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

- (CellViewSettingsTextFieldHostPortCheckbox *)populateCellViewSettingsTextFieldHostPortCheckbox:(CellViewSettingsTextFieldHostPortCheckbox *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    BOOL required = [settingDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:settingDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setState:[settingDict[@"ValueCheckbox"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settingDict[@"ValueHost"] ?: @"";
    if ( [valueHost length] == 0 ) {
        if ( [settingDict[@"DefaultValueHost"] length] != 0 ) {
            valueHost = settingDict[@"DefaultValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:settingDict[@"PlaceholderValueHost"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settingDict[@"ValuePort"] ?: @"";
    if ( [valuePort length] == 0 ) {
        if ( [settingDict[@"DefaultValuePort"] length] != 0 ) {
            valuePort = settingDict[@"DefaultValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:settingDict[@"PlaceholderValuePort"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField's 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextFieldHost] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingTextFieldPort] bind:@"enabled" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:@"value" toObject:self withKeyPath:@"checkboxState" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settingDict:row

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

- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:settingDict[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: settingDict[@"DefaultValue"]];
    
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
} // populateCellViewPopUp:settingDict:row

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

- (CellViewSettingsPopUpNoTitle *)populateCellViewSettingsPopUpNoTitle:(CellViewSettingsPopUpNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:settingDict[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: settingDict[@"DefaultValue"]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [settingDict[@"Indent"] boolValue] ) {
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
} // populateCellViewSettingsPopUpNoTitle:settingDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsCheckbox *)populateCellViewSettingsCheckbox:(CellViewSettingsCheckbox *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:settingDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setState:[settingDict[@"Value"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    //NSDictionary *valueKeys = settingDict[@"ValueKeys"] ?: @{};
    //if ( [valueKeys count] != 0 ) {
    //    [sender updateSubKeysForDict:settingDict valueString:[settingDict[@"Value"] boolValue] ? @"True" : @"False" row:row];
    //}
    
    return cellView;
} // populateCellViewCheckbox:settingDict:row

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

- (CellViewSettingsCheckboxNoDescription *)populateCellViewSettingsCheckboxNoDescription:(CellViewSettingsCheckboxNoDescription *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:settingDict[@"Title"] ?: @""];
    if ( [settingDict[@"FontWeight"] isEqualToString:@"Bold"] ) {
        [[cellView settingCheckbox] setFont:[NSFont boldSystemFontOfSize:13]];
    } else {
        [[cellView settingCheckbox] setFont:[NSFont systemFontOfSize:13]];
    }
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setState:[settingDict[@"Value"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [settingDict[@"Indent"] boolValue] ) {
        [[cellView constraintLeading] setConstant:16];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    //NSDictionary *valueKeys = settingDict[@"ValueKeys"] ?: @{};
    //if ( [valueKeys count] != 0 ) {
    //    [sender updateSubKeysForDict:settingDict valueString:[settingDict[@"Value"] boolValue] ? @"True" : @"False" row:row];
    //}
    
    return cellView;
} // populateCellViewCheckboxNoDescription:settingDict:row

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

- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:[settingDict[@"Enabled"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:[settingDict[@"Required"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setAction:@selector(checkbox:)];
    [[cellView settingEnabled] setTarget:sender];
    [[cellView settingEnabled] setTag:row];
    
    return cellView;
} // populateCellViewEnabled:settingDict:row

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

- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    //BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setDateValue:settingDict[@"Value"] ?: [NSDate date]];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Set minimum value selectable to tomorrow
    // ---------------------------------------------------------------------
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
    [[cellView settingDescription] setStringValue:[(PFCProfileCreationWindowController *)sender dateIntervalFromNowToDate:datePickerDate] ?: @""];
    
    return cellView;
} // populateCellViewCheckbox:settingDict:row

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

- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    if ( _stepperValueRemovalIntervalHours == nil || _stepperValueRemovalIntervalHours == nil ) {
        NSNumber *seconds = settingDict[@"Value"] ?: @0;
        
        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier: @"en_US"]];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour;
        
        NSDate *startDate = [NSDate date];
        NSDate *endDate = [startDate dateByAddingTimeInterval:[seconds doubleValue]];
        
        NSDateComponents *components = [calendarUS components:unitFlags fromDate:startDate toDate:endDate options:0];
        _stepperValueRemovalIntervalDays = @([components day]) ?: @0;
        _stepperValueRemovalIntervalHours = @([components hour]) ?: @0;
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
    
    NSDictionary *settingDict = _tableViewContent[(NSUInteger)row];
    NSString *tableColumnIdentifier = [tableColumn identifier];
    NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnIdentifier];
    NSString *cellType = tableColumnCellViewDict[@"CellType"];
    
    if ( [cellType isEqualToString:@"TextField"] ) {
        CellViewTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewTextField" owner:self];
        return [cellView populateCellViewTextField:cellView settingDict:settingDict[tableColumnIdentifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        CellViewPopUpButton *cellView = [tableView makeViewWithIdentifier:@"CellViewPopUpButton" owner:self];
        return [cellView populateCellViewPopUpButton:cellView settingDict:settingDict[tableColumnIdentifier] row:row sender:self];
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

- (IBAction)settingButtonAdd:(id) __unused sender {
    
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
            tableColumnDict[@"Value"] = @"";
        } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
            tableColumnDict[@"AvailableValues"] = tableColumnCellViewDict[@"AvailableValues"];
        }
        newRowDict[tableColumnKey] = tableColumnDict;
    }
    
    [self insertRowInTableView:[newRowDict copy]];
} // settingButtonAdd

- (IBAction)settingButtonRemove:(id) __unused sender {
    NSIndexSet *indexes = [_settingTableView selectedRowIndexes];
    [_tableViewContent removeObjectsAtIndexes:indexes];
    [_settingTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
} // settingButtonRemove

- (void)popUpButtonSelection:(id)sender {
    NSLog(@"Select!");
}

- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
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
    NSArray *tableColumnsArray = settingDict[@"TableViewColumns"] ?: @[];
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
    
    NSLog(@"sizeToFit");
    [[cellView settingTableView] sizeToFit];
    
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

- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Button Title
    // ---------------------------------------------------------------------
    NSString *buttonTitle = settingDict[@"ButtonTitle"] ?: @"";
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
    [[cellView settingFileViewPrompt] setStringValue:settingDict[@"FilePrompt"] ?: @""];
    
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
    if ( [settingDict[@"FilePath"] length] == 0 ) {
        [[cellView settingFileViewPrompt] setHidden:NO];
        [[cellView settingFileIcon] setHidden:YES];
        [[cellView settingFileTitle] setHidden:YES];
        [[cellView settingFileDescription] setHidden:YES];
        return cellView;
    }
    
    // ---------------------------------------------------------------------
    //  Check that file exist
    // ---------------------------------------------------------------------
    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:settingDict[@"FilePath"]];
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
    //  File Title
    // ---------------------------------------------------------------------
    // FIXME - Currently just use filename, later add class to handle file types
    NSString *title = [fileURL lastPathComponent];
    [[cellView settingFileTitle] setStringValue:title];
    if ( enabled ) {
        [[cellView settingFileTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingFileTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  File Description
    // ---------------------------------------------------------------------
    // FIXME - Currently just use "No Description", later add class to handle file types
    NSString *description = @"No Description";
    [[cellView settingFileDescription] setStringValue:description];
    
    // ---------------------------------------------------------------------
    //  Show file info
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setHidden:YES];
    [[cellView settingFileIcon] setHidden:NO];
    [[cellView settingFileTitle] setHidden:NO];
    [[cellView settingFileDescription] setHidden:NO];
    
    return cellView;
} // populateCellViewSettingsFile:settingDict:row

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

- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = settingDict[@"AvailableValues"] ?: @[];
    [[cellView settingSegmentedControl] setSegmentCount:[availableSelections count]];
    [availableSelections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[cellView settingSegmentedControl] setLabel:obj forSegment:idx];
    }];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Action
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setAction:@selector(segmentedControl:)];
    [[cellView settingSegmentedControl] setTarget:sender];
    [[cellView settingSegmentedControl] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    //NSDictionary *valueKeys = settingDict[@"ValueKeys"] ?: @{};
    //if ( [valueKeys count] != 0 ) {
    //    NSString *selectedSegment = [[cellView settingSegmentedControl] labelForSegment:[[cellView settingSegmentedControl] selectedSegment]];
    //    NSLog(@"selectedSegment=%@", selectedSegment);
    //    if ( [selectedSegment length] != 0 ) {
    //        [sender updateSubKeysForDict:settingDict valueString:selectedSegment row:row];
    //    } else {
    //        NSLog(@"[ERROR] SegmentedControl: %@ selected segment is nil", [cellView settingSegmentedControl]);
    //    }
    //}
    
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

- (CellViewSettingsTextFieldHostPort *)populateCellViewSettingsTextFieldHostPort:(CellViewSettingsTextFieldHostPort *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    BOOL required = [settingDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settingDict[@"ValueHost"] ?: @"";
    if ( [valueHost length] == 0 ) {
        if ( [settingDict[@"DefaultValueHost"] length] != 0 ) {
            valueHost = settingDict[@"DefaultValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:settingDict[@"PlaceholderValueHost"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settingDict[@"ValuePort"] ?: @"";
    if ( [valuePort length] == 0 ) {
        if ( [settingDict[@"DefaultValuePort"] length] != 0 ) {
            valuePort = settingDict[@"DefaultValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:settingDict[@"PlaceholderValuePort"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settingDict:row

@end