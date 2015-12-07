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

@interface CellViewMenu : NSTableCellView
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSTextField *menuDescription;
@property (weak) IBOutlet NSImageView *menuIcon;
@end

@interface CellViewMenuEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *menuCheckbox;
@end