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

    NSMutableArray *layoutConstraints = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Overrides (Availability)
    // -------------------------------------------------------------------------
    NSDictionary *overrides = [[PFCAvailability sharedInstance] overridesForManifestContentDict:manifestContentDict manifest:manifest settings:settings displayKeys:displayKeys];

    // -------------------------------------------------------------------------
    //  Required
    // -------------------------------------------------------------------------
    BOOL required = NO;
    if (overrides[PFCManifestKeyRequired] != nil) {
        required = [overrides[PFCManifestKeyRequired] boolValue];
    } else {
        required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }

    // -------------------------------------------------------------------------
    //  Optional
    // -------------------------------------------------------------------------
    BOOL optional = NO;
    if (overrides[PFCManifestKeyOptional] != nil) {
        optional = [overrides[PFCManifestKeyOptional] boolValue];
    } else {
        optional = [manifestContentDict[PFCManifestKeyOptional] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Enabled (if 'required' == YES, it can't be disabled)
    // -------------------------------------------------------------------------
    BOOL enabled = YES;
    if (!required) {
        if (settingsUser[PFCSettingsKeyEnabled] != nil) {
            enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
        } else if (overrides[PFCSettingsKeyEnabled] != nil) {
            enabled = [overrides[PFCSettingsKeyEnabled] boolValue];
        }
    }

    // -------------------------------------------------------------------------
    //  Supervised
    // -------------------------------------------------------------------------
    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // -------------------------------------------------------------------------
    //  Alignment
    // -------------------------------------------------------------------------
    BOOL alignRight = [manifestContentDict[PFCManifestKeyAlignRight] boolValue];
    NSInteger indentConstant = 0;
    NSString *constraintFormatTitle;
    NSString *constraintFormatDesription;
    NSString *constraintFormatTextField;
    if (alignRight) {
        indentConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevelRight:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:0];
        constraintFormatTitle = [NSString stringWithFormat:@"H:|-(8)-[textFieldTitle]-(%ld)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(8)-[textFieldDescription]-(%ld)-|", (long)indentConstant];
        constraintFormatTextField = [NSString stringWithFormat:@"H:|-(8)-[textField]-(%ld)-|", (long)indentConstant];
    } else {
        indentConstant = 8;
        if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
            indentConstant = 102;
        } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
            indentConstant =
                [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:0];
        }

        constraintFormatTitle = [NSString stringWithFormat:@"H:|-(%ld)-[textFieldTitle]-(8)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(%ld)-[textFieldDescription]-(8)-|", (long)indentConstant];
        constraintFormatTextField = [NSString stringWithFormat:@"H:|-(%ld)-[textField]-(8)-|", (long)indentConstant];
    }

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    NSTextField *textFieldTitle;
    if (title.length != 0) {

        textFieldTitle = [PFCCellTypes textFieldTitleWithString:[NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""]
                                                          width:(PFCSettingsColumnWidth - (8 + indentConstant))
                                                            tag:row
                                                     fontWeight:manifestContentDict[PFCManifestKeyFontWeight]
                                                 textAlignRight:alignRight
                                                        enabled:enabled
                                                         target:sender];

        [self setHeight:(self.height + 8 + textFieldTitle.intrinsicContentSize.height)];
        [self addSubview:textFieldTitle];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldTitle]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldTitle)]];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatTitle options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldTitle)]];
    }

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    NSString *description = manifestContentDict[PFCManifestKeyDescription] ?: @"";
    NSTextField *textFieldDescription;
    if (description.length != 0) {

        textFieldDescription =
            [PFCCellTypes textFieldDescriptionWithString:description width:(PFCSettingsColumnWidth - (8 + indentConstant)) tag:row textAlignRight:alignRight enabled:enabled target:sender];

        [self addSubview:textFieldDescription];
        [layoutConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatDesription options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldDescription)]];

        if (textFieldTitle) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(2)-[textFieldDescription]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldTitle, textFieldDescription)]];
            [self setHeight:(self.height + 2 + textFieldDescription.intrinsicContentSize.height)];
        } else {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldDescription]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldDescription)]];
            [self setHeight:(self.height + 8 + textFieldDescription.intrinsicContentSize.height)];
        }
    }

    // -------------------------------------------------------------------------
    //  Value
    // -------------------------------------------------------------------------
    NSString *value = settingsUser[PFCSettingsKeyValue] ?: @"";
    NSAttributedString *valueAttributed = nil;
    if (value.length == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
            value = manifestContentDict[PFCManifestKeyDefaultValue] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
            valueAttributed = [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValue] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    // -------------------------------------------------------------------------
    //  Placeholder Value
    // -------------------------------------------------------------------------
    NSString *placeholderString = @"";
    if ([manifestContentDict[PFCManifestKeyPlaceholderValue] length] != 0) {
        placeholderString = manifestContentDict[PFCManifestKeyPlaceholderValue] ?: @"";
    } else if (required) {
        placeholderString = @"Required";
    } else if (optional) {
        placeholderString = @"Optional";
    }

    // -------------------------------------------------------------------------
    //  TextField
    // -------------------------------------------------------------------------
    NSTextField *textField = [PFCCellTypes textFieldWithString:value placeholderString:placeholderString tag:row textAlignRight:alignRight enabled:enabled target:sender];
    if (valueAttributed.length != 0) {
        [textField setAttributedStringValue:valueAttributed];
    }
    [self addSubview:textField];

    // -------------------------------------------------------------------------
    //  TextFieldLocation Right
    // -------------------------------------------------------------------------
    if (textField && [manifestContentDict[@"TextFieldLocation"] isEqualToString:@"Right"]) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldTitle]-(4)-[textField]-(8)-|"
                                                                                       options:NSLayoutFormatAlignAllFirstBaseline
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(textFieldTitle, textField)]];

        // -------------------------------------------------------------------------
        //  TextFieldLocation Left
        // -------------------------------------------------------------------------
    } else if (textField && [manifestContentDict[@"TextFieldLocation"] isEqualToString:@"Left"]) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[textField]-(4)-[textFieldTitle]"
                                                                                       options:NSLayoutFormatAlignAllFirstBaseline
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(textField, textFieldTitle)]];

        // ---------------------------------------------------------------------
        //  TextFieldLocation "Below"
        // ---------------------------------------------------------------------
    } else {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatTextField options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
        if (textFieldDescription) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldDescription]-(7)-[textField]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldDescription, textField)]];
            [self setHeight:(self.height + 7 + textField.intrinsicContentSize.height)];
        } else if (textFieldTitle) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(7)-[textField]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldTitle, textField)]];
            [self setHeight:(self.height + 7 + textField.intrinsicContentSize.height)];
        } else {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textField]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
            [self setHeight:(self.height + 8 + textField.intrinsicContentSize.height)];
        }
    }

    // -------------------------------------------------------------------------
    //  Tool Tip
    // -------------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // -------------------------------------------------------------------------
    //  Required
    // -------------------------------------------------------------------------
    if (required && value.length == 0) {
        [self showRequired:YES];
    } else {
        [self showRequired:NO];
    }

    // -------------------------------------------------------------------------
    //  Activate Layout Constraints
    // -------------------------------------------------------------------------
    [NSLayoutConstraint activateConstraints:layoutConstraints];

    // -------------------------------------------------------------------------
    //  Height
    // -------------------------------------------------------------------------
    [self setHeight:(self.height + 3)];

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
        //[_constraintTextFieldTrailing setConstant:34.0];
        //[_imageViewRequired setHidden:NO];
    } else {
        //[_constraintTextFieldTrailing setConstant:8.0];
        //[_imageViewRequired setHidden:YES];
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
