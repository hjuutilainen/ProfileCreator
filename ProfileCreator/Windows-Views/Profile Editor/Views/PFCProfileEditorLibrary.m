//
//  PFCProfileEditorLibrary.m
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

#import "PFCAvailability.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestParser.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorLibrary.h"
#import "PFCStatusView.h"
#import "PFCTableViewCellsMenu.h"
#import "RFOverlayScrollView.h"

@interface PFCProfileEditorLibrary ()

@property (nonatomic, weak) PFCProfileEditor *profileEditor;

@property PFCPayloadLibrary selectedLibrary;

@property PFCStatusView *viewStatusLibrary;

@property NSString *selectedIdentifier;

@property NSDictionary *selectedManifest;

@property NSMutableArray *arrayProfile;
@property NSMutableArray *arrayLibrary;
@property NSMutableArray *arrayLibraryApple;
@property NSMutableArray *arrayLibraryUserPreferences;
@property NSMutableArray *arrayLibraryCustom;
@property NSMutableArray *arrayLibraryMCX;

// -------------------------------------------------------------------------
//  Payload Context Menu
// -------------------------------------------------------------------------
@property (readwrite) NSString *clickedPayloadTableViewIdentifier;
@property (readwrite) NSInteger clickedPayloadTableViewRow;
- (IBAction)menuItemShowInFinder:(id)sender;

// SEARCH VIEW

@property (strong) IBOutlet NSLayoutConstraint *constraintSeachFieldLibraryLeading;

// Searching
@property BOOL isSearchingLibraryApple;
@property BOOL isSearchingLibraryUserPreferences;
@property BOOL isSearchingLibraryCustom;
@property BOOL isSearchingLibraryMCX;

@property (readwrite) NSString *searchStringLibraryApple;
@property (readwrite) NSString *searchStringLibraryUserPreferences;
@property (readwrite) NSString *searchStringLibraryCustom;
@property (readwrite) NSString *searchStringLibraryMCX;

@property (weak) IBOutlet NSSearchField *searchFieldLibrary;
- (IBAction)searchFieldLibrary:(id)sender;

// Button Library Add
@property (weak) IBOutlet NSMenu *menuButtonLibraryAdd;
@property (weak) IBOutlet NSButton *buttonLibraryAdd;
- (IBAction)buttonLibraryAdd:(id)sender;

@end

@implementation PFCProfileEditorLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark init/dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileEditor:(PFCProfileEditor *)profileEditor {
    self = [super initWithNibName:@"PFCProfileEditorLibrary" bundle:nil];
    if (self != nil) {
        _profileEditor = profileEditor;

        _arrayProfile = [[NSMutableArray alloc] init];
        _arrayLibrary = [[NSMutableArray alloc] init];
        _arrayLibraryApple = [[NSMutableArray alloc] init];
        _arrayLibraryCustom = [[NSMutableArray alloc] init];
        _arrayLibraryMCX = [[NSMutableArray alloc] init];
        _arrayLibraryUserPreferences = [[NSMutableArray alloc] init];

        _libraryMenu = [[PFCProfileEditorLibraryMenu alloc] initWithProfileEditorLibrary:self];

        _viewStatusLibrary = [[PFCStatusView alloc] init];

        _selectedLibrary = kPFCPayloadLibraryApple;

        [self view];
    }
    return self;
} // initWithProfileEditor

- (void)dealloc {
    if (_tableViewLibrary) {
        [_tableViewLibrary setDelegate:nil];
    }
} // dealloc

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewSetup];
} // viewDidLoad

- (void)viewSetup {
    [PFCGeneralUtility insertSubview:[_libraryMenu view] inSuperview:_viewLibraryMenu hidden:NO];
    [PFCGeneralUtility insertSubview:[_viewStatusLibrary view] inSuperview:[self view] hidden:YES];

    [_tableViewProfile setDelegate:self];
    [_tableViewLibrary setDelegate:self];

    [self updateManifests];
} // viewSetup

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([[tableView identifier] isEqualToString:@"Profile"]) {
        return [_arrayProfile count];
    } else if ([[tableView identifier] isEqualToString:@"Library"]) {
        return [_arrayLibrary count];
    }
    return 0;
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableView identifier] isEqualToString:@"Profile"]) {
        if ([_arrayProfile count] <= row || [_arrayProfile count] == 0) {
            return nil;
        }

        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _arrayProfile[(NSUInteger)row];

        if ([tableColumnIdentifier isEqualToString:@"ColumnMenu"] && [manifestDict[PFCManifestKeyCellType] ?: @"" isEqualToString:PFCCellTypeMenu]) {
            CellViewMenu *cellView = [tableView makeViewWithIdentifier:@"CellViewMenu" owner:self];
            [cellView setIdentifier:nil];
            return [cellView populateCellViewMenu:cellView
                                     manifestDict:manifestDict
                                       errorCount:@([[_profileEditor manifest] errorForManifest:manifestDict updateTabBar:NO])
                                     payloadCount:@([[_profileEditor profileSettings][manifestDict[PFCManifestKeyDomain]][@"Settings"] ?: @[ @{} ] count])
                                              row:row];
        } else if ([tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"]) {
            CellViewMenuEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView manifestDict:manifestDict row:row sender:self];
        }

    } else if ([[tableView identifier] isEqualToString:@"Library"]) {
        if ([_arrayLibrary count] <= row || [_arrayLibrary count] == 0) {
            return nil;
        }

        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _arrayLibrary[(NSUInteger)row];
        if ([tableColumnIdentifier isEqualToString:@"ColumnMenu"] && [manifestDict[PFCManifestKeyCellType] ?: @"" isEqualToString:PFCCellTypeMenu]) {
            CellViewMenuLibrary *cellView = [_tableViewLibrary makeViewWithIdentifier:@"CellViewMenuLibrary" owner:self];
            [cellView setIdentifier:nil];
            return [cellView populateCellViewMenuLibrary:cellView manifestDict:manifestDict errorCount:nil row:row];
        } else if ([tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"]) {
            CellViewMenuEnabled *cellView = [_tableViewLibrary makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView manifestDict:manifestDict row:row sender:self];
        }
    }
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    // FIXME - Don't remember why I added this
    if (tableView == _tableViewProfile) {
        if (row < [_arrayProfile count]) {
            [self selectManifest:_arrayProfile[row]];
        }
    } else if (tableView == _tableViewLibrary) {
        if (row < [_arrayLibrary count]) {
            [self selectManifest:_arrayLibrary[row]];
        }
    }
    return YES;
}

- (void)checkboxMenuEnabled:(NSButton *)checkbox {

    // -------------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if (buttonTag == nil) {
        DDLogError(@"Checkbox: %@ has no tag", checkbox);
        return;
    }
    NSUInteger row = [buttonTag integerValue];

    if ([[[checkbox superview] class] isSubclassOfClass:[CellViewMenuEnabled class]]) {

        // ---------------------------------------------------------------------
        //  Check if checkbox is in table view profile
        // ---------------------------------------------------------------------
        if ((row < [_arrayProfile count]) &&
            checkbox == [(CellViewMenuEnabled *)[_tableViewProfile viewAtColumn:[_tableViewProfile columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox]) {

            // -----------------------------------------------------------------
            //  Store the cell dict for move
            // -----------------------------------------------------------------
            NSDictionary *manifestDict = _arrayProfile[row];
            NSString *manifestDomain = manifestDict[PFCManifestKeyDomain];
            DDLogInfo(@"Removing manifest with domain: %@ from table view profile", manifestDomain);

            NSInteger tableViewPayloadProfileSelectedRow = [_tableViewProfile selectedRow];
            DDLogDebug(@"Table view profile selected row: %ld", (long)tableViewPayloadProfileSelectedRow);

            NSMutableDictionary *manifestSettings = [_profileEditor profileSettings][manifestDomain];
            DDLogVerbose(@"Clicked manifest settings: %@", manifestSettings);

            // -------------------------------------------------------------------------------------------
            //  Sanity check, any manifest in table view profile should have setting key "PayloadLibrary"
            // -------------------------------------------------------------------------------------------
            NSInteger payloadLibrary;
            if (manifestSettings[PFCSettingsKeyPayloadLibrary] != nil) {
                payloadLibrary = [manifestSettings[PFCSettingsKeyPayloadLibrary] integerValue];
            } else {
                DDLogError(@"Manifest settings is missing required information about originating library");
                payloadLibrary = 2;
            }
            DDLogDebug(@"Clicked manifest payload library: %ld", (long)payloadLibrary);

            // -----------------------------------------------------------------
            //  Remove the cell dict from table view profile
            // -----------------------------------------------------------------
            [_tableViewProfile beginUpdates];
            [_arrayProfile removeObjectAtIndex:(NSUInteger)row];
            [_tableViewProfile reloadData];
            [_tableViewProfile endUpdates];

            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if (0 <= tableViewPayloadProfileSelectedRow && tableViewPayloadProfileSelectedRow != row) {
                DDLogDebug(@"Current selection was not clicked. Restoring selection to table view profile.");

                NSInteger selectedRow = (row < tableViewPayloadProfileSelectedRow) ? (tableViewPayloadProfileSelectedRow - 1) : tableViewPayloadProfileSelectedRow;
                DDLogDebug(@"Table view profile new selected row: %ld", (long)selectedRow);

                [_tableViewProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)selectedRow] byExtendingSelection:NO];
                //[self setTableViewPayloadProfileSelectedRow:selectedRow];
            }

            // -----------------------------------------------------------------
            //  Add the cell dict to table view payload library
            // -----------------------------------------------------------------
            NSInteger tableViewPayloadLibrarySelectedRow = [_tableViewLibrary selectedRow];
            DDLogDebug(@"Table view payload library selected row: %ld", (long)tableViewPayloadLibrarySelectedRow);

            NSDictionary *tableViewPayloadLibrarySelectedManifest;
            if (0 <= tableViewPayloadLibrarySelectedRow) {
                tableViewPayloadLibrarySelectedManifest = _arrayLibrary[(NSUInteger)tableViewPayloadLibrarySelectedRow];
                DDLogDebug(@"Table view payload library selected domain: %@", tableViewPayloadLibrarySelectedManifest[PFCManifestKeyDomain]);
            }

            NSMutableArray *arrayPayloadLibrarySource;
            if (payloadLibrary == _selectedLibrary) {
                [_tableViewLibrary beginUpdates];
                [_arrayLibrary addObject:manifestDict];
                [_arrayLibrary sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];
                [_tableViewLibrary reloadData];
                [_tableViewLibrary endUpdates];
            } else {
                /*
                 arrayPayloadLibrarySource = [self arrayForPayloadLibrary:payloadLibrary];
                 [arrayPayloadLibrarySource addObject:manifestDict];
                 [arrayPayloadLibrarySource sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];
                 [self saveArray:arrayPayloadLibrarySource forPayloadLibrary:payloadLibrary];
                 */
            }

            // -----------------------------------------------------------------------------
            //  If item in table view payload library was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if (0 <= tableViewPayloadLibrarySelectedRow && tableViewPayloadProfileSelectedRow != row) {
                DDLogDebug(@"Current selection was not clicked. Restoring selection to table view payload library.");

                // -------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // -------------------------------------------------------------
                NSUInteger newRow = [_arrayLibrary indexOfObject:tableViewPayloadLibrarySelectedManifest];
                DDLogDebug(@"Table view payload library new selected row: %ld", (long)newRow);

                if (newRow != NSNotFound) {
                    [_tableViewLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
                    [[_profileEditor window] makeFirstResponder:_tableViewLibrary]; // FIXME - This might not work
                    //[self setTableViewPayloadLibrarySelectedRow:newRow];
                    //[self setTableViewPayloadLibrarySelectedRowSegment:_selectedLibrary];
                    //[self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
                } else {
                    DDLogError(@"Could not find row for moved manifest in table view payload library");
                }
            }

            // -----------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view payload library
            // -----------------------------------------------------------------------------
            if (tableViewPayloadProfileSelectedRow == row && payloadLibrary == _selectedLibrary) {
                DDLogDebug(@"Current selection was clicked. Moving selection to table view payload library");

                // -------------------------------------------------------------
                //  Deselect items in table view profile
                // -------------------------------------------------------------
                [_tableViewProfile deselectAll:self];
                //[self setTableViewPayloadProfileSelectedRow:-1];

                // -------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // -------------------------------------------------------------
                NSUInteger newRow = [_arrayLibrary indexOfObject:manifestDict];
                DDLogDebug(@"Table view payload library new selected row: %ld", (long)newRow);

                if (newRow != NSNotFound) {
                    [_tableViewLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    [[_profileEditor window] makeFirstResponder:_tableViewLibrary]; // FIXME - This might not work
                    //[self setTableViewPayloadLibrarySelectedRow:newRow];
                    //[self setTableViewPayloadLibrarySelectedRowSegment:_selectedLibrary];
                    //[self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
                } else {
                    DDLogError(@"Could not find row for moved manifest in table view payload library");
                }

            } else if (tableViewPayloadProfileSelectedRow == row && payloadLibrary != _selectedLibrary) {
                DDLogDebug(@"Current selection was clicked but manifest's payload library is not selected. Moving selection to table view payload library.");

                NSUInteger newRow = [arrayPayloadLibrarySource indexOfObject:manifestDict];
                DDLogDebug(@"Table view payload library new selected row: %ld", (long)newRow);

                if (newRow != NSNotFound) {
                    //[self setSelectedPayloadTableViewIdentifier:[_tableViewLibrary identifier]];
                    //[self setTableViewPayloadLibrarySelectedRow:newRow];
                    //[self setTableViewPayloadLibrarySelectedRowSegment:payloadLibrary];
                } else {
                    DDLogError(@"Could not find row for moved manifest in table view payload library");
                }
            }

            NSMutableDictionary *settingsManifestRoot = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            [settingsManifestRoot removeObjectForKey:@"Selected"];
            [settingsManifestRoot removeObjectForKey:@"PayloadLibrary"];
            [_profileEditor profileSettings][manifestDomain] = [settingsManifestRoot mutableCopy];

            // -----------------------------------------------------------------
            //  Check if checkbox is in table view payload library
            // -----------------------------------------------------------------
        } else if ((row < [_arrayLibrary count]) &&
                   checkbox == [(CellViewMenuEnabled *)[_tableViewLibrary viewAtColumn:[_tableViewLibrary columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox]) {

            // -----------------------------------------------------------------
            //  Store the cell dict for move
            // -----------------------------------------------------------------
            NSDictionary *manifest = _arrayLibrary[row];
            DDLogVerbose(@"Clicked manifest: %@", manifest);

            NSString *manifestDomain = manifest[PFCManifestKeyDomain];
            DDLogInfo(@"Adding manifest with domain: %@ to profile", manifestDomain);

            // -----------------------------------------------------------------
            //  Remove the cell dict from table view payload library
            // -----------------------------------------------------------------
            NSInteger tableViewPayloadLibrarySelectedRow = [_tableViewLibrary selectedRow];
            DDLogDebug(@"Table view payload library selected row: %ld", (long)tableViewPayloadLibrarySelectedRow);

            [_tableViewLibrary beginUpdates];
            [_arrayLibrary removeObjectAtIndex:(NSUInteger)row];
            [_tableViewLibrary reloadData];
            [_tableViewLibrary endUpdates];

            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if (0 <= tableViewPayloadLibrarySelectedRow && tableViewPayloadLibrarySelectedRow != row) {
                DDLogDebug(@"Current selection was not clicked. Restoring selection to table view payload library.");

                NSInteger selectedRow = (row < tableViewPayloadLibrarySelectedRow) ? (tableViewPayloadLibrarySelectedRow - 1) : tableViewPayloadLibrarySelectedRow;
                DDLogDebug(@"Table view payload library new selected row: %ld", (long)selectedRow);

                [_tableViewLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
                //[self setTableViewPayloadLibrarySelectedRow:selectedRow];
            }

            // -----------------------------------------------------------------
            //  Add the cell dict to table view profile
            // -----------------------------------------------------------------
            NSInteger tableViewPayloadProfileSelectedRow = [_tableViewProfile selectedRow];
            DDLogDebug(@"Table view profile selected row: %ld", (long)tableViewPayloadProfileSelectedRow);

            NSDictionary *tableViewPayloadProfileSelectedManifest;
            if (0 <= tableViewPayloadProfileSelectedRow) {
                tableViewPayloadProfileSelectedManifest = _arrayProfile[tableViewPayloadProfileSelectedRow];
                DDLogDebug(@"Table view profile selected domain: %@", tableViewPayloadProfileSelectedManifest[PFCManifestKeyDomain]);
            }

            [_tableViewProfile beginUpdates];
            [_arrayProfile addObject:manifest];
            [_tableViewProfile reloadData];
            [_tableViewProfile endUpdates];

            // -----------------------------------------------------------------------------
            //  If item in table view profile was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if (0 <= tableViewPayloadProfileSelectedRow && tableViewPayloadLibrarySelectedRow != row) {
                DDLogDebug(@"Current selection was not clicked. Restoring selection to table view profile.");

                // -------------------------------------------------------------
                //  Find index of current selection select it
                // -------------------------------------------------------------
                NSUInteger newRow = [_arrayProfile indexOfObject:tableViewPayloadProfileSelectedManifest];
                DDLogDebug(@"Table view profile new selected row: %ld", (long)newRow);

                if (newRow != NSNotFound) {
                    [_tableViewProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
                    [[_profileEditor window] makeFirstResponder:_tableViewProfile]; // FIXME - This might not work
                    //[self setTableViewPayloadProfileSelectedRow:newRow];
                    //[self setSelectedPayloadTableViewIdentifier:[_tableViewProfile identifier]];
                } else {
                    DDLogError(@"Could not find row for moved manifest in table view profile");
                }
            }

            // -------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view profile
            // -------------------------------------------------------------------------
            if (tableViewPayloadLibrarySelectedRow == row) {
                DDLogDebug(@"Current selection was clicked. Moving selection to table view payload library");

                // -------------------------------------------------------------
                //  Deselect items in table view payload library
                // -------------------------------------------------------------
                [_tableViewLibrary deselectAll:self];
                //[self setTableViewPayloadLibrarySelectedRow:-1];

                // -------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // -------------------------------------------------------------
                NSUInteger newRow = [_arrayProfile indexOfObject:manifest];
                DDLogDebug(@"Table view profile new selected row: %ld", (long)newRow);

                if (newRow != NSNotFound) {
                    [_tableViewProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
                    [[_profileEditor window] makeFirstResponder:_tableViewProfile]; // FIXME - This might not work
                    //[self setTableViewPayloadProfileSelectedRow:newRow];
                    //[self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadProfile identifier]];
                } else {
                    DDLogError(@"Could not find row for moved manifest in table view profile");
                }
            }

            NSMutableDictionary *settingsManifestRoot = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            settingsManifestRoot[@"Selected"] = @YES;
            settingsManifestRoot[@"PayloadLibrary"] = @(_selectedLibrary);
            [_profileEditor profileSettings][manifestDomain] = [settingsManifestRoot mutableCopy];
            DDLogVerbose(@"Updated settings for clicked manifest: %@", settingsManifestRoot);

            // -----------------------------------------------------------------
            //  Update errors for manifest
            // -----------------------------------------------------------------
            [[_profileEditor manifest] errorForManifest:manifest updateTabBar:YES];
            [self reloadManifest:manifest];
        }
    } else {
        DDLogError(@"Checkbox superview class is not CellViewMenuEnabled: %@", [[checkbox superview] class]);
    }

    if ([_arrayLibrary count] == 0) {
        [self showLibraryNoManifests];
    } else {
        [self hideLibraryStatus];
    }
} // checkboxMenuEnabled

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Selection Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)selectManifest:(id)sender {

    if (![sender isKindOfClass:[NSTableView class]]) {
        DDLogError(@"Class %@ is not allowed to select manifest!", [sender class]);
        return;
    }

    NSInteger selectedRow = [sender selectedRow];
    DDLogDebug(@"Selected row: %ld", selectedRow);

    if (sender == _tableViewLibrary) {
        if (0 <= selectedRow && selectedRow < [_arrayLibrary count]) {
            [self setSelectedManifest:[_arrayLibrary objectAtIndex:selectedRow]];
        } else {
            return;
        }
    } else if (sender == _tableViewProfile) {
        if (0 <= selectedRow && selectedRow < [_arrayProfile count]) {
            [self setSelectedManifest:[_arrayProfile objectAtIndex:selectedRow]];
        } else {
            return;
        }
    } else {
        DDLogError(@"Unknown table view: %@", sender);
        return;
    }

    [[_profileEditor manifest] selectManifest:_selectedManifest inTableView:[sender identifier]];
}

- (void)selectLibrary:(PFCPayloadLibrary)library {

    // ------------------------------------------------------------------------
    //  If the payload library is collapsed, open it
    // ------------------------------------------------------------------------
    if ([_profileEditor librarySplitViewCollapsed]) {
        [_profileEditor uncollapseLibrary];
    }

    // -------------------------------------------------------------------------
    //  If the selected library already is selected, stop here
    // -------------------------------------------------------------------------
    if (_selectedLibrary == library) {
        return;
    }

    // --------------------------------------------------------------------------
    //  If the selected library can add items, show button add, else hide button
    // --------------------------------------------------------------------------
    if (library == kPFCPayloadLibraryCustom && [_buttonLibraryAdd isHidden]) {
        [self showButtonLibraryAdd];
    } else if (library != kPFCPayloadLibraryCustom && ![_buttonLibraryAdd isHidden]) {
        [self hideButtonLibraryAdd];
    }

    // --------------------------------------------------------------------------------------------
    //  If a search is NOT active in the previous selected library, save the previous library array
    //  ( If a search IS active, the previous library array was saved when the search was started )
    // --------------------------------------------------------------------------------------------
    if (![self isSearchingLibrary:_selectedLibrary]) {
        [self setArray:_arrayLibrary forLibrary:_selectedLibrary];
    }

    // -------------------------------------------------------------------------
    //  Update selected library
    // -------------------------------------------------------------------------
    [self setSelectedLibrary:library];

    // --------------------------------------------------------------------------------------------------
    //  If a search is saved in the selected library, restore that search when loading the library array
    //  If a search is NOT saved, restore the whole library array instead
    // --------------------------------------------------------------------------------------------------
    if ([self isSearchingLibrary:library]) {
        [_searchFieldLibrary setStringValue:[self searchStringForLibrary:library] ?: @""];
        [self searchFieldLibrary:nil];
    } else {
        [self hideLibraryStatus];
        [_searchFieldLibrary setStringValue:@""];
        [_tableViewLibrary beginUpdates];
        [_arrayLibrary removeAllObjects];
        [self setArrayLibrary:[self arrayForLibrary:library]];
        [_tableViewLibrary reloadData];
        [_tableViewLibrary endUpdates];
    }

    // --------------------------------------------------------------------------------------------------------
    //  If the currently selected manifest is in the selected library, restore that selection in the TableView
    // --------------------------------------------------------------------------------------------------------
    NSUInteger index = [_arrayLibrary indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull manifest, NSUInteger idx, BOOL *_Nonnull stop) {
      return [manifest isEqualToDictionary:_selectedManifest];
    }];

    if (index != NSNotFound) {
        [_tableViewLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    }

    // -------------------------------------------------------------------------
    //  If the manifest library array is empty, show "No Manifests"
    // -------------------------------------------------------------------------
    if ([_arrayLibrary count] == 0) {
        [self showLibraryNoManifests];
    } else {
        [self hideLibraryStatus];
    }
} // selectPayloadLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Manifest Array Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)reloadManifest:(NSDictionary *)manifest {
    NSUInteger Index = [_arrayProfile indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [[item objectForKey:PFCManifestKeyDomain] isEqualToString:manifest[PFCManifestKeyDomain] ?: @""];
    }];

    if (Index != NSNotFound) {
        NSRange allColumns = NSMakeRange(0, [[_tableViewProfile tableColumns] count]);
        [_tableViewProfile reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:Index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:allColumns]];
    }
} // reloadManifest

- (NSArray *)enabledDomains {
    NSMutableArray *enabledDomains = [[NSMutableArray alloc] init];
    for (NSString *domain in [[_profileEditor profileSettings] allKeys]) {
        NSDictionary *settingsManifest = [_profileEditor profileSettings][domain];
        if ([settingsManifest[PFCSettingsKeySelected] boolValue]) {
            [enabledDomains addObject:domain];
        }
    }
    return [enabledDomains copy];
} // enabledDomains

- (void)updateManifests {
    NSArray *enabledDomains = [self enabledDomains];

    [_arrayProfile removeAllObjects];
    [self updateManifestLibraryApple:enabledDomains];
    [self updateManifestLibraryUserLibrary:enabledDomains];
    [self updateManifestLibraryMCX:enabledDomains];
    [self sortArrayProfile];

    [_tableViewProfile beginUpdates];
    [_tableViewProfile reloadData];
    [_tableViewProfile endUpdates];

    [_arrayLibrary removeAllObjects];
    [self setArrayLibrary:[self arrayForLibrary:_selectedLibrary]];
    [_arrayLibrary sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];

    [_tableViewLibrary beginUpdates];
    [_tableViewLibrary reloadData];
    [_tableViewLibrary endUpdates];
} // updateManifests

- (void)updateManifestLibraryApple:(NSArray *)enabledPayloadDomains {
    NSError *error = nil;
    [_arrayLibraryApple removeAllObjects];
    NSArray *libraryAppleManifests = [[PFCManifestLibrary sharedLibrary] libraryApple:&error acceptCached:YES];
    if ([libraryAppleManifests count] != 0) {
        for (NSDictionary *manifest in libraryAppleManifests) {
            if ([[PFCAvailability sharedInstance] showManifest:manifest displayKeys:[[_profileEditor settings] displayKeys]]) {
                NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
                if ([enabledPayloadDomains containsObject:manifestDomain] || [manifestDomain isEqualToString:@"com.apple.general"]) {
                    [_arrayProfile addObject:[manifest copy]];
                } else {
                    [_arrayLibraryApple addObject:[manifest copy]];
                }
            }
        }

        // ---------------------------------------------------------------------
        //  Sort array
        // ---------------------------------------------------------------------
        [_arrayLibraryApple sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];
    } else {
        DDLogError(@"No manifests returned for library Apple");
        DDLogError(@"%@", [error localizedDescription]);
    }
} // updateManifestLibraryApple

- (void)updateManifestLibraryUserLibrary:(NSArray *)enabledPayloadDomains {
    NSError *error = nil;
    [_arrayLibraryUserPreferences removeAllObjects];
    NSArray *libraryUserPreferencesManifests = [[PFCManifestLibrary sharedLibrary] libraryUserLibraryPreferencesLocal:&error acceptCached:YES];
    if ([libraryUserPreferencesManifests count] != 0) {
        for (NSDictionary *manifest in libraryUserPreferencesManifests) {
            NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
            if ([enabledPayloadDomains containsObject:manifestDomain]) {
                [_arrayProfile addObject:manifest];
            } else {
                [_arrayLibraryUserPreferences addObject:manifest];
            }
        }

        [_arrayLibraryUserPreferences sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];
    } else {
        DDLogError(@"No manifests returned for library user library preferences");
        DDLogError(@"%@", [error localizedDescription]);
    }
} // updateManifestLibraryUserLibrary

- (void)updateManifestLibraryMCX:(NSArray *)enabledPayloadDomains {
    NSError *error = nil;
    [_arrayLibraryMCX removeAllObjects];
    NSArray *libraryMCXManifests = [[PFCManifestLibrary sharedLibrary] libraryMCX:&error acceptCached:YES];
    if ([libraryMCXManifests count] != 0) {
        for (NSDictionary *manifest in libraryMCXManifests) {
            if ([[PFCAvailability sharedInstance] showManifest:manifest displayKeys:[[_profileEditor settings] displayKeys]]) {
                NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
                if ([enabledPayloadDomains containsObject:manifestDomain]) {
                    [_arrayProfile addObject:[manifest copy]];
                } else {
                    [_arrayLibraryMCX addObject:[manifest copy]];
                }
            }
        }

        [_arrayLibraryMCX sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];
    } else {
        DDLogError(@"No manifests returned for library mcx");
        DDLogError(@"%@", [error localizedDescription]);
    }
} // updateManifestLibraryMCX

- (void)sortArrayProfile {
    [_arrayProfile sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES] ]];

    // -------------------------------------------------------------------------------------------
    //  Find index of menu item com.apple.general and move it to the top of array payload profile
    // -------------------------------------------------------------------------------------------
    NSUInteger index = [_arrayProfile indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [[item objectForKey:PFCManifestKeyDomain] isEqualToString:@"com.apple.general"];
    }];

    if (index != NSNotFound) {
        NSDictionary *generalSettingsDict = _arrayProfile[index];
        [_arrayProfile removeObjectAtIndex:index];
        [_arrayProfile insertObject:generalSettingsDict atIndex:0];
    } else {
        DDLogError(@"No menu item with domain com.apple.general was found!");
    }
} // sortArrayProfile

- (NSMutableArray *)arrayForLibrary:(PFCPayloadLibrary)library {
    switch (library) {
    case kPFCPayloadLibraryApple:
        return [_arrayLibraryApple mutableCopy];
        break;
    case kPFCPayloadLibraryUserPreferences:
        return [_arrayLibraryUserPreferences mutableCopy];
        break;
    case kPFCPayloadLibraryCustom:
        return [_arrayLibraryCustom mutableCopy];
        break;
    case kPFCPayloadLibraryMCX:
        return [_arrayLibraryMCX mutableCopy];
        break;
    default:
        return nil;
        break;
    }
} // arrayForLibrary

- (void)setArray:(NSArray *)array forLibrary:(PFCPayloadLibrary)library {
    switch (library) {
    case kPFCPayloadLibraryApple:
        [self setArrayLibraryApple:[array mutableCopy]];
        break;
    case kPFCPayloadLibraryCustom:
        [self setArrayLibraryCustom:[array mutableCopy]];
        break;
    case kPFCPayloadLibraryLibraryPreferences:
        break;
    case kPFCPayloadLibraryMCX:
        [self setArrayLibraryMCX:[array mutableCopy]];
        break;
    case kPFCPayloadLibraryUserPreferences:
        [self setArrayLibraryUserPreferences:[array mutableCopy]];
        break;
    default:
        break;
    }
} // setArray:forLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonLibraryAdd:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Get the size of the button clicked
    // -------------------------------------------------------------------------
    NSRect frame = [(NSButton *)sender frame];

    // -------------------------------------------------------------------------
    //  Calculate where the menu will have it's origin (-5 pixels below button)
    // -------------------------------------------------------------------------
    NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y - 5) toView:nil];

    // -------------------------------------------------------------------------
    //  Create the event for popUpButton (NSLeftMouseDown)
    // -------------------------------------------------------------------------
    NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown
                                        location:menuOrigin
                                   modifierFlags:0
                                       timestamp:0
                                    windowNumber:[[(NSButton *)sender window] windowNumber]
                                         context:[[(NSButton *)sender window] graphicsContext]
                                     eventNumber:0
                                      clickCount:1
                                        pressure:1];

    // -------------------------------------------------------------------------
    //  Show context menu
    // -------------------------------------------------------------------------
    [NSMenu popUpContextMenu:_menuButtonLibraryAdd withEvent:event forView:(NSButton *)sender];
} // buttonLibraryAdd

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Context Menu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayForTableViewWithIdentifier:(NSString *)tableViewIdentifier {
    if ([tableViewIdentifier isEqualToString:@"Profile"]) {
        return [_arrayProfile copy];
    } else if ([tableViewIdentifier isEqualToString:@"Library"]) {
        return [_arrayLibrary copy];
    } else {
        return nil;
    }
} // arrayForTableViewWithIdentifier

- (void)validateMenu:(NSMenu *)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // ---------------------------------------------------------------------
    //  Store which TableView and row the user right clicked on.
    // ---------------------------------------------------------------------
    [self setClickedPayloadTableViewIdentifier:tableViewIdentifier];
    [self setClickedPayloadTableViewRow:row];
    NSArray *tableViewArray = [self arrayForTableViewWithIdentifier:tableViewIdentifier];

    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if (row < 0 || [tableViewArray count] < row) {
        menu = nil;
        return;
    }

    NSDictionary *manifestDict = [tableViewArray objectAtIndex:row];

    // -------------------------------------------------------------------------------
    //  MenuItem - "Show Source In Finder"
    //  Remove this menu item unless runtime key 'PlistPath' is set in the manifest
    // -------------------------------------------------------------------------------
    NSMenuItem *menuItemShowSourceInFinder = [menu itemWithTitle:@"Show Source In Finder"];
    if ([manifestDict[PFCRuntimeKeyPlistPath] length] != 0) {
        [menuItemShowSourceInFinder setEnabled:YES];
    } else {
        [menu removeItem:menuItemShowSourceInFinder];
    }
} // validateMenu:forTableViewWithIdentifier:row

- (IBAction)menuItemShowInFinder:(id)sender {
    NSArray *tableViewArray = [self arrayForTableViewWithIdentifier:_clickedPayloadTableViewIdentifier];

    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if (_clickedPayloadTableViewRow < 0 || [tableViewArray count] < _clickedPayloadTableViewRow) {
        return;
    }

    NSDictionary *manifestDict = [tableViewArray objectAtIndex:_clickedPayloadTableViewRow];

    // ----------------------------------------------------------------------------------------
    //  If key 'PlistPath' is set, check if it's a valid path. If it is, open it in Finder
    // ----------------------------------------------------------------------------------------
    if ([manifestDict[PFCRuntimeKeyPlistPath] length] != 0) {
        NSError *error = nil;
        NSString *filePath = manifestDict[PFCRuntimeKeyPlistPath] ?: @"";
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if ([fileURL checkResourceIsReachableAndReturnError:&error]) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
} // menuItemShowInFinder

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showButtonLibraryAdd {
    [_viewLibrarySearch layoutSubtreeIfNeeded];
    [_constraintSeachFieldLibraryLeading setConstant:26.0f];
    [_buttonLibraryAdd setHidden:NO];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = 0.2;
      context.allowsImplicitAnimation = YES;
      [_viewLibrarySearch layoutSubtreeIfNeeded];
    }
        completionHandler:^{
        }];
} // showButtonLibraryAdd

- (void)hideButtonLibraryAdd {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [_viewLibrarySearch layoutSubtreeIfNeeded];
    [_constraintSeachFieldLibraryLeading setConstant:5.0f];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = 0.2;
      context.allowsImplicitAnimation = YES;
      [_viewLibrarySearch layoutSubtreeIfNeeded];
    }
        completionHandler:^{
          [_buttonLibraryAdd setHidden:YES];
        }];
} // hideButtonLibraryAdd

- (void)showSearchNoMatches {
    [_viewStatusLibrary showStatus:kPFCStatusNoMatches];
    [_scrollViewLibrary setHidden:YES];
} // showSearchNoMatches

- (void)showLibraryNoManifests {
    switch (_selectedLibrary) {
    case kPFCPayloadLibraryMCX:
        [_viewStatusLibrary showStatus:kPFCStatusNoManifestsMCX];
        break;
    case kPFCPayloadLibraryCustom:
        [_viewStatusLibrary showStatus:kPFCStatusNoManifestsCustom];
        break;
    default:
        [_viewStatusLibrary showStatus:kPFCStatusNoManifests];
        break;
    }
    [_scrollViewLibrary setHidden:YES];
} // showSearchNoMatches

- (void)hideLibraryStatus {
    [[_viewStatusLibrary view] setHidden:YES];
    [_scrollViewLibrary setHidden:NO];
} // hideSearchNoMatches

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Search Field
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)searchFieldLibrary:(id)sender {

    // -------------------------------------------------------------------------------------------------
    //  Check if this is the beginning of a search, if so save the complete array before removing items
    // -------------------------------------------------------------------------------------------------
    if (![self isSearchingLibrary:_selectedLibrary]) {
        [self setIsSearchingLibrary:_selectedLibrary isSearching:YES];
        [self setArray:_arrayLibrary forLibrary:_selectedLibrary];
    }

    NSString *searchString = [_searchFieldLibrary stringValue];
    [_tableViewLibrary beginUpdates];
    if (![searchString length]) {

        // ---------------------------------------------------------------------
        //  If user pressed (x) or deleted the search, restore the whole array
        // ---------------------------------------------------------------------
        [self restoreSearchForLibrary:_selectedLibrary];
    } else {

        // ---------------------------------------------------------------------
        //  If this is a search, store the search string if user changes library
        // ---------------------------------------------------------------------
        [self setSearchStringForLibrary:_selectedLibrary searchString:[searchString copy]];

        // ---------------------------------------------------------------------
        //  Get the whole array for the current library to filter
        // ---------------------------------------------------------------------
        NSMutableArray *currentPayloadLibrary = [self arrayForLibrary:_selectedLibrary];

        // FIXME - Should add a setting to choose what the search should match. A pull down menu with some predicate choices like all, keys, settings (default), title, type, contains, is equal
        // etc.
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"Title CONTAINS[cd] %@", searchString];

        // ------------------------------------------------------------------------
        //  Filter the array and update the content array with the matched results
        // ------------------------------------------------------------------------
        NSMutableArray *matchedObjects = [[currentPayloadLibrary filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        [self setArrayLibrary:matchedObjects];

        // ---------------------------------------------------------------------
        //  If no matches were found, show text "No Matches" in payload library
        // ---------------------------------------------------------------------
        if ([matchedObjects count] == 0) {
            [self showSearchNoMatches];
        } else if ([matchedObjects count] != 0) {
            [self hideLibraryStatus];
        }
    }

    [_tableViewLibrary reloadData];
    [_tableViewLibrary endUpdates];
} // searchFieldLibrary

- (void)setSearchStringForLibrary:(PFCPayloadLibrary)library searchString:(NSString *)searchString {
    switch (library) {
    case kPFCPayloadLibraryApple:
        [self setSearchStringLibraryApple:searchString];
        break;
    case kPFCPayloadLibraryUserPreferences:
        [self setSearchStringLibraryUserPreferences:searchString];
        break;
    case kPFCPayloadLibraryCustom:
        [self setSearchStringLibraryCustom:searchString];
        break;
    default:
        break;
    }
} // setSearchStringForLibrary:searchString

- (NSString *)searchStringForLibrary:(PFCPayloadLibrary)library {
    switch (library) {
    case kPFCPayloadLibraryApple:
        return _searchStringLibraryApple;
        break;
    case kPFCPayloadLibraryUserPreferences:
        return _searchStringLibraryUserPreferences;
        break;
    case kPFCPayloadLibraryCustom:
        return _searchStringLibraryCustom;
        break;
    case kPFCPayloadLibraryMCX:
        return _searchStringLibraryMCX;
        break;
    default:
        return nil;
        break;
    }
} // searchStringForLibrary

- (void)restoreSearchForLibrary:(PFCPayloadLibrary)library {
    [self setArrayLibrary:[self arrayForLibrary:library]];
    [self setIsSearchingLibrary:library isSearching:NO];
    [self setSearchStringForLibrary:library searchString:nil];
    [self hideLibraryStatus];
} // restoreSearchForLibrary

- (void)setIsSearchingLibrary:(PFCPayloadLibrary)library isSearching:(BOOL)isSearching {
    switch (library) {
    case kPFCPayloadLibraryApple:
        [self setIsSearchingLibraryApple:isSearching];
        break;
    case kPFCPayloadLibraryUserPreferences:
        [self setIsSearchingLibraryUserPreferences:isSearching];
        break;
    case kPFCPayloadLibraryCustom:
        [self setIsSearchingLibraryCustom:isSearching];
        break;
    case kPFCPayloadLibraryMCX:
        [self setIsSearchingLibraryMCX:isSearching];
        break;
    default:
        break;
    }
} // setIsSearchingLibrary:isSearching

- (BOOL)isSearchingLibrary:(PFCPayloadLibrary)payloadLibrary {
    switch (payloadLibrary) {
    case kPFCPayloadLibraryApple:
        return _isSearchingLibraryApple;
        break;
    case kPFCPayloadLibraryUserPreferences:
        return _isSearchingLibraryUserPreferences;
        break;
    case kPFCPayloadLibraryMCX:
        return _isSearchingLibraryMCX;
        break;
    case kPFCPayloadLibraryCustom:
        return _isSearchingLibraryCustom;
        break;
    default:
        return NO;
        break;
    }
} // isSearchingPayloadLibrary:payloadLibrary

@end
