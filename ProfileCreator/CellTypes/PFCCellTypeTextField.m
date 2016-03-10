//
//  PFCCellTypeTextField.m
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

#import "NSColor+PFCColors.h"
#import "PFCAvailability.h"
#import "PFCCellTypeTextField.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCTextFieldCellView ()

@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldTrailing;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;

@end

@implementation PFCTextFieldCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextFieldCellView *)populateCellView:(PFCTextFieldCellView *)cellView
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
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if ([value length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValue] length] != 0) {
            value = manifest[PFCManifestKeyDefaultValue] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }

    if ([valueAttributed length] != 0) {
        [[cellView settingTextField] setAttributedStringValue:valueAttributed];
    } else {
        [[cellView settingTextField] setStringValue:value];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValue] length] != 0) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValue] ?: @""];
    } else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
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
    if (required && [value length] == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewTextField:settings:row

- (void)showRequired:(BOOL)show {
    if (show) {
        [_constraintTextFieldTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

@interface PFCTextFieldCheckboxCellView ()

@property BOOL checkboxState;
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldPortTrailing;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;

@end

@implementation PFCTextFieldCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextFieldCheckboxCellView *)populateCellView:(PFCTextFieldCheckboxCellView *)cellView
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
    if (settings[PFCSettingsKeyValueCheckbox] != nil) {
        checkboxState = [settings[PFCSettingsKeyValueCheckbox] boolValue];
    } else if (manifest[PFCManifestKeyDefaultValueCheckbox]) {
        checkboxState = [manifest[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValueCheckbox]) {
        checkboxState = [settingsLocal[PFCSettingsKeyValueCheckbox] boolValue];
    }
    [[cellView settingCheckbox] setState:checkboxState];

    // ---------------------------------------------------------------------
    //  ValueTextField
    // ---------------------------------------------------------------------
    NSString *valueTextField;
    NSAttributedString *valueTextFieldAttributed = nil;
    if ([settings[PFCSettingsKeyValueTextField] length] != 0) {
        valueTextField = settings[PFCSettingsKeyValueTextField];
    } else if ([manifest[PFCManifestKeyDefaultValueTextField] length] != 0) {
        valueTextField = manifest[PFCManifestKeyDefaultValueTextField];
    } else if ([settingsLocal[PFCSettingsKeyValueTextField] length] != 0) {
        valueTextFieldAttributed =
            [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueTextField] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
    }

    if ([valueTextFieldAttributed length] != 0) {
        [[cellView settingTextField] setAttributedStringValue:valueTextFieldAttributed];
    } else {
        [[cellView settingTextField] setStringValue:valueTextField ?: @""];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value TextField
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValueTextField] length] != 0) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueTextField] ?: @""];
    } else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
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
    if (required && [valueTextField length] == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

- (void)showRequired:(BOOL)show {
    if (show) {
        [_constraintTextFieldPortTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldPortTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

@interface PFCTextFieldNoTitleCellView ()

@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldTrailing;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;

@end

@implementation PFCTextFieldNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextFieldNoTitleCellView *)populateCellView:(PFCTextFieldNoTitleCellView *)cellView
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
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if ([value length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValue] length] != 0) {
            value = manifest[PFCManifestKeyDefaultValue] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }

    if ([valueAttributed length] != 0) {
        [[cellView settingTextField] setAttributedStringValue:valueAttributed];
    } else {
        [[cellView settingTextField] setStringValue:value];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValue] length] != 0) {
        [[cellView settingTextField] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValue] ?: @""];
    } else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextField] setPlaceholderString:@""];
    }

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
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];

    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if (required && [value length] == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewTextField:settings:row

- (void)showRequired:(BOOL)show {
    if (show) {
        [_constraintTextFieldTrailing setConstant:34.0];
        [_imageViewRequired setHidden:NO];
    } else {
        [_constraintTextFieldTrailing setConstant:8.0];
        [_imageViewRequired setHidden:YES];
    }
} // showRequired

@end
