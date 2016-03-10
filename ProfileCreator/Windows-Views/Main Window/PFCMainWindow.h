//
//  PFCMainWindow.h
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

#import "PFCAlert.h"
#import "PFCMainWindowGroupTitle.h"
#import "PFCTableViews.h"
#import "PFCViews.h"
#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCMainWindow
////////////////////////////////////////////////////////////////////////////////
@interface PFCMainWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate, PFCAlertDelegate, PFCTableViewDelegate>

// -----------------------------------------------------------------------------
//  Unsorted
// -----------------------------------------------------------------------------
@property NSDictionary *selectedGroup;
@property PFCProfileGroups selectedGroupType;
@property NSMutableDictionary *profileRuntimeKeys;
@property NSString *selectedProfileUUID;
@property NSString *selectedTableViewIdentifier;

// -----------------------------------------------------------------------------
//  Window
// -----------------------------------------------------------------------------
@property (weak) IBOutlet NSSplitView *splitVewMain;

// -----------------------------------------------------------------------------
//  SplitView Menu - Profile Groups
// -----------------------------------------------------------------------------
@property (weak) IBOutlet NSVisualEffectView *viewProfileGroupsSplitView;

// -----------------------------------------------------------------------------
//  SplitView Library
// -----------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewProfileLibrarySplitView;
@property (weak) IBOutlet NSView *viewProfileLibraryTableViewSuperview;
@property (weak) IBOutlet NSTableView *tableViewProfileLibrary;
@property (weak) IBOutlet NSMenu *menuTableViewProfileLibrary;
@property NSIndexSet *tableViewProfileLibrarySelectedRows;
@property NSMutableArray *arrayProfileLibrary;

- (IBAction)selectTableViewProfileLibrary:(id)sender;

// -------------------------------------------------------------------------
//  Payload Context Menu
// -------------------------------------------------------------------------
@property (readwrite) NSString *clickedTableViewIdentifier;
@property (readwrite) NSInteger clickedTableViewRow;

// -----------------------------------------------------------------------------
//  SplitView Preview
// -----------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewPreviewSplitView;

- (void)menuItemNewProfile;
- (void)menuItemNewGroup;

// -----------------------------------------------------------------------------
//  Instance Methods
// -----------------------------------------------------------------------------
- (void)exportProfileWithUUID:(NSString *)uuid;
- (void)openProfileEditorForProfileWithUUID:(NSString *)uuid;
- (void)closeProfileEditorForProfileWithUUID:(NSString *)uuid;
- (void)updateProfileWithUUID:(NSString *)uuid;

- (void)selectGroup:(NSDictionary *)groupDict groupType:(PFCProfileGroups)group profileArray:(NSArray *)profileArray;
- (void)updateGroupSelection:(PFCProfileGroups)group;

@end
