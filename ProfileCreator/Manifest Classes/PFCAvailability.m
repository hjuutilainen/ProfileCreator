//
//  PFCAvailability.m
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
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestUtility.h"

@implementation PFCAvailability

+ (id)sharedInstance {
    static PFCAvailability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedInstance

- (BOOL)showSelf:(NSDictionary *)manifest displayKeys:(NSDictionary *)displayKeys {
    BOOL showSelf = YES;
    for (NSDictionary *availabilityDict in manifest[PFCManifestKeyAvailability] ?: @[]) {

        // -------------------------------------------------------------------------------
        //  If any dict contains 'AvailabilityKey = Self', set showManifest to NO
        //  If the current display settings are within the availability dict settings,
        //  return with YES as at all possible manifests should be show, even if only one
        //  of the selected versions can use it.
        //  The compatibility warnings should be more clear when exporting.
        // -------------------------------------------------------------------------------
        if ([availabilityDict[@"AvailabilityKey"] isEqualToString:@"Self"]) {
            showSelf = NO;

            // Return early to disable profiles that doesn't match the selected PayloadScope.
            // As this key only is applicable to OS X, and the principle is to show everything even if it's one version of one system that can use it
            // Then only check further if iOS is not available for this payload
            if ([availabilityDict[@"AvailabilityOS"] isEqualToString:@"iOS"]) {
                if (![manifest[PFCProfileDisplaySettingsKeyPayloadScope] ?: @[ PFCProfileDisplaySettingsKeyPayloadScopeUser ]
                        containsObject:displayKeys[PFCProfileDisplaySettingsKeyPayloadScope] ?: PFCProfileDisplaySettingsKeyPayloadScopeUser]) {
                    return NO;
                }
            }

            if ([self availableForOS:availabilityDict[@"AvailabilityOS"] availabilityDict:availabilityDict displayKeys:displayKeys]) {
                if ([self currentSelectionWithinVersionForOS:availabilityDict[@"AvailabilityOS"] availabilityDict:availabilityDict displayKeys:displayKeys]) {
                    return YES;
                }
            }
        }
    }
    return showSelf;
}

- (BOOL)availableForOS:(NSString *)os availabilityDict:(NSDictionary *)availabilityDict displayKeys:(NSDictionary *)displayKeys {
    if ([os isEqualToString:@"Any"]) {
        return YES;
    }

    BOOL availableForOS = YES;

    if (availabilityDict[@"Available"] == nil) {
        return availableForOS;
    }

    if ([os isEqualToString:@"OSX"] && ![availabilityDict[@"Available"] boolValue]) {
        if (![displayKeys[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue]) {
            return NO;
        }
    } else if ([os isEqualToString:@"iOS"] && ![availabilityDict[@"Available"] boolValue]) {
        if (![displayKeys[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue]) {
            return NO;
        }
    } else {
        DDLogError(@"Unknown OS: %@", os);
        return NO;
    }
    return availableForOS;
}

- (BOOL)requiredForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys {
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if ([self returnAvailabilityValueForKey:PFCManifestKeyRequired availabilityDict:availabilityDict displayKeys:displayKeys]) {
            return [availabilityDict[@"AvailabilityValue"] boolValue];
        }
    }
    return [manifestContentDict[PFCManifestKeyRequired] boolValue];
}

- (BOOL)requiredCheckboxForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys {
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if ([self returnAvailabilityValueForKey:PFCManifestKeyRequiredCheckbox availabilityDict:availabilityDict displayKeys:displayKeys]) {
            return [availabilityDict[@"AvailabilityValue"] boolValue];
        }
    }

    if (manifestContentDict[PFCManifestKeyRequiredCheckbox] != nil) {
        return [manifestContentDict[PFCManifestKeyRequiredCheckbox] boolValue];
    } else {
        return [self requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }
}

- (BOOL)requiredHostForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys {
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if ([self returnAvailabilityValueForKey:PFCManifestKeyRequiredHost availabilityDict:availabilityDict displayKeys:displayKeys]) {
            return [availabilityDict[@"AvailabilityValue"] boolValue];
        }
    }

    if (manifestContentDict[PFCManifestKeyRequiredHost] != nil) {
        return [manifestContentDict[PFCManifestKeyRequiredHost] boolValue];
    } else {
        return [self requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }
}

- (BOOL)requiredPortForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys {
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if ([self returnAvailabilityValueForKey:PFCManifestKeyRequiredPort availabilityDict:availabilityDict displayKeys:displayKeys]) {
            return [availabilityDict[@"AvailabilityValue"] boolValue];
        }
    }

    if (manifestContentDict[PFCManifestKeyRequiredPort] != nil) {
        return [manifestContentDict[PFCManifestKeyRequiredPort] boolValue];
    } else {
        return [self requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }
}

- (BOOL)currentSelectionWithinVersionForOS:(NSString *)os availabilityDict:(NSDictionary *)availabilityDict displayKeys:(NSDictionary *)displayKeys {
    if ([os isEqualToString:@"OSX"]) {
        return ([PFCGeneralUtility version:availabilityDict[@"AvailableFrom"] ?: @"0" isLowerThanVersion:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion]] &&
                [PFCGeneralUtility version:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] isLowerThanVersion:availabilityDict[@"AvailableTo"] ?: @"999"]);
    } else if ([os isEqualToString:@"iOS"]) {
        return ([PFCGeneralUtility version:availabilityDict[@"AvailableFrom"] ?: @"0" isLowerThanVersion:displayKeys[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion]] &&
                [PFCGeneralUtility version:displayKeys[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] isLowerThanVersion:availabilityDict[@"AvailableTo"] ?: @"999"]);
    } else {
        DDLogError(@"Unknown OS: %@", os);
        return NO;
    }
}

- (BOOL)returnAvailabilityValueForKey:(NSString *)key availabilityDict:(NSDictionary *)availabilityDict displayKeys:(NSDictionary *)displayKeys {
    if ([availabilityDict[@"AvailabilityKey"] isEqualToString:key]) {
        NSString *os = availabilityDict[@"AvailabilityOS"];

        // Any
        if ([os isEqualToString:@"Any"]) {
            return YES;

            // OS X
        } else if ([os isEqualToString:@"OSX"] && [displayKeys[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue]) {
            if (availabilityDict[@"AvailableFrom"] != nil || availabilityDict[@"AvailableTo"] != nil) {
                if ([self currentSelectionWithinVersionForOS:os availabilityDict:availabilityDict displayKeys:displayKeys]) {
                    return YES;
                }
            } else {
                return YES;
            }
            // iOS
        } else if ([os isEqualToString:@"iOS"] && [displayKeys[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue]) {
            if (availabilityDict[@"AvailableFrom"] != nil || availabilityDict[@"AvailableTo"] != nil) {
                if ([self currentSelectionWithinVersionForOS:os availabilityDict:availabilityDict displayKeys:displayKeys]) {
                    return YES;
                }
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (NSDictionary *)overridesForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    NSMutableDictionary *overridesDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if (![availabilityDict[PFCManifestKeyAvailabilityKey] ?: @"" isEqualToString:@"Self"] && availabilityDict[PFCManifestKeyAvailabilityValue] != nil) {
            DDLogDebug(@"AvailabilityKey: %@ is being processed", availabilityDict[PFCManifestKeyAvailabilityKey]);

            // Check AvailabilityIf
            if ([availabilityDict[PFCManifestKeyAvailableIf] count] != 0) {
                NSDictionary *availabilityIf = availabilityDict[PFCManifestKeyAvailableIf];

                // Check Selection Comparator
                NSString *selectionIdentifier = availabilityIf[PFCManifestKeyAvailabilitySelectionIdentifier] ?: @"";
                DDLogDebug(@"selectionIdentifier=%@", selectionIdentifier);

                if (selectionIdentifier.length != 0 && availabilityIf[PFCManifestKeyAvailabilitySelectionValue] != nil) {

                    // -------------------------------------------------------------------------
                    //  Get placeholder value from target manifest content dict
                    // -------------------------------------------------------------------------
                    NSDictionary *selectionManifestContentDict = [self manifestContentDictForIdentifier:selectionIdentifier manifestContent:manifest[PFCManifestKeyManifestContent]];

                    // If AvailabilityKey is 'PFCManifestKeyEnabled', verfiy that the selection target isn't disabled itself
                    /* DISABLE RECURSIVE ENABLED CHECKS FOR NOW
                    if ([availabilityDict[PFCManifestKeyAvailabilityKey] isEqualToString:PFCManifestKeyEnabled]) {
                        NSDictionary *parentOverrides = [self overridesForManifestContentDict:selectionManifestContentDict manifest:manifest settings:settings displayKeys:displayKeys];
                        DDLogDebug(@"parentOverrides=%@", parentOverrides);

                        if (parentOverrides[PFCManifestKeyEnabled] != nil && [parentOverrides[PFCManifestKeyEnabled] boolValue] == NO) {
                            overridesDict[availabilityDict[PFCManifestKeyAvailabilityKey]] = @NO;
                            continue;
                        }
                    }
*/

                    NSString *availabilityValueTypeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:availabilityIf[PFCManifestKeyAvailabilitySelectionValue]];
                    DDLogDebug(@"%@ value type: %@", PFCManifestKeyAvailabilitySelectionValue, availabilityValueTypeString);

                    if (settings[selectionIdentifier] != nil) {
                        DDLogDebug(@"Settings for selection identifier: %@", settings[selectionIdentifier]);

                        if ([availabilityValueTypeString isEqualToString:PFCValueTypeBoolean]) {
                            if ([settings[selectionIdentifier][@"Value"] boolValue] == [availabilityIf[PFCManifestKeyAvailabilitySelectionValue] boolValue]) {
                                overridesDict[availabilityDict[PFCManifestKeyAvailabilityKey]] = availabilityDict[PFCManifestKeyAvailabilityValue];
                            }
                        }
                        continue;
                    }

                    id defaultValue;
                    if (selectionManifestContentDict[PFCManifestKeyDefaultValue] != nil) {
                        NSString *typeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:selectionManifestContentDict[PFCManifestKeyDefaultValue]];

                        if ([typeString isEqualToString:PFCValueTypeString]) {
                            defaultValue = selectionManifestContentDict[PFCManifestKeyDefaultValue];
                        } else if ([typeString isEqualToString:PFCValueTypeBoolean]) {
                            defaultValue = @([selectionManifestContentDict[PFCManifestKeyDefaultValue] boolValue]);
                        }
                    } else if ([selectionManifestContentDict[PFCManifestKeyCellType] isEqualToString:PFCCellTypeCheckbox]) {
                        defaultValue = NO;
                    }

                    if ([availabilityValueTypeString isEqualToString:PFCValueTypeString]) {
                        if ([defaultValue isEqualToString:availabilityIf[PFCManifestKeyAvailabilitySelectionValue]]) {
                            overridesDict[availabilityDict[PFCManifestKeyAvailabilityKey]] = availabilityDict[PFCManifestKeyAvailabilityValue];
                        }
                    } else if ([availabilityValueTypeString isEqualToString:PFCValueTypeBoolean]) {
                        if ([availabilityIf[PFCManifestKeyAvailabilitySelectionValue] boolValue] == (BOOL)defaultValue) {
                            overridesDict[availabilityDict[PFCManifestKeyAvailabilityKey]] = availabilityDict[PFCManifestKeyAvailabilityValue];
                        }
                    }
                }
            }
        }
    }
    return [overridesDict copy];
}

- (NSDictionary *)manifestContentDictForIdentifier:(NSString *)identifier manifestContent:(NSArray *)manifestContent {
    __block NSDictionary *selectionManifestContentDict;
    [manifestContent enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dict, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([dict[PFCManifestKeyIdentifier] isEqualToString:identifier]) {
          selectionManifestContentDict = dict;
          *stop = YES;
      } else if (dict[PFCManifestKeyValueKeys] != nil) {
          for (NSString *valueKey in dict[PFCManifestKeyAvailableValues] ?: @[ @"True", @"False" ]) {
              selectionManifestContentDict = [self manifestContentDictForIdentifier:identifier manifestContent:dict[PFCManifestKeyValueKeys][valueKey]];
              if (selectionManifestContentDict.count != 0) {
                  *stop = YES;
                  break;
              }
          }
      }
    }];
    return selectionManifestContentDict;
}

@end
