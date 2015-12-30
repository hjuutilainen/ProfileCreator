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
#import "PFCFileInfoProcessors.h"

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

- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settingDict[@"Value"] ?: @"";
    if ( [value length] == 0 ) {
        if ( [manifestDict[@"DefaultValue"] length] != 0 ) {
            value = manifestDict[@"DefaultValue"] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValue"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifestDict[@"PlaceholderValue"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[self toolTipWithKey:manifestDict[@"Key"] type:manifestDict[@"Type"] required:required description:manifestDict[@"ToolTipDescription"]]];
    
    return cellView;
} // populateCellViewTextField:settingDict:row

// FIXME - Test for tool tips, will have to build this out to support attributed strings
- (NSString *)toolTipWithKey:(NSString *)key type:(NSString *)type required:(BOOL)required description:(NSString *)description {
    NSMutableString *toolTip = [[NSMutableString alloc] init];
    
    [toolTip appendString:[NSString stringWithFormat:@"\t\tKey: %@", key ?: @"Unknown"]];
    [toolTip appendString:[NSString stringWithFormat:@"\n\t       Type: %@", type ?: @"Unknown"]];
    [toolTip appendString:[NSString stringWithFormat:@"\n\tRequired: %@", (required) ? @"YES" : @"NO"]];
    if ( [description length] != 0 ) {
        [toolTip appendString:[NSString stringWithFormat:@"\n     Description: %@", description]];
    }
    
    return toolTip;
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

- (CellViewSettingsTextFieldNumber *)populateCellViewSettingsTextFieldNumber:(CellViewSettingsTextFieldNumber *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Unit
    // ---------------------------------------------------------------------
    [[cellView settingUnit] setStringValue:manifestDict[@"ValueUnit"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settingDict[@"Value"] ?: @0;
    if ( value == nil ) {
        if ( manifestDict[@"DefaultValue"] != nil ) {
            value = manifestDict[@"DefaultValue"] ?: @0;
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value stringValue]];
    [[cellView settingTextField] setTag:row];

    /* Never used, as the binding always sets it to at least 0
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( manifestDict[@"PlaceholderValue"] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[manifestDict[@"PlaceholderValue"] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    */
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifestDict[@"MinValue"] ?: @0];
    [[cellView settingStepper] setMinValue:[manifestDict[@"MinValue"] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifestDict[@"MaxValue"] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifestDict[@"MinValue"] doubleValue] ?: 99999.0];
    
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

- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setStringValue:settingDict[@"Value"] ?: @""];
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"Indent"] boolValue] ) {
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

- (CellViewSettingsTextFieldCheckbox *)populateCellViewSettingsTextFieldCheckbox:(CellViewSettingsTextFieldCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifestDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  ValueCheckbox
    // ---------------------------------------------------------------------
    if ( settingDict[@"ValueCheckbox"] != nil ) {
        [cellView setCheckboxState:[settingDict[@"ValueCheckbox"] boolValue]];
    } else {
        [cellView setCheckboxState:[settingDict[@"DefaultValueCheckbox"] boolValue]];
    }
    
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
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  ValueTextField
    // ---------------------------------------------------------------------
    NSString *value = settingDict[@"ValueTextField"] ?: @"";
    if ( [value length] == 0 ) {
        if ( [manifestDict[@"DefaultValueTextField"] length] != 0 ) {
            value = manifestDict[@"DefaultValueTextField"] ?: @"";
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:value];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value TextField
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValueTextField"] length] != 0 ) {
        [[cellView settingTextField] setPlaceholderString:manifestDict[@"PlaceholderValueTextField"] ?: @""];
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

- (CellViewSettingsTextFieldHostPortCheckbox *)populateCellViewSettingsTextFieldHostPortCheckbox:(CellViewSettingsTextFieldHostPortCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {

    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifestDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [cellView setCheckboxState:[settingDict[@"ValueCheckbox"] boolValue]];
    
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
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settingDict[@"ValueHost"] ?: @"";
    if ( [valueHost length] == 0 ) {
        if ( [manifestDict[@"DefaultValueHost"] length] != 0 ) {
            valueHost = manifestDict[@"DefaultValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifestDict[@"PlaceholderValueHost"] ?: @""];
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
        if ( [manifestDict[@"DefaultValuePort"] length] != 0 ) {
            valuePort = manifestDict[@"DefaultValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifestDict[@"PlaceholderValuePort"] ?: @""];
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

- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifestDict[@"AvailableValues"] ?: @[]];
    
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: manifestDict[@"DefaultValue"]];
    
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
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"ValueKeys"] ?: @{} count] != 0 ) {
        if ( [sender updateSubKeysForDict:settingDict valueString:[[cellView settingPopUpButton] titleOfSelectedItem] row:row] ) {
            [[sender tableViewSettings] reloadData];
        }
    }
    
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

- (CellViewSettingsPopUpNoTitle *)populateCellViewSettingsPopUpNoTitle:(CellViewSettingsPopUpNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifestDict[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: manifestDict[@"DefaultValue"]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"Indent"] boolValue] ) {
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
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"ValueKeys"] ?: @{} count] != 0 ) {
        if ( [sender updateSubKeysForDict:settingDict valueString:[[cellView settingPopUpButton] titleOfSelectedItem] row:row] ) {
            [[sender tableViewSettings] reloadData];
        }
    }
    
    return cellView;
} // populateCellViewSettingsPopUpNoTitle:settingDict:row

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

- (CellViewSettingsPopUpLeft *)populateCellViewSettingsPopUpLeft:(CellViewSettingsPopUpLeft *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifestDict[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: manifestDict[@"DefaultValue"]];
    
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
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"ValueKeys"] ?: @{} count] != 0 ) {
        if ( [sender updateSubKeysForDict:settingDict valueString:[[cellView settingPopUpButton] titleOfSelectedItem] row:row] ) {
            [[sender tableViewSettings] reloadData];
        }
    }
    
    return cellView;
} // populateCellViewPopUp:settingDict:row

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

- (CellViewSettingsTextFieldNumberLeft *)populateCellViewSettingsTextFieldNumberLeft:(CellViewSettingsTextFieldNumberLeft *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settingDict[@"Value"] ?: @0;
    if ( value == nil ) {
        if ( manifestDict[@"DefaultValue"] != nil ) {
            value = manifestDict[@"DefaultValue"] ?: @0;
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value stringValue]];
    [[cellView settingTextField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( manifestDict[@"PlaceholderValue"] != nil ) {
        [[cellView settingTextField] setPlaceholderString:[manifestDict[@"PlaceholderValue"] stringValue] ?: @""];
    } else if ( required ) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }
    
    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [[cellView settingNumberFormatter] setMinimum:manifestDict[@"MinValue"] ?: @0];
    [[cellView settingStepper] setMinValue:[manifestDict[@"MinValue"] doubleValue] ?: 0.0];
    
    [[cellView settingNumberFormatter] setMaximum:manifestDict[@"MaxValue"] ?: @99999];
    [[cellView settingStepper] setMaxValue:[manifestDict[@"MinValue"] doubleValue] ?: 99999.0];
    
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
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsCheckbox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsCheckbox *)populateCellViewSettingsCheckbox:(CellViewSettingsCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifestDict[@"Title"] ?: @""];
    
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
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Indent
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"IndentLeft"] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( [manifestDict[@"Indent"] boolValue] ) {
        [[cellView constraintLeading] setConstant:16];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"ValueKeys"] ?: @{} count] != 0 ) {
        if ( [sender updateSubKeysForDict:settingDict valueString:[settingDict[@"Value"] boolValue] ? @"True" : @"False" row:row] ) {
            [[sender tableViewSettings] reloadData];
        }
    }
    
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

- (CellViewSettingsCheckboxNoDescription *)populateCellViewSettingsCheckboxNoDescription:(CellViewSettingsCheckboxNoDescription *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:manifestDict[@"Title"] ?: @""];
    if ( [manifestDict[@"FontWeight"] isEqualToString:@"Bold"] ) {
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
    if ( [manifestDict[@"Indent"] boolValue] ) {
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
    if ( [manifestDict[@"ValueKeys"] ?: @{} count] != 0 ) {
        if ( [sender updateSubKeysForDict:settingDict valueString:[settingDict[@"Value"] boolValue] ? @"True" : @"False" row:row] ) {
            [[sender tableViewSettings] reloadData];
        }
    }
    
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

- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:[manifestDict[@"Enabled"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:[manifestDict[@"Required"] boolValue]];
    
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

- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
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

- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
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
            columnDict[@"Value"] = [inputText copy];
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
    
    NSDictionary *settingDict = _tableViewContent[(NSUInteger)row];
    NSString *tableColumnIdentifier = [tableColumn identifier];
    NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnIdentifier];
    NSString *cellType = tableColumnCellViewDict[@"CellType"];
    
    if ( [cellType isEqualToString:@"TextField"] ) {
        CellViewTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewTextField" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewTextField:cellView settingDict:settingDict[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        CellViewPopUpButton *cellView = [tableView makeViewWithIdentifier:@"CellViewPopUpButton" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewPopUpButton:cellView settingDict:settingDict[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
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
    if ( _sender && _senderRow ) {
        NSMutableDictionary *cellDict = [[[(PFCProfileCreationWindowController *)_sender tableViewSettingsItemsEnabled] objectAtIndex:(NSUInteger)_senderRow] mutableCopy];
        cellDict[@"TableViewContent"] = [_tableViewContent copy];
        [[(PFCProfileCreationWindowController *)_sender tableViewSettingsItemsEnabled] replaceObjectAtIndex:(NSUInteger)_senderRow withObject:cellDict];
    }
}

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
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
        } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
            tableColumnDict[@"AvailableValues"] = tableColumnCellViewDict[@"AvailableValues"] ?: @[];
        }
        newRowDict[tableColumnKey] = tableColumnDict;
    }
    
    [self insertRowInTableView:[newRowDict copy]];
    [self updateTableViewSavedContent];
} // settingButtonAdd

- (IBAction)settingButtonRemove:(id) __unused sender {
    NSIndexSet *indexes = [_settingTableView selectedRowIndexes];
    [_tableViewContent removeObjectsAtIndexes:indexes];
    [_settingTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
    [self updateTableViewSavedContent];
} // settingButtonRemove

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
        columnDict[@"Value"] = selectedTitle;
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

- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    if ( ! _tableViewContent ) {
        _tableViewContent = [settingDict[@"TableViewContent"] mutableCopy] ?: [[NSMutableArray alloc] init];
    }
    
    [self setSender:sender];
    [self setSenderRow:row];
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
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
    NSArray *tableColumnsArray = manifestDict[@"TableViewColumns"] ?: @[];
    for ( NSDictionary *tableColumnDict in tableColumnsArray ) {
        NSString *tableColumnTitle = manifestDict[@"Title"] ?: @"";
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

- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Button Title
    // ---------------------------------------------------------------------
    NSString *buttonTitle = manifestDict[@"ButtonTitle"] ?: @"";
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
    [[cellView settingFileViewPrompt] setStringValue:manifestDict[@"FilePrompt"] ?: @""];
    
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
    //  File Info
    // ---------------------------------------------------------------------
    if ( [fileURL checkResourceIsReachableAndReturnError:nil] ) {
        
        if ( manifestDict[@"FileInfoProcessor"] != nil ) {
            [self setInfoForFileAtURL:fileURL withFileInfoProcessor:manifestDict[@"FileInfoProcessor"]];
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

- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Reset Segmented Control
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSegmentCount:0];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = manifestDict[@"AvailableValues"] ?: @[];
    [[cellView settingSegmentedControl] setSegmentCount:[availableSelections count]];
    [availableSelections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[cellView settingSegmentedControl] setLabel:obj forSegment:idx];
    }];
    
    // ---------------------------------------------------------------------
    //  Select saved selection or 0 if never saved
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSelected:YES forSegment:[settingDict[@"Value"] integerValue] ?: 0];
    
    // ---------------------------------------------------------------------
    //  Segmented Control Action
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setAction:@selector(segmentedControl:)];
    [[cellView settingSegmentedControl] setTarget:sender];
    [[cellView settingSegmentedControl] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Update sub keys
    // ---------------------------------------------------------------------
    NSDictionary *valueKeys = manifestDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] != 0 ) {
        NSString *selectedSegment = [[cellView settingSegmentedControl] labelForSegment:[[cellView settingSegmentedControl] selectedSegment]];
        if ( [selectedSegment length] != 0 ) {
            if ( [sender updateSubKeysForDict:settingDict valueString:selectedSegment row:row] ) {
                [[sender tableViewSettings] reloadData];
            }
        } else {
            NSLog(@"[ERROR] SegmentedControl: %@ selected segment is nil", [cellView settingSegmentedControl]);
        }
    }
    
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

- (CellViewSettingsTextFieldHostPort *)populateCellViewSettingsTextFieldHostPort:(CellViewSettingsTextFieldHostPort *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender {
    
    BOOL enabled = [manifestDict[@"Enabled"] boolValue];
    BOOL required = [manifestDict[@"Required"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifestDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settingDict[@"ValueHost"] ?: @"";
    //NSLog(@"settingsDict=%@", settingDict);
    //NSLog(@"valueHost=%@", valueHost);
    if ( [valueHost length] == 0 ) {
        if ( [manifestDict[@"DefaultValueHost"] length] != 0 ) {
            valueHost = manifestDict[@"DefaultValueHost"] ?: @"";
        }
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setStringValue:valueHost];
    [[cellView settingTextFieldHost] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValueHost"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifestDict[@"PlaceholderValueHost"] ?: @""];
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
        if ( [manifestDict[@"DefaultValuePort"] length] != 0 ) {
            valuePort = manifestDict[@"DefaultValuePort"] ?: @"";
        }
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setStringValue:valuePort];
    [[cellView settingTextFieldPort] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [manifestDict[@"PlaceholderValuePort"] length] != 0 ) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifestDict[@"PlaceholderValuePort"] ?: @""];
    } else if ( required ) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }
    
    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settingDict:row

@end