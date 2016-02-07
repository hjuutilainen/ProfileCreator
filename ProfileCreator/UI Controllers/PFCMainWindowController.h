//
//  PFCMainWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-02.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFCViews.h"
#import "PFCProfileGroupTitle.h"

@interface PFCMainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate, PFCProfileGroupDelegate>

// -------------------------------------------------------------------------
//  Unsorted
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
//  Window
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSSplitView *splitVewMain;

// -------------------------------------------------------------------------
//  SplitView Menu
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewPreviewSuperview;


// -------------------------------------------------------------------------
//  SplitView Menu - Profile Groups
// -------------------------------------------------------------------------
@property NSMutableDictionary *selectedGroup;
@property (weak) IBOutlet NSView *viewProfileGroupsSplitView;
@property (weak) IBOutlet PFCViewMainGroups *viewProfileGroupsSuperview;
@property (weak) IBOutlet NSView *viewAddGroupsSuperview;
@property PFCProfileGroupTitleView *viewAddGroupsTitle;
@property NSInteger tableViewProfileGroupsSelectedRow;

@property NSInteger tableViewProfileGroupAllSelectedRow;
@property (weak) IBOutlet NSTableView *tableViewProfileGroupAll;
@property NSMutableArray *arrayProfileGroupAll;
- (IBAction)selectTableViewProfileGroupAll:(id)sender;

@property (weak) IBOutlet NSTableView *tableViewProfileGroups;

@property NSMutableArray *arrayProfileGroups;
- (IBAction)selectTableViewProfileGroups:(id)sender;
@property NSString *selectedTableViewIdentifier;

// Profile Library
@property (weak) IBOutlet NSView *viewProfileLibrarySplitView;
@property (weak) IBOutlet NSView *viewProfileLibraryFooterSplitView;
@property (weak) IBOutlet NSView *viewProfileLibraryTableViewSuperview;
@property (weak) IBOutlet NSTableView *tableViewProfileLibrary;
@property NSMutableArray *arrayProfileLibrary;
- (IBAction)selectTableViewProfileLibrary:(id)sender;

@property BOOL profilePreviewHidden;
@property (weak) IBOutlet NSPopUpButton *popUpButtonProfileLibraryFooter;
@property (weak) IBOutlet NSSegmentedControl *segmentedControlProfileLibraryFooterAddRemove;
- (IBAction)segmentedControlProfileLibraryFooterAddRemove:(id)sender;

@property (weak) IBOutlet NSView *viewPreviewSplitView;
@property (weak) IBOutlet NSView *viewPreviewNoProfiles;

@property NSMutableArray *arrayProfileDicts;








@end
