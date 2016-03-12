//
//  PFCMainWindow.m
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

#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCMainWindow.h"
#import "PFCMainWindowGroup.h"
#import "PFCMainWindowGroupTitle.h"
#import "PFCMainWindowPreview.h"
#import "PFCMainWindowSort.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"
#import "PFCProfileUtility.h"
#import "PFCTableViewCellsProfiles.h"
#import "PFCTableViews.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCTableViewIdentifierProfileLibrary = @"TableViewIdentifierProfileLibrary";
NSString *const PFCTableViewIdentifierProfileGroupAll = @"TableViewIdentifierProfileGroupAll";
NSString *const PFCTableViewIdentifierProfileGroups = @"TableViewIdentifierProfileGroups";
NSString *const PFCTableViewIdentifierProfileSmartGroups = @"TableViewIdentifierProfileSmartGroups";

@interface PFCMainWindow ()

@property PFCMainWindowPreview *preview;
@property PFCMainWindowSort *sort;

// Groups
@property NSMutableArray *arrayGroups;
@property PFCMainWindowGroup *groupAll;
@property PFCMainWindowGroup *groupGroups;
@property PFCMainWindowGroup *groupSmartGroups;

@property (weak) IBOutlet NSView *viewLibrarySortSplitView;

- (IBAction)toolbarItemAdd:(id)sender;

@property (weak) IBOutlet NSSearchField *searchField;
- (IBAction)searchField:(id)sender;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////
@implementation PFCMainWindow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    self = [super initWithWindowNibName:@"PFCMainWindow"];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Initialize Arrays
        // ---------------------------------------------------------------------
        _arrayProfileLibrary = [[NSMutableArray alloc] init];
        _arrayGroups = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Initialize Dictionaries
        // ---------------------------------------------------------------------
        _profileRuntimeKeys = [[NSMutableDictionary alloc] init];

        // ---------------------------------------------------------------------
        //  Initialize Classes
        // ---------------------------------------------------------------------
        _groupAll = [[PFCMainWindowGroup alloc] initWithGroup:kPFCProfileGroupAll mainWindow:self];
        _groupGroups = [[PFCMainWindowGroup alloc] initWithGroup:kPFCProfileGroups mainWindow:self];
        _groupSmartGroups = [[PFCMainWindowGroup alloc] initWithGroup:kPFCProfileSmartGroups mainWindow:self];

        _preview = [[PFCMainWindowPreview alloc] initWithMainWindow:self];
        _sort = [[PFCMainWindowSort alloc] init];
    }
    return self;
} // init

- (void)dealloc {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
} // dealloc

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindowController Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [super windowDidLoad];

    // -------------------------------------------------------------------------
    //  Set window background color to white and hide window title
    // -------------------------------------------------------------------------
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    [[self window] setTitleVisibility:NSWindowTitleHidden];

    // -------------------------------------------------------------------------
    //  Add content views to window
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:_viewProfileLibraryTableViewSuperview inSuperview:_viewProfileLibrarySplitView hidden:NO];
    [PFCGeneralUtility insertSubview:[_preview viewPreviewSuperview] inSuperview:_viewPreviewSplitView hidden:YES];
    [PFCGeneralUtility insertSubview:[_sort view] inSuperview:_viewLibrarySortSplitView hidden:NO];

    // -------------------------------------------------------------------------
    //  Add error views to content views
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:[[_preview viewStatus] view] inSuperview:_viewPreviewSplitView hidden:NO];

    // -------------------------------------------------------------------------
    //  Perform Initial Setup
    // -------------------------------------------------------------------------
    [self initialSetup];
} // windowDidLoad

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCMainWindowController Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)initialSetup {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Initialize PFCProfileUtility and update profile cache
    // -------------------------------------------------------------------------
    [[PFCProfileUtility sharedUtility] updateProfileCache];

    // -------------------------------------------------------------------------
    //  Setup Groups
    // -------------------------------------------------------------------------
    // FIXME - This should be read from settings, if they are shown or hidden
    [_arrayGroups addObjectsFromArray:@[ _groupGroups, _groupSmartGroups ]];
    [self updateGroups];

    // -------------------------------------------------------------------------
    //  Setup TableView "Profile Library"
    // -------------------------------------------------------------------------
    [self setupProfileLibrary];

    // -------------------------------------------------------------------------
    //  Select "All Profiles" in table view
    // -------------------------------------------------------------------------
    [[_groupAll tableViewGroup] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [_groupAll selectGroup:self];

    // -------------------------------------------------------------------------
    //  Set first responder
    // -------------------------------------------------------------------------
    [self setFirstResponder];
} // initialSetup

- (void)setFirstResponder {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [[self window] setInitialFirstResponder:[_groupAll tableViewGroup]];
} // setFirstResponder

- (void)setupProfileLibrary {
    [self setTableViewProfileLibrarySelectedRows:[NSIndexSet indexSet]];

    [_tableViewProfileLibrary setTarget:self];
    [_tableViewProfileLibrary setDoubleAction:@selector(editSelectedProfile:)];
    [_tableViewProfileLibrary setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];

    NSMenu *menu = [[NSMenu alloc] init];
    [menu setAutoenablesItems:NO];

    // -------------------------------------------------------------------------
    //  Add item: "New Profile"
    // -------------------------------------------------------------------------
    NSMenuItem *menuItemNewProfile = [[NSMenuItem alloc] init];
    [menuItemNewProfile setTitle:@"New Profile"];
    [menuItemNewProfile setKeyEquivalent:@"n"];
    [menuItemNewProfile setKeyEquivalentModifierMask:NSCommandKeyMask];
    [menuItemNewProfile setEnabled:YES];
    [menuItemNewProfile setTarget:self];
    [menuItemNewProfile setAction:@selector(menuItemNewProfile)];
    [menu addItem:menuItemNewProfile];

    // -------------------------------------------------------------------------
    //  Add item separator
    // -------------------------------------------------------------------------
    [menu addItem:[NSMenuItem separatorItem]];

    // -------------------------------------------------------------------------
    //  Add item: "Show In Finder"
    // -------------------------------------------------------------------------
    NSMenuItem *menuItemShowInFinder = [[NSMenuItem alloc] init];
    [menuItemShowInFinder setTitle:@"Show In Finder"];
    [menuItemShowInFinder setTarget:self];
    [menuItemShowInFinder setAction:@selector(menuItemShowInFinder:)];
    [menu addItem:menuItemShowInFinder];

    [_tableViewProfileLibrary setMenu:menu];
    [_tableViewProfileLibrary reloadData];
} // setupProfileLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if (splitView == _splitVewMain) {
        if (view == [[_splitVewMain subviews] lastObject]) {
            return YES;
        }
        return NO;
    }
    return YES;
} // splitView:shouldAdjustSizeOfSubview

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == _splitVewMain) {
        if (dividerIndex == 0) {
            return proposedMaximumPosition - 190;
        } else if (dividerIndex == 1) {
            return proposedMaximumPosition - 260;
        } else if (dividerIndex == 2) {
        }
    }
    return proposedMaximumPosition;
} // splitView:constrainMaxCoordinate:ofSubviewAt

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == _splitVewMain) {
        if (dividerIndex == 0) {
            return proposedMinimumPosition + 149;
        } else if (dividerIndex == 1) {
            return proposedMinimumPosition + 190;
        } else if (dividerIndex == 2) {
            return proposedMinimumPosition + 260;
        }
    }
    return proposedMinimumPosition;
} // splitView:constrainMinCoordinate:ofSubviewAt

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if (splitView == _splitVewMain && subview == [[_splitVewMain subviews] firstObject]) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    if (splitView == _splitVewMain && dividerIndex == 0) {
        return [_splitVewMain isSubviewCollapsed:[_splitVewMain subviews][0]];
    }
    return NO;
} // splitView:shouldHideDividerAtIndex

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary]) {
        return (NSInteger)[_arrayProfileLibrary count];
    }
    return 0;
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {

    // ------------------------------------------------------------------------------------------------
    //  Stop user from empty selections
    //  Empty selection is still needed as there are multiple table views and they need to feel as one
    // ------------------------------------------------------------------------------------------------
    if ([[tableView identifier] isEqualToString:_selectedTableViewIdentifier] && [proposedSelectionIndexes count] == 0) {
        return [NSIndexSet indexSetWithIndex:(NSUInteger)[tableView selectedRow]];
    }
    return proposedSelectionIndexes;
} // tableView:selectionIndexesForProposedSelection

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *tableViewIdentifier = [tableView identifier];
    if ([tableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileLibrary]) {

        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ([_arrayProfileLibrary count] == 0 || [_arrayProfileLibrary count] < row) {
            return nil;
        }

        CellViewProfile *cellView = [tableView makeViewWithIdentifier:@"CellViewProfile" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfile:cellView profileDict:[[PFCProfileUtility sharedUtility] profileWithUUID:_arrayProfileLibrary[(NSUInteger)row]] row:row];
    }
    return nil;
} // tableView:viewForTableColumn:row

- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
    NSData *draggingData = [[draggingInfo draggingPasteboard] dataForType:PFCProfileDraggingType];
    NSArray *profileUUIDs = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    draggingInfo.numberOfValidItemsForDrop = (NSInteger)[profileUUIDs count];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(nonnull NSIndexSet *)rowIndexes toPasteboard:(nonnull NSPasteboard *)pboard {
    if ([[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary]) {
        NSMutableArray *selectedProfileUUIDs = [[NSMutableArray alloc] init];
        NSArray *selectedProfiles = [_arrayProfileLibrary objectsAtIndexes:rowIndexes];
        for (NSString *profileUUID in selectedProfiles) {
            [selectedProfileUUIDs addObject:profileUUID];
        }

        [pboard clearContents];
        [pboard declareTypes:@[ PFCProfileDraggingType ] owner:nil];
        [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[selectedProfileUUIDs copy]] forType:PFCProfileDraggingType];
        return YES;
    }
    return NO;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTableViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)validateMenu:(NSMenu *)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Validate menu for row: %ld in table view with identifier: %@", (long)row, tableViewIdentifier);

    // ---------------------------------------------------------------------
    //  Store which TableView and row the user right clicked on.
    // ---------------------------------------------------------------------
    [self setClickedTableViewIdentifier:tableViewIdentifier];
    [self setClickedTableViewRow:row];

    [menu setAutoenablesItems:NO];
    NSMenuItem *menuItemShowInFinder = [menu itemWithTitle:@"Show In Finder"];

    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if (row < 0 || [_arrayProfileLibrary count] < row) {

        DDLogDebug(@"Disable: \"Show In Finder\"");
        [menuItemShowInFinder setEnabled:NO];
        menu = nil;
        return;
    }

    NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:_arrayProfileLibrary[(NSUInteger)row] ?: @""];

    // -------------------------------------------------------------------------------
    //  MenuItem - "Show In Finder"
    //  Remove this menu item unless runtime key 'Path' is set in the manifest
    // -------------------------------------------------------------------------------
    [menuItemShowInFinder setEnabled:([profileDict[PFCRuntimeKeyPath] length] != 0)];
} // validateMenu:forTableViewWithIdentifier:row

- (BOOL)deleteKeyPressedForTableView:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Check if any rows are selected, else return here
    // -------------------------------------------------------------------------
    NSIndexSet *selectedRows = [sender selectedRowIndexes];
    DDLogDebug(@"Selected rows: %@", selectedRows);

    if ([selectedRows count] == 0) {
        return NO;
    }

    DDLogDebug(@"Table view identifier: %@", [sender identifier]);
    if ([[sender identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary]) {
        [self removeProfilesAtIndexes:selectedRows];
    } else {
        return NO;
    }
    return YES;
} // deleteKeyPressedForTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)insertProfileInTableView:(id)profile {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    NSIndexSet *indexSet = [_tableViewProfileLibrary selectedRowIndexes];
    NSInteger index = [indexSet lastIndex];
    if (index == NSNotFound) {
        index = -1;
    }
    index++;
    [_tableViewProfileLibrary beginUpdates];
    [_tableViewProfileLibrary insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationEffectNone];
    [_tableViewProfileLibrary scrollRowToVisible:index];
    [_arrayProfileLibrary insertObject:profile atIndex:(NSUInteger)index];
    [_tableViewProfileLibrary endUpdates];
    return index;
} // insertProfileInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCAlert Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)alertReturnCode:(NSInteger)returnCode alertInfo:(NSDictionary *)alertInfo {
    NSString *alertTag = alertInfo[PFCAlertTagKey];
    if ([alertTag isEqualToString:PFCAlertTagDeleteProfiles]) {
        if (returnCode == NSAlertSecondButtonReturn) { // Delete
            [self deleteProfilesWithUUIDs:alertInfo[PFCProfileTemplateKeyUUID] ?: @[]];
        }
    } else if ([alertTag isEqualToString:PFCAlertTagDeleteProfilesInGroup]) {
        if (returnCode == NSAlertSecondButtonReturn) { // Delete
            if (alertInfo[@"Group"] != nil) {
                [self removeProfilesWithUUIDs:alertInfo[PFCProfileTemplateKeyUUID] ?: @[] fromGroupWithUUID:alertInfo[@"GroupUUID"] ?: @"" inGroup:[alertInfo[@"Group"] integerValue]];
            } else {
                DDLogError(@"");
            }
        }
    }
} // alertReturnCode:alertInfo

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Profile Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)removeProfilesAtIndexes:(NSIndexSet *)selectedRows {

    NSArray *selectedProfiles = [_arrayProfileLibrary objectsAtIndexes:selectedRows];

    NSMutableArray *profileNames = [[NSMutableArray alloc] init];
    NSMutableArray *profileUUIDs = [[NSMutableArray alloc] init];
    PFCAlert *alert = [[PFCAlert alloc] initWithDelegate:self];

    if ([_selectedGroup[@"Config"][PFCProfileGroupKeyName] isEqualToString:@"All Profiles"]) {

        for (NSString *profileUUID in selectedProfiles) {
            NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:profileUUID];
            [profileNames addObject:profileDict[@"Config"][PFCProfileTemplateKeyName] ?: @""];
            [profileUUIDs addObject:profileDict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""];
        }

        [alert showAlertDeleteProfiles:profileNames alertInfo:@{PFCAlertTagKey : PFCAlertTagDeleteProfiles, PFCProfileTemplateKeyUUID : [profileUUIDs copy]}];
    } else {
        for (NSString *profileUUID in selectedProfiles) {
            NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:profileUUID];
            [profileNames addObject:profileDict[@"Config"][PFCProfileTemplateKeyName] ?: @""];
            [profileUUIDs addObject:profileDict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""];
        }

        NSString *groupName = _selectedGroup[@"Config"][PFCProfileGroupKeyName] ?: @"";
        NSString *groupUUID = _selectedGroup[@"Config"][PFCProfileGroupKeyUUID] ?: @"";
        PFCProfileGroups group = kPFCProfileGroups;

        [alert showAlertDeleteProfiles:profileNames
                             fromGroup:groupName
                             alertInfo:@{
                                 PFCAlertTagKey : PFCAlertTagDeleteProfilesInGroup,
                                 PFCProfileTemplateKeyUUID : [profileUUIDs copy],
                                 @"GroupUUID" : groupUUID,
                                 @"Group" : @(group)
                             }];
    }
} // removeProfilesAtIndexes

- (void)deleteProfilesWithUUIDs:(NSArray *)profileUUIDs {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([profileUUIDs count] == 0) {
        DDLogError(@"No UUID was passed!");
        return;
    }
    DDLogDebug(@"Profile UUIDs: %@", profileUUIDs);

    __block NSError *error = nil;
    [profileUUIDs enumerateObjectsUsingBlock:^(NSString *_Nonnull uuid, NSUInteger idx, BOOL *_Nonnull stop) {
      DDLogInfo(@"Deleting profile with UUID: %@", uuid);
      if (![[PFCProfileUtility sharedUtility] deleteProfileWithUUID:uuid error:&error]) {
          DDLogError(@"%@", [error localizedDescription]);
      }

      [_arrayProfileLibrary removeObject:uuid];
    }];

    [_groupGroups deleteProfilesWithUUIDs:profileUUIDs];

    DDLogDebug(@"Selected profile UUID: %@", _selectedProfileUUID);
    if ([profileUUIDs containsObject:_selectedProfileUUID ?: @""]) {
        [_tableViewProfileLibrary deselectAll:self];
        [_preview showProfilePreviewNoSelection];
    }

    [[PFCProfileUtility sharedUtility] updateProfileCache];

    [_tableViewProfileLibrary beginUpdates];
    [_tableViewProfileLibrary reloadData];
    [_tableViewProfileLibrary endUpdates];

    [self setTableViewProfileLibrarySelectedRows:[_tableViewProfileLibrary selectedRowIndexes]];
} // deleteProfilesWithUUIDs

- (void)removeProfilesWithUUIDs:(NSArray *)profileUUIDs fromGroupWithUUID:(NSString *)groupUUID inGroup:(PFCProfileGroups)group {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([profileUUIDs count] == 0 || [groupUUID length] == 0) {
        DDLogError(@"No UUID was passed!");
        return;
    }

    if ([profileUUIDs containsObject:_selectedProfileUUID]) {
        [self setSelectedProfileUUID:nil];
    }
    DDLogDebug(@"Profile UUIDs: %@", profileUUIDs);
    DDLogDebug(@"Group UUID: %@", groupUUID);

    switch (group) {
    case kPFCProfileGroups: {
        [_groupGroups removeProfilesWithUUIDs:profileUUIDs fromGroupWithUUID:groupUUID];
    } break;
    case kPFCProfileSmartGroups: {
        // Smart Groups are searches, they can't remove profiles like this so this should probably be removed.
    } break;
    default:
        break;
    }
} // removeProfilesWithUUIDs

- (void)editSelectedProfile:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Verify table view is profile library
    // -------------------------------------------------------------------------
    if ([[sender identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary]) {

        // ---------------------------------------------------------------------
        //  Get currently selected row
        // ---------------------------------------------------------------------
        NSInteger clickedRow = [sender clickedRow];
        DDLogDebug(@"Profile library selected row: %ld", (long)clickedRow);

        if (0 <= clickedRow) {
            [self openProfileEditorForProfileWithUUID:_arrayProfileLibrary[clickedRow] ?: @""];
        }
    }
} // editSelectedProfile

- (void)openProfileEditorForProfileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    DDLogInfo(@"Open profile editor for profile with UUID: %@", uuid);
    if ([uuid length] == 0) {
        DDLogError(@"No profile uuid was passed for open");
        return;
    }

    PFCProfileEditor *editor;
    NSMutableDictionary *profileRuntimeKeys = _profileRuntimeKeys[uuid] ?: [[NSMutableDictionary alloc] init];
    DDLogDebug(@"Current profile runtime keys: %@", profileRuntimeKeys);

    if (profileRuntimeKeys[PFCRuntimeKeyProfileEditor] != nil) {
        editor = profileRuntimeKeys[PFCRuntimeKeyProfileEditor];
    } else {
        NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];
        if ([profileDict count] != 0) {
            editor = [[PFCProfileEditor alloc] initWithProfileDict:profileDict mainWindow:self];
            if (editor) {
                DDLogDebug(@"Adding profile editor to profile runtime keys");
                profileRuntimeKeys[PFCRuntimeKeyProfileEditor] = editor;
                _profileRuntimeKeys[uuid] = profileRuntimeKeys;
            }
        }
    }

    if (editor) {
        [[editor window] makeKeyAndOrderFront:self];
    }
} // openProfileEditorForProfileWithUUID

- (void)closeProfileEditorForProfileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    DDLogInfo(@"Close profile editor for profile with UUID: %@", uuid);
    if ([uuid length] == 0) {
        DDLogError(@"No profile uuid was passed for close");
        return;
    }

    NSMutableDictionary *profileRuntimeKeys = [_profileRuntimeKeys[uuid] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    DDLogDebug(@"Current profile runtime keys: %@", profileRuntimeKeys);

    if (profileRuntimeKeys[PFCRuntimeKeyProfileEditor] != nil) {
        DDLogDebug(@"Removing profile editor from profile runtime keys");
        [profileRuntimeKeys removeObjectForKey:PFCRuntimeKeyProfileEditor];
        _profileRuntimeKeys[uuid] = profileRuntimeKeys;
    }

    NSDictionary *profile = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];

    NSString *profilePath = profile[PFCProfileTemplateKeyPath] ?: @"";
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    if (![profileURL checkResourceIsReachableAndReturnError:nil]) {
        DDLogWarn(@"No profile exist at profile save path, will remove from tableview");
        [[PFCProfileUtility sharedUtility] removeUnsavedProfileWithUUID:uuid];

        if (_selectedGroupType == kPFCProfileGroupAll) {
            [_groupAll selectGroup:self];
        } else {
            // FIXME - Here should select the profile or group selected
        }
    }
} // closeProfileEditorForProfileWithUUID

- (void)createNewProfile {

    NSString *uuid = [[NSUUID UUID] UUIDString];
    DDLogDebug(@"New profile uuid: %@", uuid);

    NSDictionary *profileDict = @{
        PFCRuntimeKeyPath : [PFCGeneralUtility newProfilePath],
        @"Config" : @{
            PFCProfileTemplateKeyName : PFCDefaultProfileName,
            PFCProfileTemplateKeyIdentifierFormat : PFCDefaultProfileIdentifierFormat,
            PFCProfileTemplateKeyDisplaySettings : @{
                PFCProfileDisplaySettingsKeyPlatform : @{PFCProfileDisplaySettingsKeyPlatformOSX : @YES, PFCProfileDisplaySettingsKeyPlatformiOS : @NO},
                PFCProfileDisplaySettingsKeySupervised : @NO
            },
            PFCProfileTemplateKeyUUID : uuid
        }
    };

    [[PFCProfileUtility sharedUtility] addUnsavedProfile:profileDict];

    PFCProfileEditor *editor = [[PFCProfileEditor alloc] initWithProfileDict:profileDict mainWindow:self];
    if (editor) {
        NSMutableDictionary *profileRuntimeKeys = _profileRuntimeKeys[uuid] ?: [[NSMutableDictionary alloc] init];
        DDLogDebug(@"Current profile runtime keys: %@", profileRuntimeKeys);

        profileRuntimeKeys[PFCRuntimeKeyProfileEditor] = editor;
        _profileRuntimeKeys[uuid] = [profileRuntimeKeys copy];

        [[editor window] makeKeyAndOrderFront:self];
    }

    [self insertProfileInTableView:uuid];
} // createNewProfile

- (void)updateProfileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Profile UUID: %@", uuid);

    DDLogDebug(@"Selected group: %ld", (long)_selectedGroupType);
    NSUInteger selectedIndex = NSNotFound;
    if (_selectedGroupType == kPFCProfileGroupAll) {
        if ([_arrayProfileLibrary containsObject:uuid]) {
            selectedIndex = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSString *_Nonnull string, NSUInteger idx, BOOL *_Nonnull stop) {
              return [string isEqualToString:uuid];
            }];
        }
    } else if (_selectedGroupType == kPFCProfileGroups) {
        selectedIndex = [_groupGroups indexOfProfileWithUUID:uuid];
    } else if (_selectedGroupType == kPFCProfileSmartGroups) {
        // FIXME - This isn't implemented yet
    } else {
        DDLogError(@"Unknown table view identifier: %@", _selectedTableViewIdentifier);
    }

    if (selectedIndex != NSNotFound) {
        NSRange allColumns = NSMakeRange(0, [[_tableViewProfileLibrary tableColumns] count]);
        [_tableViewProfileLibrary reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:allColumns]];
    }

    DDLogDebug(@"Selected profile UUID: %@", _selectedProfileUUID);
    if ([_selectedProfileUUID isEqualToString:uuid]) {
        NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];
        if ([profileDict count] != 0) {
            [_preview updatePreviewWithProfileDict:profileDict];
        }
    }
} // updateProfileWithUUID

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Group Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)deleteGroupWithUUID:(NSString *)uuid inGroup:(PFCProfileGroups)group {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([uuid length] == 0) {
        DDLogError(@"No UUID was passed!");
        return;
    }
    DDLogDebug(@"Group UUID: %@", uuid);

    switch (group) {
    case kPFCProfileGroups: {
        [_groupGroups deleteGroupWithUUID:uuid];
    } break;

    case kPFCProfileSmartGroups: {
        [_groupSmartGroups deleteGroupWithUUID:uuid];
    }
    default:
        break;
    }
} // deleteGroupWithUUID:inGroup

- (void)selectGroup:(NSDictionary *)groupDict groupType:(PFCProfileGroups)group profileArray:(NSArray *)profileArray {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [self setSelectedGroup:groupDict];
    [self updateGroupSelection:group];

    NSIndexSet *rowIndexes = [NSIndexSet indexSet];

    [_tableViewProfileLibrary beginUpdates];
    [_arrayProfileLibrary removeAllObjects];

    if (1 <= [profileArray count]) {
        [_arrayProfileLibrary addObjectsFromArray:profileArray];

        if ([_selectedProfileUUID length] != 0) {
            NSUInteger index = [_arrayProfileLibrary indexOfObject:_selectedProfileUUID];

            if (index != NSNotFound) {
                rowIndexes = [NSIndexSet indexSetWithIndex:index];
            }
        } else if (1 < [_tableViewProfileLibrarySelectedRows count]) {
            rowIndexes = _tableViewProfileLibrarySelectedRows;
        }
    } else {
        if ([_selectedProfileUUID length] == 0) {
            [_preview showProfilePreviewNoSelection];
        }
    }

    [_tableViewProfileLibrary reloadData];
    [_tableViewProfileLibrary endUpdates];

    if ([rowIndexes count]) {
        [_tableViewProfileLibrary selectRowIndexes:rowIndexes byExtendingSelection:NO];
    }
}

- (void)updateGroups {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSView *groupView = [_groupAll viewGroup];
    NSView *previousGroupView = groupView;

    // -------------------------------------------------------------------------
    //  Add "All Profiles" at the top
    // -------------------------------------------------------------------------
    [_viewProfileGroupsSplitView addSubview:groupView positioned:NSWindowAbove relativeTo:nil];
    [groupView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_viewProfileGroupsSplitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[groupView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupView)]];
    [_viewProfileGroupsSplitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[groupView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupView)]];

    // -------------------------------------------------------------------------
    //  Loop through selected groups and add to window
    // -------------------------------------------------------------------------
    for (PFCMainWindowGroup *group in _arrayGroups) {
        groupView = [group viewGroup];
        if (groupView != nil) {
            [_viewProfileGroupsSplitView addSubview:groupView positioned:NSWindowAbove relativeTo:nil];
            [groupView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_viewProfileGroupsSplitView
                addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[groupView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupView)]];
            [_viewProfileGroupsSplitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousGroupView]-0-[groupView]"
                                                                                                options:0
                                                                                                metrics:nil
                                                                                                  views:NSDictionaryOfVariableBindings(previousGroupView, groupView)]];
            previousGroupView = groupView;
        }
    }

    // -------------------------------------------------------------------------
    //  Add last group added's trailing constraint to bottom
    // -------------------------------------------------------------------------
    [_viewProfileGroupsSplitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[groupView]-0@1-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupView)]];
}

- (void)updateGroupSelection:(PFCProfileGroups)group {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [self setSelectedGroupType:group];
    for (PFCMainWindowGroup *groupView in [_arrayGroups arrayByAddingObject:_groupAll]) {
        if (group != [groupView group]) {
            [[groupView tableViewGroup] deselectAll:self];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)selectTableViewProfileLibrary:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSIndexSet *selectedRowIndexes = [_tableViewProfileLibrary selectedRowIndexes];
    DDLogDebug(@"Table view profile library selected rows: %@", selectedRowIndexes);

    if ([selectedRowIndexes count] == 0) {

        // ---------------------------------------------------------------------
        //  Update the selection properties with the current value
        // ---------------------------------------------------------------------
        DDLogDebug(@"Updating table view profile library selected row");
        [self setTableViewProfileLibrarySelectedRows:selectedRowIndexes];

        // -----------------------------------------------------------------
        //  Hide profile preview and show no selection
        // -----------------------------------------------------------------
        [_preview showProfilePreviewNoSelection];

        // -----------------------------------------------------------------
        //  Unset the SelectedProfileUUID
        // -----------------------------------------------------------------
        DDLogDebug(@"Removing selected profile uuid");
        [self setSelectedProfileUUID:nil];

    } else if (1 < [selectedRowIndexes count]) {

        // ---------------------------------------------------------------------
        //  Update the selection properties with the current value
        // ---------------------------------------------------------------------
        DDLogDebug(@"Updating table view profile library selected row");
        [self setTableViewProfileLibrarySelectedRows:selectedRowIndexes];

        // ---------------------------------------------------------------------
        //  Hide profile preview and show count of selected profiles
        // ---------------------------------------------------------------------
        [_preview showProfilePreviewMultipleSelections:@([selectedRowIndexes count])];

        // ---------------------------------------------------------------------
        //  Unset the SelectedProfileUUID
        // ---------------------------------------------------------------------
        [self setSelectedProfileUUID:nil];

    } else if (selectedRowIndexes != _tableViewProfileLibrarySelectedRows) {

        // ---------------------------------------------------------------------
        //  Update the selection properties with the current value
        // ---------------------------------------------------------------------
        DDLogDebug(@"Updating table view profile library selected row");
        [self setTableViewProfileLibrarySelectedRows:selectedRowIndexes];

        // ---------------------------------------------------------------------
        //  Get selected row as NSInteger
        // ---------------------------------------------------------------------
        NSInteger selectedRow = [selectedRowIndexes firstIndex];
        DDLogDebug(@"Table view profile library selected row: %ld", (long)selectedRow);

        if (selectedRow != NSNotFound) {

            // -----------------------------------------------------------------
            //  Call method to change profile selection (and preview)
            // -----------------------------------------------------------------
            [self selectTableViewProfileLibraryRow:selectedRow];
        } else {

            // -----------------------------------------------------------------
            //  Hide profile preview and show no selection
            // -----------------------------------------------------------------
            [_preview showProfilePreviewNoSelection];

            // -----------------------------------------------------------------
            //  Unset the SelectedProfileUUID
            // -----------------------------------------------------------------
            DDLogDebug(@"Removing selected profile uuid");
            [self setSelectedProfileUUID:nil];
        }
    } else {
        DDLogDebug(@"Current profile is already selected");
    }
} // selectTableViewProfileLibrary

- (void)selectTableViewProfileLibraryRow:(NSInteger)row {

    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ([_tableViewProfileLibrarySelectedRows firstIndex] != NSNotFound && [_tableViewProfileLibrarySelectedRows firstIndex] <= [_arrayProfileLibrary count]) {

        // ---------------------------------------------------------------------
        //  Load the current profile from the array
        // ---------------------------------------------------------------------
        NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:_arrayProfileLibrary[row] ?: @""];

        // ---------------------------------------------------------------------
        //  Verify the profile has any content
        // ---------------------------------------------------------------------
        if ([profileDict count] == 0) {

            [_preview showProfilePreviewError];
            return;
        }

        // --------------------------------------------------------------------------
        //  Store the currently selected uuid in local variable _selectedProfileUUID
        // --------------------------------------------------------------------------
        NSString *profileUUID = profileDict[@"Config"][PFCProfileTemplateKeyUUID] ?: @"";
        DDLogDebug(@"Selected profile UUID: %@", profileUUID);

        if ([profileUUID length] == 0) {
            [_preview showProfilePreviewError];
            return;
        }
        [self setSelectedProfileUUID:profileUUID];

        // ---------------------------------------------------------------------
        //  Populate the preview view with the selected profile
        // ---------------------------------------------------------------------
        [_preview updatePreviewWithProfileDict:profileDict];

        // ---------------------------------------------------------------------
        //  Show selected profile preview (of not already visible)
        // ---------------------------------------------------------------------
        [_preview showProfilePreview];
    } else {

        // ---------------------------------------------------------------------
        //  Unset the SelectedProfileUUID
        // ---------------------------------------------------------------------
        DDLogDebug(@"Removing selected profile UUID");
        [self setSelectedProfileUUID:nil];
    }
}

- (void)exportProfileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([_tableViewProfileLibrarySelectedRows count] == 0) {
        if ([[_tableViewProfileLibrary selectedRowIndexes] count] == 0) {
            return;
        } else {
            [self setTableViewProfileLibrarySelectedRows:[_tableViewProfileLibrary selectedRowIndexes]];
        }
    }

    if ([uuid length] == 0) {
        uuid = _arrayProfileLibrary[[_tableViewProfileLibrarySelectedRows firstIndex]];
    }

    NSDictionary *settingsProfile = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];

    // -------------------------------------------------------------------------
    //  Get only settings and domains for selected payloads.
    //  THe application saves all settings, even if they are made in payloads that's not enabled
    // -------------------------------------------------------------------------
    NSDictionary *settingsAll = settingsProfile[@"Config"][PFCProfileTemplateKeySettings] ?: @{};
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

    for (NSString *domain in [settingsAll allKeys]) {
        if (![settingsAll[domain][PFCSettingsKeySelected] boolValue] && ![domain isEqualToString:@"com.apple.general"]) {
            continue;
        }

        settings[domain] = settingsAll[domain];
    }
    NSArray *selectedDomains = [settings allKeys];
    NSArray *selectedManifests = [[PFCManifestLibrary sharedLibrary] manifestsWithDomains:selectedDomains];

    // FIXME - HERE DO VERIFICATION!

    if ([settings count] != 0) {
        PFCProfileExport *export = [[PFCProfileExport alloc] initWithProfileSettings:settingsProfile mainWindow:self];

        NSString *profileName = settingsProfile[@"Config"][PFCProfileTemplateKeyName] ?: @"";
        NSSavePanel *panel = [NSSavePanel savePanel];

        //[panel setAccessoryView:_viewExportPanel]; // Activate later for custom exports

        [panel setAllowedFileTypes:@[ @"com.apple.mobileconfig" ]];
        [panel setCanCreateDirectories:YES];
        [panel setTitle:@"Export Profile"];
        [panel setPrompt:@"Export"];
        [panel setNameFieldStringValue:profileName];
        [panel beginSheetModalForWindow:[self window]
                      completionHandler:^(NSInteger result) {
                        if (result == NSFileHandlingPanelOKButton) {
                            NSURL *saveURL = [panel URL];
                            [export exportProfileToURL:saveURL manifests:selectedManifests settings:settings];
                        }
                      }];
    }
}

- (void)menuItemShowInFinder:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if (_clickedTableViewRow < 0 || [_arrayProfileLibrary count] < _clickedTableViewRow) {
        return;
    }

    NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:_arrayProfileLibrary[_clickedTableViewRow] ?: @""];

    // ----------------------------------------------------------------------------------------
    //  If key 'Path' is set, check if it's a valid path. If it is, open it in Finder
    // ----------------------------------------------------------------------------------------
    if ([profileDict[PFCRuntimeKeyPath] length] != 0) {
        NSError *error = nil;
        NSString *filePath = profileDict[PFCRuntimeKeyPath] ?: @"";
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if ([fileURL checkResourceIsReachableAndReturnError:&error]) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
        } else {
            DDLogError(@"%@", [error localizedDescription]);
        }
    }
}

- (void)menuItemNewProfile {
    [self createNewProfile];
} // menuItemNewProfile

- (void)menuItemNewGroup {
    [_groupGroups createNewGroupOfType:kPFCProfileGroups];
} // menuItemNewGroup

- (IBAction)toolbarItemAdd:(id)sender {
    [self createNewProfile];
} // toolbarItemAdd

- (IBAction)searchField:(id)sender {
}

@end
