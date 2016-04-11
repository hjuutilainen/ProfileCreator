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

@end
