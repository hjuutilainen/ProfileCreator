//
//  PFCCellTypePopUpButton.m
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
#import "PFCCellTypePopUpButton.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCPopUpButtonCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonCellView *)populateCellView:(PFCPopUpButtonCellView *)cellView
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

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
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
    if ([settings[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if ([manifest[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if ([selectedItem length] != 0) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ([[[cellView settingPopUpButton] itemArray] count] != 0) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
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

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return nil;
    }

    NSString *selectedItem = settings[PFCSettingsKeyValue];
    if ([selectedItem length] == 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    if ([selectedItem length] == 0) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"No Selection" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    if (![manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] containsObject:selectedItem]) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"Invalid Selection" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys];
    if (valueKeys[selectedItem]) {
        return [[PFCManifestParser sharedParser] settingsErrorForManifestContent:valueKeys[selectedItem] settings:settings displayKeys:displayKeys];
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray *__autoreleasing *)payloads sender:(PFCProfileExport *)sender {
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'PopUpButton'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyAvailableValues ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get selected title
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (value == nil) {
        DDLogError(@"Value is empty");
        return;
    } else if (![[value class] isSubclassOfClass:[NSString class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([NSString class]) ]];
    } else {
        DDLogDebug(@"Selected title: %@", value);
    }

    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [sender createPayloadFromValueKey:value
                      availableValues:manifestContentDict[PFCManifestKeyAvailableValues]
                  manifestContentDict:manifestContentDict
                             settings:settings
                           payloadKey:nil
                          payloadType:nil
                          payloadUUID:nil
                             payloads:payloads];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean, PFCValueTypeString ];

    // -------------------------------------------------------------------------
    //  AvailableValues/ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                      required:YES
                                               availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];
    [lintReport addObjectsFromArray:[sender reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Indentation
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    return [lintReport copy];
}

@end

@interface PFCPopUpButtonLeftCellView ()

@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonLeftCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonLeftCellView *)populateCellView:(PFCPopUpButtonLeftCellView *)cellView
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

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
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
    if ([settings[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if ([manifest[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if ([selectedItem length] != 0) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ([[[cellView settingPopUpButton] itemArray] count] != 0) {
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

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    return [PFCPopUpButtonCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray *__autoreleasing *)payloads sender:(PFCProfileExport *)sender {
    return [PFCPopUpButtonCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean, PFCValueTypeString ];

    // -------------------------------------------------------------------------
    //  AvailableValues/ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                      required:YES
                                               availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];
    [lintReport addObjectsFromArray:[sender reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    return [lintReport copy];
}

@end

@interface PFCPopUpButtonNoTitleCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonNoTitleCellView *)populateCellView:(PFCPopUpButtonNoTitleCellView *)cellView
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
    if ([settings[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if ([manifest[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if ([selectedItem length] != 0) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ([[[cellView settingPopUpButton] itemArray] count] != 0) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
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

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    return [PFCPopUpButtonCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray *__autoreleasing *)payloads sender:(PFCProfileExport *)sender {
    return [PFCPopUpButtonCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean, PFCValueTypeString ];

    // -------------------------------------------------------------------------
    //  AvailableValues/ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                      required:YES
                                               availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];
    [lintReport addObjectsFromArray:[sender reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Indentation
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    return [lintReport copy];
}

@end
