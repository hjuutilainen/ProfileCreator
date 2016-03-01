//
//  PFCCellTypeTextFieldHostPort.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "NSColor+PFCColors.h"
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
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
    BOOL requiredHost = [[PFCCellTypes sharedInstance] requiredHostForManifestContentDict:manifest displayKeys:displayKeys];
    BOOL requiredPort = [[PFCCellTypes sharedInstance] requiredPortForManifestContentDict:manifest displayKeys:displayKeys];

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
    if (requiredHost && [valueHost length] == 0) {
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
