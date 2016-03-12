//
//  PFCCellTypeTextFieldHostPort.m
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
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCTextFieldHostPortCellView ()

@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldPortTrailing;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCTextFieldHostPortCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextFieldHostPortCellView *)populateCellView:(PFCTextFieldHostPortCellView *)cellView
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
    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifest displayKeys:displayKeys];
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if ((!requiredHost || !requiredPort) && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    BOOL optional = [manifest[PFCManifestKeyOptional] boolValue];

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
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settings[PFCSettingsKeyValueHost] ?: @"";
    NSAttributedString *valueHostAttributed = nil;
    if ([valueHost length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValueHost] length] != 0) {
            valueHost = manifest[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValueHost] length] != 0) {
            valueHostAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }
    if ([valueHostAttributed length] != 0) {
        [[cellView settingTextFieldHost] setAttributedStringValue:valueHostAttributed];
    } else {
        [[cellView settingTextFieldHost] setStringValue:valueHost];
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValueHost] length] != 0) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueHost] ?: @""];
    } else if (requiredHost) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else if (optional) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settings[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valuePortAttributed = nil;
    if ([valuePort length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValuePort] length] != 0) {
            valuePort = manifest[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValuePort] length] != 0) {
            valuePortAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }

    if ([valuePortAttributed length] != 0) {
        [[cellView settingTextFieldPort] setAttributedStringValue:valuePortAttributed];
    } else {
        [[cellView settingTextFieldPort] setStringValue:valuePort];
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValuePort] length] != 0) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValuePort] ?: @""];
    } else if (requiredPort) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else if (optional) {
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
    if (requiredHost && [valueHost length] == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if ([contentDictSettings count] == 0) {
        DDLogDebug(@"No settings!");
    }
    // Host
    NSMutableArray *array = [NSMutableArray array];

    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if ([valueHost length] == 0) {
        valueHost = contentDictSettings[PFCManifestKeyDefaultValueHost];
    }

    if (requiredHost && [valueHost length] == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    // Port
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if ([valuePort length] == 0) {
        valuePort = contentDictSettings[PFCManifestKeyDefaultValuePort];
    }

    if (requiredPort && [valuePort length] == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    if ([array count] != 0) {
        return @{identifier : [array copy]};
    }

    return nil;
}

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

@interface PFCTextFieldHostPortCheckboxCellView ()

@property BOOL checkboxState;
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldPortTrailing;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCTextFieldHostPortCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextFieldHostPortCheckboxCellView *)populateCellView:(PFCTextFieldHostPortCheckboxCellView *)cellView
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
    BOOL requiredHost = [[PFCCellTypes sharedInstance] requiredHostForManifestContentDict:manifest displayKeys:displayKeys];
    BOOL requiredPort = [[PFCCellTypes sharedInstance] requiredPortForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if ((!requiredHost || !requiredPort) && settings[PFCSettingsKeyEnabled] != nil) {
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
    if (settings[PFCSettingsKeyValueCheckbox] != nil) {
        checkboxState = [settings[PFCSettingsKeyValueCheckbox] boolValue];
    } else if (manifest[PFCManifestKeyDefaultValueCheckbox]) {
        checkboxState = [manifest[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValueCheckbox]) {
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
    if ([valueHost length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValueHost] length] != 0) {
            valueHost = manifest[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValueHost] length] != 0) {
            valueHostAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }

    if ([valueHostAttributed length] != 0) {
        [[cellView settingTextFieldHost] setAttributedStringValue:valueHostAttributed];
    } else {
        [[cellView settingTextFieldHost] setStringValue:valueHost];
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value Host
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValueHost] length] != 0) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValueHost] ?: @""];
    } else if (requiredHost) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else if (optional) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settings[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valuePortAttributed = nil;
    if ([valuePort length] == 0) {
        if ([manifest[PFCManifestKeyDefaultValuePort] length] != 0) {
            valuePort = manifest[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValuePort] length] != 0) {
            valuePortAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @"" attributes:@{NSForegroundColorAttributeName : [NSColor localSettingsColor]}];
        }
    }

    if ([valueHostAttributed length] != 0) {
        [[cellView settingTextFieldPort] setAttributedStringValue:valuePortAttributed];
    } else {
        [[cellView settingTextFieldPort] setStringValue:valuePort];
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifest[PFCManifestKeyPlaceholderValuePort] length] != 0) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifest[PFCManifestKeyPlaceholderValuePort] ?: @""];
    } else if (requiredPort) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else if (optional) {
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
    [[cellView settingTextFieldHost] bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingTextFieldPort] bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    [[cellView settingTextFieldHost] setEnabled:enabled];
    [[cellView settingTextFieldPort] setEnabled:enabled];

    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if ((requiredHost || requiredPort) && [valueHost length] == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewSettingsTextFieldHostPort:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if ([contentDictSettings count] == 0) {
        DDLogDebug(@"No settings!");
    }
    // Host
    NSMutableArray *array = [NSMutableArray array];

    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if ([valueHost length] == 0) {
        valueHost = contentDictSettings[PFCManifestKeyDefaultValueHost];
    }

    if (requiredHost && [valueHost length] == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    // Port
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSNumber *valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if (valuePort == nil) {
        valuePort = contentDictSettings[PFCManifestKeyDefaultValuePort];
    }

    if (requiredPort && valuePort == nil) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    if ([array count] != 0) {
        return @{identifier : [array copy]};
    }

    return nil;
}

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
