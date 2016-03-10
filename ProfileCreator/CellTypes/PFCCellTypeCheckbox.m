//
//  PFCCellTypeCheckbox.m
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
#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCCheckboxCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCCheckboxCellView *)populateCellView:(PFCCheckboxCellView *)cellView
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

    BOOL supervisedOnly = [manifest[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:[NSString stringWithFormat:@"%@%@", manifest[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settings[PFCSettingsKeyValue] != nil) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if (manifest[PFCManifestKeyDefaultValue]) {
        checkboxState = [manifest[PFCManifestKeyDefaultValue] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        checkboxState = [settingsLocal[PFCSettingsKeyValue] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:102];
    } else if (manifest[PFCManifestKeyIndentLevel] != nil) {
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

@interface PFCCheckboxNoDescriptionCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;

@end

@implementation PFCCheckboxNoDescriptionCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCCheckboxNoDescriptionCellView *)populateCellView:(PFCCheckboxNoDescriptionCellView *)cellView
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

    BOOL supervisedOnly = [manifest[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:[NSString stringWithFormat:@"%@%@", manifest[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];

    // ---------------------------------------------------------------------
    //  FontWeight of the Title
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyFontWeight] isEqualToString:PFCFontWeightBold]) {
        [[cellView settingCheckbox] setFont:[NSFont boldSystemFontOfSize:13]];
    } else {
        [[cellView settingCheckbox] setFont:[NSFont systemFontOfSize:13]];
    }

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settings[PFCSettingsKeyValue] != nil) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if (manifest[PFCManifestKeyDefaultValue]) {
        checkboxState = [manifest[PFCManifestKeyDefaultValue] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        checkboxState = [settingsLocal[PFCSettingsKeyValue] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:102];
    } else if (manifest[PFCManifestKeyIndentLevel] != nil) {
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
