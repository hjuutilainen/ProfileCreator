//
//  PFCCellTypeTextFieldHostPort.m
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
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldHostPortCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCTextFieldHostPortCellView ()
@end

@implementation PFCTextFieldHostPortCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCTextFieldHostPortCellView *)cellView
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
    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];

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
    if ((!requiredHost || !requiredPort) && settingsUser[PFCSettingsKeyEnabled] != nil) {
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
        constraintFormatTextField = [NSString stringWithFormat:@"H:|-(8)-[textFieldPort(==49)]-(2)-[textFieldSemicolon(==4)]-(2)-[textFieldHost]-(%ld)-|", (long)indentConstant];
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
        constraintFormatTextField = [NSString stringWithFormat:@"H:|-(8)-[textFieldHost]-(2)-[textFieldSemicolon(==4)]-(2)-[textFieldPort(==49)]-(%ld)-|", (long)indentConstant];
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
    //  Value Host
    // -------------------------------------------------------------------------
    NSString *valueHost = settingsUser[PFCSettingsKeyValueHost] ?: @"";
    NSAttributedString *valueAttributedHost = nil;
    if (valueHost.length == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValueHost] length] != 0) {
            valueHost = manifestContentDict[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValueHost] length] != 0) {
            valueAttributedHost =
                [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    // -------------------------------------------------------------------------
    //  Placeholder Value Host
    // -------------------------------------------------------------------------
    NSString *placeholderStringHost = @"";
    if ([manifestContentDict[PFCManifestKeyPlaceholderValueHost] length] != 0) {
        placeholderStringHost = manifestContentDict[PFCManifestKeyPlaceholderValueHost] ?: @"";
    } else if (requiredHost) {
        placeholderStringHost = @"Required";
    } else if (optional) {
        placeholderStringHost = @"Optional";
    }

    // -------------------------------------------------------------------------
    //  TextField Host
    // -------------------------------------------------------------------------
    NSTextField *textFieldHost = [PFCCellTypes textFieldWithString:valueHost placeholderString:placeholderStringHost tag:row textAlignRight:alignRight enabled:enabled target:sender];
    [textFieldHost setIdentifier:PFCSettingsKeyValueHost];
    if (valueAttributedHost.length != 0) {
        [textFieldHost setAttributedStringValue:valueAttributedHost];
    }
    [self addSubview:textFieldHost];

    // -------------------------------------------------------------------------
    //  Value Port
    // -------------------------------------------------------------------------
    NSString *valuePort = settingsUser[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valueAttributedPort = nil;
    if (valuePort.length == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValuePort] length] != 0) {
            valuePort = manifestContentDict[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValuePort] length] != 0) {
            valueAttributedPort =
                [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    // -------------------------------------------------------------------------
    //  Placeholder Value Port
    // -------------------------------------------------------------------------
    NSString *placeholderStringPort = @"";
    if ([manifestContentDict[PFCManifestKeyPlaceholderValuePort] length] != 0) {
        placeholderStringPort = manifestContentDict[PFCManifestKeyPlaceholderValuePort] ?: @"";
    } else if (requiredPort) {
        placeholderStringPort = @"Req";
    } else if (optional) {
        placeholderStringPort = @"Opt";
    }

    // -------------------------------------------------------------------------
    //  TextField Port
    // -------------------------------------------------------------------------
    NSTextField *textFieldPort = [PFCCellTypes textFieldWithString:valuePort placeholderString:placeholderStringPort tag:row textAlignRight:alignRight enabled:enabled target:sender];
    [textFieldPort setIdentifier:PFCSettingsKeyValuePort];
    if (valueAttributedPort.length != 0) {
        [textFieldPort setAttributedStringValue:valueAttributedPort];
    }
    [self addSubview:textFieldPort];

    // -------------------------------------------------------------------------
    //  TextField Semicolon
    // -------------------------------------------------------------------------
    NSTextField *textFieldSemicolon = [PFCCellTypes textFieldTitleWithString:@":" width:4.0f tag:row fontWeight:@"Regular" textAlignRight:alignRight enabled:enabled target:sender];
    [self addSubview:textFieldSemicolon];

    // -------------------------------------------------------------------------
    //  TextField Constraints
    // -------------------------------------------------------------------------
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintFormatTextField
                                                                                   options:NSLayoutFormatAlignAllBaseline
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(textFieldHost, textFieldPort, textFieldSemicolon)]];
    if (textFieldDescription) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldDescription]-(7)-[textFieldHost]"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(textFieldDescription, textFieldHost)]];
        [self setHeight:(self.height + 7 + textFieldHost.intrinsicContentSize.height)];
    } else if (textFieldTitle) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textFieldTitle]-(7)-[textFieldHost]"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(textFieldTitle, textFieldHost)]];
        [self setHeight:(self.height + 7 + textFieldHost.intrinsicContentSize.height)];
    } else {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[textFieldHost]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldHost)]];
        [self setHeight:(self.height + 8 + textFieldHost.intrinsicContentSize.height)];
    }

    // -------------------------------------------------------------------------
    //  Tool Tip
    // -------------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // -------------------------------------------------------------------------
    //  Required
    // -------------------------------------------------------------------------
    if (requiredHost && [valueHost length] == 0) {
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
    // Host
    NSMutableArray *array = [NSMutableArray array];

    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if (valueHost.length == 0) {
        valueHost = contentDictSettings[PFCManifestKeyDefaultValueHost];
    }

    if (requiredHost && valueHost.length == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    // Port
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if (valuePort.length == 0) {
        valuePort = contentDictSettings[PFCManifestKeyDefaultValuePort];
    }

    if (requiredPort && valuePort.length == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    if (array.count != 0) {
        return @{identifier : [array copy]};
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldHostPort'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get value for Host
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if (valueHost == nil) {
        valueHost = manifestContentDict[PFCManifestKeyDefaultValueHost];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (valueHost == nil || ([[valueHost class] isSubclassOfClass:[NSString class]] && [valueHost length] == 0)) {
        DDLogDebug(@"PayloadValueHost is empty");
        valueHost = @"";
    } else if (![[valueHost class] isSubclassOfClass:[NSString class]]) {
        return
            [sender payloadErrorForValueClass:NSStringFromClass([valueHost class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([NSString class]) ]];
    } else {
        DDLogDebug(@"PayloadValueHost: %@", valueHost);
    }

    // -------------------------------------------------------------------------
    //  Get value for Port
    // -------------------------------------------------------------------------
    id valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if (valuePort == nil) {
        valuePort = manifestContentDict[PFCManifestKeyDefaultValuePort];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (valuePort == nil) {
        DDLogDebug(@"PayloadValuePort is empty");
    } else if ([[valuePort class] isSubclassOfClass:[NSString class]]) {

        // ---------------------------------------------------------------------
        //  Convert string to integer
        // ---------------------------------------------------------------------
        valuePort = @([(NSString *)valuePort integerValue]);
    } else if (![[valuePort class] isEqualTo:[@(0) class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([valuePort class])
                                      payloadKey:manifestContentDict[PFCManifestKeyPayloadType]
                                exptectedClasses:@[ NSStringFromClass([NSString class]), NSStringFromClass([@(0) class]) ]];
    } else {
        DDLogDebug(@"PayloadValuePort: %@", valuePort);
    }

    NSString *payloadKey;
    NSString *payloadKeyHost = manifestContentDict[PFCManifestKeyPayloadKeyHost];
    NSString *payloadKeyPort;
    if ([payloadKeyHost length] != 0 && [manifestContentDict[PFCManifestKeyPayloadKeyPort] length] == 0) {
        DDLogError(@"PayloadKeyHost is: %@ but PayloadKeyPort is undefined", payloadKeyHost);
        return;
    } else if ([payloadKeyHost length] != 0) {
        payloadKeyPort = manifestContentDict[PFCManifestKeyPayloadKeyPort];
    } else if ([manifestContentDict[PFCManifestKeyPayloadKey] length] != 0) {
        payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
    } else {
        DDLogError(@"No PayloadKey was defined!");
        return;
    }

    if ([valueHost length] == 0 && [manifestContentDict[PFCManifestKeyOptional] boolValue]) {
        DDLogDebug(@"PayloadKey: %@ is optional, skipping", payloadKeyHost ?: payloadKey);
        return;
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
    if ([payloadKey length] != 0) {
        payloadDictDict[payloadKey] = [NSString stringWithFormat:@"%@:%@", valueHost, [valuePort stringValue]];
    } else {
        payloadDictDict[payloadKeyHost] = valueHost;
        payloadDictDict[payloadKeyPort] = valuePort;
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

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload Keys
    // -------------------------------------------------------------------------
    NSArray *payloadKeys = @[
        @{ @"PayloadKeySuffix" : @"Host",
           @"AllowedTypes" : @[ PFCValueTypeString ] },

        @{ @"PayloadKeySuffix" : @"Port",
           @"AllowedTypes" : @[ PFCValueTypeString, PFCValueTypeInteger ] }
    ];
    [lintReport
        addObjectsFromArray:[sender reportForPayloadKeys:payloadKeys manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]];

    [lintReport addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValueHost
                                           manifestContentDict:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                  allowedTypes:@[ PFCValueTypeString ]]];
    [lintReport addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValuePort
                                           manifestContentDict:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                  allowedTypes:@[ PFCValueTypeInteger ]]];

    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

- (void)showRequired:(BOOL)show {
    if (show) {
        //[_constraintTextFieldPortTrailing setConstant:34.0];
        //[_imageViewRequired setHidden:NO];
    } else {
        //[_constraintTextFieldPortTrailing setConstant:8.0];
        //[_imageViewRequired setHidden:YES];
    }
} // showRequired

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTextFieldHostPortCheckboxCellView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCTextFieldHostPortCheckboxCellView ()

@property BOOL checkboxState;
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldPortTrailing;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCTextFieldHostPortCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCTextFieldHostPortCheckboxCellView *)cellView
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
    BOOL requiredCheckbox = NO;
    if (overrides[PFCManifestKeyRequiredCheckbox] != nil) {
        requiredCheckbox = [overrides[PFCManifestKeyRequiredCheckbox] boolValue];
    } else {
        requiredCheckbox = [[PFCAvailability sharedInstance] requiredCheckboxForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }

    // ---------------------------------------------------------------------------------------
    //  Get required state for this cell view
    // ---------------------------------------------------------------------------------------
    BOOL requiredHost = NO;
    if (overrides[PFCManifestKeyRequiredHost] != nil) {
        requiredHost = [overrides[PFCManifestKeyRequiredHost] boolValue];
    } else {
        requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }

    // ---------------------------------------------------------------------------------------
    //  Get required state for this cell view
    // ---------------------------------------------------------------------------------------
    BOOL requiredPort = NO;
    if (overrides[PFCManifestKeyRequiredPort] != nil) {
        requiredPort = [overrides[PFCManifestKeyRequiredPort] boolValue];
    } else {
        requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];
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
    if (!requiredCheckbox) {
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
        [[cellView settingCheckbox] setTitle:title];
    } else {
        [[cellView settingCheckbox] removeFromSuperview];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingDescription)]];
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
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingCheckbox]-[_settingTextFieldHost]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_settingCheckbox, _settingTextFieldHost)]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingTextFieldHost]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingTextFieldHost)]];
        }
    }

    // ---------------------------------------------------------------------
    //  Value Checkbox
    // ---------------------------------------------------------------------
    BOOL valueCheckbox = NO;
    if (settingsUser[PFCSettingsKeyValueCheckbox] != nil) {
        valueCheckbox = [settingsUser[PFCSettingsKeyValueCheckbox] boolValue];
    } else if (manifestContentDict[PFCManifestKeyDefaultValueCheckbox]) {
        valueCheckbox = [manifestContentDict[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if (settingsLocal[PFCSettingsKeyValueCheckbox]) {
        valueCheckbox = [settingsLocal[PFCSettingsKeyValueCheckbox] boolValue];
    }
    [self setCheckboxState:valueCheckbox];

    // ---------------------------------------------------------------------
    //  Target Action Checkbox
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:sender];
    [[cellView settingCheckbox] setTag:row];

    // ---------------------------------------------------------------------
    //  Value Host
    // ---------------------------------------------------------------------
    NSString *valueHost = settingsUser[PFCSettingsKeyValueHost] ?: @"";
    NSAttributedString *valueHostAttributed = nil;
    if ([valueHost length] == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValueHost] length] != 0) {
            valueHost = manifestContentDict[PFCManifestKeyDefaultValueHost] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValueHost] length] != 0) {
            valueHostAttributed =
                [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValueHost] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    if ([valueHostAttributed length] != 0) {
        [[cellView settingTextFieldHost] setAttributedStringValue:valueHostAttributed];
    } else {
        [[cellView settingTextFieldHost] setStringValue:valueHost];
    }
    [[cellView settingTextFieldHost] setDelegate:sender];
    [[cellView settingTextFieldHost] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value Host
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyPlaceholderValueHost] length] != 0) {
        [[cellView settingTextFieldHost] setPlaceholderString:manifestContentDict[PFCManifestKeyPlaceholderValueHost] ?: @""];
    } else if (valueCheckbox && requiredHost) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Required"];
    } else if (valueCheckbox && optional) {
        [[cellView settingTextFieldHost] setPlaceholderString:@"Optional"];
    } else {
        [[cellView settingTextFieldHost] setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  Value Port
    // ---------------------------------------------------------------------
    NSString *valuePort = settingsUser[PFCSettingsKeyValuePort] ?: @"";
    NSAttributedString *valuePortAttributed = nil;
    if ([valuePort length] == 0) {
        if ([manifestContentDict[PFCManifestKeyDefaultValuePort] length] != 0) {
            valuePort = manifestContentDict[PFCManifestKeyDefaultValuePort] ?: @"";
        } else if ([settingsLocal[PFCSettingsKeyValuePort] length] != 0) {
            valuePortAttributed =
                [[NSAttributedString alloc] initWithString:settingsLocal[PFCSettingsKeyValuePort] ?: @"" attributes:@{NSForegroundColorAttributeName : NSColor.pfc_localSettingsColor}];
        }
    }

    if ([valueHostAttributed length] != 0) {
        [[cellView settingTextFieldPort] setAttributedStringValue:valuePortAttributed];
    } else {
        [[cellView settingTextFieldPort] setStringValue:valuePort];
    }
    [[cellView settingTextFieldPort] setDelegate:sender];
    [[cellView settingTextFieldPort] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyPlaceholderValuePort] length] != 0) {
        [[cellView settingTextFieldPort] setPlaceholderString:manifestContentDict[PFCManifestKeyPlaceholderValuePort] ?: @""];
    } else if (valueCheckbox && requiredPort) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Req"];
    } else if (valueCheckbox && optional) {
        [[cellView settingTextFieldPort] setPlaceholderString:@"Opt"];
    } else {
        [[cellView settingTextFieldPort] setPlaceholderString:@""];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Bind Checkbox to TextField's 'Enabled'
    // ---------------------------------------------------------------------
    [[cellView settingTextFieldHost] bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingTextFieldPort] bind:NSEnabledBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingCheckbox] bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(checkboxState)) options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];

    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    if (valueCheckbox && (requiredHost || requiredPort) && [valueHost length] == 0) {
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
    // Host
    NSMutableArray *array = [NSMutableArray array];

    BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSString *valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if (valueHost.length == 0) {
        valueHost = contentDictSettings[PFCManifestKeyDefaultValueHost];
    }

    if (requiredHost && valueHost.length == 0) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    // Port
    BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    NSNumber *valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if (valuePort == nil) {
        valuePort = contentDictSettings[PFCManifestKeyDefaultValuePort];
    }

    if (requiredPort && valuePort == nil) {
        [array addObject:[PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict]];
    }

    if (array.count != 0) {
        return @{identifier : [array copy]};
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldHostPortCheckbox'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType ] manifestContentDict:manifestContentDict]) {
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
    //  If Checkbox is enabled
    // -------------------------------------------------------------------------
    // FIXME - Here i could check if there are any payloadKeys for host/port, but they should be required
    if (checkboxState) {

        // ------------------------------------------------------------------------
        //  All keys are equal to TextFieldHostPort, so use that to add to payload
        // ------------------------------------------------------------------------
        [PFCTextFieldHostPortCellView createPayloadForCellType:manifestContentDict manifest:manifest settings:settings payloads:payloads sender:sender];
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

    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValueCheckbox
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeBoolean ]]];
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValueHost
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeString ]]];
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValuePort
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                              allowedTypes:@[ PFCValueTypeInteger ]]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload Keys
    // -------------------------------------------------------------------------
    NSArray *payloadKeys = @[
        @{ @"PayloadKeySuffix" : @"Host",
           @"AllowedTypes" : @[ PFCValueTypeString ] },

        @{ @"PayloadKeySuffix" : @"Port",
           @"AllowedTypes" : @[ PFCValueTypeInteger ] }
    ];
    [lintReport
        addObjectsFromArray:[sender reportForPayloadKeys:payloadKeys manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]];

    [lintReport addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValueHost
                                           manifestContentDict:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                  allowedTypes:@[ PFCValueTypeString ]]];

    [lintReport addObject:[sender reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValuePort
                                           manifestContentDict:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                  allowedTypes:@[ PFCValueTypeInteger ]]];

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
