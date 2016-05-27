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
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCPopUpButtonCellView ()
@end

@implementation PFCPopUpButtonCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCPopUpButtonCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // -------------------------------------------------------------------------
    //  Create Checkbox
    // -------------------------------------------------------------------------
    NSPopUpButton *popUpButton = [[NSPopUpButton alloc] init];
    [popUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [popUpButton setAction:@selector(popUpButtonSelection:)];
    [popUpButton setTarget:sender];
    [popUpButton setTag:row];

    if (manifestContentDict[@"PopUpButtonWidth"] != nil) {
        NSString *constraintFormat = [NSString stringWithFormat:@"H:[popUpButton(==%@)]", [manifestContentDict[@"PopUpButtonWidth"] stringValue]];
        [popUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormat options:0 metrics:nil views:NSDictionaryOfVariableBindings(popUpButton)]];
    }

    [self addSubview:popUpButton];

    // -------------------------------------------------------------------------
    //  Get availability overrides
    // -------------------------------------------------------------------------
    NSDictionary *overrides = [[PFCAvailability sharedInstance] overridesForManifestContentDict:manifestContentDict manifest:manifest settings:settings displayKeys:displayKeys];

    // -------------------------------------------------------------------------
    //  Get required state for this cell view
    // -------------------------------------------------------------------------
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
    [popUpButton setEnabled:enabled];

    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    BOOL alignRight = [manifestContentDict[PFCManifestKeyAlignRight] boolValue];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    NSTextField *textFieldTitle;
    if (title.length != 0) {

        textFieldTitle = [[NSTextField alloc] init];
        [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
        [textFieldTitle setBordered:NO];
        [textFieldTitle setBezeled:NO];
        [textFieldTitle setDrawsBackground:NO];
        [textFieldTitle setEditable:NO];
        [textFieldTitle setSelectable:NO];
        [textFieldTitle setTarget:sender];
        [textFieldTitle setTag:row];

        if ([manifestContentDict[PFCManifestKeyFontWeight] isEqualToString:PFCFontWeightRegular]) {
            [textFieldTitle setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
        } else {
            [textFieldTitle setFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
        }

        if (alignRight) {
            [textFieldTitle setAlignment:NSRightTextAlignment];
        }

        [self addSubview:textFieldTitle];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldTitle]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldTitle)]];

        title = [NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""];
        [textFieldTitle setStringValue:title];

        if (enabled) {
            [textFieldTitle setTextColor:[NSColor blackColor]];
        } else {
            [textFieldTitle setTextColor:[NSColor grayColor]];
        }
    }

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    NSString *description = manifestContentDict[PFCManifestKeyDescription] ?: @"";
    NSTextField *textFieldDescription;
    if (description.length != 0) {

        textFieldDescription = [[NSTextField alloc] init];
        [textFieldDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textFieldDescription setBordered:NO];
        [textFieldDescription setBezeled:NO];
        [textFieldDescription setDrawsBackground:NO];
        [textFieldDescription setEditable:NO];
        [textFieldDescription setSelectable:NO];
        [textFieldDescription setTextColor:[NSColor controlShadowColor]];
        [textFieldDescription setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
        [textFieldDescription setTarget:sender];
        [textFieldDescription setTag:row];

        if (alignRight) {
            [textFieldDescription setAlignment:NSRightTextAlignment];
        }

        [self addSubview:textFieldDescription];
        if (title.length != 0) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(2)-[textFieldDescription]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(textFieldTitle, textFieldDescription)]];
            [self setHeight:(self.height + 2)];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldDescription)]];
            [self setHeight:(self.height + 8)];
        }

        [textFieldDescription setStringValue:description];
        [self setHeight:(self.height + textFieldDescription.intrinsicContentSize.height)];
    }

    // -------------------------------------------------------------------------
    //  Alignment
    // -------------------------------------------------------------------------
    NSInteger indentConstant = 0;
    NSString *constraintFormatTitle;
    NSString *constraintFormatDesription;
    NSString *constraintFormatPopUpButton;
    if (alignRight) {
        indentConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevelRight:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:0];
        constraintFormatTitle = [NSString stringWithFormat:@"H:|-(8)-[textFieldTitle]-(%ld)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(8)-[textFieldDescription]-(%ld)-|", (long)indentConstant];
        constraintFormatPopUpButton = [NSString stringWithFormat:@"H:|-(>=8)-[popUpButton]-(%ld)-|", (long)indentConstant];
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
        constraintFormatPopUpButton = [NSString stringWithFormat:@"H:|-(%ld)-[popUpButton]-(>=8)-|", (long)indentConstant];
    }

    if (textFieldTitle) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatTitle options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldTitle)]];

        // Calculate text field height
        textFieldTitle.preferredMaxLayoutWidth = ((PFCIndentCenterConstant * 2) - (8 + indentConstant));
        DDLogDebug(@"prefferendwidth: %f", textFieldTitle.preferredMaxLayoutWidth);
        DDLogDebug(@"titlelength: %lu", (unsigned long)title.length);
        DDLogDebug(@"BOUNDS: %f", textFieldTitle.bounds.size.height);
        DDLogDebug(@"FRAME: %f", textFieldTitle.frame.size.height);
        DDLogDebug(@"INTRINSIC: %f", textFieldTitle.intrinsicContentSize.height);
        [self setHeight:(self.height + 8 + textFieldTitle.intrinsicContentSize.height)];
    }

    if (textFieldDescription) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatDesription options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldDescription)]];

        // Calculate text field height
        textFieldDescription.preferredMaxLayoutWidth = ((PFCIndentCenterConstant * 2) - (8 + indentConstant));
        DDLogDebug(@"prefferendwidth: %f", textFieldDescription.preferredMaxLayoutWidth);
        DDLogDebug(@"titlelength: %lu", (unsigned long)description.length);
        DDLogDebug(@"BOUNDS: %f", textFieldDescription.bounds.size.height);
        DDLogDebug(@"FRAME: %f", textFieldDescription.frame.size.height);
        DDLogDebug(@"INTRINSIC: %f", textFieldDescription.intrinsicContentSize.height);
        [self setHeight:(self.height + 8 + textFieldDescription.intrinsicContentSize.height)];
    }

    // -------------------------------------------------------------------------
    //  CheckboxLocation
    // -------------------------------------------------------------------------
    if (textFieldTitle && [manifestContentDict[@"PopUpButtonLocation"] isEqualToString:@"Right"]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textFieldTitle]-(4)-[popUpButton]-(>=8)-|"
                                                                     options:NSLayoutFormatAlignAllBaseline
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textFieldTitle, popUpButton)]];
    } else if (textFieldTitle && [manifestContentDict[@"PopUpButtonLocation"] isEqualToString:@"Left"]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[popUpButton]-(4)-[textFieldTitle]"
                                                                     options:NSLayoutFormatAlignAllBaseline
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(popUpButton, textFieldTitle)]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatPopUpButton options:0 metrics:nil views:NSDictionaryOfVariableBindings(popUpButton)]];
        if (textFieldDescription) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldDescription]-(7)-[popUpButton]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(textFieldDescription, popUpButton)]];
            [self setHeight:(self.height + 7)];
        } else if (textFieldTitle) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(7)-[popUpButton]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(textFieldTitle, popUpButton)]];
            [self setHeight:(self.height + 7)];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[popUpButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popUpButton)]];
            [self setHeight:(self.height + 8)];
        }
        DDLogDebug(@"AHHAHAHA: %f", popUpButton.intrinsicContentSize.height);
        [self setHeight:(self.height + popUpButton.intrinsicContentSize.height)];
    }

    // -------------------------------------------------------------------------
    //  Value
    // -------------------------------------------------------------------------
    [popUpButton removeAllItems];
    [popUpButton addItemsWithTitles:manifestContentDict[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ([settingsUser[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsUser[PFCSettingsKeyValue];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if (selectedItem.length != 0) {
        [popUpButton selectItemWithTitle:selectedItem];
    } else if (popUpButton.itemArray.count != 0) {
        [popUpButton selectItemAtIndex:0];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    [self setHeight:(self.height + 3)];

    return cellView;
} // populateCellViewPopUpButton:settings:row

/*
 - (instancetype)populateCellView:(PFCPopUpButtonCellView *)cellView
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

 // -------------------------------------------------------------------------
 //  Get required state for this cell view
 // -------------------------------------------------------------------------
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
 //  Indentation
 // ---------------------------------------------------------------------
 CGFloat constraintConstant = 8;
 if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
 constraintConstant = 102;
 } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
 constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifestContentDict[PFCManifestKeyIndentLevel] baseConstant:@(PFCIndentLevelBaseConstant)];
 }
 [[cellView constraintLeadingPopUpButton] setConstant:constraintConstant];

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
 [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_settingDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingDescription)]];
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
 [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingTitle]-[_settingPopUpButton]"
 options:0
 metrics:nil
 views:NSDictionaryOfVariableBindings(_settingTitle, _settingPopUpButton)]];
 } else {
 [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_settingPopUpButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
 }
 }

 // ---------------------------------------------------------------------
 //  Value
 // ---------------------------------------------------------------------
 [[cellView settingPopUpButton] removeAllItems];
 [[cellView settingPopUpButton] addItemsWithTitles:manifestContentDict[PFCManifestKeyAvailableValues] ?: @[]];
 NSString *selectedItem;
 if ([settingsUser[PFCSettingsKeyValue] length] != 0) {
 selectedItem = settingsUser[PFCSettingsKeyValue];
 } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
 selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
 } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
 selectedItem = settingsLocal[PFCSettingsKeyValue];
 }

 if (selectedItem.length != 0) {
 [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
 } else if (cellView.settingPopUpButton.itemArray.count != 0) {
 [[cellView settingPopUpButton] selectItemAtIndex:0];
 }

 // ---------------------------------------------------------------------
 //  PopUpButton Width
 // ---------------------------------------------------------------------
 DDLogDebug(@"PopUpButtonWidth=%@", manifestContentDict[@"PopUpButtonWidth"]);
 if (manifestContentDict[@"PopUpButtonWidth"] != nil) {
 DDLogDebug(@"PopUpButtonWidthStringValue=%@", [manifestContentDict[@"PopUpButtonWidth"] stringValue]);
 NSString *constraintFormat = [NSString stringWithFormat:@"H:[_settingPopUpButton(==%@)]", [manifestContentDict[@"PopUpButtonWidth"] stringValue]];
 [_settingPopUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormat options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
 } else {
 //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_settingPopUpButton]-(8)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
 }

 // ---------------------------------------------------------------------
 //  Tool Tip
 // ---------------------------------------------------------------------
 [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

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
 */

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

@interface PFCPopUpButtonCheckboxCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingTitle;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingDescription;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeadingPopUpButton;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCPopUpButtonCheckboxCellView *)cellView
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

    // -------------------------------------------------------------------------
    //  Get required state for this cell view
    // -------------------------------------------------------------------------
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
    //  Indentation
    // ---------------------------------------------------------------------
    CGFloat constraintConstant = 8;
    if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
        constraintConstant = 102;
    } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        constraintConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] baseConstant:PFCIndentLevelBaseConstant offset:0];
    }
    [[cellView constraintLeadingPopUpButton] setConstant:constraintConstant];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    if (title.length != 0) {
        title = [NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""];
        [[cellView settingCheckbox] setTitle:title];
        [[cellView constraintLeadingTitle] setConstant:constraintConstant];
    } else {
        [[cellView settingCheckbox] removeFromSuperview];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_settingDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingDescription)]];
    }

    // ---------------------------------------------------------------------
    //  FontWeight of the Title
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyFontWeight] isEqualToString:PFCFontWeightRegular]) {
        [[cellView settingCheckbox] setFont:[NSFont systemFontOfSize:13]];
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
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingCheckbox]-(8)-[_settingPopUpButton]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_settingCheckbox, _settingPopUpButton)]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_settingPopUpButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
        }
    }

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifestContentDict[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ([settingsUser[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsUser[PFCSettingsKeyValue];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if (selectedItem.length != 0) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if (cellView.settingPopUpButton.itemArray.count != 0) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }

    // ---------------------------------------------------------------------
    //  PopUpButton Width
    // ---------------------------------------------------------------------
    DDLogDebug(@"PopUpButtonWidth=%@", manifestContentDict[@"PopUpButtonWidth"]);
    if (manifestContentDict[@"PopUpButtonWidth"] != nil) {
        DDLogDebug(@"PopUpButtonWidthStringValue=%@", [manifestContentDict[@"PopUpButtonWidth"] stringValue]);
        NSString *constraintFormat = [NSString stringWithFormat:@"H:[_settingPopUpButton(==%@)]", [manifestContentDict[@"PopUpButtonWidth"] stringValue]];
        [_settingPopUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormat options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
    } else {
        //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_settingPopUpButton]-(8)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingPopUpButton)]];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

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

@interface PFCPopUpButtonLeftCellView ()

@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonLeftCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCPopUpButtonLeftCellView *)cellView
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

    BOOL enabled = YES;
    if (!required && settingsUser[PFCSettingsKeyEnabled] != nil) {
        enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
    }

    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:[NSString stringWithFormat:@"%@%@", manifestContentDict[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];
    if (enabled) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestContentDict[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifestContentDict[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ([settingsUser[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsUser[PFCSettingsKeyValue];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }

    if (selectedItem.length != 0) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if (cellView.settingPopUpButton.itemArray.count != 0) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

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

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {
    return [PFCPopUpButtonCellView createPayloadForCellType:manifestContentDict manifest:manifest settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeBoolean, PFCValueTypeString, PFCValueTypeInteger ];

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
