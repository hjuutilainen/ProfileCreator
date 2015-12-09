//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCProfileCreationWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property BOOL advancedSettings;

// TableView Menu

@property (weak) IBOutlet NSTableView *tableViewMenu;
- (IBAction)tableViewMenu:(id)sender;
@property NSMutableArray *tableViewMenuItemsEnabled;
@property NSMutableArray *tableViewMenuItemsDisabled;
@property BOOL columnMenuEnabledHidden;

// TableView Settings

@property (weak) IBOutlet NSTableView *tableViewSettings;
@property NSMutableArray *tableViewSettingsItemsEnabled;
@property NSMutableArray *tableViewSettingsItemsDisabled;
@property BOOL columnSettingsEnabledHidden;

@property (weak) IBOutlet NSView *viewSettingsSuperView;
@property (strong) IBOutlet NSView *viewErrorReadingSettings;

@end
