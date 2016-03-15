//
//  PFCManifestLinter.m
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

#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestLintError.h"

@interface PFCManifestLint ()

// Global
@property NSMutableArray *domains;
@property NSMutableArray *titles;

// Reset each manifest
@property NSMutableArray *manifestIdentifiers;
@property NSMutableArray *payloadKeys;
@property NSMutableArray *payloadTypes;
@property NSString *payloadTabTitle;

@end

@implementation PFCManifestLint

- (id)init {
    self = [super init];
    if (self != nil) {
        _domains = [[NSMutableArray alloc] init];
        _titles = [[NSMutableArray alloc] init];

        _payloadKeys = [[NSMutableArray alloc] init];
        _payloadTypes = [[NSMutableArray alloc] init];
        _manifestIdentifiers = [[NSMutableArray alloc] init];
    }
    return self;
}

// Generate Report

- (NSArray *)reportForManifests:(NSArray *)manifests {
    NSMutableArray *report = [[NSMutableArray alloc] init];
    [_domains removeAllObjects];
    [_titles removeAllObjects];

    for (NSDictionary *manifest in manifests) {

        [_manifestIdentifiers removeAllObjects];
        [_payloadKeys removeAllObjects];
        [_payloadTypes removeAllObjects];
        [self setPayloadTabTitle:@""];

        [report addObjectsFromArray:[self reportForManifest:manifest]];
    }
    [report removeObject:@{}];
    return [report copy];
}

- (NSArray *)reportForManifest:(NSDictionary *)manifest {
    NSMutableArray *manifestReport = [[NSMutableArray alloc] init];
    [manifestReport addObjectsFromArray:[self reportForManifestRoot:manifest] ?: @[]];
    [manifestReport addObjectsFromArray:[self reportForManifestContent:manifest] ?: @[]];
    return [manifestReport copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Manifest Root
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForManifestRoot:(NSDictionary *)manifest {
    NSMutableArray *manifestReportRoot = [[NSMutableArray alloc] init];
    [manifestReportRoot addObject:[self reportForManifestRootCellType:manifest]];        // Key: CellType
    [manifestReportRoot addObject:[self reportForManifestRootDomain:manifest]];          // Key: Domain
    [manifestReportRoot addObjectsFromArray:[self reportForManifestRootIcon:manifest]];  // Key: IconName, IconPath, IconBundlePath
    [manifestReportRoot addObject:[self reportForManifestRootManifestContent:manifest]]; // Key: ManifestContent
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTabTitle:manifest]]; // Key: PayloadTabTitle
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTypes:manifest]];    // Key: PayloadTypes
    [manifestReportRoot addObject:[self reportForManifestRootRequired:manifest]];        // Key: Required
    [manifestReportRoot addObject:[self reportForManifestRootTitle:manifest]];           // Key: Title
    return [manifestReportRoot copy];
}

- (NSDictionary *)reportForManifestRootCellType:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyCellType] != nil) {
        if (![manifest[PFCManifestKeyCellType] isEqualToString:@"Menu"]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyCellType keyPath:nil value:manifest[PFCManifestKeyCellType] manifest:manifest overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyCellType keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootDomain:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyDomain] != nil) {
        if ([manifest[PFCManifestKeyDomain] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyDomain keyPath:nil value:manifest[PFCManifestKeyDomain] manifest:manifest overrides:nil];
        }

        if ([_domains containsObject:manifest[PFCManifestKeyDomain]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorDuplicate key:PFCManifestKeyDomain keyPath:nil value:manifest[PFCManifestKeyDomain] manifest:manifest overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyDomain keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSArray *)reportForManifestRootIcon:(NSDictionary *)manifest {
    NSMutableArray *iconReport = [[NSMutableArray alloc] init];
    if (manifest[PFCManifestKeyIconName] == nil && manifest[PFCManifestKeyIconPath] == nil && manifest[PFCManifestKeyIconPathBundle] == nil) {
        [iconReport addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeySuggestedNotFound key:PFCManifestKeyIconName keyPath:nil value:nil manifest:manifest overrides:nil]];
    } else {
        [iconReport addObject:[self reportForManifestRootIconName:manifest]];       // Key: IconName
        [iconReport addObject:[self reportForManifestRootIconPath:manifest]];       // Key: IconPath
        [iconReport addObject:[self reportForManifestRootIconPathBundle:manifest]]; // Key: IconPathBundle
    }
    return [iconReport copy];
}

- (NSDictionary *)reportForManifestRootIconName:(NSDictionary *)manifest {
    // FIXME - Haven't tested thoroughly
    if (manifest[PFCManifestKeyIconName] != nil) {
        if ([manifest[PFCManifestKeyIconName] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyIconName keyPath:nil value:manifest[PFCManifestKeyIconName] manifest:manifest overrides:nil];
        } else if ([NSImage imageNamed:manifest[PFCManifestKeyIconName]] == nil) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorResourceNotFound key:PFCManifestKeyIconName keyPath:nil value:manifest[PFCManifestKeyIconName] manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootIconPath:(NSDictionary *)manifest {
    // FIXME - Haven't tested thoroughly
    if (manifest[PFCManifestKeyIconPath] != nil) {
        if ([manifest[PFCManifestKeyIconPath] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyIconPath keyPath:nil value:manifest[PFCManifestKeyIconPath] manifest:manifest overrides:nil];
        }

        NSURL *iconURL = [NSURL fileURLWithPath:manifest[PFCManifestKeyIconPath]];
        if (![iconURL checkResourceIsReachableAndReturnError:nil]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorResourceNotFound key:PFCManifestKeyIconPath keyPath:nil value:manifest[PFCManifestKeyIconPath] manifest:manifest overrides:nil];
        }

        // FIXME - Define a better error than resource not found for this, also check if this check works
        if (![[NSImage alloc] initWithContentsOfURL:iconURL]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorResourceNotFound key:PFCManifestKeyIconPath keyPath:nil value:manifest[PFCManifestKeyIconPath] manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootIconPathBundle:(NSDictionary *)manifest {
    // FIXME - Haven't tested thoroughly
    if (manifest[PFCManifestKeyIconPathBundle] != nil) {
        if ([manifest[PFCManifestKeyIconPathBundle] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyIconPathBundle
                                               keyPath:nil
                                                 value:manifest[PFCManifestKeyIconPathBundle]
                                              manifest:manifest
                                             overrides:nil];
        }

        NSURL *bundleURL = [NSURL fileURLWithPath:manifest[PFCManifestKeyIconPathBundle]];
        if (![bundleURL checkResourceIsReachableAndReturnError:nil]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorResourceNotFound
                                                   key:PFCManifestKeyIconPathBundle
                                               keyPath:nil
                                                 value:manifest[PFCManifestKeyIconPathBundle]
                                              manifest:manifest
                                             overrides:nil];
        }

        // FIXME - Define a better error than resource not found for this, also check if this check works
        if (![[NSWorkspace sharedWorkspace] iconForFile:[bundleURL path]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorResourceNotFound
                                                   key:PFCManifestKeyIconPathBundle
                                               keyPath:nil
                                                 value:manifest[PFCManifestKeyIconPathBundle]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootManifestContent:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyManifestContent] != nil) {
        if ([manifest[PFCManifestKeyManifestContent] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyManifestContent
                                               keyPath:nil
                                                 value:manifest[PFCManifestKeyManifestContent]
                                              manifest:manifest
                                             overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyManifestContent keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootPayloadTabTitle:(NSDictionary *)manifest {
    [self setPayloadTabTitle:manifest[PFCManifestKeyPayloadTabTitle] ?: @""];
    if ([_payloadTabTitle length] != 0) {
        if (![manifest[PFCManifestKeyAllowMultiplePayloads] boolValue]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:PFCManifestKeyPayloadTabTitle keyPath:nil value:nil manifest:manifest overrides:nil];
        }
    } else if ([manifest[PFCManifestKeyAllowMultiplePayloads] boolValue]) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadTabTitle keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootPayloadTypes:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyPayloadTypes] != nil) {
        if ([manifest[PFCManifestKeyPayloadTypes] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyPayloadTypes keyPath:nil value:manifest[PFCManifestKeyPayloadTypes] manifest:manifest overrides:nil];
        }

        // FIXME - Here should check that this matches all collected payload types, but, that might be better to do last in manifest.
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadTypes keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootRequired:(NSDictionary *)manifest {

    // -------------------------------------------------------------------------
    //  If manifest isn't com.apple.general
    // -------------------------------------------------------------------------
    if (![manifest[PFCManifestKeyDomain] isEqualToString:@"com.apple.general"]) {

        // -------------------------------------------------------------------------
        //  ..and contains key 'Required' at the root, return error
        // -------------------------------------------------------------------------
        if (manifest[PFCManifestKeyRequired] != nil) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:PFCManifestKeyRequired keyPath:nil value:manifest[PFCManifestKeyRequired] manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootTitle:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyTitle] != nil) {
        if ([manifest[PFCManifestKeyTitle] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyTitle keyPath:nil value:manifest[PFCManifestKeyTitle] manifest:manifest overrides:nil];
        }

        if ([_titles containsObject:manifest[PFCManifestKeyTitle]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorDuplicate key:PFCManifestKeyTitle keyPath:nil value:manifest[PFCManifestKeyTitle] manifest:manifest overrides:nil];
        } else {
            [_titles addObject:manifest[PFCManifestKeyTitle]];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyTitle keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Manifest Content
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForManifestContent:(NSDictionary *)manifest {
    NSMutableArray *reportContent = [[NSMutableArray alloc] init];
    NSString *parentKeyPath = [NSString stringWithFormat:@":%@", PFCManifestKeyManifestContent];
    __block NSString *keyPath;
    [manifest[PFCManifestKeyManifestContent] ?: @[] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull manifestContentDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
      keyPath = [NSString stringWithFormat:@"%@:%lu", parentKeyPath, (unsigned long)idx];
      [reportContent addObjectsFromArray:[self reportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[keyPath copy]]];
    }];
    return [reportContent copy];
}

- (NSArray *)reportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportContentDict = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Reports for general keys
    // -------------------------------------------------------------------------
    [reportContentDict addObject:[self reportForIdentifier:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];         // Key: Identifier
    [reportContentDict addObject:[self reportForOptional:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Optional
    [reportContentDict addObject:[self reportForToolTipDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ToolTipDescription

    // -------------------------------------------------------------------------
    //  Reports for CellType specific keys
    // -------------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyCellType] != nil) {
        NSString *cellType = manifestContentDict[PFCManifestKeyCellType];

        // ---------------------------------------------------------------------
        //  Checkbox
        // ---------------------------------------------------------------------
        if ([cellType isEqualToString:PFCCellTypeCheckbox]) {

            // ---------------------------------------------------------------------
            //  CheckboxNoDescription
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {

            // ---------------------------------------------------------------------
            //  DatePicker
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {

            // ---------------------------------------------------------------------
            //  DatePickerNoTitle
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {

            // ---------------------------------------------------------------------
            //  File
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeFile]) {

            // ---------------------------------------------------------------------
            //  Padding
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypePadding]) {

            // ---------------------------------------------------------------------
            //  PopUpButton
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {

            // ---------------------------------------------------------------------
            //  PopUpButtonLeft
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {

            // ---------------------------------------------------------------------
            //  PopUpButtonNoTitle
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {

            // ---------------------------------------------------------------------
            //  SegmentedControl
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {

            // ---------------------------------------------------------------------
            //  TableView
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTableView]) {

            // ---------------------------------------------------------------------
            //  TextField
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
            [reportContentDict addObjectsFromArray:[self reportForCellTypeTextField:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

            // ---------------------------------------------------------------------
            //  TextFieldCheckbox
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {

            // ---------------------------------------------------------------------
            //  TextFieldDaysHoursNoTitle
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {

            // ---------------------------------------------------------------------
            //  TextFieldHostPort
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort]) {

            // ---------------------------------------------------------------------
            //  TextFieldHostPortCheckbox
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {

            // ---------------------------------------------------------------------
            //  TextFieldNoTitle
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle]) {

            // ---------------------------------------------------------------------
            //  TextFieldNumber
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {

            // ---------------------------------------------------------------------
            //  TextFieldNumberLeft
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {

            // ---------------------------------------------------------------------
            //  TextView
            // ---------------------------------------------------------------------
        } else if ([cellType isEqualToString:PFCCellTypeTextView]) {

            // -------------------------------------------------------------------------
            //  CellType: *UNKNOWN*
            // -------------------------------------------------------------------------
        } else {
            [reportContentDict addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                                         key:PFCManifestKeyCellType
                                                                     keyPath:parentKeyPath
                                                                       value:manifestContentDict[PFCManifestKeyCellType]
                                                                    manifest:manifest
                                                                   overrides:nil]];
        }
    } else {
        [reportContentDict addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyCellType keyPath:parentKeyPath value:nil manifest:manifest overrides:nil]];
    }
    return [reportContentDict copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)reportForIdentifier:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyIdentifier] != nil) {
        if ([manifestContentDict[PFCManifestKeyIdentifier] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyIdentifier
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyIdentifier]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([_manifestIdentifiers containsObject:manifestContentDict[PFCManifestKeyIdentifier]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorDuplicate
                                                   key:PFCManifestKeyIdentifier
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyIdentifier]
                                              manifest:manifest
                                             overrides:nil];
        } else {
            [_manifestIdentifiers addObject:manifestContentDict[PFCManifestKeyIdentifier]];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyIdentifier keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForOptional:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if ([manifestContentDict[PFCManifestKeyRequired] boolValue] && manifestContentDict[PFCManifestKeyOptional] != nil) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                               key:PFCManifestKeyOptional
                                           keyPath:parentKeyPath
                                             value:manifestContentDict[PFCManifestKeyOptional]
                                          manifest:manifest
                                         overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForToolTipDescription:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyToolTipDescription] != nil) {
        if ([manifestContentDict[PFCManifestKeyToolTipDescription] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyToolTipDescription keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)reportForPayloadKey:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath ignored:(BOOL)ignored {
    if (manifestContentDict[PFCManifestKeyPayloadKey] != nil) {
        if (ignored) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                   key:PFCManifestKeyPayloadKey
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPayloadKey]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([manifestContentDict[PFCManifestKeyPayloadKey] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyPayloadKey keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }

        if ([_payloadKeys containsObject:[NSString stringWithFormat:@"%@:%@", parentKeyPath, manifestContentDict[PFCManifestKeyPayloadKey]]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorDuplicate
                                                   key:PFCManifestKeyPayloadKey
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPayloadKey]
                                              manifest:manifest
                                             overrides:nil];
        } else {
            [_payloadKeys addObject:[NSString stringWithFormat:@"%@:%@", parentKeyPath, manifestContentDict[PFCManifestKeyPayloadKey]]];
        }

    } else if (!ignored) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadKey keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForPayloadType:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath ignored:(BOOL)ignored {
    if (manifestContentDict[PFCManifestKeyPayloadType] != nil) {
        if (ignored) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                   key:PFCManifestKeyPayloadType
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPayloadType]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([manifestContentDict[PFCManifestKeyPayloadType] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyPayloadType keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }

        if (![_payloadTypes containsObject:manifestContentDict[PFCManifestKeyPayloadType]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueRequiredNotFound
                                                   key:PFCManifestKeyPayloadKey
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPayloadType]
                                              manifest:manifest
                                             overrides:nil];
        }

    } else if (!ignored) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadType keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForPayloadValueType:(NSDictionary *)manifestContentDict
                                   manifest:(NSDictionary *)manifest
                              parentKeyPath:(NSString *)parentKeyPath
                                    ignored:(BOOL)ignored
                               allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[PFCManifestKeyPayloadValueType] != nil) {
        if (ignored) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                   key:PFCManifestKeyPayloadValueType
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPayloadValueType]
                                              manifest:manifest
                                             overrides:nil];
        }

        // FIXME - Finish these tests
    } else if (!ignored) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadValueType keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellType Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForCellTypeTextField:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportTextField;
    [reportTextField addObject:[self reportForPayloadKey:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:NO]];  // Key: PayloadKey
    [reportTextField addObject:[self reportForPayloadType:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:NO]]; // Key: PayloadType
    [reportTextField
        addObject:[self reportForPayloadValueType:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:YES allowedTypes:@[ PFCValueTypeString ]]]; // Key: PayloadValueType
    return [reportTextField copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Availability
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForAvailability:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportAvailability = [[NSMutableArray alloc] init];
    NSString *keyPath = [NSString stringWithFormat:@"%@:%@", parentKeyPath, PFCManifestKeyAvailability];
    __block NSString *arrayKeyPath;
    [manifestContentDict[PFCManifestKeyAvailability] ?: @[] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull availabilityDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
      arrayKeyPath = [NSString stringWithFormat:@"%@:%lu", keyPath, (unsigned long)idx];
      [reportAvailability addObject:[self reportForAvailabilityKey:availabilityDict manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:arrayKeyPath]];
    }];
    return [reportAvailability copy];
}

- (NSDictionary *)reportForAvailabilityKey:(NSDictionary *)availabilityDict
                       manifestContentDict:(NSDictionary *)manifestContentDict
                                  manifest:(NSDictionary *)manifest
                             parentKeyPath:(NSString *)parentKeyPath {
    if (availabilityDict[@"AvailabilityKey"] != nil) {
        if ([manifestContentDict[@"AvailabilityKey"] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:@"AvailabilityKey"
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[@"AvailabilityKey"]
                                              manifest:manifest
                                             overrides:nil];
        }

        if (![[manifestContentDict allKeys] containsObject:manifestContentDict[@"AvailabilityKey"]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:@"AvailabilityKey"
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[@"AvailabilityKey"]
                                              manifest:manifest
                                             overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:@"AvailabilityKey" keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

@end
