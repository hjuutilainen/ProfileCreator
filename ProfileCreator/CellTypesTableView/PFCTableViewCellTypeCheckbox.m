//
//  PFCTableViewCellTypeCheckbox.m
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
#import "PFCTableViewCellTypeCheckbox.h"

@interface PFCTableViewCheckboxCellView ()
@property (readwrite) NSString *columnIdentifier;
@end

@implementation PFCTableViewCheckboxCellView

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
    BOOL checkboxState = NO;
    if (settings[PFCSettingsKeyValue] != nil) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if (settings[@"DefaultValue"]) {
        checkboxState = [settings[@"DefaultValue"] boolValue];
    }
    [[cellView checkbox] setState:checkboxState];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView checkbox] setAction:@selector(checkbox:)];
    [[cellView checkbox] setTarget:sender];
    [[cellView checkbox] setTag:row];

    return cellView;
}

@end
