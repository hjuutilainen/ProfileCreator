//
//  PFCTableViewMenuCells.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTableViewMenuCells : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenu : NSTableCellView
@property (weak) IBOutlet NSTextField *errorCount;
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSTextField *menuDescription;
@property (weak) IBOutlet NSImageView *menuIcon;
- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenuEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *menuCheckbox;
- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView manifestDict:(NSDictionary *)manifestDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuLibrary
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenuLibrary : NSTableCellView
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSImageView *menuIcon;
- (CellViewMenuLibrary *)populateCellViewMenuLibrary:(CellViewMenuLibrary *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount row:(NSInteger)row;
@end