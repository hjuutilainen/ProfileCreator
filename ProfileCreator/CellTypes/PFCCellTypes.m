//
//  PFCCellTypes.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"

// CellTypes
#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypeTextView.h"

@implementation PFCCellTypes

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedInstance {
    static PFCCellTypes *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedUtility

- (CGFloat)rowHeightForCellType:(NSString *)cellType {
    if ([cellType isEqualToString:PFCCellTypePadding]) {
        return 20.0f;
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        return 33.0f;
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        return 38.0f;
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle] || [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        return 39.0f;
    } else if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        return 52.0f;
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        return 53.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle] || [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] || [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        return 54.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextField] || [cellType isEqualToString:PFCCellTypeTextFieldHostPort] || [cellType isEqualToString:PFCCellTypePopUpButton] ||
               [cellType isEqualToString:PFCCellTypeTextFieldNumber] || [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] || [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        return 80.0f;
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        return 83.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        return 114.0f;
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        return 192.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        return 212.0f;
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return 1;
}

- (NSView *)cellViewForCellType:(NSString *)cellType
                      tableView:(NSTableView *)tableView
            manifestContentDict:(NSDictionary *)manifestContentDict
               userSettingsDict:(NSDictionary *)userSettingsDict
              localSettingsDict:(NSDictionary *)localSettingsDict
                    displayKeys:(NSDictionary *)displayKeys
                            row:(NSInteger)row
                         sender:(id)sender {

    id cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    if (cellView) {
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return
            [cellView populateCellView:cellView manifest:manifestContentDict settings:userSettingsDict settingsLocal:localSettingsDict displayKeys:(NSDictionary *)displayKeys row:row sender:sender];
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return nil;
}

// ----

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

- (BOOL)returnAvailabilityValueForKey:(NSString *)key availabilityDict:(NSDictionary *)availabilityDict displayKeys:(NSDictionary *)displayKeys {
    if ([availabilityDict[@"AvailabilityKey"] isEqualToString:key]) {
        NSString *os = availabilityDict[@"AvailabilityOS"];

        // Any
        if ([os isEqualToString:@"Any"]) {
            return YES;

            // OS X
        } else if ([os isEqualToString:@"OSX"] && [displayKeys[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue]) {
            if (availabilityDict[@"AvailableFrom"] != nil || availabilityDict[@"AvailableTo"] != nil) {
                if ([PFCGeneralUtility version:availabilityDict[@"AvailableFrom"] ?: @"0" isLowerThanVersion:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion]] &&
                    [PFCGeneralUtility version:displayKeys[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] isLowerThanVersion:availabilityDict[@"AvailableTo"] ?: @"999"]) {
                    return YES;
                }
            } else {
                return YES;
            }
            // iOS
        } else if ([os isEqualToString:@"iOS"] && [displayKeys[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue]) {
            if (availabilityDict[@"AvailableFrom"] != nil || availabilityDict[@"AvailableTo"] != nil) {
                if ([PFCGeneralUtility version:availabilityDict[@"AvailableFrom"] ?: @"0" isLowerThanVersion:displayKeys[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion]] &&
                    [PFCGeneralUtility version:displayKeys[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] isLowerThanVersion:availabilityDict[@"AvailableTo"] ?: @"999"]) {
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
