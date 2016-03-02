//
//  PFCTableViewCellsProfiles.m
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
#import "PFCTableViewCellsProfiles.h"

@implementation PFCTableViewCellsProfiles
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewProfile

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewProfile *)populateCellViewProfile:(CellViewProfile *)cellView profileDict:(NSDictionary *)profileDict row:(NSInteger)row {

    NSDictionary *profileSettingsDict = profileDict[@"Config"];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:profileSettingsDict[PFCProfileTemplateKeyName] ?: @""];

    return cellView;
} // populateCellViewMenu:menuDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewGroupName
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewGroupName

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewGroupName *)populateCellView:(CellViewGroupName *)cellView group:(PFCProfileGroups)group profileDict:(NSDictionary *)profileDict row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:profileDict[@"Config"][PFCProfileGroupKeyName] ?: @""];

    return cellView;
} // populateCellViewMenu:menuDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewGroupIcon
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewGroupIcon

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewGroupIcon *)populateCellView:(CellViewGroupIcon *)cellView group:(PFCProfileGroups)group profileDict:(NSDictionary *)profileDict row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [PFCMainWindowGroupTitle iconForGroup:group];
    //if ( icon ) {
        [[cellView imageView] setImage:icon];
    //}
    
    return cellView;
} // populateCellViewMenu:menuDict:row

@end