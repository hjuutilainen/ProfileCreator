//
//  PFCMainWindowController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-02.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindowController.h"
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCTableViewIdentifierProfileLibrary = @"TableViewIdentifierProfileLibrary";
NSString *const PFCTableViewIdentifierProfileGroups = @"TableViewIdentifierProfileGroups";
NSString *const PFCTableViewIdentifierProfileGroupAll = @"TableViewIdentifierProfileGroupAll";
int const PFCTableViewGroupsRowHeight = 24;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////
@implementation PFCMainWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    self = [super initWithWindowNibName:@"PFCMainWindowController"];
    if (self != nil) {
        
        // ---------------------------------------------------------------------
        //  Initialize Arrays
        // ---------------------------------------------------------------------
        _arrayProfileLibrary = [[NSMutableArray alloc] init];
        _arrayProfileGroups = [[NSMutableArray alloc] init];
        _arrayProfileGroupAll = [[NSMutableArray alloc] init];
        _arrayProfileDicts = [[NSMutableArray alloc] init];
        
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
    [self setTableViewProfileLibrarySelectedRow:-1];
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
    //  Add all saved profile UUIDs to group's "Profiles" array
    // -------------------------------------------------------------------------
    NSMutableArray *profiles = [[NSMutableArray alloc] init];
    [[[PFCProfileUtility sharedUtility] savedProfiles] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [profiles addObject:dict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""];
    }];
    
    // -------------------------------------------------------------------------
    //  Remove all empty objects
    // -------------------------------------------------------------------------
    [profiles removeObject:@""];
    
    // -------------------------------------------------------------------------
    //  Add the only item "All Profiles" to table view.
    // -------------------------------------------------------------------------
    [_arrayProfileGroupAll addObject:@{ @"Config" : @{ PFCProfileGroupKeyName : @"All Profiles",
                                                       PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString],
                                                       PFCProfileGroupKeyProfiles : [profiles copy] ?: @[]}}];
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
        
        CellViewProfile *cellView = [tableView makeViewWithIdentifier:@"CellViewProfile" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfile:cellView profileDict:_arrayProfileLibrary[(NSUInteger)row] row:row];
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
    
    NSDictionary *profileSettings = profileDict[@"Config"];
    
    NSString *profileName = profileSettings[PFCProfileTemplateKeyName];
    [_textFieldPreviewProfileName setStringValue:profileName ?: @""];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showProfilePreview {
    [_viewPreviewSuperview setHidden:NO];
    [self setProfilePreviewHidden:NO];
    
    [_viewPreviewSelectionUnavailable setHidden:YES];
    [_textFieldPreviewSelectionUnavailable setStringValue:@""];
    [self setProfilePreviewSelectionUnavailableHidden:YES];
} // showProfilePreview

- (void)showProfilePreviewError {
    [_textFieldPreviewSelectionUnavailable setStringValue:@"Error Reading Selected Profile"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
} // showProfilePreviewError

- (void)showProfilePreviewNoSelection {
    [_textFieldPreviewSelectionUnavailable setStringValue:@"No Profile Selected"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
} // showProfilePreviewNoSelection

- (void)showProfilePreviewMultipleSelections:(NSNumber *)count {
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
        
        // ---------------------------------------------------------------------
        //  Sanity check that selection and array is reasonable
        // ---------------------------------------------------------------------
        if ( 0 <= selectedRow && selectedRow <= [_arrayProfileLibrary count] ) {
            NSMutableDictionary *profileDict = [_arrayProfileLibrary[selectedRow] mutableCopy];
            
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
                    [_arrayProfileLibrary replaceObjectAtIndex:selectedRow withObject:[profileDict copy]];
                } else {
                    DDLogError(@"Instantiating profile editor failed");
                }
            }
            [[editor window] makeKeyAndOrderFront:self];
        }
    }
} // editSelectedProfile

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
}

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
            NSInteger index = [_arrayProfileGroupAll indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:groupUUID];
            }];
            DDLogDebug(@"Group index: %ld", (long)index);
            
            if ( index != NSNotFound ) {
                [_tableViewProfileGroupAll beginUpdates];
                [_arrayProfileGroupAll removeObjectAtIndex:index];
                [_tableViewProfileGroupAll reloadData];
                [_tableViewProfileGroupAll endUpdates];
                //[self setTableViewHeight:PFCTableViewGroupsRowHeight*(int)[_arrayProfileGroupAll count] tableView:_scrollViewProfileGroups];
            }
        }
        default:
            break;
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
    
    NSUInteger index = NSNotFound;
    
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
        DDLogDebug(@"Setting selected profile table view identifier: %@", _selectedTableViewIdentifier);
        
        // ------------------------------------------------------------------------------------
        //  Load the current group dict from the array
        // ------------------------------------------------------------------------------------
        NSMutableDictionary *group = [_arrayProfileGroupAll[_tableViewProfileGroupAllSelectedRow] mutableCopy];
        [self setSelectedGroup:[group copy]];
        
        // ---------------------------------------------------------------------
        //  Load the current group profile array from the selected group dict
        // ---------------------------------------------------------------------
        NSArray *groupProfileUUIDArray = group[@"Config"][PFCProfileGroupKeyProfiles] ?: @[];
        NSArray *groupProfiles = [[PFCProfileUtility sharedUtility] profileDictsFromUUIDs:groupProfileUUIDArray];
        
        // ------------------------------------------------------------------------------------------
        //
        // ------------------------------------------------------------------------------------------
        if ( 1 <= [groupProfiles count] ) {
            [_arrayProfileLibrary addObjectsFromArray:groupProfiles];
            
            if ( [_selectedProfileUUID length] != 0 ) {
                index = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:_selectedProfileUUID];
                }];
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
    
    if ( index != NSNotFound ) {
        [_tableViewProfileLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
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
    
    NSUInteger index = NSNotFound;
    
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
        NSArray *groupProfiles = [[PFCProfileUtility sharedUtility] profileDictsFromUUIDs:groupProfileUUIDArray];
        
        // ------------------------------------------------------------------------------------------
        //
        // ------------------------------------------------------------------------------------------
        if ( 1 <= [groupProfiles count] ) {
            [_arrayProfileLibrary addObjectsFromArray:groupProfiles];
            
            if ( [_selectedProfileUUID length] != 0 ) {
                index = [_arrayProfileLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:_selectedProfileUUID];
                }];
            }
        } else {
            if ( [_selectedProfileUUID length] == 0 && _profilePreviewSelectionUnavailableHidden ) {
                [self showProfilePreviewNoSelection];
            }
        }
    } else {
        DDLogError(@"Profile groups selection is -1, this should not happen");
    }
    
    [_tableViewProfileLibrary reloadData];
    [_tableViewProfileLibrary endUpdates];
    
    if ( index != NSNotFound ) {
        [_tableViewProfileLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }
} // selectTableViewProfileGroupsRow

- (IBAction)selectTableViewProfileLibrary:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger selectedRow = [_tableViewProfileLibrary selectedRow];
    
    if ( selectedRow != _tableViewProfileLibrarySelectedRow ) {
        
        // -------------------------------------------------------------------------
        //  Update the selection properties with the current value
        // -------------------------------------------------------------------------
        [self setTableViewProfileLibrarySelectedRow:selectedRow];
        
        if ( 0 <= selectedRow ) {
            [self selectTableViewProfileLibraryRow:selectedRow];
        } else {
            if ( _profilePreviewSelectionUnavailableHidden ) {
                [self showProfilePreviewNoSelection];
            }
            
            // ---------------------------------------------------------------------
            //  Unset the SelectedProfileUUID
            // ---------------------------------------------------------------------
            [self setSelectedProfileUUID:nil];
        }
    }
} // selectTableViewProfileLibrary

- (void)selectTableViewProfileLibraryRow:(NSInteger)row {
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewProfileLibrarySelectedRow && _tableViewProfileLibrarySelectedRow <= [_arrayProfileLibrary count] ) {
        
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
        [self setSelectedProfileUUID:nil];
    }
}

@end
