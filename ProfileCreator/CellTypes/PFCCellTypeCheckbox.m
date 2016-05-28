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
@end

@implementation PFCCheckboxCellView

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
    //  Create Checkbox
    // -------------------------------------------------------------------------
    NSButton *buttonCheckbox = [[NSButton alloc] init];
    [buttonCheckbox setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonCheckbox setButtonType:NSSwitchButton];
    [buttonCheckbox setAction:@selector(checkbox:)];
    [buttonCheckbox setTarget:sender];
    [buttonCheckbox setTitle:@""];
    [buttonCheckbox setTag:row];

    [self addSubview:buttonCheckbox];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[buttonCheckbox]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buttonCheckbox)]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[buttonCheckbox(==%f)]", buttonCheckbox.intrinsicContentSize.width]
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(buttonCheckbox)]];

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
    [buttonCheckbox setEnabled:enabled];

    // -------------------------------------------------------------------------
    //  Supervised
    // -------------------------------------------------------------------------
    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // -------------------------------------------------------------------------
    //  Alignment
    // -------------------------------------------------------------------------
    BOOL alignRight = [manifestContentDict[PFCManifestKeyAlignRight] boolValue];
    NSInteger indentConstant;
    NSString *constraintFormatCheckbox;
    NSString *constraintFormatDesription;
    if (alignRight) {
        [buttonCheckbox setImagePosition:NSImageRight];
        [buttonCheckbox setAlignment:NSRightTextAlignment];

        indentConstant =
            [[PFCManifestUtility sharedUtility] constantForIndentationLevelRight:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:-18];
        constraintFormatCheckbox = [NSString stringWithFormat:@"H:|-(8)-[textFieldTitle][buttonCheckbox]-(%ld)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(8)-[textFieldDescription]-(%ld)-|", (long)indentConstant];
    } else {
        indentConstant = 8;
        if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
            indentConstant = 102;
        } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
            indentConstant =
                [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] ?: 0 baseConstant:PFCIndentLevelBaseConstant offset:0];
        }

        constraintFormatCheckbox = [NSString stringWithFormat:@"H:|-(%ld)-[buttonCheckbox][textFieldTitle]-(8)-|", (long)indentConstant];
        constraintFormatDesription = [NSString stringWithFormat:@"H:|-(%ld)-[textFieldDescription]-(8)-|", (long)indentConstant];
    }

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    NSTextField *textFieldTitle = [PFCCellTypes textFieldTitleWithString:[NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""]
                                                                   width:(PFCSettingsColumnWidth - ((8 + indentConstant) + buttonCheckbox.intrinsicContentSize.width))
                                                                     tag:row
                                                              fontWeight:manifestContentDict[PFCManifestKeyFontWeight]
                                                          textAlignRight:alignRight
                                                                 enabled:enabled
                                                                  target:sender];

    [self setHeight:(self.height + 8 + textFieldTitle.intrinsicContentSize.height)];
    [self addSubview:textFieldTitle];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatCheckbox
                                                                                   options:NSLayoutFormatAlignAllFirstBaseline
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(buttonCheckbox, textFieldTitle)]];

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
        [textFieldDescription setPreferredMaxLayoutWidth:(PFCSettingsColumnWidth - (8 + indentConstant))];
        [textFieldDescription setStringValue:description];

        [self setHeight:(self.height + 2 + textFieldDescription.intrinsicContentSize.height)];
        [self addSubview:textFieldDescription];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[buttonCheckbox]-(2)-[textFieldDescription]"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(buttonCheckbox, textFieldDescription)]];
        [layoutConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatDesription options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldDescription)]];
    }

    // -------------------------------------------------------------------------
    //  Value
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settingsUser[PFCSettingsKeyValue] != nil) {
        checkboxState = [settingsUser[PFCSettingsKeyValue] boolValue];
    } else if (manifestContentDict[PFCManifestKeyDefaultValue]) {
        checkboxState = [manifestContentDict[PFCManifestKeyDefaultValue] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        checkboxState = [settingsLocal[PFCSettingsKeyValue] boolValue];
    }
    [buttonCheckbox setState:checkboxState];

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
            if ([manifestContentDict[@"InvertBoolean"] boolValue]) {
                payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = @((BOOL)!checkboxState);
            } else {
                payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = @(checkboxState);
            }

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
