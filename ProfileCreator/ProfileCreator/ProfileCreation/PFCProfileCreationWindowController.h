//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCProfileCreationWindowController : NSWindowController

// TableView Menu

@property (weak) IBOutlet NSTableView *tableViewMenu;


@property NSMutableArray *tableViewMenuItemsEnabled;
@property NSMutableArray *tableViewMenuItemsDisabled;

// TableView Settings

@property (weak) IBOutlet NSTableView *tableViewSettings;

@property NSMutableArray *tableViewSettingsItemsEnabled;
@property NSMutableArray *tableViewSettingsItemsDisabled;

@end
