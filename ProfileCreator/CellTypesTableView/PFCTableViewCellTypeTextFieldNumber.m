//
//  PFCTableViewCellTypeTextFieldNumber.m
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
#import "PFCTableViewCellTypeTextFieldNumber.h"

@interface PFCTableViewTextFieldNumberCellView ()
@property (readwrite) NSString *columnIdentifier;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;
@end

@implementation PFCTableViewTextFieldNumberCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateTableViewCellView:(id)cellView
                                 settings:(NSDictionary *)settings
                               columnDict:(NSDictionary *)columnDict
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

    if (value.length == 0) {
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
}

@end
