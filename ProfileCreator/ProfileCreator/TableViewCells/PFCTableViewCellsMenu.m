//
//  PFCTableViewMenuCells.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsMenu.h"
#import "PFCProfileCreationWindowController.h"
#import "PFCConstants.h"
#import "PFCManifestTools.h"

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

- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount row:(NSInteger)row {
    
    if ( errorCount != nil ) {
        NSAttributedString *errorCountString = [[NSAttributedString alloc] initWithString:[errorCount stringValue] attributes:@{ NSForegroundColorAttributeName : [NSColor redColor] }];
        [[cellView errorCount] setAttributedStringValue:errorCountString];
    } else {
        [[cellView errorCount] setStringValue:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView menuTitle] setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView menuDescription] setStringValue:manifestDict[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [PFCManifestTools iconForManifest:manifestDict];
    if ( icon ) {
        [[cellView menuIcon] setImage:icon];
    }
    
    return cellView;
} // populateCellViewMenu:manifestDict:row

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
    [[cellView menuCheckbox] setState:[manifestDict[PFCManifestKeyEnabled] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setHidden:[manifestDict[PFCManifestKeyRequired] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setAction:@selector(checkboxMenuEnabled:)];
    [[cellView menuCheckbox] setTarget:sender];
    [[cellView menuCheckbox] setTag:row];
    
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
    [[cellView menuTitle] setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];
        
    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [PFCManifestTools iconForManifest:manifestDict];
    if ( icon ) {
        [[cellView menuIcon] setImage:icon];
    }
    
    return cellView;
} // populateCellViewMenu:manifestDict:row

@end