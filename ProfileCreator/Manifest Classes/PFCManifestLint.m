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

    [manifestReportRoot addObject:[self reportForManifestRootAllowMultiplePayloads:manifest]]; // Key: AllowMultiplePayloads
    [manifestReportRoot addObject:[self reportForManifestRootCellType:manifest]];              // Key: CellType
    [manifestReportRoot addObject:[self reportForManifestRootDescription:manifest]];           // Key: Description
    [manifestReportRoot addObject:[self reportForManifestRootDomain:manifest]];                // Key: Domain
    [manifestReportRoot addObjectsFromArray:[self reportForManifestRootIcon:manifest]];        // Key: IconName, IconPath, IconBundlePath
    [manifestReportRoot addObject:[self reportForManifestRootManifestContent:manifest]];       // Key: ManifestContent
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTabTitle:manifest]];       // Key: PayloadTabTitle
    [manifestReportRoot addObject:[self reportForManifestRootPayloadTypes:manifest]];          // Key: PayloadTypes
    [manifestReportRoot addObject:[self reportForManifestRootRequired:manifest]];              // Key: Required
    [manifestReportRoot addObject:[self reportForManifestRootTitle:manifest]];                 // Key: Title

    for (NSString *key in [manifest allKeys]) {
        if (![_manifestRootKeys containsObject:key]) {
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
    // [reportContentDict addObject:[self reportForAvailability:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];   // Key: Availability
    [reportContentDict addObject:[self reportForIdentifier:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];         // Key: Identifier
    [reportContentDict addObject:[self reportForOptional:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Optional
    [reportContentDict addObject:[self reportForRequired:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Required
    [reportContentDict addObject:[self reportForToolTipDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ToolTipDescription

    // -------------------------------------------------------------------------
    //  Reports for CellType specific keys
    // -------------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyCellType] != nil) {
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

- (NSDictionary *)reportForDefaultValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[PFCManifestKeyDefaultValue] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyDefaultValue];

        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[PFCManifestKeyDefaultValue]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyDefaultValue
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyDefaultValue]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([valueType isEqualToString:PFCValueTypeString]) {
            if ([manifestContentDict[PFCManifestKeyDefaultValue] length] == 0) {
                return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyDefaultValue keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
            }
        }

        // FIXME - Finish these tests
    }
    return @{};
}

- (NSDictionary *)reportForDefaultValueCheckbox:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[PFCManifestKeyDefaultValueCheckbox] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyDefaultValueCheckbox];

        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[PFCManifestKeyDefaultValueCheckbox]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyDefaultValue
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyDefaultValueCheckbox]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForDefaultValueTextField:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[PFCManifestKeyDefaultValueTextField] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyDefaultValueTextField];

        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[PFCManifestKeyDefaultValueTextField]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyDefaultValueTextField
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyDefaultValueTextField]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([valueType isEqualToString:PFCValueTypeString]) {
            if ([manifestContentDict[PFCManifestKeyDefaultValueTextField] length] == 0) {
                return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyDefaultValueTextField keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
            }
        }
    }
    return @{};
}

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

- (NSDictionary *)reportForOptional:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyOptional] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyOptional];

        if ([manifestContentDict[PFCManifestKeyRequired] boolValue] && manifestContentDict[PFCManifestKeyOptional] != nil) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorKeyIgnored
                                                   key:PFCManifestKeyOptional
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyOptional]
                                              manifest:manifest
                                             overrides:nil];
        }
    }
    return @{};
}

- (NSDictionary *)reportForPlaceholderValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath allowedTypes:(NSArray *)allowedTypes {
    if (manifestContentDict[PFCManifestKeyPlaceholderValue] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyPlaceholderValue];
        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:manifestContentDict[PFCManifestKeyPlaceholderValue]];
        if (![allowedTypes containsObject:valueType]) {
            return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                   key:PFCManifestKeyPlaceholderValue
                                               keyPath:parentKeyPath
                                                 value:manifestContentDict[PFCManifestKeyPlaceholderValue]
                                              manifest:manifest
                                             overrides:nil];
        }

        if ([valueType isEqualToString:PFCValueTypeString]) {
            if ([manifestContentDict[PFCManifestKeyPlaceholderValue] length] == 0) {
                return [PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid key:PFCManifestKeyPlaceholderValue keyPath:parentKeyPath value:nil manifest:manifest overrides:nil];
            }
        }

        // FIXME - Finish these tests
    }
    return @{};
}

- (NSDictionary *)reportForRequired:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    if (manifestContentDict[PFCManifestKeyRequired] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyRequired];
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

- (NSDictionary *)reportForPayloadKey:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath ignored:(BOOL)ignored {
    if (manifestContentDict[PFCManifestKeyPayloadKey] != nil) {
        [_manifestContentDictKeys addObject:PFCManifestKeyPayloadKey];
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
        [_manifestContentDictKeys addObject:PFCManifestKeyPayloadType];
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
        [_manifestContentDictKeys addObject:PFCManifestKeyPayloadValueType];
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

- (NSArray *)reportForCellType:(NSString *)cellType manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportCellType = [[NSMutableArray alloc] init];

    // ---------------------------------------------------------------------
    //  Checkbox
    // ---------------------------------------------------------------------
    if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeCheckbox:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeCheckboxNoDescription:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeDatePicker:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeDatePickerNoTitle:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeFile:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  Padding
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePadding]) {
        // No Content

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypePopUpButton:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypePopUpButtonLeft:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypePopUpButtonNoTitle:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeSegmentedControl:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeTextField:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {
        [reportCellType addObjectsFromArray:[self reportForCellTypeTextFieldCheckbox:manifestContentDict manifest:manifest parentKeyPath:[parentKeyPath copy]]];

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
        [reportCellType addObject:[PFCManifestLintError errorWithCode:kPFCLintErrorValueInvalid
                                                                  key:PFCManifestKeyCellType
                                                              keyPath:parentKeyPath
                                                                value:manifestContentDict[PFCManifestKeyCellType]
                                                             manifest:manifest
                                                            overrides:nil]];
    }

    return [reportCellType copy];
}

- (NSArray *)reportForCellTypeCheckbox:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportCheckbox;
    [reportCheckbox addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean ]]]; // Key: DefaultValue
    [reportCheckbox addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                        // Key: Description
    [reportCheckbox addObject:[self reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                         // Key: IndentLeft
    [reportCheckbox addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                        // Key: IndentLevel
    [reportCheckbox addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                              // Key: Title
    [reportCheckbox
        addObjectsFromArray:[self reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:NO availableValues:@[ @"True", @"False" ]]]; // Key: ValueKeys
    return [reportCheckbox copy];
}

- (NSArray *)reportForCellTypeCheckboxNoDescription:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportCheckboxNoDescription;
    [reportCheckboxNoDescription addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean ]]]; // Key: DefaultValue
    [reportCheckboxNoDescription addObject:[self reportForFontWeight:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                         // Key: FontWeight
    [reportCheckboxNoDescription addObject:[self reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                         // Key: IndentLeft
    [reportCheckboxNoDescription addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                        // Key: IndentLevel
    [reportCheckboxNoDescription addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                              // Key: Title
    [reportCheckboxNoDescription
        addObjectsFromArray:[self reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:NO availableValues:@[ @"True", @"False" ]]]; // Key: ValueKeys
    return [reportCheckboxNoDescription copy];
}

- (NSArray *)reportForCellTypeDatePicker:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportDatePicker;
    [reportDatePicker addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeDate ]]]; // Key: DefaultValue
    [reportDatePicker addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                     // Key: Description
    [reportDatePicker addObject:[self reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                      // Key: IndentLeft
    [reportDatePicker addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                     // Key: IndentLevel
    [reportDatePicker addObject:[self reportForMinValueOffsetDays:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                              // Key: MinValueOffsetDays
    [reportDatePicker addObject:[self reportForMinValueOffsetHours:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                             // Key: MinValueOffsetHours
    [reportDatePicker addObject:[self reportForMinValueOffsetMinutes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                           // Key: MinValueOffsetMinutes
    [reportDatePicker addObject:[self reportForShowDateInterval:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                // Key: ShowDateInterval
    [reportDatePicker addObject:[self reportForShowDateTime:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                    // Key: ShowDateTime
    [reportDatePicker addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                           // Key: Title
    return [reportDatePicker copy];
}

- (NSArray *)reportForCellTypeDatePickerNoTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportDatePicker;
    [reportDatePicker addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeDate ]]]; // Key: DefaultValue
    [reportDatePicker addObject:[self reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                      // Key: IndentLeft
    [reportDatePicker addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                     // Key: IndentLevel
    [reportDatePicker addObject:[self reportForMinValueOffsetDays:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                              // Key: MinValueOffsetDays
    [reportDatePicker addObject:[self reportForMinValueOffsetHours:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                             // Key: MinValueOffsetHours
    [reportDatePicker addObject:[self reportForMinValueOffsetMinutes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                           // Key: MinValueOffsetMinutes
    [reportDatePicker addObject:[self reportForShowDateInterval:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                // Key: ShowDateInterval
    [reportDatePicker addObject:[self reportForShowDateTime:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                    // Key: ShowDateTime
    return [reportDatePicker copy];
}

- (NSArray *)reportForCellTypeFile:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportFile;
    [reportFile addObject:[self reportForAllowedFileTypes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];      // Key: AllowedFileTypes
    [reportFile addObject:[self reportForAllowedFileExtensions:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: AllowedFileExtensions
    [reportFile addObject:[self reportForButtonTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: ButtonTitle
    [reportFile addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Description
    [reportFile addObject:[self reportForFileInfoProcessor:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];     // Key: FileInfoProcessor
    [reportFile addObject:[self reportForFilePrompt:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];            // Key: FilePrompt
    [reportFile addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                 // Key: Title
    [reportFile addObject:[self reportForPayloadValueType:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:YES allowedTypes:@[ PFCValueTypeData ]]]; // Key: PayloadValueType
    return [reportFile copy];
}

- (NSArray *)reportForCellTypePopUpButton:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportPopUpButton;
    [reportPopUpButton addObject:[self reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: AvailableValues
    [reportPopUpButton addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];     // Key: IndentLevel
    [reportPopUpButton addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Title
    [reportPopUpButton
        addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean, PFCValueTypeString ]]]; // Key: DefaultValue
    [reportPopUpButton addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                             // Key: Description
    [reportPopUpButton addObjectsFromArray:[self reportForValueKeys:manifestContentDict
                                                           manifest:manifest
                                                      parentKeyPath:parentKeyPath
                                                           required:YES
                                                    availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];                      // Key: ValueKeys
    [reportPopUpButton addObjectsFromArray:[self reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ValueKeysShared
    return [reportPopUpButton copy];
}

- (NSArray *)reportForCellTypePopUpButtonLeft:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportPopUpButtonLeft;
    [reportPopUpButtonLeft addObject:[self reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: AvailableValues
    [reportPopUpButtonLeft addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];           // Key: Title
    [reportPopUpButtonLeft
        addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean, PFCValueTypeString ]]]; // Key: DefaultValue
    [reportPopUpButtonLeft addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                         // Key: Description
    [reportPopUpButtonLeft addObjectsFromArray:[self reportForValueKeys:manifestContentDict
                                                               manifest:manifest
                                                          parentKeyPath:parentKeyPath
                                                               required:YES
                                                        availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];                      // Key: ValueKeys
    [reportPopUpButtonLeft addObjectsFromArray:[self reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ValueKeysShared
    return [reportPopUpButtonLeft copy];
}

- (NSArray *)reportForCellTypePopUpButtonNoTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportPopUpButtonNoTitle;
    [reportPopUpButtonNoTitle addObject:[self reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: AvailableValues
    [reportPopUpButtonNoTitle addObject:[self reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];     // Key: IndentLevel
    [reportPopUpButtonNoTitle
        addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean, PFCValueTypeString ]]]; // Key: DefaultValue
    [reportPopUpButtonNoTitle addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                      // Key: Description
    [reportPopUpButtonNoTitle addObjectsFromArray:[self reportForValueKeys:manifestContentDict
                                                                  manifest:manifest
                                                             parentKeyPath:parentKeyPath
                                                                  required:YES
                                                           availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];                      // Key: ValueKeys
    [reportPopUpButtonNoTitle addObjectsFromArray:[self reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ValueKeysShared
    return [reportPopUpButtonNoTitle copy];
}

- (NSArray *)reportForCellTypeSegmentedControl:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportSegmentedControl;
    [reportSegmentedControl addObject:[self reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: AvailableValues
    [reportSegmentedControl addObjectsFromArray:[self reportForValueKeys:manifestContentDict
                                                                manifest:manifest
                                                           parentKeyPath:parentKeyPath
                                                                required:YES
                                                         availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];                      // Key: ValueKeys
    [reportSegmentedControl addObjectsFromArray:[self reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]]; // Key: ValueKeysShared
    return [reportSegmentedControl copy];
}

- (NSArray *)reportForCellTypeTextField:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportTextField;
    [reportTextField addObject:[self reportForDefaultValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]]; // Key: DefaultValue
    [reportTextField addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                       // Key: Description
    [reportTextField addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                             // Key: Title
    [reportTextField addObject:[self reportForPayloadKey:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:NO]];                             // Key: PayloadKey
    [reportTextField addObject:[self reportForPayloadType:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:NO]];                            // Key: PayloadType
    [reportTextField
        addObject:[self reportForPayloadValueType:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath ignored:YES allowedTypes:@[ PFCValueTypeString ]]];  // Key: PayloadValueType
    [reportTextField addObject:[self reportForPlaceholderValue:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]]; // Key: PlaceholderValue
    return [reportTextField copy];
}

- (NSArray *)reportForCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath {
    NSMutableArray *reportTextFieldCheckbox;
    [reportTextFieldCheckbox
        addObject:[self reportForDefaultValueCheckbox:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeBoolean ]]]; // Key: DefaultValueCheckbox
    [reportTextFieldCheckbox
        addObject:[self reportForDefaultValueTextField:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeString ]]]; // Key: DefaultValueTextField
    [reportTextFieldCheckbox addObject:[self reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                           // Key: Description
    [reportTextFieldCheckbox addObject:[self reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];                                 // Key: Title

    // FIXME - Finish these tests
    return [reportTextFieldCheckbox copy];
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
