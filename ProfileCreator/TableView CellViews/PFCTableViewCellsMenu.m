//
//  PFCTableViewCellsMenu.m
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
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCTableViewCellsMenu.h"

@implementation PFCTableViewMenuCells
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewMenu

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount payloadCount:(NSNumber *)payloadCount row:(NSInteger)row {

    // -------------------------------------------------------------------------
    //  Error Counter
    // -------------------------------------------------------------------------
    if (errorCount != nil && 0 < errorCount.integerValue) {
        NSAttributedString *errorCountString = [[NSAttributedString alloc] initWithString:errorCount.stringValue attributes:@{NSForegroundColorAttributeName : NSColor.redColor}];
        [cellView.errorCount setAttributedStringValue:errorCountString];
    } else {
        [cellView.errorCount setStringValue:@""];
    }

    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [cellView.menuTitle setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];

    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    if ([manifestDict[PFCManifestKeyDomain] isEqualToString:@"com.apple.general"]) {
        [cellView.menuDescription setStringValue:@"Mandatory"];
    } else {
        [cellView.menuDescription setStringValue:[NSString stringWithFormat:@"%@ %@ Configured", payloadCount.stringValue, (payloadCount.intValue == 1) ? @"Payload" : @"Payloads"]];
    }

    // -------------------------------------------------------------------------
    //  Icon
    // -------------------------------------------------------------------------
    NSImage *icon = [[PFCManifestUtility sharedUtility] iconForManifest:manifestDict];
    if (icon) {
        [cellView.menuIcon setImage:icon];
    }

    return cellView;
} // populateCellViewMenu:manifestDict:errorCount:payloadCount:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewMenuEnabled

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView manifestDict:(NSDictionary *)manifestDict row:(NSInteger)row sender:(id)sender {

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [cellView.menuCheckbox setState:[manifestDict[PFCSettingsKeyEnabled] boolValue]];

    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [cellView.menuCheckbox setHidden:[manifestDict[PFCManifestKeyRequired] boolValue]];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [cellView.menuCheckbox setAction:@selector(checkboxMenuEnabled:)];
    [cellView.menuCheckbox setTarget:sender];
    [cellView.menuCheckbox setTag:row];

    return cellView;
} // populateCellViewEnabled:manifestDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuLibrary
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewMenuLibrary

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewMenuLibrary *)populateCellViewMenuLibrary:(CellViewMenuLibrary *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [cellView.menuTitle setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];

    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[PFCManifestUtility sharedUtility] iconForManifest:manifestDict];
    if (icon) {
        [cellView.menuIcon setImage:icon];
    }

    return cellView;
} // populateCellViewMenuLibrary:manifestDict:row

@end
