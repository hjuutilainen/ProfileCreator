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
- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView menuDict:(NSDictionary *)menuDict errorCount:(NSNumber *)errorCount row:(NSInteger)row;
+ (CGFloat)cellViewHeight;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenuEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *menuCheckbox;
- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView menuDict:(NSDictionary *)menuDict row:(NSInteger)row sender:(id)sender;
+ (CGFloat)cellViewHeight;
@end