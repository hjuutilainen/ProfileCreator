//
//  PFCMainWindowController.m
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

#import "PFCMainWindow.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCTableViewCellsProfiles.h"
#import "PFCProfileEditor.h"
#import "PFCGeneralUtility.h"
#import "PFCManifestParser.h"
#import "PFCProfileUtility.h"
#import "NSView+NSLayoutConstraintFilter.h"
#import "PFCTableViews.h"
#import "PFCProfileGroupTitle.h"
#import "PFCPayloadPreview.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestUtility.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCTableViewIdentifierProfileLibrary = @"TableViewIdentifierProfileLibrary";
NSString *const PFCTableViewIdentifierProfileGroupAll = @"TableViewIdentifierProfileGroupAll";
NSString *const PFCTableViewIdentifierProfileGroups = @"TableViewIdentifierProfileGroups";
NSString *const PFCTableViewIdentifierProfileSmartGroups = @"TableViewIdentifierProfileSmartGroups";
int const PFCTableViewGroupsRowHeight = 24;

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
        _arrayProfileGroupAll = [[NSMutableArray alloc] init];
        _arrayProfileGroups = [[NSMutableArray alloc] init];
        _arrayProfileSmartGroups = [[NSMutableArray alloc] init];
        _arrayStackViewPreview = [[NSMutableArray alloc] init];
        
        // ---------------------------------------------------------------------
        //  Initialize Classes
        // ---------------------------------------------------------------------
        PFCProfileGroupTitle *profileGroupTitleViewController = [[PFCProfileGroupTitle alloc] init];
        [(PFCProfileGroupTitleView *)[profileGroupTitleViewController view] setDelegate:self];
        [(PFCProfileGroupTitleView *)[profileGroupTitleViewController view] setProfileGroup:kPFCProfileGroups];
        [[(PFCProfileGroupTitleView *)[profileGroupTitleViewController view] textFieldTitle] setStringValue:@"Groups"];
        _viewAddGroupsTitle = (PFCProfileGroupTitleView *)[profileGroupTitleViewController view];
        
        PFCProfileGroupTitle *profileSmartGroupTitleViewController = [[PFCProfileGroupTitle alloc] init];
        [(PFCProfileGroupTitleView *)[profileSmartGroupTitleViewController view] setDelegate:self];
        [(PFCProfileGroupTitleView *)[profileSmartGroupTitleViewController view] setProfileGroup:kPFCProfileSmartGroups];
        [[(PFCProfileGroupTitleView *)[profileSmartGroupTitleViewController view] textFieldTitle] setStringValue:@"Smart Groups"];
        _viewAddSmartGroupsTitle = (PFCProfileGroupTitleView *)[profileSmartGroupTitleViewController view];
        
        // ---------------------------------------------------------------------
        //  Initialize BOOLs (for clarity)
        // ---------------------------------------------------------------------
        _profilePreviewHidden = YES;
        _profilePreviewSelectionUnavailableHidden = YES;
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
    //  Set window background color to white
    // -------------------------------------------------------------------------
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    
    // -------------------------------------------------------------------------
    //  Add content views to window
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:_viewProfileGroupsSuperview inSuperview:_viewProfileGroupsSplitView hidden:NO];
    [PFCGeneralUtility insertSubview:_viewAddGroupsTitle inSuperview:_viewAddGroupsSuperview hidden:NO];
    [PFCGeneralUtility insertSubview:_viewAddSmartGroupsTitle inSuperview:_viewAddSmartGroupsSuperview hidden:NO];
    [PFCGeneralUtility insertSubview:_viewProfileLibraryTableViewSuperview inSuperview:_viewProfileLibrarySplitView hidden:NO];
    [PFCGeneralUtility insertSubview:_viewPreviewSuperview inSuperview:_viewPreviewSplitView hidden:YES];
    
    // -------------------------------------------------------------------------
    //  Add error views to content views
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:_viewPreviewSelectionUnavailable inSuperview:_viewPreviewSplitView hidden:NO];
    
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
    //  Initialize PFCProfileUtility
    // -------------------------------------------------------------------------
    [PFCProfileUtility sharedUtility];
    
    // -------------------------------------------------------------------------
    //  Setup TableView "All Profiles"
    // -------------------------------------------------------------------------
    [self setTableViewProfileGroupAllSelectedRow:-1];
    [self setupProfileGroupAll];
    
    // -------------------------------------------------------------------------
    //  Setup TableView "Profile Groups"
    // -------------------------------------------------------------------------
    [self setTableViewProfileGroupsSelectedRow:-1];
    
    // -------------------------------------------------------------------------
    //  Setup TableView "Profile Library"
    // -------------------------------------------------------------------------
    [self setTableViewProfileLibrarySelectedRows:[NSIndexSet indexSet]];
    [_tableViewProfileLibrary setTarget:self];
    [_tableViewProfileLibrary setDoubleAction:@selector(editSelectedProfile:)];
    
    // -------------------------------------------------------------------------
    //  Setup TableView "Profile Preview"
    // -------------------------------------------------------------------------
    // FIXME - Add init here
    [self showProfilePreviewNoSelection];
    
    // -------------------------------------------------------------------------
    //  Select "All Profiles"
    // -------------------------------------------------------------------------
    [self selectTableViewProfileGroupAllRow:0];
    [_tableViewProfileGroupAll selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
} // initialSetup

- (void)setupProfileGroupAll {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    // -------------------------------------------------------------------------
    //  Add the only item "All Profiles" to table view.
    // -------------------------------------------------------------------------
    [_arrayProfileGroupAll addObject:@{ @"Config" : @{ PFCProfileGroupKeyName : @"All Profiles",
                                                       PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString] }}];
    [_tableViewProfileGroupAll reloadData];
} // setupProfileGroupAll

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if ( splitView == _splitVewMain ) {
        if ( view == [[_splitVewMain subviews] lastObject] ) {
            return YES;
        }
        return NO;
    }
    return YES;
} // splitView:shouldAdjustSizeOfSubview

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ( splitView == _splitVewMain ) {
        if ( dividerIndex == 0 ) {
            return proposedMaximumPosition - 190;
        } else if ( dividerIndex == 1 ) {
            return proposedMaximumPosition - 260;
        } else if ( dividerIndex == 2 ) {
            
        }
    }
    return proposedMaximumPosition;
} // splitView:constrainMaxCoordinate:ofSubviewAt

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ( splitView == _splitVewMain ) {
        if ( dividerIndex == 0 ) {
            return  proposedMinimumPosition + 149;
        } else if ( dividerIndex == 1 ) {
            return proposedMinimumPosition + 190;
        } else if ( dividerIndex == 2 ) {
            return proposedMinimumPosition + 260;
        }
    }
    return proposedMinimumPosition;
} // splitView:constrainMinCoordinate:ofSubviewAt

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if ( splitView == _splitVewMain && subview == [[_splitVewMain subviews] firstObject] ) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    if ( splitView == _splitVewMain && dividerIndex == 0 ) {
        return [_splitVewMain isSubviewCollapsed:[_splitVewMain subviews][0]] ;
    }
    return NO;
} // splitView:shouldHideDividerAtIndex

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary] ) {
        return (NSInteger)[_arrayProfileLibrary count];
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileGroups] ) {
        return (NSInteger)[_arrayProfileGroups count];
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileGroupAll] ) {
        return (NSInteger)[_arrayProfileGroupAll count];
    } else {
        return 0;
    }
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
    if ( [[tableView identifier] isEqualToString:_selectedTableViewIdentifier] && [proposedSelectionIndexes count] == 0 ) {
        return [NSIndexSet indexSetWithIndex:[tableView selectedRow]];
    }
    return proposedSelectionIndexes;
} // tableView:selectionIndexesForProposedSelection

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *tableViewIdentifier = [tableView identifier];
    if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileLibrary] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayProfileLibrary count] == 0 || [_arrayProfileLibrary count] < row ) {
            return nil;
        }
        
        NSDictionary *profileDict;
        if ( [_selectedGroup[@"Config"][PFCProfileGroupKeyName] isEqualToString:@"All Profiles"] ) {
            profileDict = _arrayProfileLibrary[row] ?: @{};
        } else {
            profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:_arrayProfileLibrary[row]];
        }
        
        CellViewProfile *cellView = [tableView makeViewWithIdentifier:@"CellViewProfile" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfile:cellView profileDict:profileDict row:row];
    } else if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileGroups] && [[tableColumn identifier] isEqualToString:@"TableColumnProfileGroups"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayProfileGroups count] == 0 || [_arrayProfileGroups count] < row ) {
            return nil;
        }
        
        CellViewProfileGroup *cellView = [tableView makeViewWithIdentifier:@"CellViewProfileGroup" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfileGroup:cellView profileDict:_arrayProfileGroups[(NSUInteger)row] row:row];
    } else if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileGroupAll] && [[tableColumn identifier] isEqualToString:@"TableColumnProfileGroups"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayProfileGroupAll count] == 0 || [_arrayProfileGroupAll count] < row ) {
            return nil;
        }
        
        CellViewProfileGroup *cellView = [tableView makeViewWithIdentifier:@"CellViewProfileGroupAll" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfileGroup:cellView profileDict:_arrayProfileGroupAll[(NSUInteger)row] row:row];
    }
    return nil;
} // tableView:viewForTableColumn:row

- (NSInteger)insertProfileInTableView:(NSDictionary *)profileDict {
    NSInteger index = [_tableViewProfileLibrary selectedRow];
    index++;
    [_tableViewProfileLibrary beginUpdates];
    [_tableViewProfileLibrary insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationEffectNone];
    [_tableViewProfileLibrary scrollRowToVisible:index];
    [_arrayProfileLibrary insertObject:profileDict atIndex:(NSUInteger)index];
    [_tableViewProfileLibrary endUpdates];
    return index;
} // insertProfileInTableView

- (NSInteger)insertProfileGroupInTableView:(NSDictionary *)profileDict {
    NSInteger index = [_tableViewProfileGroups selectedRow];
    index++;
    [_tableViewProfileGroups beginUpdates];
    [_tableViewProfileGroups insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationEffectNone];
    [_tableViewProfileGroups scrollRowToVisible:index];
    [_arrayProfileGroups insertObject:profileDict atIndex:(NSUInteger)index];
    [_tableViewProfileGroups endUpdates];
    return index;
} // insertProfileGroupInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Saving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)saveGroup:(NSDictionary *)groupDict error:(NSError **)error {
    NSURL *groupSaveFolder = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfileGroups];
    if ( ! [groupSaveFolder checkResourceIsReachableAndReturnError:nil] ) {
        if ( ! [[NSFileManager defaultManager] createDirectoryAtURL:groupSaveFolder withIntermediateDirectories:YES attributes:nil error:error] ) {
            return NO;
        }
    }
    
    NSString *groupPath = groupDict[PFCRuntimeKeyPath] ?: [PFCGeneralUtility newProfileGroupPath];
    NSURL *groupURL = [NSURL fileURLWithPath:groupPath];
    NSDictionary *groupConfig = groupDict[@"Config"];
    return [groupConfig writeToURL:groupURL atomically:YES];
} // saveGroup:error

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Preview
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updatePreviewWithProfileDict:(NSDictionary *)profileDict {
    
    // ---------------------------------------------------------------------
    //  Clean up previews preview content
    // ---------------------------------------------------------------------
    [_arrayStackViewPreview removeAllObjects];
    for ( NSView *view in [_stackViewPreview views] ) {
        [view removeFromSuperview];
    }
    
    // ---------------------------------------------------------------------
    //  Clean up previews preview content
    // ---------------------------------------------------------------------
    NSDictionary *profileSettings = profileDict[@"Config"];
    
    NSString *profileName = profileSettings[PFCProfileTemplateKeyName];
    [_textFieldPreviewProfileName setStringValue:profileName ?: @""];
    
    for ( NSString *domain in [profileSettings[@"Settings"] allKeys] ?: @[] ) {
        DDLogDebug(@"Payload domain: %@", domain);
        
        NSDictionary *domainSettings = profileSettings[@"Settings"][domain];
        if ( ! [domain isEqualToString:@"com.apple.general"] && ! [domainSettings[@"Selected"] boolValue] ) {
            continue;
        }
        
        if ( [domain isEqualToString:@"com.apple.general"] || domainSettings[@"PayloadLibrary"] != nil ) {
            NSInteger payloadLibrary = [domainSettings[@"PayloadLibrary"] integerValue] ?: 0;
            DDLogDebug(@"Payload library: %ld", (long)payloadLibrary);
            
            NSDictionary *manifest = [[PFCManifestLibrary sharedLibrary] manifestFromLibrary:payloadLibrary withDomain:domain];
            if ( [manifest count] != 0 ) {
                PFCPayloadPreview *preview = [self previewForMainfest:manifest domain:domain];
                [_arrayStackViewPreview addObject:preview];
                [_stackViewPreview addView:[preview view] inGravity:NSStackViewGravityTop];
            } else {
                DDLogError(@"No manifest returned from payload library: %ld with domain: %@", (long)payloadLibrary, domain);
            }
        } else {
            DDLogError(@"");
        }
    }
}

- (PFCPayloadPreview *)previewForMainfest:(NSDictionary *)manifest domain:(NSString *)domain {
    
    PFCPayloadPreview *preview = [[PFCPayloadPreview alloc] init];
    
    [preview setPayloadDomain:manifest[PFCManifestKeyTitle] ?: domain];
    [preview setPayloadDescription:manifest[PFCManifestKeyDescription] ?: @""];
    
    NSImage *icon = [[PFCManifestUtility sharedUtility] iconForManifest:manifest];
    if ( icon ) {
        [preview setPayloadIcon:icon];
    }
    
    return preview;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showProfilePreview {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_viewPreviewSuperview setHidden:NO];
    [self setProfilePreviewHidden:NO];
    
    [_viewPreviewSelectionUnavailable setHidden:YES];
    [_textFieldPreviewSelectionUnavailable setStringValue:@""];
    [self setProfilePreviewSelectionUnavailableHidden:YES];
} // showProfilePreview

- (void)showProfilePreviewError {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:@"Error Reading Selected Profile"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
} // showProfilePreviewError

- (void)showProfilePreviewNoSelection {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:@"No Profile Selected"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
} // showProfilePreviewNoSelection

- (void)showProfilePreviewMultipleSelections:(NSNumber *)count {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:[NSString stringWithFormat:@"%@ %@ Selected", [count stringValue], ([count intValue] == 1) ? @"Profile" : @"Profiles"]];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
} // showProfilePreviewNoSelection

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Unsorted
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)editSelectedProfile:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    // -------------------------------------------------------------------------
    //  Verify table view is profile library
    // -------------------------------------------------------------------------
    if ( [[sender identifier] isEqualToString:PFCTableViewIdentifierProfileLibrary] ) {
        
        // ---------------------------------------------------------------------
        //  Get currently selected row
        // ---------------------------------------------------------------------
        NSInteger selectedRow = [sender clickedRow];
        DDLogDebug(@"Profile library selected row: %ld", (long)selectedRow);
        
        [self openProfileEditorForProfileAtRow:selectedRow];
    }
} // editSelectedProfile

- (void)openProfileEditorForProfileAtRow:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Sanity check that selection and array is reasonable
    // ---------------------------------------------------------------------
    if ( 0 <= row && row <= [_arrayProfileLibrary count] ) {
        NSMutableDictionary *profileDict = [_arrayProfileLibrary[row] mutableCopy];
        
        // ---------------------------------------------------------------------------------------------
        //  Check if an editor is already open, else instantiate a new one and save in the profile dict
        // ---------------------------------------------------------------------------------------------
        PFCProfileEditor *editor;
        if ( profileDict[PFCRuntimeKeyProfileEditor] != nil ) {
            editor = profileDict[PFCRuntimeKeyProfileEditor];
        } else {
            editor = [[PFCProfileEditor alloc] initWithProfileDict:[profileDict copy] sender:self];
            if ( editor ) {
                profileDict[PFCRuntimeKeyProfileEditor] = editor;
                [_arrayProfileLibrary replaceObjectAtIndex:row withObject:[profileDict copy]];
            } else {
                DDLogError(@"Instantiating profile editor failed");
            }
        }
        [[editor window] makeKeyAndOrderFront:self];
    }
} // openProfileEditorForProfileAtRow

- (void)renameProfileWithUUID:(NSString *)profileUUID newName:(NSString *)newName {
    
}

- (void)closeProfileEditorForProfileWithUUID:(NSString *)profileUUID {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    DDLogInfo(@"Close profile editor for profile with UUID: %@", profileUUID);
    NSUInteger index = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL *stop) {
        return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:profileUUID];
    }];
    DDLogDebug(@"Profile index: %lu", (unsigned long)index);
    
    if ( index != NSNotFound ) {
        NSMutableDictionary *profileDict = [[_arrayProfileLibrary objectAtIndex:index] mutableCopy];
        [profileDict removeObjectForKey:PFCRuntimeKeyProfileEditor];
        [_arrayProfileLibrary replaceObjectAtIndex:index withObject:[profileDict copy]];
    } else {
        DDLogError(@"Found no profile with UUID: %@", profileUUID);
    }
} // closeProfileEditorForProfileWithUUID

- (void)createNewProfile {
    NSMutableDictionary *profileDict = [@{ PFCRuntimeKeyPath : [PFCGeneralUtility newProfilePath],
                                           @"Config" : @{ PFCProfileTemplateKeyName : PFCDefaultProfileName,
                                                          PFCProfileTemplateKeyUUID : [[NSUUID UUID] UUIDString] }} mutableCopy];
    
    PFCProfileEditor *editor = [[PFCProfileEditor alloc] initWithProfileDict:[profileDict copy] sender:self];
    if ( editor ) {
        profileDict[PFCRuntimeKeyProfileEditor] = editor;
        [[editor window] makeKeyAndOrderFront:self];
    }
    
    [self insertProfileInTableView:[profileDict copy]];
} // createNewProfile

- (void)addGroupOfType:(PFCProfileGroups)group {
    if ( group == kPFCProfileGroups ) {
        NSNumber *index = @([self insertProfileGroupInTableView:@{ PFCRuntimeKeyPath : [PFCGeneralUtility newProfileGroupPath],
                                                                   @"Config" : @{ PFCProfileGroupKeyName : PFCDefaultProfileGroupName,
                                                                                  PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString] }}]);
        [self selectTableViewProfileGroupsRow:[index integerValue]];
        [_tableViewProfileGroups selectRowIndexes:[NSIndexSet indexSetWithIndex:[index integerValue]] byExtendingSelection:NO];
        [[[_tableViewProfileGroups viewAtColumn:1
                                            row:[index integerValue]
                                makeIfNecessary:NO] menuTitle] selectText:self];
        
        [self setTableViewHeight:PFCTableViewGroupsRowHeight*(int)[_arrayProfileGroups count] tableView:_scrollViewProfileGroups];
    } else if ( group == kPFCProfileSmartGroups ) {
        NSLog(@"Add a SMART GROUP");
    }
} // addGroup

- (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView {
    NSLayoutConstraint *constraint = [scrollView constraintForAttribute:NSLayoutAttributeHeight];
    [constraint setConstant:tableHeight];
} // setTableViewHeight

- (BOOL)deleteKeyPressedForTableView:(PFCProfileGroupTableView *)tableView {
    
    // -------------------------------------------------------------------------
    //  Check if any row is selected, else return here
    // -------------------------------------------------------------------------
    NSInteger selectedRow = [tableView selectedRow];
    if (selectedRow == -1) return NO;
    
    NSDictionary *groupDict;
    if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierProfileGroups] ) {
        groupDict = _arrayProfileGroups[selectedRow] ?: @{};
    } else {
        return NO;
    }
    
    NSString *groupName = groupDict[@"Config"][PFCProfileGroupKeyName] ?: @"";
    NSString *groupUUID = groupDict[@"Config"][PFCProfileGroupKeyUUID] ?: @"";
    
    PFCAlert *alert = [[PFCAlert alloc] initWithDelegate:self];
    [alert showAlertDeleteGroup:groupName alertInfo:@{ PFCAlertTagKey : PFCAlertTagDeleteGroup,
                                                       PFCProfileGroupKeyUUID : groupUUID,
                                                       @"TableViewIdentifier" : [tableView identifier] }];
    
    return YES;
} // deleteKeyPressedForTableView

- (void)alertReturnCode:(NSInteger)returnCode alertInfo:(NSDictionary *)alertInfo {
    NSString *alertTag = alertInfo[PFCAlertTagKey];
    if ( [alertTag isEqualToString:PFCAlertTagDeleteGroup] ) {
        if ( returnCode == NSAlertSecondButtonReturn ) {    // Delete
            if ( [alertInfo[@"TableViewIdentifier"] ?: @"" isEqualToString:PFCTableViewIdentifierProfileGroups] ) {
                [self deleteGroupWithUUID:alertInfo[PFCProfileGroupKeyUUID] ?: @"" inGroup:kPFCProfileGroups];
            }
        }
    }
}

- (void)deleteGroupWithUUID:(NSString *)groupUUID inGroup:(PFCProfileGroups)group {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ( [groupUUID length] == 0 ) {
        DDLogError(@"No UUID was passed!");
        return;
    }
    DDLogDebug(@"Group UUID: %@", groupUUID);
    
    switch (group) {
        case kPFCProfileGroups:
        {
            NSInteger index = [_arrayProfileGroups indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:groupUUID];
            }];
            DDLogDebug(@"Group index: %ld", (long)index);
            
            if ( index != NSNotFound ) {
                [_tableViewProfileGroups beginUpdates];
                [_arrayProfileGroups removeObjectAtIndex:index];
                [_tableViewProfileGroups reloadData];
                [_tableViewProfileGroups endUpdates];
                [self setTableViewHeight:PFCTableViewGroupsRowHeight*(int)[_arrayProfileGroups count] tableView:_scrollViewProfileGroups];
            }
        }
            break;
            
        case kPFCProfileSmartGroups:
        {
            NSInteger index = [_arrayProfileSmartGroups indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:groupUUID];
            }];
            DDLogDebug(@"Group index: %ld", (long)index);
            
            if ( index != NSNotFound ) {
                [_tableViewProfileGroupAll beginUpdates];
                [_arrayProfileSmartGroups removeObjectAtIndex:index];
                [_tableViewProfileGroupAll reloadData];
                [_tableViewProfileGroupAll endUpdates];
                //[self setTableViewHeight:PFCTableViewGroupsRowHeight*(int)[_arrayProfileGroupAll count] tableView:_scrollViewProfileGroups];
            }
        }
        default:
            break;
    }
}

- (void)updateProfileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Profile UUID: %@", uuid);
    
    DDLogDebug(@"Selected table view identifier: %@", _selectedTableViewIdentifier);
    if ( [_selectedTableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileGroupAll] ) {
        NSUInteger selectedIndex = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:uuid];
        }];
        
        if ( selectedIndex != NSNotFound ) {
            NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];
            if ( [profileDict count] != 0 ) {
                [_arrayProfileLibrary replaceObjectAtIndex:selectedIndex withObject:profileDict];
            }
            
            NSRange allColumns = NSMakeRange(0, [[_tableViewProfileLibrary tableColumns] count]);
            [_tableViewProfileLibrary reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:allColumns]];
        }
    } else if ( [_selectedTableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileGroups] ) {
        if ( [_arrayProfileGroups containsObject:uuid] ) {
            NSUInteger selectedIndex = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSString * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
                return [string isEqualToString:uuid];
            }];
            
            if ( selectedIndex != NSNotFound ) {
                NSRange allColumns = NSMakeRange(0, [[_tableViewProfileLibrary tableColumns] count]);
                [_tableViewProfileLibrary reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:allColumns]];
            }
        }
    } else if ( [_selectedTableViewIdentifier isEqualToString:PFCTableViewIdentifierProfileSmartGroups] ) {
        // FIXME - This isn't implemented yet
    } else {
        DDLogError(@"Unknown table view identifier: %@", _selectedTableViewIdentifier);
    }
    
    
    DDLogDebug(@"Selected profile UUID: %@", _selectedProfileUUID);
    if ( [_selectedProfileUUID isEqualToString:uuid] ) {
        NSDictionary *profileDict = [[PFCProfileUtility sharedUtility] profileWithUUID:uuid];
        if ( [profileDict count] != 0 ) {
            [self updatePreviewWithProfileDict:profileDict];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)segmentedControlProfileLibraryFooterAddRemove:(id)sender {
    if ( [sender selectedSegment] == 0 ) {
        [self createNewProfile];
    } else {
        NSLog(@"Remove");
        //[self removeProfile];
    }
} // segmentedControlProfileLibraryFooterAddRemove

- (IBAction)selectTableViewProfileGroupAll:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger selectedRow = [_tableViewProfileGroupAll selectedRow];
    if ( 0 <= selectedRow && selectedRow != _tableViewProfileGroupAllSelectedRow ) {
        [self selectTableViewProfileGroupAllRow:selectedRow];
    } else {
        [_tableViewProfileGroupAll selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    }
} // selectTableViewProfileGroupAll

- (void)selectTableViewProfileGroupAllRow:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSIndexSet *rowIndexes = [NSIndexSet indexSet];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewProfileGroups deselectAll:self];
    [self setTableViewProfileGroupsSelectedRow:-1];
    [self setTableViewProfileGroupAllSelectedRow:row];
    
    [_tableViewProfileLibrary beginUpdates];
    [_arrayProfileLibrary removeAllObjects];
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewProfileGroupAllSelectedRow && _tableViewProfileGroupAllSelectedRow <= [_arrayProfileGroupAll count] ) {
        
        // ------------------------------------------------------------------------------------
        //  Update the SelectedTableViewIdentifier with the current TableView identifier
        // ------------------------------------------------------------------------------------
        [self setSelectedTableViewIdentifier:[_tableViewProfileGroupAll identifier]];
        DDLogDebug(@"Updating selected profile table view identifier: %@", _selectedTableViewIdentifier);
        
        // ---------------------------------------------------------------------
        //  Load the current group dict from the array
        // ---------------------------------------------------------------------
        NSMutableDictionary *group = [_arrayProfileGroupAll[_tableViewProfileGroupAllSelectedRow] mutableCopy];
        DDLogDebug(@"Updating selected group: %@", group[@"Config"][PFCProfileGroupKeyName] ?: @"");
        [self setSelectedGroup:[group copy]];
        
        // ---------------------------------------------------------------------
        //  Load all current profiles
        // ---------------------------------------------------------------------
        NSArray *profiles = [[PFCProfileUtility sharedUtility] profiles] ?: @[];
        
        // ------------------------------------------------------------------------------------------
        //
        // ------------------------------------------------------------------------------------------
        if ( 1 <= [profiles count] ) {
            [_arrayProfileLibrary addObjectsFromArray:profiles];
            if ( [_selectedProfileUUID length] != 0 ) {
                NSUInteger index = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:_selectedProfileUUID];
                }];
                
                if ( index != NSNotFound ) {
                    rowIndexes = [NSIndexSet indexSetWithIndex:index];
                }
            } else if ( 1 < [_tableViewProfileLibrarySelectedRows count] ) {
                rowIndexes = _tableViewProfileLibrarySelectedRows;
            }
        } else {
            if ( [_selectedProfileUUID length] == 0 && _profilePreviewSelectionUnavailableHidden ) {
                [self showProfilePreviewNoSelection];
            }
        }
    } else {
        DDLogError(@"Profile group all selection is -1, this should not happen");
    }
    
    [_tableViewProfileLibrary reloadData];
    [_tableViewProfileLibrary endUpdates];
    
    if ( [rowIndexes count] ) {
        [_tableViewProfileLibrary selectRowIndexes:rowIndexes byExtendingSelection:NO];
    }
} // selectTableViewProfileGroupAllRow

- (IBAction)selectTableViewProfileGroups:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger selectedRow = [_tableViewProfileGroups selectedRow];
    if ( 0 <= selectedRow && selectedRow != _tableViewProfileGroupsSelectedRow ) {
        [self selectTableViewProfileGroupsRow:selectedRow];
    } else {
        [_tableViewProfileGroups selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    }
} // selectTableViewProfileGroups

- (void)selectTableViewProfileGroupsRow:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSIndexSet *rowIndexes = [NSIndexSet indexSet];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewProfileGroupAll deselectAll:self];
    [self setSelectedTableViewIdentifier:[_tableViewProfileGroups identifier]];
    [self setTableViewProfileGroupAllSelectedRow:-1];
    [self setTableViewProfileGroupsSelectedRow:row];
    
    [_tableViewProfileLibrary beginUpdates];
    [_arrayProfileLibrary removeAllObjects];
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewProfileGroupsSelectedRow && _tableViewProfileGroupsSelectedRow <= [_arrayProfileGroups count] ) {
        
        // ------------------------------------------------------------------------------------
        //  Update the SelectedTableViewIdentifier with the current TableView identifier
        // ------------------------------------------------------------------------------------
        [self setSelectedTableViewIdentifier:[_tableViewProfileGroups identifier]];
        DDLogDebug(@"Setting selected profile table view identifier: %@", _selectedTableViewIdentifier);
        
        // ---------------------------------------------------------------------
        //  Load the current group dict from the array
        // ---------------------------------------------------------------------
        NSMutableDictionary *group = [_arrayProfileGroups[_tableViewProfileGroupsSelectedRow] mutableCopy];
        [self setSelectedGroup:[group copy]];
        
        // ---------------------------------------------------------------------
        //  Load the current group profile array from the selected group dict
        // ---------------------------------------------------------------------
        NSArray *groupProfileUUIDArray = group[@"Config"][PFCProfileGroupKeyProfiles] ?: @[];
        
        // ------------------------------------------------------------------------------------------
        //
        // ------------------------------------------------------------------------------------------
        if ( 1 <= [groupProfileUUIDArray count] ) {
            [_arrayProfileLibrary addObjectsFromArray:groupProfileUUIDArray];
            
            if ( [_selectedProfileUUID length] != 0 ) {
                NSUInteger index = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:_selectedProfileUUID];
                }];
                
                if ( index != NSNotFound ) {
                    rowIndexes = [NSIndexSet indexSetWithIndex:index];
                }
            } else if ( 1 < [_tableViewProfileLibrarySelectedRows count] ) {
                rowIndexes = _tableViewProfileLibrarySelectedRows;
            }
        } else {
            if ( [_selectedProfileUUID length] == 0 ) {
                [self showProfilePreviewNoSelection];
            }
        }
    } else {
        DDLogError(@"Profile groups selection is -1, this should not happen");
    }
    
    [_tableViewProfileLibrary reloadData];
    [_tableViewProfileLibrary endUpdates];
    
    if ( [rowIndexes count] ) {
        [_tableViewProfileLibrary selectRowIndexes:rowIndexes byExtendingSelection:NO];
    }
} // selectTableViewProfileGroupsRow

- (IBAction) selectTableViewProfileSmartGroups:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger selectedRow = [_tableViewProfileSmartGroups selectedRow];
    if ( 0 <= selectedRow && selectedRow != _tableViewProfileSmartGroupsSelectedRow ) {
        [self selectTableViewProfileSmartGroupsRow:selectedRow];
    } else {
        [_tableViewProfileSmartGroups selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    }
} // selectTableViewProfileSmartGroups

- (void) selectTableViewProfileSmartGroupsRow:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
} // selectTableViewProfileSmartGroupsRow

- (IBAction) selectTableViewProfileLibrary:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSIndexSet *selectedRowIndexes = [_tableViewProfileLibrary selectedRowIndexes];
    DDLogDebug(@"Table view profile library selected rows: %@", selectedRowIndexes);
    
    if ( 1 < [selectedRowIndexes count] ) {
        
        // ---------------------------------------------------------------------
        //  Update the selection properties with the current value
        // ---------------------------------------------------------------------
        DDLogDebug(@"Updating table view profile library selected row");
        [self setTableViewProfileLibrarySelectedRows:selectedRowIndexes];
        
        // ---------------------------------------------------------------------
        //  Hide profile preview and show count of selected profiles
        // ---------------------------------------------------------------------
        [self showProfilePreviewMultipleSelections:@([selectedRowIndexes count])];
        
        // ---------------------------------------------------------------------
        //  Unset the SelectedProfileUUID
        // ---------------------------------------------------------------------
        [self setSelectedProfileUUID:nil];
        
    } else if ( selectedRowIndexes != _tableViewProfileLibrarySelectedRows ) {
        
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
        
        if ( selectedRow != NSNotFound ) {
            
            // -----------------------------------------------------------------
            //  Call method to change profile selection (and preview)
            // -----------------------------------------------------------------
            [self selectTableViewProfileLibraryRow:selectedRow];
        } else {
            
            // -----------------------------------------------------------------
            //  Hide profile preview and show no selection
            // -----------------------------------------------------------------
            [self showProfilePreviewNoSelection];
            
            // -----------------------------------------------------------------
            //  Unset the SelectedProfileUUID
            // -----------------------------------------------------------------
            DDLogDebug(@"Removing selected profile uuid");
            [self setSelectedProfileUUID:nil];
        }
    }
} // selectTableViewProfileLibrary

- (void) selectTableViewProfileLibraryRow:(NSInteger)row {
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( [_tableViewProfileLibrarySelectedRows firstIndex] != NSNotFound && [_tableViewProfileLibrarySelectedRows firstIndex] <= [_arrayProfileLibrary count] ) {
        
        // ---------------------------------------------------------------------
        //  Load the current profile from the array
        // ---------------------------------------------------------------------
        NSDictionary *profileDict = _arrayProfileLibrary[row] ?: @{};
        
        // ---------------------------------------------------------------------
        //  Verify the profile has any content
        // ---------------------------------------------------------------------
        if ( [profileDict count] == 0 ) {
            if ( _profilePreviewSelectionUnavailableHidden ) {
                [self showProfilePreviewError];
            }
            return;
        }
        
        // --------------------------------------------------------------------------
        //  Store the currently selected uuid in local variable _selectedProfileUUID
        // --------------------------------------------------------------------------
        NSString *profileUUID = profileDict[@"Config"][PFCProfileTemplateKeyUUID] ?: @"";
        DDLogDebug(@"Selected profile UUID: %@", profileUUID);
        
        if ( [profileUUID length] == 0 ) {
            if ( _profilePreviewSelectionUnavailableHidden ) {
                [self showProfilePreviewError];
            }
            return;
        }
        [self setSelectedProfileUUID:profileUUID];
        
        // ---------------------------------------------------------------------
        //  Populate the preview view with the selected profile
        // ---------------------------------------------------------------------
        [self updatePreviewWithProfileDict:profileDict];
        
        // ---------------------------------------------------------------------
        //  Show selected profile preview (of not already visible)
        // ---------------------------------------------------------------------
        if ( _profilePreviewHidden ) {
            [self showProfilePreview];
        }
    } else {
        
        // ---------------------------------------------------------------------
        //  Unset the SelectedProfileUUID
        // ---------------------------------------------------------------------
        DDLogDebug(@"Removing selected profile UUID");
        [self setSelectedProfileUUID:nil];
    }
}

- (IBAction)buttonProfileExport:(id)sender {
    
}

- (IBAction)buttonProfileEdit:(id)sender {
    
    if ( [_selectedProfileUUID length] != 0 ) {
        
    }
}

@end
