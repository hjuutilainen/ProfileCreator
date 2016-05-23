//
//  PFCCellTypes.m
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

#import "PFCCellTypeProtocol.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"

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

- (CGFloat)rowHeightForManifestContentDict:(NSDictionary *)manifestContentDict {
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    if ([cellType isEqualToString:PFCCellTypePadding]) {
        return 20.0f;
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        return 38.0f;
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle] || [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        return 39.0f;
    } else if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            return 25.0f;
        } else {
            return 52.0f;
        }
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        return 53.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        return 54.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort] || [cellType isEqualToString:PFCCellTypeTextFieldNumber] || [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ||
               [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        return 81.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 26.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 16.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 26.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        return 83.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextLabel]) {
        CGFloat baseHeight = 46.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        return 114.0f;
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        return 192.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        return 212.0f;
    } else if ([cellType isEqualToString:PFCCellTypeRadioButton]) {
        CGFloat baseHeight = 93.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }

        NSInteger buttonCount = [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count];
        return (baseHeight + (buttonCount - 2) * 22);
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return 1;
}

@end
