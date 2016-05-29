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

#import "NSColor+PFCColors.h"
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
@property NSNumber *value;
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
    NSString *constraintFormatTextFieldNumber;
    if (alignRight) {
        indentConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevelRight:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:0];
        constraintFormatTitle = [NSString stringWithFormat:@"H:|-(8)-[textFieldTitle]-(%ld)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(8)-[textFieldDescription]-(%ld)-|", (long)indentConstant];
        // constraintFormatTextFieldNumber = [NSString stringWithFormat:@"H:|-(>=8)-[stepper]-(3)-[textFieldNumber]-(%ld)-|", (long)indentConstant];
        constraintFormatTextFieldNumber = [NSString stringWithFormat:@"H:[textFieldNumber]-(%ld)-|", (long)indentConstant];
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
        // constraintFormatTextFieldNumber = [NSString stringWithFormat:@"H:|-(%ld)-[textFieldNumber]-(3)-[stepper]-(>=8)-|", (long)indentConstant];
        constraintFormatTextFieldNumber = [NSString stringWithFormat:@"H:|-(%ld)-[textFieldNumber]", (long)indentConstant];
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
    NSNumber *value = settingsUser[PFCSettingsKeyValue];
    NSAttributedString *valueAttributed = nil;
    if (value == nil) {
        if (manifestContentDict[PFCManifestKeyDefaultValue] != nil) {
            value = manifestContentDict[PFCManifestKeyDefaultValue];
        } else if (settingsLocal[PFCSettingsKeyValue] != nil) {
            valueAttributed =
                [[NSAttributedString alloc] initWithString:[settingsLocal[PFCSettingsKeyValue] stringValue] attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
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
    //  TextFieldNumber
    // -------------------------------------------------------------------------
    NSTextField *textFieldNumber = [PFCCellTypes textFieldNumberWithString:[value ?: @0 stringValue]
                                                         placeholderString:placeholderString
                                                                       tag:row
                                                                  minValue:manifestContentDict[PFCManifestKeyMinValue]
                                                                  maxValue:manifestContentDict[PFCManifestKeyMaxValue]
                                                            textAlignRight:alignRight
                                                                   enabled:enabled
                                                                    target:sender];
    if (valueAttributed.length != 0) {
        [textFieldNumber setAttributedStringValue:valueAttributed];
    }

    [textFieldNumber bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(value)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    [self addSubview:textFieldNumber];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[textFieldNumber(==%f)]", NSWidth(textFieldNumber.frame)]
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(textFieldNumber)]];

    // -------------------------------------------------------------------------
    //  Stepper
    // -------------------------------------------------------------------------
    NSStepper *stepper;
    if ([manifestContentDict[@"ShowStepper"] boolValue]) {
        stepper = [[NSStepper alloc] init];
        [stepper setTranslatesAutoresizingMaskIntoConstraints:NO];
        [stepper setValueWraps:NO];
        [stepper setMinValue:[[(NSNumberFormatter *)[textFieldNumber formatter] minimum] doubleValue]];
        [stepper setMaxValue:[[(NSNumberFormatter *)[textFieldNumber formatter] maximum] doubleValue]];
        [stepper setEnabled:enabled];

        [self addSubview:stepper];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[stepper(==%f)]", (stepper.intrinsicContentSize.width)]
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(stepper)]];

        [stepper bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(value)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

        if (alignRight) {
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:textFieldNumber
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:stepper
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0f
                                                                       constant:-1.0f]];
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[stepper]-(4)-[textFieldNumber]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(stepper, textFieldNumber)]];

        } else {
            [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:stepper
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:textFieldNumber
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0f
                                                                       constant:-1.0f]];
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldNumber]-(2)-[stepper]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(stepper, textFieldNumber)]];
        }
    }

    // -------------------------------------------------------------------------
    //  Updated bidning value
    // -------------------------------------------------------------------------
    if (_value == nil) {
        [self setValue:value];
    }

    // -------------------------------------------------------------------------
    //  TextFieldLocation Right
    // -------------------------------------------------------------------------
    if ([manifestContentDict[@"TextFieldLocation"] isEqualToString:@"Right"]) {
        if (stepper) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldTitle]-(4)-[stepper]"
                                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldTitle, stepper)]];
        } else {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldTitle]-(4)-[textFieldNumber]"
                                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldTitle, textFieldNumber)]];
        }
        /*
        [layoutConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldNumber]-(>=8)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldNumber)]];
*/
        // -------------------------------------------------------------------------
        //  TextFieldLocation Left
        // -------------------------------------------------------------------------
    } else if ([manifestContentDict[@"TextFieldLocation"] isEqualToString:@"Left"]) {
        if (stepper) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[stepper]-(4)-[textFieldTitle]"
                                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(stepper, textFieldTitle)]];
        } else {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldNumber]-(4)-[textFieldTitle]"
                                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldNumber, textFieldTitle)]];
        }

        // ---------------------------------------------------------------------
        //  TextFieldLocation "Below"
        // ---------------------------------------------------------------------
    } else {

        [layoutConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatTextFieldNumber options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldNumber)]];

        // ---------------------------------------------------------------------
        //  TextFieldUnit
        // ---------------------------------------------------------------------
        NSString *unit = manifestContentDict[PFCManifestKeyUnit] ?: @"";
        NSTextField *textFieldUnit;
        if (unit.length != 0) {
            textFieldUnit = [PFCCellTypes textFieldTitleWithString:unit
                                                             width:(PFCSettingsColumnWidth - (8 + indentConstant)) // FIXME
                                                               tag:row
                                                        fontWeight:manifestContentDict[PFCManifestKeyFontWeight]
                                                    textAlignRight:alignRight
                                                           enabled:enabled
                                                            target:sender];

            [self addSubview:textFieldUnit];
            if (stepper) {
                [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[stepper]-(4)-[textFieldUnit]-(8)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(textFieldUnit, stepper)]];
            } else {
                [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldNumber]-(4)-[textFieldUnit]-(8)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(textFieldNumber, textFieldUnit)]];
            }
        } else {
            if (stepper) {
                [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[stepper]-(>=8)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(stepper)]];
            } else {
                [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldNumber]-(>=8)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(textFieldNumber)]];
            }
        }

        if (textFieldDescription) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldDescription]-(7)-[textFieldNumber]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldDescription, textFieldNumber)]];
            [self setHeight:(self.height + 7 + textFieldNumber.intrinsicContentSize.height)];
        } else if (textFieldTitle) {
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(7)-[textFieldNumber]"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:NSDictionaryOfVariableBindings(textFieldTitle, textFieldNumber)]];
            [self setHeight:(self.height + 7 + textFieldNumber.intrinsicContentSize.height)];
        } else {
            [layoutConstraints
                addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldNumber]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldNumber)]];
            [self setHeight:(self.height + 8 + textFieldNumber.intrinsicContentSize.height)];
        }
    }

    // -------------------------------------------------------------------------
    //  Tool Tip
    // -------------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

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
