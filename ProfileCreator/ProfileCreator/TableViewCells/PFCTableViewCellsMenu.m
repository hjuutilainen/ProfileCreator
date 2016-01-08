//
//  PFCTableViewMenuCells.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsMenu.h"
#import "PFCProfileCreationWindowController.h"

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

- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView menuDict:(NSDictionary *)menuDict errorCount:(NSNumber *)errorCount row:(NSInteger)row {
    
    if ( errorCount != nil ) {
        NSAttributedString *errorCountString = [[NSAttributedString alloc] initWithString:[errorCount stringValue] attributes:@{ NSForegroundColorAttributeName : [NSColor redColor] }];
        [[cellView errorCount] setAttributedStringValue:errorCountString];
    } else {
        [[cellView errorCount] setStringValue:@""];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView menuTitle] setStringValue:menuDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView menuDescription] setStringValue:menuDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[NSBundle mainBundle] imageForResource:menuDict[@"IconName"]];
    if ( icon ) {
        [[cellView menuIcon] setImage:icon];
    } else {
        NSURL *iconURL = [NSURL fileURLWithPath:menuDict[@"IconPath"] ?: @""];
        if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
            NSImage *icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
            if ( icon ) {
                [[cellView menuIcon] setImage:icon];
            }
        }
        
        iconURL = [NSURL fileURLWithPath:menuDict[@"IconPathBundle"] ?: @""];
        if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
            NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[iconURL path]];
            if ( icon ) {
                [[cellView menuIcon] setImage:icon];
            }
        }
    }
    
    return cellView;
} // populateCellViewMenu:menuDict:row

+ (CGFloat)cellViewHeight {
    return 44.0;
} // cellViewHeight

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

- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView menuDict:(NSDictionary *)menuDict row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setState:[menuDict[@"Enabled"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setHidden:[menuDict[@"Required"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setAction:@selector(checkboxMenuEnabled:)];
    [[cellView menuCheckbox] setTarget:sender];
    [[cellView menuCheckbox] setTag:row];
    
    return cellView;
} // populateCellViewEnabled:menuDict:row

+ (CGFloat)cellViewHeight {
    return 44.0;
} // cellViewHeight

@end