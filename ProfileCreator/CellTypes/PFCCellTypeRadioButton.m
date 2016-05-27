//
//  PFCCellTypeRadioButton.m
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
#import "PFCCellTypeRadioButton.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCRadioButtonCellView ()

@property NSMutableArray *radioButtons;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (strong) IBOutlet NSLayoutConstraint *buttonsConstraintLeading;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCRadioButtonCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCRadioButtonCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    [_radioButtons removeAllObjects];

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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[_settingDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingDescription)]];
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
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingTitle]-[_settingRadioButton1]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_settingTitle, _settingRadioButton1)]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[_settingRadioButton1]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingRadioButton1)]];
        }
    }

    NSString *selectedItem;
    if ([settingsUser[PFCSettingsKeyValueRadioButton] length] != 0) {
        selectedItem = settingsUser[PFCSettingsKeyValueRadioButton];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValueRadioButton] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValueRadioButton];
    }

    // ---------------------------------------------------------------------
    //  Setup buttons
    // ---------------------------------------------------------------------
    __block NSButton *lastButton;
    __block NSButton *currentButton;
    [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] enumerateObjectsUsingBlock:^(NSString *_Nonnull titleString, NSUInteger idx, BOOL *_Nonnull stop) {
      if (idx == 0) {
          currentButton = [cellView settingRadioButton1];
      } else if (idx == 1) {
          currentButton = [cellView settingRadioButton2];
      } else {
          NSButton *newButton = [[NSButton alloc] init];
          [newButton setButtonType:NSRadioButton];
          [self addSubview:newButton];
          [newButton setTranslatesAutoresizingMaskIntoConstraints:NO];
          [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastButton]-[newButton]"
                                                                       options:NSLayoutFormatAlignAllLeading
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(lastButton, newButton)]];
          currentButton = newButton;
      }

      NSString *additionalFieldType;
      NSString *buttonTitle;
      if (manifestContentDict[PFCManifestKeyValueKeys][titleString] != nil) {
          if ([titleString containsString:@"%TextField%"]) {
              additionalFieldType = @"%TextField%";
          } else if ([titleString containsString:@"%TextFieldNumber%"]) {
              additionalFieldType = @"%TextFieldNumber%";
          }
      }

      if (additionalFieldType.length != 0) {
          buttonTitle = [[titleString componentsSeparatedByString:additionalFieldType] firstObject];
      } else {
          buttonTitle = titleString;
      }

      BOOL subElementsEnabled = NO;
      [currentButton setTitle:buttonTitle];

      // NOTE - Checkong for both titleString and buttonTitle might encouter two buttonts that's equal. Should fix.
      if ([titleString isEqualToString:selectedItem] || [buttonTitle isEqualToString:selectedItem]) {
          [currentButton setState:NSOnState];

          if (enabled) {
              subElementsEnabled = YES;
          }
      }

      // Add extra fields
      if (additionalFieldType.length != 0) {
          [self addAdditionalInputFieldWithType:additionalFieldType
                                       toButton:currentButton
                                      withTitle:titleString
                                buttonValueKeys:manifestContentDict[PFCManifestKeyValueKeys][titleString]
                                       settings:settings
                                        enabled:subElementsEnabled
                                            row:row
                                         sender:sender];
      }

      [currentButton setAction:@selector(radioButton:)];
      [currentButton setTarget:sender];
      [currentButton setTag:row];
      [currentButton setEnabled:enabled];
      [currentButton setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];

      [_radioButtons addObject:currentButton];
      lastButton = currentButton;
    }];

    // ---------------------------------------------------------------------
    //  If no button was selected, select first
    // ---------------------------------------------------------------------
    if (selectedItem.length == 0) {
        [[cellView settingRadioButton1] setState:NSOnState];
    }

    // ---------------------------------------------------------------------
    //  Text Indentation
    // ---------------------------------------------------------------------
    NSInteger constraintConstant = 8;
    if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
        constraintConstant = 102;
    } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        constraintConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] baseConstant:PFCIndentLevelBaseConstant offset:0];
    }
    [[cellView constraintLeading] setConstant:constraintConstant];
    DDLogDebug(@"constraintConstant=%ld", (long)constraintConstant);

    // ---------------------------------------------------------------------
    //  Buttons Indentation
    // ---------------------------------------------------------------------
    NSInteger buttonsConstraintConstant = 8;
    if (manifestContentDict[@"IndentLevelButtons"] != nil) {
        buttonsConstraintConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[@"IndentLevelButtons"] integerValue] baseConstant:PFCIndentLevelBaseConstant offset:0];
    }
    [[cellView buttonsConstraintLeading] setConstant:buttonsConstraintConstant];
    DDLogDebug(@"buttonsConstraintConstant=%ld", (long)buttonsConstraintConstant);

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    return cellView;
} // populateCellViewRadioButton:settings:row

- (void)addAdditionalInputFieldWithType:(NSString *)type
                               toButton:(NSButton *)radioButton
                              withTitle:(NSString *)title
                        buttonValueKeys:(NSArray *)buttonValueKeys
                               settings:(NSDictionary *)settings
                                enabled:(BOOL)enabled
                                    row:(NSInteger)row
                                 sender:(id)sender {
    if ([type isEqualToString:@"%TextField%"] || [type isEqualToString:@"%TextFieldNumber%"]) {
        [self addTextFieldType:type toButton:radioButton withTitle:title buttonValueKeys:buttonValueKeys settings:settings enabled:enabled row:row sender:sender];
    }
}

- (void)addTextFieldType:(NSString *)textFieldType
                toButton:(NSButton *)radioButton
               withTitle:(NSString *)title
         buttonValueKeys:(NSArray *)buttonValueKeys
                settings:(NSDictionary *)settings
                 enabled:(BOOL)enabled
                     row:(NSInteger)row
                  sender:(id)sender {

    __block NSDictionary *buttonConfigDict = @{};
    [buttonValueKeys enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull valueKeysDict, NSUInteger idx, BOOL *_Nonnull stop) {
      if (valueKeysDict[textFieldType] != nil) {
          buttonConfigDict = valueKeysDict[textFieldType];
          *stop = YES;
      }
    }];

    NSTextField *textField = [[NSTextField alloc] init];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Add TextField to cell view
    [self addSubview:textField];

    // Set static width
    // FIXME - PLACEHOLDER CHECK
    if (buttonConfigDict[@"Width"] != nil) {
        [textField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[textField(==%@)]", [buttonConfigDict[@"Width"] stringValue]]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(textField)]];
    } else {
        [textField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textField(==200)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    }
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[radioButton]-[textField]"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(radioButton, textField)]];
    [textField setEnabled:enabled];
    [textField setDelegate:sender];
    [textField setTag:row];

    NSString *identifier = buttonConfigDict[PFCManifestKeyIdentifier];
    if (identifier.length == 0) {
        DDLogError(@"");
        return;
    }

    [textField setIdentifier:identifier];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[identifier][PFCSettingsKeyValue] ?: @"";
    if (value.length == 0) {
        if ([buttonConfigDict[PFCManifestKeyDefaultValue] length] != 0) {
            value = buttonConfigDict[PFCManifestKeyDefaultValue] ?: @"";
        }
    }
    [textField setStringValue:value];

    NSArray *titleStrings = [title componentsSeparatedByString:textFieldType];
    if (1 < titleStrings.count) {
        NSTextField *textLabel = [[NSTextField alloc] init];
        [textLabel setStringValue:titleStrings[1]];
        [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textLabel setBezeled:NO];
        [textLabel setDrawsBackground:NO];
        [textLabel setEditable:NO];
        [textLabel setSelectable:NO];
        [textLabel setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:[[textField cell] controlSize]]]];
        [textLabel setEnabled:enabled];

        // Add TextField to cell view
        [self addSubview:textLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textField]-[textLabel]"
                                                                     options:NSLayoutFormatAlignAllBaseline
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textField, textLabel)]];
    }
}

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if (identifier.length == 0) {
        return nil;
    }

    NSString *selectedItem = settings[PFCSettingsKeyValue];
    if (selectedItem.length == 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    if (selectedItem.length == 0) {
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

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'RadioButton'
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

    NSString *payloadType = manifestContentDict[PFCManifestKeyPayloadType];
    if ([PFCGeneralUtility isValidUUID:payloadType]) {
        DDLogDebug(@"payloadType: %@ IS a valid UUID", payloadType);
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
    //
    // -------------------------------------------------------------------------
    [sender createPayloadFromValueKey:value
                      availableValues:manifestContentDict[PFCManifestKeyAvailableValues]
                  manifestContentDict:manifestContentDict
                             manifest:manifest
                             settings:settings
                           payloadKey:nil
                          payloadType:payloadType
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
