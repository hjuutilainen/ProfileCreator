//
//  PFCTableViewCellTypeTextField.m
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
#import "PFCTableViewCellTypeTextField.h"

@interface PFCTableViewTextFieldCellView ()
@property (readwrite) NSString *columnIdentifier;
@end

@implementation PFCTableViewTextFieldCellView

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
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    if ([value length] == 0) {
        if ([settings[@"DefaultValue"] length] != 0) {
            value = settings[@"DefaultValue"] ?: @"";
        }
    }
    [[cellView textField] setDelegate:sender];
    [[cellView textField] setStringValue:value];
    [[cellView textField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([columnDict[PFCManifestKeyPlaceholderValue] length] != 0) {
        [[cellView textField] setPlaceholderString:columnDict[PFCManifestKeyPlaceholderValue] ?: @""];
    } else {
        [[cellView textField] setPlaceholderString:@""];
    }

    /*
    else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    }
*/
    return cellView;
}

@end
