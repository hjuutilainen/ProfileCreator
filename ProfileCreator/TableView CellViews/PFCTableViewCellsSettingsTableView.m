//
//  PFCTableViewCellsSettingsTableView.m
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

#import "PFCCellTypeTableView.h"
#import "PFCConstants.h"
#import "PFCTableViewCellsSettings.h"
#import "PFCTableViewCellsSettingsTableView.h"

@implementation PFCTableViewCellsSettingsTableView
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPopUpButton
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewPopUpButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewPopUpButton *)populateCellViewPopUpButton:(CellViewPopUpButton *)cellView
                                            settings:(NSDictionary *)settings
                                    columnIdentifier:(NSString *)columnIdentifier
                                                 row:(NSInteger)row
                                              sender:(id)sender {

    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [cellView.popUpButton removeAllItems];
    [cellView.popUpButton addItemsWithTitles:settings[@"AvailableValues"] ?: @[]];
    [cellView.popUpButton selectItemWithTitle:settings[PFCSettingsKeyValue] ?: settings[@"DefaultValue"]];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [cellView.popUpButton setAction:@selector(popUpButtonSelection:)];
    [cellView.popUpButton setTarget:sender];
    [cellView.popUpButton setTag:row];

    return cellView;
} // populateCellViewPopUp:settings:row
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewTextFieldNumber
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewTextFieldNumber

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (CellViewTextFieldNumber *)populateCellViewTextFieldNumber:(CellViewTextFieldNumber *)cellView
                                                    settings:(NSDictionary *)settings
                                            columnIdentifier:(NSString *)columnIdentifier
                                                         row:(NSInteger)row
                                                      sender:(id)sender {

    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value;
    if (settings[PFCSettingsKeyValue] != nil) {
        if ([[settings[PFCSettingsKeyValue] class] isSubclassOfClass:[NSString class]]) {
            value = settings[PFCSettingsKeyValue] ?: @"";
        } else if ([[settings[PFCSettingsKeyValue] class] isSubclassOfClass:[@(0) class]]) {
            value = [settings[PFCSettingsKeyValue] stringValue] ?: @"";
        }
    }

    if ([value length] == 0) {
        if (settings[@"DefaultValue"] != nil) {
            if ([[settings[@"DefaultValue"] class] isSubclassOfClass:[NSString class]]) {
                value = settings[@"DefaultValue"] ?: @"";
            } else if ([[settings[@"DefaultValue"] class] isSubclassOfClass:[@(0) class]]) {
                value = [settings[@"DefaultValue"] stringValue] ?: @"";
            }
        }
    }

    [[cellView textField] setDelegate:sender];
    [[cellView textField] setStringValue:value ?: @""];
    [[cellView textField] setTag:row];

    // ---------------------------------------------------------------------
    //  NumberFormatter Min/Max Value
    // ---------------------------------------------------------------------
    //[[cellView settingNumberFormatter] setMinimum:manifest[@"MinValue"] ?: @0];
    //[[cellView settingStepper] setMinValue:[manifest[@"MinValue"] doubleValue] ?: 0.0];

    //[[cellView settingNumberFormatter] setMaximum:manifest[@"MaxValue"] ?: @99999];
    //[[cellView settingStepper] setMaxValue:[manifest[@"MinValue"] doubleValue] ?: 99999.0];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([settings[@"PlaceholderValue"] length] != 0) {
        [[cellView textField] setPlaceholderString:settings[@"PlaceholderValue"] ?: @""];
    } else {
        [[cellView textField] setPlaceholderString:@""];
    }

    return cellView;
} // populateCellViewTextField:settings:row

@end
