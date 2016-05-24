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
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileExport.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldNumberCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCTextFieldNumberCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingTitle;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingDescription;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingTextField;

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

- (instancetype)populateCellView:(PFCTextFieldNumberCellView *)cellView
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
        optional = [overrides[PFCManifestKeyOptional] boolValue];
    } else {
        optional = [manifestContentDict[PFCManifestKeyOptional] boolValue];
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
    //  Indentation
    // ---------------------------------------------------------------------
    CGFloat constraintConstant = 8;
    if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
        constraintConstant = 102;
    } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifestContentDict[PFCManifestKeyIndentLevel] baseConstant:@(PFCIndentLevelBaseConstant)];
    }
    [[cellView constraintLeadingTextField] setConstant:constraintConstant];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    if (title.length != 0) {
        title = [NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""];
        [[cellView settingTitle] setStringValue:title];
        [[cellView constraintLeadingTitle] setConstant:constraintConstant];
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
        [[cellView constraintLeadingDescription] setConstant:constraintConstant];
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
    //  Unit
    // ---------------------------------------------------------------------
    [cellView.settingUnit setStringValue:manifestContentDict[PFCManifestKeyUnit] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settingsUser[PFCSettingsKeyValue];
    if (value == nil) {
        if (manifestContentDict[PFCManifestKeyDefaultValue] != nil) {
            value = manifestContentDict[PFCManifestKeyDefaultValue];
        } else if (settingsLocal[PFCSettingsKeyValue] != nil) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [cellView.settingTextField setDelegate:sender];
    [cellView.settingTextField setStringValue:[value ?: @0 stringValue]];
    [cellView.settingTextField setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyPlaceholderValue] != nil) {
        [cellView.settingTextField setPlaceholderString:[manifestContentDict[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if (required) {
        [cellView.settingTextField setPlaceholderString:@"Required"];
    } else if (optional) {
        [cellView.settingTextField setPlaceholderString:@"Optional"];
    } else {
        [cellView.settingTextField setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [cellView.settingNumberFormatter setMinimum:manifestContentDict[PFCManifestKeyMinValue] ?: @0];
    [cellView.settingStepper setMinValue:[manifestContentDict[PFCManifestKeyMinValue] doubleValue] ?: 0.0];

    [cellView.settingNumberFormatter setMaximum:manifestContentDict[PFCManifestKeyMaxValue] ?: @99999];
    [cellView.settingStepper setMaxValue:[manifestContentDict[PFCManifestKeyMaxValue] doubleValue] ?: 99999.0];

    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [cellView.settingStepper setValueWraps:NO];
    if (_stepperValue == nil) {
        [self setStepperValue:value];
    }
    [cellView.settingTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [cellView.settingStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [cellView.settingTextField setEnabled:enabled];
    [cellView.settingStepper setEnabled:enabled];

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
    NSNumber *value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = contentDictSettings[PFCManifestKeyDefaultValue];
    }

    NSNumber *minValue = manifestContentDict[PFCManifestKeyMinValue];
    NSNumber *maxValue = manifestContentDict[PFCManifestKeyMaxValue];

    if (required && (value == nil || value <= minValue || maxValue < value)) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldNumber'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey, PFCManifestKeyPayloadValueType ]
                                   manifestContentDict:manifestContentDict]) {
        return;
    }

    NSString *payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];

    // -------------------------------------------------------------------------
    //  Verify PayloadValueType is set and valid
    // -------------------------------------------------------------------------
    NSString *payloadValueType = manifestContentDict[PFCManifestKeyPayloadValueType];
    if (![payloadValueType isEqualToString:@"Integer"] && ![payloadValueType isEqualToString:@"Float"]) {
        DDLogError(@"Unknown PayloadValueType: %@ for CellType: %@", payloadValueType, PFCCellTypeTextFieldNumber);
        return;
    }

    // -------------------------------------------------------------------------
    //  Get value
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    if (value == nil) {
        // FIXME - Value for a number cannot be empty, how to handle this?
        DDLogError(@"Value is empty");
        return;
    } else if (![[value class] isSubclassOfClass:[@(0) class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([@(0) class]) ]];
    }

    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

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
    } else {
        payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }

    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    if ([payloadValueType isEqualToString:@"Integer"]) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value integerValue]);
    } else if ([payloadValueType isEqualToString:@"Float"]) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value floatValue]);
    }

    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if (index != NSNotFound) {
        [*payloads replaceObjectAtIndex:index withObject:payloadDictDict.copy];
    } else {
        [*payloads addObject:payloadDictDict.copy];
    }
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeInteger, PFCValueTypeFloat ]]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForUnit:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMaxValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMinValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldNumberLeftCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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

- (instancetype)populateCellView:(PFCTextFieldNumberLeftCellView *)cellView
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

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:[NSString stringWithFormat:@"%@%@", manifestContentDict[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];
    if (enabled) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestContentDict[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSNumber *value = settingsUser[PFCSettingsKeyValue];
    if (value == nil) {
        if (manifestContentDict[PFCManifestKeyDefaultValue] != nil) {
            value = manifestContentDict[PFCManifestKeyDefaultValue];
        } else if (settingsLocal[PFCSettingsKeyValue] != nil) {
            value = settingsLocal[PFCSettingsKeyValue];
        }
    }
    [cellView.settingTextField setDelegate:sender];
    [cellView.settingTextField setStringValue:[value ?: @0 stringValue]];
    [cellView.settingTextField setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyPlaceholderValue] != nil) {
        [cellView.settingTextField setPlaceholderString:[manifestContentDict[PFCManifestKeyPlaceholderValue] stringValue] ?: @""];
    } else if (required) {
        [cellView.settingTextField setPlaceholderString:@"Required"];
    } else if (optional) {
        [cellView.settingTextField setPlaceholderString:@"Optional"];
    } else {
        [cellView.settingTextField setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    [cellView.settingNumberFormatter setMinimum:manifestContentDict[PFCManifestKeyMinValue] ?: @0];
    [cellView.settingStepper setMinValue:[manifestContentDict[PFCManifestKeyMinValue] doubleValue] ?: 0.0];

    [cellView.settingNumberFormatter setMaximum:manifestContentDict[PFCManifestKeyMaxValue] ?: @99999];
    [cellView.settingStepper setMaxValue:[manifestContentDict[PFCManifestKeyMaxValue] doubleValue] ?: 99999.0];

    // ---------------------------------------------------------------------
    //  Stepper
    // ---------------------------------------------------------------------
    [cellView.settingStepper setValueWraps:NO];
    if (_stepperValue == nil) {
        [self setStepperValue:settingsUser[PFCSettingsKeyValue] ?: @0];
    }
    [cellView.settingTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [cellView.settingStepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(stepperValue)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [cellView.settingTextField setEnabled:enabled];
    [cellView.settingStepper setEnabled:enabled];

    return cellView;
} // populateCellViewTextField:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    return [PFCTextFieldNumberCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {
    [PFCTextFieldNumberCellView createPayloadForCellType:manifestContentDict manifest:manifest settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    // This might not catch all keys, for example the "left" key etc. Either do own implementation or add extra checks.
    return [PFCTextFieldNumberCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath sender:sender];
}

@end
