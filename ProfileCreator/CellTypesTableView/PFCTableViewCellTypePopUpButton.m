//
//  PFCTableViewCellTypePopUpButton.m
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
#import "PFCTableViewCellTypePopUpButton.h"

@interface PFCTableViewPopUpButtonCellView ()
@property (readwrite) NSString *columnIdentifier;
@end

@implementation PFCTableViewPopUpButtonCellView

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
    [[cellView popUpButton] removeAllItems];
    [[cellView popUpButton] addItemsWithTitles:settings[@"AvailableValues"] ?: @[]];
    [[cellView popUpButton] selectItemWithTitle:settings[PFCSettingsKeyValue] ?: settings[@"DefaultValue"]];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView popUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView popUpButton] setTarget:sender];
    [[cellView popUpButton] setTag:row];

    return cellView;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloadDict:(NSMutableDictionary **)payloadDict sender:(PFCProfileExport *)sender {
}

@end
