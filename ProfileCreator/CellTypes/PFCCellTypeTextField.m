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
#import "PFCError.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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

- (instancetype)populateCellView:(id)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // -------------------------------------------------------------------------
    //  Get availability overrides
    // -------------------------------------------------------------------------
    NSDictionary *overrides = [[PFCAvailability sharedInstance] overridesForManifestContentDict:manifestContentDict manifest:manifest settings:settings displayKeys:displayKeys];

    // ---------------------------------------------------------------------------------------
    //  Get required state for this cell view
    // ---------------------------------------------------------------------------------------
    BOOL required = NO;
    if (overrides[PFCManifestKeyRequired] != nil) {
        required = [overrides[PFCManifestKeyRequired] boolValue];
    } else {
        required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }

    // ---------------------------------------------------------------------------------------
    //  Get optional state for this cell view
    // ---------------------------------------------------------------------------------------
    BOOL optional = NO;
    if (overrides[PFCManifestKeyOptional] != nil) {
        required = [overrides[PFCManifestKeyOptional] boolValue];
    } else {
        required = [manifestContentDict[PFCManifestKeyOptional] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Determine if UI should be enabled or disabled
    //  If 'required', it cannot be disabled
    // -------------------------------------------------------------------------
    BOOL enabled = YES;
    if (!required) {
        if (settingsUser[PFCSettingsKeyEnabled] != nil) {
            enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
        } else if (overrides[PFCSettingsKeyEnabled] != nil) {
            enabled = [overrides[PFCSettingsKeyEnabled] boolValue];
        }
    }

    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    if (title.length != 0) {
        title = [NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""];
        [[cellView settingTitle] setStringValue:title];
        if (enabled) {
            [[cellView settingTitle] setTextColor:[NSColor blackColor]];
        } else {
            [[cellView settingTitle] setTextColor:[NSColor grayColor]];
        }
    } else {
        [[cellView settingTitle] removeFromSuperview];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingDescription]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_settingDescription, _settingTextField)]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    NSString *description = manifestContentDict[PFCManifestKeyDescription] ?: @"";
    if (description.length != 0) {
        [[cellView settingDescription] setStringValue:description];
    } else {
        [[cellView settingDescription] removeFromSuperview];
        if (title.length != 0) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingTitle]-[_settingTextField]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_settingTitle, _settingTextField)]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingTextField]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingTextField)]];
        }
    }

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settingsUser[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if (value.length == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
            value = manifestContentDict[PFCManifestKeyDefaultValue] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    if (valueAttributed.length != 0) {
        [[cellView settingTextField] setAttributedStringValue:valueAttributed];
    } else {
        [[cellView settingTextField] setStringValue:value];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyPlaceholderValue] length] != 0) {
        [[cellView settingTextField] setPlaceholderString:manifestContentDict[PFCManifestKeyPlaceholderValue] ?: @""];
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
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setEnabled:enabled];

    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if (required && value.length == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    return cellView;
} // populateCellViewTextField:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if (identifier.length == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if (contentDictSettings.count == 0) {
        DDLogDebug(@"No settings!");
    }

    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    NSString *value = contentDictSettings[PFCSettingsKeyValue];
    if (value.length == 0) {
        value = contentDictSettings[PFCManifestKeyDefaultValue];
    }

    if (required && value.length == 0) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray **)payloads
                          sender:(PFCProfileExport *)sender {

    NSString *payloadKey;
    id value;

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextField'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Process any availability overrides
    // -------------------------------------------------------------------------
    NSDictionary *availabilityOverrides = [[PFCAvailability sharedInstance] overridesForManifestContentDict:manifestContentDict manifest:manifest settings:settings displayKeys:@{}];

    // -------------------------------------------------------------------------
    //  Get value for current PayloadKey
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (value == nil || ([[value class] isSubclassOfClass:[NSString class]] && [value length] == 0)) {
        DDLogDebug(@"PayloadValue is empty");

        if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return;
        }

        value = @"";
    } else if (![[value class] isSubclassOfClass:[NSString class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([NSString class]) ]];
    } else {
        DDLogDebug(@"PayloadValue: %@", value);
    }

    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

    NSString *payloadType = manifestContentDict[PFCManifestKeyPayloadType];
    if ([PFCGeneralUtility isValidUUID:payloadType]) {
        if (payloadType == manifestContentDict[PFCManifestKeyIdentifier]) {
            payloadType = value;
        } else {
            NSString *resolvedPayloadType = [sender resolvedPayloadTypes][payloadType];
            if (resolvedPayloadType.length == 0) {
                payloadType = [sender payloadTypeFromUUID:payloadType manifest:manifest settings:settings];
                if (payloadType.length == 0) {
                    DDLogError(@"Unable to resolve PayloadType for manifest content dict!");
                    return;
                }
            } else {
                payloadType = resolvedPayloadType;
            }
        }
    }
    DDLogDebug(@"PayloadType: %@", payloadType);

    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [item[PFCManifestKeyPayloadUUID] isEqualToString:settings[payloadType][PFCProfileTemplateKeyUUID] ?: @""];
    }];

    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if (index != NSNotFound) {
        payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
    } else {
        payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadType payloadUUID:nil];
    }

    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadKey = availabilityOverrides[PFCManifestKeyPayloadKey] ?: manifestContentDict[PFCManifestKeyPayloadKey];
    payloadDictDict[payloadKey] = value;

    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if (index != NSNotFound) {
        [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeString ];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Default/Placeholder Value
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];
    [lintReport
        addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Payload Keys
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    return [lintReport copy];
}

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldCheckboxCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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

- (instancetype)populateCellView:(id)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    BOOL optional = [manifestContentDict[PFCManifestKeyOptional] boolValue];
    BOOL enabled = YES;
    if (!required && settingsUser[PFCSettingsKeyEnabled] != nil) {
        enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
    }
    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title (of the Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:[NSString stringWithFormat:@"%@%@", manifestContentDict[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestContentDict[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  ValueCheckbox
    // ---------------------------------------------------------------------
    if (settingsUser[PFCSettingsKeyValueCheckbox] != nil) {
        [self setCheckboxState:[settingsUser[PFCSettingsKeyValueCheckbox] boolValue]];
    } else if (manifestContentDict[PFCManifestKeyDefaultValueCheckbox]) {
        [self setCheckboxState:[manifestContentDict[PFCManifestKeyDefaultValueCheckbox] boolValue]];
    } else if (settingsLocal[PFCSettingsKeyValueCheckbox]) {
        [self setCheckboxState:[settingsLocal[PFCSettingsKeyValueCheckbox] boolValue]];
    }

    // ---------------------------------------------------------------------
    //  ValueTextField
    // ---------------------------------------------------------------------
    NSString *valueTextField;
    NSAttributedString *valueTextFieldAttributed = nil;
    if ([settingsUser[PFCSettingsKeyValueTextField] length] != 0) {
        valueTextField = settingsUser[PFCSettingsKeyValueTextField];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValueTextField] length] != 0) {
        valueTextField = manifestContentDict[PFCManifestKeyDefaultValueTextField];
    } else if ([settingsLocal[PFCSettingsKeyValueTextField] length] != 0) {
        valueTextFieldAttributed =
            [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueTextField] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
    }

    if (valueTextFieldAttributed.length != 0) {
        [[cellView settingTextField] setAttributedStringValue:valueTextFieldAttributed];
    } else {
        [[cellView settingTextField] setStringValue:valueTextField ?: @""];
    }
    [[cellView settingTextField] setDelegate:sender];
    [[cellView settingTextField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value TextField
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyPlaceholderValueTextField] length] != 0) {
        [[cellView settingTextField] setPlaceholderString:manifestContentDict[PFCManifestKeyPlaceholderValueTextField] ?: @""];
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
    [[cellView settingTextField] bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

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
    if (required && valueTextField.length == 0) {
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
    if (identifier.length == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if (contentDictSettings.count == 0) {
        DDLogDebug(@"No settings!");
    }

    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    NSString *value = contentDictSettings[PFCSettingsKeyValueTextField];
    if (value.length == 0) {
        value = contentDictSettings[PFCManifestKeyDefaultValueTextField];
    }

    if (required && value.length == 0) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray **)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldCheckbox'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get value for Checkbox
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id valueCheckbox = contentDictSettings[PFCSettingsKeyValueCheckbox];
    if (valueCheckbox == nil) {
        valueCheckbox = manifestContentDict[PFCManifestKeyDefaultValueCheckbox];
    }

    // -------------------------------------------------------------------------
    //  Verify CheckboxValue is of the expected class type(s)
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (valueCheckbox == nil) {
        DDLogWarn(@"CheckboxValue is empty");

        if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
            // FIXME - Log this different, if checkbox payload key is empty for example, or log both payload keys?
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]);
            return;
        }
    } else if (![[valueCheckbox class] isEqualTo:[@(YES) class]] && ![[valueCheckbox class] isEqualTo:[@(0) class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([valueCheckbox class])
                                      payloadKey:manifestContentDict[PFCManifestKeyPayloadType]
                                exptectedClasses:@[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]];
    } else {
        checkboxState = [(NSNumber *)valueCheckbox boolValue];
        DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
    }

    // -------------------------------------------------------------------------
    //  If Checkbox is enabled, verify required keys for TextField
    // -------------------------------------------------------------------------
    if (checkboxState && [sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadKeyTextField ] manifestContentDict:manifestContentDict]) {

        // ---------------------------------------------------------------------
        //  Get value for TextField
        // ---------------------------------------------------------------------
        id valueTextField = contentDictSettings[PFCSettingsKeyValue];
        if (valueTextField == nil) {
            valueTextField = manifestContentDict[PFCManifestKeyDefaultValue];
        }

        // ---------------------------------------------------------------------
        //  Verify value is of the expected class type(s)
        // ---------------------------------------------------------------------
        if (valueTextField == nil || ([[valueTextField class] isSubclassOfClass:[NSString class]] && [valueTextField length] == 0)) {
            DDLogDebug(@"PayloadValue is empty");

            if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
                DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
                return;
            }

            valueTextField = @"";
        } else if (![[valueTextField class] isSubclassOfClass:[NSString class]]) {
            return [sender payloadErrorForValueClass:NSStringFromClass([valueTextField class])
                                          payloadKey:manifestContentDict[PFCManifestKeyPayloadType]
                                    exptectedClasses:@[ NSStringFromClass([NSString class]) ]];
        } else {
            DDLogDebug(@"PayloadValue: %@", valueTextField);
        }

        // ---------------------------------------------------------------------
        //  Resolve any nested payload keys
        //  FIXME - Need to implement this for nested keys
        // ---------------------------------------------------------------------
        // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

        //  FIXME - Add UUID for PayloadTypeTextField/Checkbox
        //  FIXME - Rename PFCProfileTemplateKeyUUID to PayloadUUID and use a SettingsKey
        NSString *payloadTypeTextField;
        NSString *payloadUUIDTextField;
        if (manifestContentDict[PFCManifestKeyPayloadTypeCheckbox] != nil) {
            payloadTypeTextField = manifestContentDict[PFCManifestKeyPayloadTypeTextField];
            payloadUUIDTextField = settings[@"PayloadUUIDTextField"] ?: settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
        } else {
            payloadTypeTextField = manifestContentDict[PFCManifestKeyPayloadType];
            payloadUUIDTextField = settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
        }

        // ---------------------------------------------------------------------
        //  Get index of current payload in payload array
        // ---------------------------------------------------------------------
        NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
          return [item[PFCManifestKeyPayloadUUID] isEqualToString:payloadUUIDTextField ?: @""];
        }];

        // ----------------------------------------------------------------------------------
        //  Create mutable version of current payload, or create new payload if none existed
        // ----------------------------------------------------------------------------------
        NSMutableDictionary *payloadDictDict;
        if (index != NSNotFound) {
            payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
        } else {
            payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadTypeTextField payloadUUID:payloadUUIDTextField];
        }

        // ---------------------------------------------------------------------
        //  Add current key and value to payload
        // ---------------------------------------------------------------------
        payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKeyTextField]] = valueTextField;

        // ---------------------------------------------------------------------
        //  Save payload to payload array
        // ---------------------------------------------------------------------
        if (index != NSNotFound) {
            [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
        } else {
            [*payloads addObject:[payloadDictDict copy]];
        }
    }

    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadKeyCheckbox ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

    //  FIXME - Add UUID for PayloadTypeTextField/Checkbox
    //  FIXME - Rename PFCProfileTemplateKeyUUID to PayloadUUID and use a SettingsKey
    NSString *payloadTypeCheckbox;
    NSString *payloadUUIDCheckbox;
    if (manifestContentDict[PFCManifestKeyPayloadTypeCheckbox] != nil) {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadTypeCheckbox];
        payloadUUIDCheckbox = settings[@"PayloadUUIDCheckbox"] ?: settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    } else {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadType];
        payloadUUIDCheckbox = settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    }

    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [item[PFCManifestKeyPayloadUUID] isEqualToString:payloadUUIDCheckbox ?: @""];
    }];

    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if (index != NSNotFound) {
        payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
    } else {
        payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadTypeCheckbox payloadUUID:payloadUUIDCheckbox];
    }

    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]] = @(checkboxState);

    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if (index != NSNotFound) {
        [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }

    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [sender createPayloadFromValueKey:(checkboxState) ? @"True" : @"False"
                      availableValues:manifestContentDict[PFCManifestKeyAvailableValues]
                  manifestContentDict:manifestContentDict
                             manifest:manifest
                             settings:settings
                           payloadKey:manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]
                          payloadType:payloadTypeCheckbox
                          payloadUUID:payloadUUIDCheckbox
                             payloads:payloads];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:YES availableValues:@[ @"True", @"False" ]]];

    // -------------------------------------------------------------------------
    //  ValueKeysShared
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Default Values
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValueCheckbox
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeBoolean ]]];

    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValueTextField
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeString ]]];

    // -------------------------------------------------------------------------
    //  Placeholder Values
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValueTextField
                                           manifestContentDict:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                  allowedTypes:@[ PFCValueTypeString ]]];

    // -------------------------------------------------------------------------
    //  Payload Keys
    // -------------------------------------------------------------------------
    NSArray *payloadKeys = @[
        @{ @"PayloadKeySuffix" : @"Checkbox",
           @"AllowedTypes" : @[ PFCValueTypeBoolean ] },

        @{ @"PayloadKeySuffix" : @"TextField",
           @"AllowedTypes" : @[ PFCValueTypeString ] }
    ];
    [lintReport
        addObjectsFromArray:[sender reportForPayloadKeys:payloadKeys manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]];

    return [lintReport copy];
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
