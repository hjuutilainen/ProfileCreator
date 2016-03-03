//
//  PFCCellTypeTextView.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-24.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "NSColor+PFCColors.h"
#import "PFCCellTypeTextView.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCAvailability.h"

@interface PFCTextViewCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldTrailing;
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;

@end

@implementation PFCTextViewCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCTextViewCellView *)populateCellView:(PFCTextViewCellView *)cellView
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
} // populateTextView:settings:row

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
