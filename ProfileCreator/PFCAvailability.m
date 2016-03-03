//
//  PFCAvailability.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-03.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCAvailability.h"
#import "PFCLog.h"
#import "PFCGeneralUtility.h"
#import "PFCConstants.h"

@implementation PFCAvailability

+ (id)sharedInstance {
    static PFCAvailability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedUtility

- (BOOL)showManifest:(NSDictionary *)manifest displayKeys:(NSDictionary *)displayKeys {
    BOOL showManifest = YES;
    for (NSDictionary *availabilityDict in manifest[PFCManifestKeyAvailability] ?: @[]) {
        
        // -------------------------------------------------------------------------------
        //  If any dict contains 'AvailabilityKey = Self', set showManifest to NO
        //  If the current display settings are within the availability dict settings,
        //  return with YES as at all possible manifests should be show, even if only one
        //  of the selected versions can use it.
        //  The compatibility warnings will be mor clear when exporting.
        // -------------------------------------------------------------------------------
        if ( [availabilityDict[@"AvailabilityKey"] isEqualToString:@"Self"] ) {
            showManifest = NO;
            if ([self currentSelectionWithinVersionForOS:availabilityDict[@"AvailabilityOS"] availabilityDict:availabilityDict displayKeys:displayKeys] ) {
                return YES;
            }
        }
    }
    return showManifest;
}

- (BOOL)requiredForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys {
    for (NSDictionary *availabilityDict in manifestContentDict[PFCManifestKeyAvailability] ?: @[]) {
        if ([self returnAvailabilityValueForKey:PFCManifestKeyRequired availabilityDict:availabilityDict displayKeys:displayKeys]) {
            return [availabilityDict[@"AvailabilityValue"] boolValue];
        }
    }
    return [manifestContentDict[PFCManifestKeyRequired] boolValue];
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
    if ( [os isEqualToString:@"OSX"] ) {
        return ([PFCGeneralUtility version:availabilityDict[@"AvailableFrom"] ?: @"0" isLowerThanVersion:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion]] &&
                [PFCGeneralUtility version:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] isLowerThanVersion:availabilityDict[@"AvailableTo"] ?: @"999"]);
    } else if ( [os isEqualToString:@"iOS"] ) {
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

@end
