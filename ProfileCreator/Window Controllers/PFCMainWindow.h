//
//  PFCMainWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "PFCViews.h"
#import "PFCProfileGroupTitle.h"
#import "PFCAlert.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCMainWindow
////////////////////////////////////////////////////////////////////////////////
@interface PFCMainWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate, PFCProfileGroupDelegate, PFCAlertDelegate>

// -----------------------------------------------------------------------------
//  Unsorted
// -----------------------------------------------------------------------------
@property                    NSMutableDictionary        *selectedGroup;
@property                    NSString                   *selectedProfileUUID;
@property                    NSString                   *selectedTableViewIdentifier;

// -----------------------------------------------------------------------------
//  Window
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSSplitView                *splitVewMain;

// -----------------------------------------------------------------------------
//  SplitView Menu - Profile Groups
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSView                     *viewProfileGroupsSplitView;
@property (weak)    IBOutlet NSScrollView               *scrollViewProfileGroups;
@property (weak)    IBOutlet PFCViewMainGroups          *viewProfileGroupsSuperview;

// -----------------------------------------------------------------------------
//  SplitView Menu - "All Profiles"
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSTableView                *tableViewProfileGroupAll;
@property                    NSInteger                  tableViewProfileGroupAllSelectedRow;
@property                    NSMutableArray             *arrayProfileGroupAll;

- (IBAction) selectTableViewProfileGroupAll:(id)sender;

// -----------------------------------------------------------------------------
//  SplitView Menu - "Groups"
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSView                     *viewAddGroupsSuperview;
@property (weak)    IBOutlet NSTableView                *tableViewProfileGroups;
@property                    PFCProfileGroupTitleView   *viewAddGroupsTitle;
@property                    NSInteger                  tableViewProfileGroupsSelectedRow;
@property                    NSMutableArray             *arrayProfileGroups;

- (IBAction) selectTableViewProfileGroups:(id)sender;

// -----------------------------------------------------------------------------
//  SplitView Menu - "Smart Groups"
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSView                     *viewAddSmartGroupsSuperview;
@property (weak)    IBOutlet NSTableView                *tableViewProfileSmartGroups;
@property                    PFCProfileGroupTitleView   *viewAddSmartGroupsTitle;
@property                    NSInteger                  tableViewProfileSmartGroupsSelectedRow;
@property                    NSMutableArray             *arrayProfileSmartGroups;

- (IBAction) selectTableViewProfileSmartGroups:(id)sender;

// -----------------------------------------------------------------------------
//  SplitView Library
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSView                     *viewProfileLibrarySplitView;
@property (weak)    IBOutlet NSView                     *viewProfileLibraryFooterSplitView;
@property (weak)    IBOutlet NSView                     *viewProfileLibraryTableViewSuperview;
@property (weak)    IBOutlet NSTableView                *tableViewProfileLibrary;
@property                    NSIndexSet                 *tableViewProfileLibrarySelectedRows;
@property                    NSMutableArray             *arrayProfileLibrary;

- (IBAction) selectTableViewProfileLibrary:(id)sender;

// -----------------------------------------------------------------------------
//  SplitView Preview
// -----------------------------------------------------------------------------
@property (weak)    IBOutlet NSView                     *viewPreviewSplitView;
@property (weak)    IBOutlet NSView                     *viewPreviewSuperview;
@property (weak)    IBOutlet NSView                     *viewPreviewSelectionUnavailable;
@property (weak)    IBOutlet NSPopUpButton              *popUpButtonProfileLibraryFooter;
@property (weak)    IBOutlet NSSegmentedControl         *segmentedControlProfileLibraryFooterAddRemove;
@property (weak)    IBOutlet NSButton                   *buttonProfileEdit;
@property (weak)    IBOutlet NSButton                   *buttonProfileExport;
@property (weak)    IBOutlet NSTextField                *textFieldPreviewProfileName;
@property (weak)    IBOutlet NSTextField                *textFieldPreviewSelectionUnavailable;
@property                    BOOL                       profilePreviewHidden;
@property                    BOOL                       profilePreviewSelectionUnavailableHidden;

- (IBAction) buttonProfileEdit:(id)sender;
- (IBAction) buttonProfileExport:(id)sender;
- (IBAction) segmentedControlProfileLibraryFooterAddRemove:(id)sender;

// -----------------------------------------------------------------------------
//  Instance Methods
// -----------------------------------------------------------------------------
- (void)closeProfileEditorForProfileWithUUID:(NSString *)profileUUID;
- (void)renameProfileWithUUID:(NSString *)profileUUID newName:(NSString *)newName;

@end
