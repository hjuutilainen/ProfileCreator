//
//  PFCCellTypes.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCellTypes.h"
#import "PFCLog.h"
#import "PFCConstants.h"

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
    if ( [cellType isEqualToString:PFCCellTypePadding] ) {
        return 20.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
        return 33.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
        return 38.0f;
    } else if (
               [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ||
               [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
        return 39.0f;
    } else if (
               [cellType isEqualToString:PFCCellTypeCheckbox] ) {
        return 52.0f;
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
        return 53.0f;
    } else if (
               [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ||
               [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ||
               [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
        return 54.0f;
    } else if (
               [cellType isEqualToString:PFCCellTypeTextField] ||
               [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ||
               [cellType isEqualToString:PFCCellTypePopUpButton] ||
               [cellType isEqualToString:PFCCellTypeTextFieldNumber] ||
               [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ||
               [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
        return 80.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeDatePicker] ) {
        return 83.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeTextView] ) {
        return 114.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
        return 192.0f;
    } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
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
                            row:(NSInteger)row
                         sender:(id)sender {
    
    id cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    if ( cellView ) {
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellView:cellView manifest:manifestContentDict settings:userSettingsDict settingsLocal:localSettingsDict row:row sender:sender];
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return nil;
}

@end

