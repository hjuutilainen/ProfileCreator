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
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCCheckboxCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(id)cellView
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

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    NSString *checkboxState = [settings[PFCSettingsKeyValue] boolValue] ? @"True" : @"False";
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys];
    if (valueKeys[checkboxState]) {
        return [[PFCManifestParser sharedParser] settingsErrorForManifestContent:valueKeys[checkboxState] settings:settings displayKeys:displayKeys];
    }
    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'Checkbox'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get value for Checkbox
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    // -------------------------------------------------------------------------
    //  Verify CheckboxValue is of the expected class type(s)
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (value == nil) {
        DDLogWarn(@"CheckboxValue is empty");

        if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return;
        }
    } else if (![[value class] isEqualTo:[@(YES) class]] && ![[value class] isEqualTo:[@(0) class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([value class])
                                      payloadKey:manifestContentDict[PFCManifestKeyPayloadType]
                                exptectedClasses:@[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]];
    } else {
        checkboxState = [(NSNumber *)value boolValue];
        DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
    }

    // ---------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // ---------------------------------------------------------------------
    // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

    if ([sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey ] manifestContentDict:manifestContentDict]) {

        // -------------------------------------------------------------------------
        //  Get index of current payload in payload array
        // -------------------------------------------------------------------------
        NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
          return [item[PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
        }];

        // ----------------------------------------------------------------------------------
        //  Create mutable version of current payload, or create new payload if none existed
        // ----------------------------------------------------------------------------------
        NSMutableDictionary *payloadDictDict;
        if (index != NSNotFound) {
            payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
            DDLogDebug(@"Current Payload Dict: %@", payloadDictDict);
        } else {
            payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
            DDLogDebug(@"Creating NEW Dict for current Payload");
        }

        // -------------------------------------------------------------------------
        //  Add current key and value to payload (if PayloadValueType is empty or Boolean)
        // -------------------------------------------------------------------------
        DDLogDebug(@"manifestContentDict[PFCManifestKeyPayloadValueType]=%@", manifestContentDict[PFCManifestKeyPayloadValueType]);
        if (manifestContentDict[PFCManifestKeyPayloadValueType] == nil || [manifestContentDict[PFCManifestKeyPayloadValueType] isEqualToString:@"Boolean"]) {
            DDLogDebug(@"Setting the boolean value of the checkbox as the key value!");
            payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = @(checkboxState);

            // -------------------------------------------------------------------------
            //  Save payload to payload array
            // -------------------------------------------------------------------------
            if (index != NSNotFound) {
                [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
            } else {
                [*payloads addObject:[payloadDictDict copy]];
            }
        }
    }

    // -------------------------------------------------------------------------
    //  Resolve any
    // -------------------------------------------------------------------------
    [sender createPayloadFromValueKey:(checkboxState) ? @"True" : @"False"
                      availableValues:@[ @"True", @"False" ]
                  manifestContentDict:manifestContentDict
                             manifest:manifest
                             settings:settings
                           payloadKey:nil
                          payloadType:nil
                          payloadUUID:nil
                             payloads:payloads];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean ];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Indentation
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:NO availableValues:@[ @"True", @"False" ]]];

    return [lintReport copy];
}

@end

@interface PFCCheckboxNoDescriptionCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;

@end

@implementation PFCCheckboxNoDescriptionCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(id)cellView
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

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    return [PFCCheckboxCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {
    return [PFCCheckboxCellView createPayloadForCellType:manifestContentDict manifest:manifest settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean ];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  FontWeight
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForFontWeight:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Indentation
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:NO availableValues:@[ @"True", @"False" ]]];

    return [lintReport copy];
}

@end
