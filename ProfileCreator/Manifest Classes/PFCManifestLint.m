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

#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypeFile.h"
#import "PFCCellTypePopUpButton.h"
#import "PFCCellTypeProtocol.h"
#import "PFCCellTypeSegmentedControl.h"
#import "PFCCellTypeTextField.h"
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypeTextFieldNumber.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestLintError.h"
#import "PFCManifestUtility.h"

@interface PFCManifestLint ()

// Global
@property NSMutableArray *domains;
@property NSMutableArray *titles;

// Reset each manifest
@property NSMutableArray *manifestIdentifiers;
@property NSMutableArray *payloadKeys;
@property NSMutableArray *payloadTypes;
@property NSString *payloadTabTitle;
@property NSMutableArray *manifestRootKeys;

// Reset each manifest content dict
@property NSMutableArray *manifestContentDictKeys;
@property NSMutableArray *manifestContentDictAvailableValues;
@property NSMutableArray *manifestContentDictValueKeysShared;

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
        _manifestRootKeys = [[NSMutableArray alloc] init];

        _manifestContentDictKeys = [[NSMutableArray alloc] init];
        _manifestContentDictAvailableValues = [[NSMutableArray alloc] init];
        _manifestContentDictValueKeysShared = [[NSMutableArray alloc] init];
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

    [_manifestRootKeys removeAllObjects];

    [manifestReportRoot addObjectsFromArray:[self reportForManifestRootAvailability:manifest]]; // Key: Availability
    [manifestReportRoot addObject:[self reportForManifestRootAllowMultiplePayloads:manifest]];  // Key: AllowMultiplePayloads
    [manifestReportRoot addObject:[self reportForManifestRootCellType:manifest]];               // Key: CellType
    [manifestReportRoot addObject:[self reportForManifestRootDescription:manifest]];            // Key: Description
    [manifestReportRoot addObject:[self reportForManifestRootDomain:manifest]];                 // Key: Domain
    [manifestReportRoot addObjectsFromArray:[self reportForManifestRootIcon:manifest]];         // Key: IconName, IconPath, IconBundlePath
    [manifestReportRoot addObject:[self reportForManifestRootManifestContent:manifest]];        // Key: ManifestContent
    [manifestReportRoot addObject:[self reportForManifestRootPayloadLibrary:manifest]];         // Key: PayloadLibrary
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTabTitle:manifest]];        // Key: PayloadTabTitle
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTypes:manifest]];           // Key: PayloadTypes
    [manifestReportRoot addObject:[self reportForManifestRootRequired:manifest]];               // Key: Required
    [manifestReportRoot addObject:[self reportForManifestRootTitle:manifest]];                  // Key: Title

    for (NSString *key in [manifest allKeys]) {
        if (![_manifestRootKeys containsObject:key] && ![key isEqualToString:@"Path"]) {
            [manifestReportRoot addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyIncompatible key:key keyPath:nil value:manifest[key] manifest:manifest overrides:nil]];
        }
    }

    return [manifestReportRoot copy];
}

- (NSDictionary *)reportForManifestRootAllowMultiplePayloads:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyAllowMultiplePayloads] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyAllowMultiplePayloads];
    }
    return @{};
}

- (NSArray *)reportForManifestRootAvailability:(NSDictionary *)manifest {
    NSMutableArray *reportAvailability = [[NSMutableArray alloc] init];
    NSString *keyPath = @":Availability";
    if (manifest[PFCManifestKeyAvailability] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyAvailability];

        __block NSString *arrayKeyPath;
        [manifest[PFCManifestKeyAvailability] ?: @[] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull availabilityDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
          arrayKeyPath = [NSString stringWithFormat:@"%@:%lu", keyPath, (unsigned long)idx];
          [reportAvailability addObject:[self reportForRootAvailabilityKey:availabilityDict manifest:manifest parentKeyPath:arrayKeyPath]];
        }];
    }
    return [reportAvailability copy];
}

- (NSDictionary *)reportForRootAvailabilityKey:(NSDictionary *)availabilityDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (availabilityDict[@"AvailabilityKey"] != nil) {
        [_manifestRootKeys addObject:@"AvailabilityKey"];

        if ([availabilityDict[@"AvailabilityKey"] length] == 0) {
            return
                [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:@"AvailabilityKey" keyPath:parentKeyPath value:availabilityDict[@"AvailabilityKey"] manifest:manifest overrides:nil];
        }

        if (![[manifest allKeys] containsObject:availabilityDict[@"AvailabilityKey"]] && ![availabilityDict[@"AvailabilityKey"] isEqualToString:@"Self"]) {
            return
                [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:@"AvailabilityKey" keyPath:parentKeyPath value:availabilityDict[@"AvailabilityKey"] manifest:manifest overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:@"AvailabilityKey" keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootCellType:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyCellType] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyCellType];
        if (![manifest[PFCManifestKeyCellType] isEqualToString:@"Menu"]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyCellType keyPath:nil value:manifest[PFCManifestKeyCellType] manifest:manifest overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyCellType keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootDescription:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyDescription] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyDescription];
        if ([manifest[PFCManifestKeyDescription] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyDescription keyPath:nil value:manifest[PFCManifestKeyDescription] manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootDomain:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyDomain] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyDomain];
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
        [_manifestRootKeys addObject:PFCManifestKeyIconName];
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
        [_manifestRootKeys addObject:PFCManifestKeyIconPath];
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
        [_manifestRootKeys addObject:PFCManifestKeyIconPathBundle];
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
        [_manifestRootKeys addObject:PFCManifestKeyManifestContent];

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

- (NSDictionary *)reportForManifestRootPayloadLibrary:(NSDictionary *)manifest {
    if (manifest[PFCRuntimeKeyPayloadLibrary] != nil) {
        // Could also check that the library is valid.
        [_manifestRootKeys addObject:PFCRuntimeKeyPayloadLibrary];
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCRuntimeKeyPayloadLibrary keyPath:nil value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootPayloadTabTitle:(NSDictionary *)manifest {
    [self setPayloadTabTitle:manifest[PFCManifestKeyPayloadTabTitle] ?: @""];
    if (manifest[PFCManifestKeyPayloadTabTitle] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyPayloadTabTitle];

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
        [_manifestRootKeys addObject:PFCManifestKeyPayloadTypes];

        if ([manifest[PFCManifestKeyPayloadTypes] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyPayloadTypes keyPath:nil value:manifest[PFCManifestKeyPayloadTypes] manifest:manifest overrides:nil];
        } else {
            [_payloadTypes addObjectsFromArray:manifest[PFCManifestKeyPayloadTypes]];
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
            [_manifestRootKeys addObject:PFCManifestKeyRequired];
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:PFCManifestKeyRequired keyPath:nil value:manifest[PFCManifestKeyRequired] manifest:manifest overrides:nil];
        }
    } else if (manifest[PFCManifestKeyRequired] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyRequired];
    }
    return @{};
}

- (NSDictionary *)reportForManifestRootTitle:(NSDictionary *)manifest {
    if (manifest[PFCManifestKeyTitle] != nil) {
        [_manifestRootKeys addObject:PFCManifestKeyTitle];

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
      [_manifestContentDictKeys removeAllObjects];
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
    [reportContentDict addObjectsFromArray:[self reportForAvailability:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                 // Key: Availability
    [reportContentDict addObject:[self reportForIdentifier:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                             // Key: Identifier
    [reportContentDict addObject:[self reportForOptionalKey:PFCManifestKeyOptional manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: Optional
    [reportContentDict addObject:[self reportForRequiredKey:PFCManifestKeyRequired manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: Required
    [reportContentDict addObject:[self reportForToolTipDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                     // Key: ToolTipDescription

    // -------------------------------------------------------------------------
    //  Reports for CellType specific keys
    // -------------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyCellType] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyCellType];
        [reportContentDict
            addObjectsFromArray:[self reportForCellType:manifestContentDict[PFCManifestKeyCellType] manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    } else {
        [reportContentDict addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyCellType keyPath:parentKeyPath value:nil manifest:manifest overrides:nil]];
    }

    for (NSString *key in [manifestContentDict allKeys]) {
        if (![_manifestContentDictKeys containsObject:key]) {
            [reportContentDict
                addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyIncompatible key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil]];
        }
    }

    return [reportContentDict copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)reportForAllowedFileTypes:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyAllowedFileTypes] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyAllowedFileTypes];

        if ([manifestContentDict[PFCManifestKeyAllowedFileTypes] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyAllowedFileTypes
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyAllowedFileTypes]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForAllowedFileExtensions:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyAllowedFileExtensions] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyAllowedFileExtensions];

        if ([manifestContentDict[PFCManifestKeyAllowedFileExtensions] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyAllowedFileExtensions
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyAllowedFileExtensions]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForAvailableValues:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyAvailableValues] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyAvailableValues];

        if ([manifestContentDict[PFCManifestKeyAvailableValues] count] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueRequiredNotFound key:PFCManifestKeyAvailableValues keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        } else {
            [_manifestContentDictAvailableValues addObjectsFromArray:manifestContentDict[PFCManifestKeyAvailableValues]];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyAvailableValues keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForButtonTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyButtonTitle] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyButtonTitle];

        if ([manifestContentDict[PFCManifestKeyButtonTitle] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyButtonTitle
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyButtonTitle]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  DefaultValue(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForDefaultValueKey:(NSString *)key
                       manifestContentDict:(NSDictionary *)manifestContentDict
                                  manifest:(NSDictionary *)manifest
                             parentKeyPath:(NSString *)parentKeyPath
                              allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];

        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[key]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }

        if ([valueType isEqualToString:PFCValueTypeString]) {
            if ([manifestContentDict[key] length] == 0) {
                return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
            }
        }

        // FIXME - Finish these tests
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  Description
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForDescription:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyDescription] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyDescription];

        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyDescription keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForFileInfoProcessor:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyFileInfoProcessor] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyFileInfoProcessor];

        if ([manifestContentDict[PFCManifestKeyFileInfoProcessor] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyFileInfoProcessor keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForFilePrompt:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyFilePrompt] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyFilePrompt];

        if ([manifestContentDict[PFCManifestKeyFilePrompt] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyFilePrompt keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForFontWeight:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyFontWeight] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyFontWeight];

        if ([manifestContentDict[PFCManifestKeyFontWeight] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyFontWeight keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }

        if (![manifestContentDict[PFCManifestKeyFontWeight] isEqualToString:@"Bold"]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyFontWeight keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForIdentifier:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyIdentifier] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyIdentifier];

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

- (NSDictionary *)reportForIndentLeft:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyIndentLeft] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyIndentLeft];
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  IndentLevel
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForIndentLevel:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyIndentLevel];

        if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                   key:PFCManifestKeyIndentLevel
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyIndentLevel]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([manifestContentDict[PFCManifestKeyIndentLevel] integerValue] < 1 || 5 < [manifestContentDict[PFCManifestKeyIndentLevel] integerValue]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyIndentLevel
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyIndentLevel]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForMaxValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyMaxValue] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyMaxValue];
    }
    return @{};
}

- (NSDictionary *)reportForMinValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyMinValue] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyMinValue];
    }
    return @{};
}

- (NSDictionary *)reportForMinValueOffsetDays:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyMinValueOffsetDays] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyMinValueOffsetDays];

        if ([manifestContentDict[PFCManifestKeyMinValueOffsetDays] integerValue] < 1) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyMinValueOffsetDays
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyMinValueOffsetDays]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForMinValueOffsetHours:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyMinValueOffsetHours] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyMinValueOffsetHours];

        if ([manifestContentDict[PFCManifestKeyMinValueOffsetHours] integerValue] < 1) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyMinValueOffsetHours
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyMinValueOffsetHours]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForMinValueOffsetMinutes:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyMinValueOffsetMinutes];

        if ([manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] integerValue] < 1) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyMinValueOffsetMinutes
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyMinValueOffsetMinutes]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForOptionalKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];

        if ([manifestContentDict[PFCManifestKeyRequired] boolValue] && manifestContentDict[key] != nil) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  PlaceholderValue(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForPlaceholderValueKey:(NSString *)key
                           manifestContentDict:(NSDictionary *)manifestContentDict
                                      manifest:(NSDictionary *)manifest
                                 parentKeyPath:(NSString *)parentKeyPath
                                  allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];
        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[key]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }

        if ([valueType isEqualToString:PFCValueTypeString]) {
            if ([manifestContentDict[key] length] == 0) {
                return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
            }
        }

        // FIXME - Finish these tests
    }
    return @{};
} // reportForPlaceholderValueKey:manifestContentDict:manifest:parentKeyPath:allowedTypes

- (NSDictionary *)reportForRequiredKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];
    }
    return @{};
}

- (NSDictionary *)reportForShowDateInterval:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyShowDateInterval] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyShowDateInterval];
    }
    return @{};
}

- (NSDictionary *)reportForShowDateTime:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyShowDateTime] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyShowDateTime];
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  Title
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyTitle] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyTitle];
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyToolTipDescription keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForToolTipDescription:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyToolTipDescription] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyToolTipDescription];
        if ([manifestContentDict[PFCManifestKeyToolTipDescription] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyToolTipDescription keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForUnit:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyUnit] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyUnit];
        if ([manifestContentDict[PFCManifestKeyUnit] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyUnit keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }
    }
    return @{};
}

// -----------------------------------------------------------------------------
//  ValueKeys
// -----------------------------------------------------------------------------
- (NSArray *)reportForValueKeys:(NSDictionary *)manifestContentDict
                       manifest:(NSDictionary *)manifest
                  parentKeyPath:(NSString *)parentKeyPath
                       required:(BOOL)required
                availableValues:(NSArray *)availableValues {
    NSMutableArray *reportValueKeys;
    NSString *keyPath = [NSString stringWithFormat:@"%@:%@", parentKeyPath, PFCManifestKeyValueKeys];
    if (manifestContentDict[PFCManifestKeyValueKeys] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyValueKeys];

        if ([manifestContentDict[PFCManifestKeyValueKeys] count] == 0) {
            [reportValueKeys addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                                       key:PFCManifestKeyValueKeys
                                                                   keyPath:parentKeyPath
                                                                     value:manifestContentDict[PFCManifestKeyValueKeys]
                                                                  manifest:manifest
                                                                 overrides:nil]];
        } else {
            for (NSString *key in [manifestContentDict[PFCManifestKeyValueKeys] allKeys] ?: @[]) {
                NSString *valueKeyPath = [NSString stringWithFormat:@"%@:%@", keyPath, key];
                if (![availableValues containsObject:key]) {
                    [reportValueKeys addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                                               key:key
                                                                           keyPath:valueKeyPath
                                                                             value:manifestContentDict[PFCManifestKeyValueKeysShared][key]
                                                                          manifest:manifest
                                                                         overrides:nil]];
                } else {
                    __block NSString *arrayKeyPath;
                    [manifestContentDict[PFCManifestKeyValueKeys][key] ?: @[]
                        enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull sharedManifestContentDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
                          arrayKeyPath = [NSString stringWithFormat:@"%@:%lu", valueKeyPath, (unsigned long)idx];
                          [reportValueKeys addObjectsFromArray:[self reportForManifestContentDict:sharedManifestContentDict manifest:manifest parentKeyPath:[arrayKeyPath copy]]];
                        }];
                }
            }
        }
    } else if (required) {
        [reportValueKeys addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyValueKeys keyPath:parentKeyPath value:nil manifest:manifest overrides:nil]];
    }
    return [reportValueKeys copy];
}

// -----------------------------------------------------------------------------
//  ValueKeysShared
// -----------------------------------------------------------------------------
- (NSArray *)reportForValueKeysShared:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportValueKeysShared;
    NSString *keyPath = [NSString stringWithFormat:@"%@:%@", parentKeyPath, PFCManifestKeyValueKeysShared];
    if (manifestContentDict[PFCManifestKeyValueKeysShared] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyValueKeysShared];

        if ([manifestContentDict[PFCManifestKeyValueKeysShared] count] == 0) {
            [reportValueKeysShared addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                                             key:PFCManifestKeyValueKeysShared
                                                                         keyPath:parentKeyPath
                                                                           value:manifestContentDict[PFCManifestKeyValueKeysShared]
                                                                        manifest:manifest
                                                                       overrides:nil]];
        } else {
            for (NSString *key in [manifestContentDict[PFCManifestKeyValueKeysShared] allKeys] ?: @[]) {
                NSString *sharedKeyPath = [NSString stringWithFormat:@"%@:%@", keyPath, key];
                if (![_manifestContentDictValueKeysShared containsObject:key]) {
                    [reportValueKeysShared addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                                                     key:key
                                                                                 keyPath:sharedKeyPath
                                                                                   value:manifestContentDict[PFCManifestKeyValueKeysShared][key]
                                                                                manifest:manifest
                                                                               overrides:nil]];
                } else {
                    __block NSString *arrayKeyPath;
                    [manifestContentDict[PFCManifestKeyValueKeysShared][key] ?: @[]
                        enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull sharedManifestContentDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
                          arrayKeyPath = [NSString stringWithFormat:@"%@:%lu", sharedKeyPath, (unsigned long)idx];
                          [reportValueKeysShared addObjectsFromArray:[self reportForManifestContentDict:sharedManifestContentDict manifest:manifest parentKeyPath:[arrayKeyPath copy]]];
                        }];
                }
            }
        }
    }
    return [reportValueKeysShared copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForPayloadKeys:(NSArray *)payloadKeys
              manifestContentDict:(NSDictionary *)manifestContentDict
                         manifest:(NSDictionary *)manifest
                    parentKeyPath:(NSString *)parentKeyPath
                     allowedTypes:(NSArray *)allowedTypes {

    NSMutableArray *reportPayload = [[NSMutableArray alloc] init];
    if (manifestContentDict[PFCManifestKeyPayloadKey] != nil) {
        [reportPayload addObject:[self reportForPayloadKey:PFCManifestKeyPayloadKey
                                       manifestContentDict:manifestContentDict
                                                  manifest:manifest
                                             parentKeyPath:parentKeyPath
                                                  optional:[manifestContentDict[PFCManifestKeyOptional] boolValue]
                                                  required:[manifestContentDict[PFCManifestKeyRequired] boolValue]]];

        [reportPayload addObject:[self reportForPayloadTypeKey:PFCManifestKeyPayloadType manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

        [reportPayload addObject:[self reportForPayloadValueTypeKey:PFCManifestKeyPayloadValueType
                                                manifestContentDict:manifestContentDict
                                                           manifest:manifest
                                                      parentKeyPath:parentKeyPath
                                                       allowedTypes:allowedTypes]];
    } else {
        for (NSDictionary *payloadKeyDict in payloadKeys ?: @[]) {
            [reportPayload addObjectsFromArray:[self reportForPayloadKeySuffix:payloadKeyDict[@"PayloadKeySuffix"]
                                                           manifestContentDict:manifestContentDict
                                                                      manifest:manifest
                                                                 parentKeyPath:parentKeyPath
                                                                  allowedTypes:payloadKeyDict[@"AllowedTypes"]]];
        }
    }
    return [reportPayload copy];
}

- (NSArray *)reportForPayloadKeySuffix:(NSString *)suffix
                   manifestContentDict:(NSDictionary *)manifestContentDict
                              manifest:(NSDictionary *)manifest
                         parentKeyPath:(NSString *)parentKeyPath
                          allowedTypes:(NSArray *)allowedTypes {

    NSMutableArray *reportPayloadKeySuffix = [[NSMutableArray alloc] init];
    NSDictionary *payloadKeySuffixDict;
    if ([suffix isEqualToString:@"Checkbox"]) {
        payloadKeySuffixDict = @{
            @"Key" : PFCManifestKeyPayloadKeyCheckbox,
            @"Optinal" : @([manifestContentDict[PFCManifestKeyOptionalCheckbox] boolValue]),
            @"Required" : @([manifestContentDict[PFCManifestKeyRequiredCheckbox] boolValue]),
            @"Type" : PFCManifestKeyPayloadTypeCheckbox,
            @"ValueType" : PFCManifestKeyPayloadValueTypeCheckbox,
            @"DefaultValue" : PFCManifestKeyDefaultValueCheckbox
        };
    } else if ([suffix isEqualToString:@"Host"]) {
        payloadKeySuffixDict = @{
            @"Key" : PFCManifestKeyPayloadKeyHost,
            @"Optinal" : @([manifestContentDict[PFCManifestKeyOptionalHost] boolValue]),
            @"Required" : @([manifestContentDict[PFCManifestKeyRequiredHost] boolValue]),
            @"Type" : PFCManifestKeyPayloadTypeHost,
            @"ValueType" : PFCManifestKeyPayloadValueTypeHost,
            @"DefaultValue" : PFCManifestKeyDefaultValueHost
        };
    } else if ([suffix isEqualToString:@"Port"]) {
        payloadKeySuffixDict = @{
            @"Key" : PFCManifestKeyPayloadKeyPort,
            @"Optinal" : @([manifestContentDict[PFCManifestKeyOptionalPort] boolValue]),
            @"Required" : @([manifestContentDict[PFCManifestKeyRequiredPort] boolValue]),
            @"Type" : PFCManifestKeyPayloadTypePort,
            @"ValueType" : PFCManifestKeyPayloadValueTypePort,
            @"DefaultValue" : PFCManifestKeyDefaultValuePort
        };
    } else if ([suffix isEqualToString:@"TextField"]) {
        payloadKeySuffixDict = @{
            @"Key" : PFCManifestKeyPayloadKeyTextField,
            @"Optinal" : @([manifestContentDict[PFCManifestKeyOptionalTextField] boolValue]),
            @"Required" : @([manifestContentDict[PFCManifestKeyRequiredTextField] boolValue]),
            @"Type" : PFCManifestKeyPayloadTypeTextField,
            @"ValueType" : PFCManifestKeyPayloadValueTypeTextField,
            @"DefaultValue" : PFCManifestKeyDefaultValueTextField
        };
    } else {
        DDLogError(@"Unknown payload key suffix: %@", suffix);
        return @[];
    }

    [reportPayloadKeySuffix addObject:[self reportForPayloadKey:payloadKeySuffixDict[@"Key"]
                                            manifestContentDict:manifestContentDict
                                                       manifest:manifest
                                                  parentKeyPath:parentKeyPath
                                                       optional:[payloadKeySuffixDict[@"Optinal"] boolValue]
                                                       required:[payloadKeySuffixDict[@"Required"] boolValue]]];

    [reportPayloadKeySuffix addObject:[self reportForPayloadTypeKey:payloadKeySuffixDict[@"Type"] manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    [reportPayloadKeySuffix addObject:[self reportForPayloadValueTypeKey:payloadKeySuffixDict[@"ValueType"]
                                                     manifestContentDict:manifestContentDict
                                                                manifest:manifest
                                                           parentKeyPath:parentKeyPath
                                                            allowedTypes:allowedTypes]];

    [reportPayloadKeySuffix addObject:[self reportForDefaultValueKey:payloadKeySuffixDict[@"DefaultValue"]
                                                 manifestContentDict:manifestContentDict
                                                            manifest:manifest
                                                       parentKeyPath:parentKeyPath
                                                        allowedTypes:allowedTypes]];

    return [reportPayloadKeySuffix copy];
}

- (NSDictionary *)reportForPayloadKey:(NSString *)key
                  manifestContentDict:(NSDictionary *)manifestContentDict
                             manifest:(NSDictionary *)manifest
                        parentKeyPath:(NSString *)parentKeyPath
                             optional:(BOOL)optional
                             required:(BOOL)required {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];

        if (required && !optional && [manifestContentDict[key] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }

        if ([_payloadKeys containsObject:[NSString stringWithFormat:@"%@:%@", parentKeyPath, manifestContentDict[key]]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorDuplicate key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        } else {
            [_payloadKeys addObject:[NSString stringWithFormat:@"%@:%@", parentKeyPath, manifestContentDict[key]]];
        }
    } else if (required) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:PFCManifestKeyPayloadKey keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForPayloadTypeKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {

    if (key != PFCManifestKeyPayloadType && [manifestContentDict[PFCManifestKeyPayloadType] length] != 0) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }

    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];

        if ([manifestContentDict[key] length] == 0) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
        }

        if (![_payloadTypes containsObject:manifestContentDict[key]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueRequiredNotFound key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

- (NSDictionary *)reportForPayloadValueTypeKey:(NSString *)key
                           manifestContentDict:(NSDictionary *)manifestContentDict
                                      manifest:(NSDictionary *)manifest
                                 parentKeyPath:(NSString *)parentKeyPath
                                  allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[key] != nil) {
        [_manifestContentDictKeys addObject:key];

        if ([allowedTypes ?: @[] count] == 1) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }

        if (![allowedTypes containsObject:manifestContentDict[key]]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:key keyPath:parentKeyPath value:manifestContentDict[key] manifest:manifest overrides:nil];
        }
    } else if ([allowedTypes ?: @[] count] != 1) {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:key keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellType Keys
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForCellType:(NSString *)cellType manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportCellType = [[NSMutableArray alloc] init];

    // ---------------------------------------------------------------------
    //  Checkbox
    // ---------------------------------------------------------------------
    if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        [reportCellType addObjectsFromArray:[PFCCheckboxCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        [reportCellType addObjectsFromArray:[PFCCheckboxNoDescriptionCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        [reportCellType addObjectsFromArray:[PFCDatePickerCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {
        [reportCellType addObjectsFromArray:[PFCDatePickerNoTitleCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        [reportCellType addObjectsFromArray:[PFCFileCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  Padding
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePadding]) {
        // No Content

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        [reportCellType addObjectsFromArray:[PFCPopUpButtonCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        [reportCellType addObjectsFromArray:[PFCPopUpButtonLeftCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {
        [reportCellType addObjectsFromArray:[PFCPopUpButtonNoTitleCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        [reportCellType addObjectsFromArray:[PFCSegmentedControlCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        [reportCellType addObjectsFromArray:[PFCTextFieldCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {
        [reportCellType addObjectsFromArray:[PFCTextFieldCheckboxCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        // No Checks

        // ---------------------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort]) {
        [reportCellType addObjectsFromArray:[PFCTextFieldHostPortCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        [reportCellType
            addObjectsFromArray:[PFCTextFieldHostPortCheckboxCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle]) {
        [reportCellType addObjectsFromArray:[PFCTextFieldNoTitleCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {
        [reportCellType addObjectsFromArray:[PFCTextFieldNumberCellView lintReportForManifestContentDict:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy] sender:self]];

        // ---------------------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeTextFieldNumberLeft:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  TextView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeTextView:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // -------------------------------------------------------------------------
        //  CellType: *UNKNOWN*
        // -------------------------------------------------------------------------
    } else {
        [reportCellType addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                                  key:PFCManifestKeyCellType
                                                              keyPath:parentKeyPath
                                                                value:manifestContentDict[PFCManifestKeyCellType]
                                                             manifest:manifest
                                                            overrides:nil]];
    }

    return [reportCellType copy];
}

- (NSArray *)reportForCellTypeTextFieldNumberLeft:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportTextFieldNumberLeft = [[NSMutableArray alloc] init];
    [reportTextFieldNumberLeft addObject:[self reportForDefaultValueKey:PFCManifestKeyDefaultValue
                                                    manifestContentDict:manifestContentDict
                                                               manifest:manifest
                                                          parentKeyPath:parentKeyPath
                                                           allowedTypes:@[ PFCValueTypeInteger, PFCValueTypeFloat ]]];                   // Key: DefaultValue
    [reportTextFieldNumberLeft addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: Description
    [reportTextFieldNumberLeft addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];       // Key: Title
    [reportTextFieldNumberLeft addObject:[self reportForMaxValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];    // Key: MinValue
    [reportTextFieldNumberLeft addObject:[self reportForMinValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];    // Key: MaxValue
    return [reportTextFieldNumberLeft copy];
}

- (NSArray *)reportForCellTypeTextView:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportTextView = [[NSMutableArray alloc] init];
    [reportTextView addObject:[self reportForDefaultValueKey:PFCManifestKeyDefaultValue
                                         manifestContentDict:manifestContentDict
                                                    manifest:manifest
                                               parentKeyPath:parentKeyPath
                                                allowedTypes:@[ PFCValueTypeString ]]];                                       // Key: DefaultValue
    [reportTextView addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: Description
    [reportTextView addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];       // Key: Title
    /*
    [reportTextView
        addObject:[self reportForPayloadKey:PFCManifestKeyPayloadKey manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath optional:NO ignored:NO]]; // Key: PayloadKey
    [reportTextView addObject:[self reportForPayloadTypeKey:PFCManifestKeyPayloadType
                                        manifestContentDict:manifestContentDict
                                                   manifest:manifest
                                              parentKeyPath:parentKeyPath
                                                   optional:NO
                                                    ignored:NO]]; // Key: PayloadType
    [reportTextView addObject:[self reportForPayloadValueTypeKey:PFCManifestKeyPayloadType
                                             manifestContentDict:manifestContentDict
                                                        manifest:manifest
                                                   parentKeyPath:parentKeyPath
                                                        optional:YES
                                                    allowedTypes:@[ PFCValueTypeString ]]]; // Key: PayloadValueType
    [reportTextView addObject:[self reportForPlaceholderValueKey:PFCManifestKeyPlaceholderValue
                                             manifestContentDict:manifestContentDict
                                                        manifest:manifest
                                                   parentKeyPath:parentKeyPath
                                                    allowedTypes:@[ PFCValueTypeString ]]]; // Key: PlaceholderValue
     */
    return [reportTextView copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Availability
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)reportForAvailability:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportAvailability = [[NSMutableArray alloc] init];
    NSString *keyPath = [NSString stringWithFormat:@"%@:%@", parentKeyPath, PFCManifestKeyAvailability];
    if (manifestContentDict[PFCManifestKeyAvailability] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyAvailability];

        __block NSString *arrayKeyPath;
        [manifestContentDict[PFCManifestKeyAvailability] ?: @[] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull availabilityDict, NSUInteger idx, BOOL *_Nonnull __unused stop) {
          arrayKeyPath = [NSString stringWithFormat:@"%@:%lu", keyPath, (unsigned long)idx];
          [reportAvailability addObject:[self reportForAvailabilityDict:availabilityDict manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:arrayKeyPath]];
        }];
    }
    return [reportAvailability copy];
}

- (NSDictionary *)reportForAvailabilityDict:(NSDictionary *)availabilityDict
                        manifestContentDict:(NSDictionary *)manifestContentDict
                                   manifest:(NSDictionary *)manifest
                              parentKeyPath:(NSString *)parentKeyPath {
    if (availabilityDict[@"AvailabilityKey"] != nil) {
        [_manifestContentDictKeys addObject:@"AvailabilityKey"];
        if ([availabilityDict[@"AvailabilityKey"] length] == 0) {
            return
                [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:@"AvailabilityKey" keyPath:parentKeyPath value:availabilityDict[@"AvailabilityKey"] manifest:manifest overrides:nil];
        }

        if (![manifestContentDict.allKeys containsObject:availabilityDict[@"AvailabilityKey"]] && ![availabilityDict[@"AvailabilityKey"] isEqualToString:@"Self"]) {
            // If the availability key is any one of these, let it pass. This needs definition.
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeySuggestedNotFound
                                                   key:@"AvailabilityKey"
                                               keyPath:parentKeyPath
                                                 value:availabilityDict[@"AvailabilityKey"]
                                              manifest:manifest
                                             overrides:nil];
        }
    } else {
        return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyRequiredNotFound key:@"AvailabilityKey" keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
    }
    return @{};
}

@end
