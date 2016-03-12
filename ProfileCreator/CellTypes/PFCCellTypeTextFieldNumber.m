//
//  PFCCellTypeTextFieldNumber.m
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
#import "PFCCellTypeTextFieldNumber.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"

@interface PFCTextFieldNumberCellView ()

@property NSNumber *stepperValue;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
@property (weak) IBOutlet NSTextField *settingUnit;
@property (weak) IBOutlet NSStepper *settingStepper;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;

@end

@implementation PFCTextFieldNumberCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (PFCTextFieldNumberCellView *)populateCellView:(PFCTextFieldNumberCellView *)cellView
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
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
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
    if (value == nil) {
        if (manifest[PFCManifestKeyDefaultValue] != nil) {
            value = manifest[PFCManifestKeyDefaultValue];
        } else if (settingsLocal[PFCSettingsKeyValue] != nil) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value ?: @0 stringValue]];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if (manifest[PFCManifestKeyPlaceholderValue] != nil) {
        [[cellView settingTextField] setPlaceholderString:[manifest[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
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
    if (_stepperValue == nil) {
        [self setStepperValue:value];
    }
    [[cellView settingTextField] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

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

@interface PFCTextFieldNumberLeftCellView ()

@property NSNumber *stepperValue;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
@property (weak) IBOutlet NSStepper *settingStepper;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;

@end

@implementation PFCTextFieldNumberLeftCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (PFCTextFieldNumberLeftCellView *)populateCellView:(PFCTextFieldNumberLeftCellView *)cellView
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
    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
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
    if (value == nil) {
        if (manifest[PFCManifestKeyDefaultValue] != nil) {
            value = manifest[PFCManifestKeyDefaultValue];
        } else if (settingsLocal[PFCSettingsKeyValue] != nil) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setStringValue:[value ?: @0 stringValue]];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if (manifest[PFCManifestKeyPlaceholderValue] != nil) {
        [[cellView settingTextField] setPlaceholderString:[manifest[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
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
    if (_stepperValue == nil) {
        [self setStepperValue:settings[PFCSettingsKeyValue] ?: @0];
    }
    [[cellView settingTextField] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepper] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

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
