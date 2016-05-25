//
//  PFCProfileEditorManifest.m
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
#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypeFile.h"
#import "PFCCellTypePopUpButton.h"
#import "PFCCellTypeRadioButton.h"
#import "PFCCellTypeSegmentedControl.h"
#import "PFCCellTypeTextField.h"
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorManifest.h"
#import "PFCTableViewCellsSettings.h"

@interface PFCProfileEditorManifest ()

- (IBAction)buttonAddTab:(id)sender;
@property (strong) IBOutlet NSButton *buttonAddTab;
@property (strong) IBOutlet NSStackView *stackViewTabBar;
@property (strong) IBOutlet RFOverlayScrollView *scrollViewManifest;
@property (strong) IBOutlet NSLayoutConstraint *constraintScollViewManifestTop;

@property (nonatomic, weak) PFCProfileEditor *profileEditor;

@property NSMutableArray *arrayManifestContent;
@property NSMutableArray *arrayManifestTabs;

@property (readwrite) BOOL showValuesSource;
@property (readwrite) BOOL showColumnDisabled;
@property (weak) IBOutlet NSButton *checkboxShowKeysSupervised;

@property (weak) IBOutlet NSButton *checkboxOSX;
@property (weak) IBOutlet NSPopUpButton *popUpButtonOSXMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonOSXMaxVersion;

@property (weak) IBOutlet NSButton *checkboxiOS;
@property (weak) IBOutlet NSPopUpButton *popUpButtoniOSMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtoniOSMaxVersion;

@property (weak) IBOutlet NSPopUpButton *popUpButtonProfileScope;
@property (weak) IBOutlet NSPopUpButton *popUpButtonDistributionType;

@property BOOL tabBarHidden;

@property NSDictionary *selectedManifest;
@property PFCPayloadLibrary selectedManifestLibrary;

@property (readwrite) NSMutableDictionary *settingsLocalManifest;

@property (weak) IBOutlet PFCTableView *tableViewManifestContent;

@end

@implementation PFCProfileEditorManifest

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark init/dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileEditor:(PFCProfileEditor *)profileEditor {
    self = [super initWithNibName:@"PFCProfileEditorManifest" bundle:nil];
    if (self != nil) {
        _profileEditor = profileEditor;

        _arrayManifestContent = [[NSMutableArray alloc] init];
        _arrayManifestTabs = [[NSMutableArray alloc] init];

        // Setup some defaults
        _showColumnDisabled = NO;
        _showValuesSource = YES;
        _showKeysHidden = NO;
        _showKeysDisabled = NO;

        [self view];
    }
    return self;
} // initWithProfileEditor

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(showColumnDisabled)) context:nil];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(showValuesSource)) context:nil];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysHidden)) context:nil];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysDisabled)) context:nil];
}

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

    // -------------------------------------------------------------------------
    //  Register KVO observers
    // -------------------------------------------------------------------------
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(showColumnDisabled)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(showValuesSource)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysHidden)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysDisabled)) options:NSKeyValueObservingOptionNew context:nil];
    [_profileEditor addObserver:self forKeyPath:NSStringFromSelector(@selector(deallocKVO)) options:NSKeyValueObservingOptionNew context:nil];
    if ([_profileEditor settings]) {
        [[_profileEditor settings] addObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysSupervised)) options:NSKeyValueObservingOptionNew context:nil];
        [[_profileEditor settings] addObserver:self forKeyPath:NSStringFromSelector(@selector(includePlatformOSX)) options:NSKeyValueObservingOptionNew context:nil];
        [[_profileEditor settings] addObserver:self forKeyPath:NSStringFromSelector(@selector(includePlatformiOS)) options:NSKeyValueObservingOptionNew context:nil];

        // -------------------------------------------------------------------------
        //  Bindings
        // -------------------------------------------------------------------------

        // Supervised
        [_checkboxShowKeysSupervised bind:NSValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(showKeysSupervised)) options:nil];

        // Profile Scope
        [_popUpButtonProfileScope bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(payloadScope)) options:nil];

        // Profile Distribution Type
        [_popUpButtonDistributionType bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(distributionType)) options:nil];

        // OS X
        [_checkboxOSX bind:NSValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(includePlatformOSX)) options:nil];
        [_popUpButtonOSXMinVersion bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(osxMinVersion)) options:nil];
        [_popUpButtonOSXMaxVersion bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(osxMaxVersion)) options:nil];

        // iOS
        [_checkboxiOS bind:NSValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(includePlatformiOS)) options:nil];
        [_popUpButtoniOSMinVersion bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(iosMinVersion)) options:nil];
        [_popUpButtoniOSMaxVersion bind:NSSelectedValueBinding toObject:[_profileEditor settings] withKeyPath:NSStringFromSelector(@selector(iosMaxVersion)) options:nil];
    }

    [self setupTabBar];
    [self updateManifestColumns];
    [PFCGeneralUtility setupOSVersionsButtonOSXMin:_popUpButtonOSXMinVersion osxMax:_popUpButtonOSXMaxVersion iOSMin:_popUpButtoniOSMinVersion iOSMax:_popUpButtoniOSMaxVersion sender:self];
} // viewSetup

- (void)setupTabBar {
    [_stackViewTabBar setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_stackViewTabBar setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
    PFCProfileEditorManifestTab *newTabController = [[PFCProfileEditorManifestTab alloc] init];
    PFCProfileEditorManifestTabView *newTabView = (PFCProfileEditorManifestTabView *)newTabController.view;
    [newTabView setDelegate:self];
    [_arrayManifestTabs addObject:newTabView];
    [_stackViewTabBar addView:newTabView inGravity:NSStackViewGravityTrailing];
    [self setTabBarHidden:YES];
} // setupSettingsTabBar

- (void)updateManifestColumns {
    for (NSTableColumn *column in _tableViewManifestContent.tableColumns) {
        if ([column.identifier isEqualToString:@"ColumnSettingsEnabled"]) {
            [column setHidden:!_showColumnDisabled];
        } else if ([column.identifier isEqualToString:@"ColumnMinOS"]) {
            [column setHidden:YES];
        }
    }
}

- (void)selectOSVersion:(NSMenuItem *)menuItem {
    NSMenu *menu = [menuItem menu];
    if (menu == [_popUpButtonOSXMinVersion menu]) {
        [_profileEditor.settings setOsxMinVersion:menuItem.title];
    } else if (menu == [_popUpButtonOSXMaxVersion menu]) {
        [_profileEditor.settings setOsxMaxVersion:menuItem.title];
    } else if (menu == [_popUpButtoniOSMinVersion menu]) {
        [_profileEditor.settings setIosMinVersion:menuItem.title];
    } else if (menu == [_popUpButtoniOSMaxVersion menu]) {
        [_profileEditor.settings setIosMaxVersion:menuItem.title];
    }
} // selectOSVersion

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    NSMenu *menu = [menuItem menu];
    if (menu == [_popUpButtonOSXMinVersion menu]) {
        return [PFCGeneralUtility version:[menuItem title] isLowerThanVersion:[[_profileEditor settings] osxMaxVersion]];
    } else if (menu == [_popUpButtonOSXMaxVersion menu]) {
        return [PFCGeneralUtility version:[[_profileEditor settings] osxMinVersion] isLowerThanVersion:[menuItem title]];
    } else if (menu == [_popUpButtoniOSMinVersion menu]) {
        return [PFCGeneralUtility version:[menuItem title] isLowerThanVersion:[[_profileEditor settings] iosMaxVersion]];
    } else if (menu == [_popUpButtoniOSMaxVersion menu]) {
        return [PFCGeneralUtility version:[[_profileEditor settings] iosMinVersion] isLowerThanVersion:[menuItem title]];
    }
    return YES;
} // validateMenuItem

- (void)updateTableViewSettingsFromManifest:(NSDictionary *)manifest {

    // -------------------------------------------------------------------------
    //  Check that profile settings isn't currently visible
    // -------------------------------------------------------------------------
    if (![[[_profileEditor settings] view] isHidden]) {
        return;
    }

    [_tableViewManifestContent beginUpdates];
    [_arrayManifestContent removeAllObjects];
    NSArray *manifestContent = [self manifestContentForManifest:manifest];
    NSArray *manifestContentArray =
        [[PFCManifestParser sharedParser] arrayFromManifestContent:manifestContent settings:_settingsManifest settingsLocal:_settingsLocalManifest displayKeys:_profileEditor.settings.displayKeys];

    // ------------------------------------------------------------------------------------------
    //  FIXME - Check count is 3 or greater ( because manifestContentForManifest adds 2 paddings
    //          This is not optimal, should add those after the content was calculated
    // ------------------------------------------------------------------------------------------
    if (3 <= manifestContentArray.count) {
        [_arrayManifestContent addObjectsFromArray:manifestContentArray];
        [self updateToolbarWithTitle:manifest[PFCManifestKeyTitle] ?: @"" icon:[[PFCManifestUtility sharedUtility] iconForManifest:manifest]];
        [_profileEditor hideManifestStatus];
    } else {
        [_profileEditor showManifestNoSettings];
    }
    DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
    [_tableViewManifestContent reloadData];
    [_tableViewManifestContent endUpdates];
} // updateTableViewSettingsFromManifest

- (IBAction)buttonAddTab:(id)sender {
    [self addTabShouldSaveSettings:YES];
} // buttonAddPayload

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (row < _arrayManifestContent.count) {
        return [[PFCCellTypes sharedInstance] rowHeightForManifestContentDict:_arrayManifestContent[(NSUInteger)row] ?: @{}];
    }
    return 1;
} // tableView:heightOfRow

- (NSArray *)manifestContentForManifest:(NSDictionary *)manifest {
    NSMutableArray *manifestContent = [[NSMutableArray alloc] init];
    NSArray *manifestContentAll = manifest[PFCManifestKeyManifestContent] ?: @[];
    [manifestContentAll enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull manifestContentDict, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([[PFCAvailability sharedInstance] showSelf:manifestContentDict displayKeys:_profileEditor.settings.displayKeys]) {
          [manifestContent addObject:manifestContentDict];
      }
    }];

    if (manifestContent.count != 0) {

        // ---------------------------------------------------------------------
        //  Add padding row to top of table view
        // ---------------------------------------------------------------------
        [manifestContent insertObject:@{ PFCManifestKeyCellType : PFCCellTypePadding } atIndex:0];

        // ---------------------------------------------------------------------
        //  Add padding row to end of table view
        // ---------------------------------------------------------------------
        [manifestContent addObject:@{PFCManifestKeyCellType : PFCCellTypePadding}];
    }
    return [manifestContent copy];
} // manifestContentForManifest

- (void)updateToolbarWithTitle:(NSString *)title icon:(NSImage *)icon {
    [[_profileEditor textFieldToolbar] setStringValue:title];
    [[_profileEditor imageViewToolbar] setImage:icon];
} // updateToolbarWithTitle:icon

- (void)selectManifest:(NSDictionary *)manifest inTableView:(NSString *)tableViewIdentifier {

    // -----------------------------------------------------------------------------------
    //  Save the selected manifest settings before changing manifest in the settings view
    // -----------------------------------------------------------------------------------
    [self saveSelectedManifest];

    // -------------------------------------------------------------------------
    //  Update the selection properties with the current selection
    // -------------------------------------------------------------------------
    [_profileEditor updateTableViewSelection:tableViewIdentifier];

    [_tableViewManifestContent beginUpdates];
    [_arrayManifestContent removeAllObjects];

    // -------------------------------------------------------------------------
    //  Update the selected manifest
    // -------------------------------------------------------------------------
    [self setSelectedManifest:[manifest copy]];

    // -------------------------------------------------------------------------
    //  Get manifest domain
    // -------------------------------------------------------------------------
    NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
    DDLogDebug(@"Selected manifest domain: %@", manifestDomain);

    // -----------------------------------------------------------------------
    //  Get saved index of selected tab (if not saved, select index 0)
    // ------------------------------------------------------------------------
    [self setSelectedTab:[[_profileEditor profileSettings][manifestDomain][@"SelectedTab"] integerValue] ?: 0];

    // ---------------------------------------------------------------------
    //  Update tab count to match saved settings
    // ---------------------------------------------------------------------
    NSInteger manifestTabCount = [self updateTabCountForManifestDomain:manifestDomain];

    // ---------------------------------------------------------------------
    //  Post notification to select saved tab index
    // ---------------------------------------------------------------------
    [self selectTab:_selectedTab saveSettings:NO sender:self];

    // ------------------------------------------------------------------------------------
    //  Load the current settings from the saved settings dict (by using the payload domain)
    // ------------------------------------------------------------------------------------
    [self setSettingsManifest:[self settingsForManifestWithDomain:manifestDomain manifestTabIndex:_selectedTab]];
    [self setSettingsLocalManifest:[[[PFCManifestLibrary sharedLibrary] cachedLocalSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init]];

    // ------------------------------------------------------------------------------------
    //  Load the current manifest content dict array from the selected manifest
    //  If the manifest content dict array is empty, show "Error Reading Settings"
    // ------------------------------------------------------------------------------------
    NSArray *manifestContent = [self manifestContentForManifest:manifest];
    DDLogDebug(@"Manifest content: %@", manifestContent);

    NSArray *manifestContentArray =
        [[PFCManifestParser sharedParser] arrayFromManifestContent:manifestContent settings:_settingsManifest settingsLocal:_settingsLocalManifest displayKeys:_profileEditor.settings.displayKeys];
    DDLogDebug(@"Manifest content array: %@", manifestContentArray);

    // ------------------------------------------------------------------------------------------
    //  FIXME - Check count is 3 or greater ( because manifestContentForManifest adds 2 paddings
    //          This is not optimal, should add those after the content was calculated
    // ------------------------------------------------------------------------------------------
    if (3 <= manifestContentArray.count) {
        [_arrayManifestContent addObjectsFromArray:[manifestContentArray copy]];
        [self updateToolbarWithTitle:manifest[PFCManifestKeyTitle] ?: @"" icon:[[PFCManifestUtility sharedUtility] iconForManifest:manifest]];
        [_profileEditor showManifest];

        // -----------------------------------------------------------------
        //  Update all tabs with saved values
        // -----------------------------------------------------------------
        if ([manifest[PFCManifestKeyAllowMultiplePayloads] boolValue]) {
            [self updateTabBarTitles];

            // Fix to get the first tab to also get an initial error count, could possibly be done somewhere else
            if (manifestTabCount == 1) {
                NSDictionary *settingsError = [[PFCManifestParser sharedParser] settingsErrorForManifestContent:manifest[PFCManifestKeyManifestContent]
                                                                                                       settings:_settingsManifest
                                                                                                    displayKeys:_profileEditor.settings.displayKeys];
                NSNumber *errorCount = @([[settingsError allKeys] count]) ?: @0;
                [self updatePayloadTabErrorCount:errorCount tabIndex:0];
            }
            [self errorForManifest:manifest updateTabBar:YES];
        }

        // --------------------------------------------------------------------------
        //  Show/Hide tab view and button depending on current manifest and settings
        // --------------------------------------------------------------------------
        [self allowMultiplePayloads:[manifest[PFCManifestKeyAllowMultiplePayloads] boolValue]];
        if (manifestTabCount == 1) {
            [self setTabBarHidden:YES];
        } else {
            [self setTabBarHidden:NO];
        }
        [_stackViewTabBar.superview display];

        [_profileEditor hideManifestStatus];

        /*
        if (![[_profileEditor splitViewWindow] isSubviewCollapsed:[_splitViewWindow subviews][2]]) {
            [[_profileEditor info] updateInfoForManifestDict:manifest];
        }
         */
    } else {
        [_profileEditor showManifestNoSettings];
    }

    DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
    [_tableViewManifestContent reloadData];
    [_tableViewManifestContent endUpdates];
}

- (void)allowMultiplePayloads:(BOOL)allowMultiplePayloads {
    if (allowMultiplePayloads && _constraintScollViewManifestTop.constant == 0.0f) {
        [_constraintScollViewManifestTop setConstant:24.0f];

        [self.view addSubview:_buttonAddTab positioned:NSWindowAbove relativeTo:nil];
        [_buttonAddTab setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_buttonAddTab]-0-[_scrollViewManifest]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_buttonAddTab, _scrollViewManifest)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_buttonAddTab(24)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_buttonAddTab)]];

        [self.view addSubview:_stackViewTabBar positioned:NSWindowAbove relativeTo:nil];
        [_stackViewTabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_stackViewTabBar]-0-[_scrollViewManifest]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_stackViewTabBar, _scrollViewManifest)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_stackViewTabBar]-0-[_buttonAddTab]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_stackViewTabBar, _buttonAddTab)]];

    } else if (!allowMultiplePayloads && _constraintScollViewManifestTop.constant == 24.0f) {
        DDLogDebug(@"Remove tab bar to view");
        [_constraintScollViewManifestTop setConstant:0.0f];
        [_stackViewTabBar removeFromSuperview];
        [_buttonAddTab removeFromSuperview];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    return _arrayManifestContent.count;
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    if (_arrayManifestContent.count < row || _arrayManifestContent.count == 0) {
        return nil;
    }

    NSString *tableColumnIdentifier = tableColumn.identifier;
    DDLogVerbose(@"Table Column: %@", tableColumnIdentifier);
    NSDictionary *manifestContentDict = _arrayManifestContent[(NSUInteger)row];
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    DDLogVerbose(@"CellType: %@", cellType);
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];

    if ([tableColumnIdentifier isEqualToString:@"ColumnSettings"]) {

        // -----------------------------------------------------------------
        //  Padding
        // -----------------------------------------------------------------
        if ([cellType isEqualToString:PFCCellTypePadding]) {
            return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
        } else {
            id cellView = [tableView makeViewWithIdentifier:cellType owner:self];
            if (cellView) {
                [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                return [cellView populateCellView:cellView
                    manifestContentDict:manifestContentDict
                    manifest:_selectedManifest
                    settings:_settingsManifest ?: @{}
                    settingsUser:_settingsManifest[identifier] ?: @{}
                    settingsLocal:(_showValuesSource) ? _settingsLocalManifest[identifier] : @{}
                    displayKeys:_profileEditor.settings.displayKeys
                    row:row
                    sender:self];
            } else {
                DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
                return nil;
            }
        }
    } else if ([tableColumnIdentifier isEqualToString:@"ColumnSettingsEnabled"]) {

        if ([cellType isEqualToString:PFCCellTypePadding]) {
            return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
        } else {

            NSDictionary *userSettingsDict = _settingsManifest[identifier];
            NSDictionary *localSettingsDict;
            if (_showValuesSource) {
                localSettingsDict = _settingsLocalManifest[identifier];
            }

            CellViewSettingsEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsEnabled" owner:self];
            [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
            return [cellView populateCellViewEnabled:cellView manifest:manifestContentDict settings:userSettingsDict settingsLocal:localSettingsDict row:row sender:self];
        }
    }
    return nil;
} // tableView:viewForTableColumn:row

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Verify the settings array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if (_arrayManifestContent.count <= 0) {
        return;
    }

    // ---------------------------------------------------------------------
    //  Get current cell's manifest dict identifier
    // ---------------------------------------------------------------------
    NSDictionary *manifestContentDict = _arrayManifestContent[(NSUInteger)row];
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    if (![cellType isEqualToString:PFCCellTypePadding]) {
        NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
        if (identifier.length == 0) {
            return;
        }

        // -----------------------------------------------------------------
        //  It the cell is disabled, change cell background to grey
        // -----------------------------------------------------------------
        if (_settingsManifest[identifier][PFCSettingsKeyEnabled] != nil) {
            if (![_settingsManifest[identifier][PFCSettingsKeyEnabled] boolValue]) {
                [rowView setBackgroundColor:[NSColor quaternaryLabelColor]];
                return;
            }
        }

        // -----------------------------------------------------------------
        //  It the cell is hidden, change cell background to grey
        // -----------------------------------------------------------------
        if (manifestContentDict[PFCManifestKeyHidden] != nil) {
            if ([manifestContentDict[PFCManifestKeyHidden] boolValue]) {
                [rowView setBackgroundColor:[NSColor quaternaryLabelColor]];
                return;
            }
        }

        [rowView setBackgroundColor:[NSColor clearColor]];
    }
} // tableView:didAddRowView:forRow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)change context:(void *)__unused context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(showColumnDisabled))]) {
        [self updateManifestColumns];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(showValuesSource))]) {
        [_tableViewManifestContent beginUpdates];
        DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
        [_tableViewManifestContent reloadData];
        [_tableViewManifestContent endUpdates];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(showKeysDisabled))] || [keyPath isEqualToString:NSStringFromSelector(@selector(showKeysHidden))] ||
               [keyPath isEqualToString:NSStringFromSelector(@selector(showKeysSupervised))] || [keyPath isEqualToString:NSStringFromSelector(@selector(includePlatformOSX))] ||
               [keyPath isEqualToString:NSStringFromSelector(@selector(includePlatformiOS))] || [keyPath isEqualToString:NSStringFromSelector(@selector(payloadScope))] ||
               [keyPath isEqualToString:NSStringFromSelector(@selector(distributionType))]) {
        [self updateTableViewSettingsFromManifest:_selectedManifest];
        [[_profileEditor library] updateManifests];
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(deallocKVO))]) {
        if ([change[NSKeyValueChangeNewKey] boolValue]) {
            [_profileEditor removeObserver:self forKeyPath:NSStringFromSelector(@selector(deallocKVO)) context:nil];
            [[_profileEditor settings] removeObserver:self forKeyPath:NSStringFromSelector(@selector(showKeysSupervised)) context:nil];
            [[_profileEditor settings] removeObserver:self forKeyPath:NSStringFromSelector(@selector(includePlatformOSX)) context:nil];
            [[_profileEditor settings] removeObserver:self forKeyPath:NSStringFromSelector(@selector(includePlatformiOS)) context:nil];
        }
    }
} // observeValueForKeyPath:ofObject:change:context

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCProfileCreationTabDelegate Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)selectTab:(NSUInteger)tabIndex saveSettings:(BOOL)saveSettings sender:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Selected tab index: %ld", (long)tabIndex);
    DDLogDebug(@"Should save settings: %@", (saveSettings) ? @"YES" : @"NO");

    // -------------------------------------------------------------------------
    //  Loop through all tabs and update _isSelected
    //  Do this even if tabIndex is the same as currently selected to force UI update for instance when nothing was selected
    // -------------------------------------------------------------------------
    [[_stackViewTabBar views] enumerateObjectsUsingBlock:^(__kindof NSView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if (idx == tabIndex) {
          [obj setIsSelected:YES];
      } else {
          [obj setIsSelected:NO];
      }
    }];

    // -------------------------------------------------------------------------
    //  If currently selected index is selected again, do nothing
    // -------------------------------------------------------------------------
    DDLogDebug(@"Current selected tab index: %ld", _selectedTab);
    if (tabIndex == _selectedTab) {
        DDLogDebug(@"Tab index is equal to currently selected tab index. Returning.");
        return;
    }

    // --------------------------------------------------------------------------------
    //  Save current settings if sender didn't explicitly add "SaveSettingsDone" = YES
    // --------------------------------------------------------------------------------
    NSString *manifestDomain = _selectedManifest[PFCManifestKeyDomain];
    DDLogDebug(@"Current manifest domain: %@", manifestDomain);
    if (saveSettings) {
        [self saveSettingsForManifestWithDomain:manifestDomain settings:_settingsManifest manifestTabIndex:_selectedTab];
    }

    // -------------------------------------------------------------------------
    //  Store the currently selected tab in local variable _tabIndexSelected
    // -------------------------------------------------------------------------
    DDLogVerbose(@"Setting tab index selected to: %ld", (long)tabIndex);
    [self setSelectedTab:tabIndex];

    // -------------------------------------------------------------------------
    //  Save the currently selected tab in user settings
    // -------------------------------------------------------------------------
    [self saveTabIndexSelected:tabIndex forManifestDomain:manifestDomain];

    // -------------------------------------------------------------------------
    //  Set correct settings for selected tab
    // -------------------------------------------------------------------------
    [self setSettingsManifest:[self settingsForManifestWithDomain:manifestDomain manifestTabIndex:tabIndex]];

    // -------------------------------------------------------------------------
    //  Update settings view with the new settings
    // -------------------------------------------------------------------------
    [_tableViewManifestContent beginUpdates];
    DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
    [_tableViewManifestContent reloadData];
    [_tableViewManifestContent endUpdates];
} // tabIndexSelected:sender

- (NSMutableDictionary *)settingsForManifestWithDomain:(NSString *)manifestDomain manifestTabIndex:(NSInteger)manifestTabIndex {
    // -------------------------------------------------------------------------
    //  Check that manifest array contains any settings dict, else return new
    // -------------------------------------------------------------------------
    NSArray *manifestSettings = [_profileEditor profileSettings][manifestDomain][@"Settings"] ?: @[];
    if (manifestSettings.count == 0) {
        return [[NSMutableDictionary alloc] init];
    }

    // -------------------------------------------------------------------------
    //  Check that selected index exist in settings, else return new
    // -------------------------------------------------------------------------
    if (manifestSettings.count <= manifestTabIndex) {
        return [[NSMutableDictionary alloc] init];
    }

    return [manifestSettings[manifestTabIndex] mutableCopy];
} // settingsForManifestWithDomain:manifestTabIndex

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PayloadTabs
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)addTabShouldSaveSettings:(BOOL)saveSettings {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Should save settings: %@", saveSettings ? @"YES" : @"NO");

    if (PFCMaximumPayloadCount <= _arrayManifestTabs.count) {
        NSAlert *alert = [NSAlert
            alertWithError:[NSError errorWithDomain:@"com.github.ProfileCreator"
                                               code:100
                                           userInfo:@{
                                               NSLocalizedDescriptionKey : @"Maximum Payload Count Reached",
                                               NSLocalizedRecoverySuggestionErrorKey :
                                                   [NSString stringWithFormat:@"Current maximum payload count is %ld during beta, this is because no implementation to hande scrolling tabs has been "
                                                                              @"implemented yet.\n\nAdd a feature request if this is something you need to push it up the priority list.",
                                                                              (long)PFCMaximumPayloadCount]
                                           }]];
        [alert beginSheetModalForWindow:_profileEditor.window
                      completionHandler:^(NSModalResponse returnCode){

                      }];
        return;
    }

    // -------------------------------------------------------------------------
    //  Create a new view controller and extract the tab view
    // -------------------------------------------------------------------------
    PFCProfileEditorManifestTab *newTabController = [[PFCProfileEditorManifestTab alloc] init];
    PFCProfileEditorManifestTabView *newTabView = (PFCProfileEditorManifestTabView *)newTabController.view;
    [newTabView setDelegate:self];
    [newTabView setIsSelected:YES]; // This is when added

    // -------------------------------------------------------------------------
    //  Add the new tab view to the tab view array
    // -------------------------------------------------------------------------
    DDLogDebug(@"Adding tab view to array payload tabs...");
    [_arrayManifestTabs addObject:newTabView];

    // -------------------------------------------------------------------------
    //  Get index of where to add the new stack view (end of current views)
    // -------------------------------------------------------------------------
    NSInteger newIndex = _stackViewTabBar.views.count;
    DDLogDebug(@"New index for tab in stack view: %ld", (long)newIndex);

    // -------------------------------------------------------------------------
    //  Insert new view in stack view
    // -------------------------------------------------------------------------
    [_stackViewTabBar insertView:newTabView atIndex:newIndex inGravity:NSStackViewGravityTrailing];

    // -------------------------------------------------------------------------
    //  Post notification to select the newly created view
    // -------------------------------------------------------------------------
    [self selectTab:newIndex saveSettings:saveSettings sender:self];

    // -------------------------------------------------------------------------
    //  Update new tab with default title
    // -------------------------------------------------------------------------
    [self updatePayloadTabTitle:@"" tabIndex:newIndex];

    // -------------------------------------------------------------------------
    //  Update new tab with errors
    // -------------------------------------------------------------------------
    NSDictionary *settingsError =
        [[PFCManifestParser sharedParser] settingsErrorForManifestContent:_selectedManifest[PFCManifestKeyManifestContent] settings:@{} displayKeys:_profileEditor.settings.displayKeys];
    NSNumber *errorCount = @(settingsError.allKeys.count) ?: @0;
    [self updatePayloadTabErrorCount:errorCount tabIndex:newIndex];
    [_profileEditor.library reloadManifest:_selectedManifest];

    // -------------------------------------------------------------------------
    //  When adding a view the tab bar should become visible
    // -------------------------------------------------------------------------
    if (_tabBarHidden) {
        [self setTabBarHidden:NO];
    }
} // addPayloadTab

- (void)updatePayloadTabTitle:(NSString *)title tabIndex:(NSUInteger)tabIndex {
    PFCProfileEditorManifestTabView *tab = (PFCProfileEditorManifestTabView *)_arrayManifestTabs[tabIndex];
    if ([title length] == 0) {
        title = [@(tabIndex) stringValue];
    }
    [tab updateTitle:title ?: @""];
} // updatePayloadTabTitle

- (void)updatePayloadTabErrorCount:(NSNumber *)errorCount tabIndex:(NSUInteger)tabIndex {
    PFCProfileEditorManifestTabView *tab = (PFCProfileEditorManifestTabView *)_arrayManifestTabs[tabIndex];
    [tab updateErrorCount:errorCount ?: @0];
} // updatePayloadTabErrorCount

- (void)updateTabBarTitles {

    // -----------------------------------------------------------------
    //  Update all tabs with saved values
    // -----------------------------------------------------------------
    NSString *manifestDomain = _selectedManifest[PFCManifestKeyDomain];
    DDLogDebug(@"Manifest domain: %@", manifestDomain);

    NSArray *manifestSettings;
    NSString *payloadTabTitleIndex = _selectedManifest[PFCManifestKeyPayloadTabTitle] ?: @"";
    DDLogDebug(@"Manifest tab title uuid: %@", payloadTabTitleIndex);

    if (payloadTabTitleIndex.length != 0) {
        manifestSettings = [_profileEditor profileSettings][manifestDomain][@"Settings"];
    }

    if (_arrayManifestTabs.count != 0) {
        [_arrayManifestTabs enumerateObjectsUsingBlock:^(id _Nonnull __unused obj, NSUInteger idx, BOOL *_Nonnull __unused stop) {
          if (idx < manifestSettings.count) {
              NSDictionary *settings = manifestSettings[idx][payloadTabTitleIndex] ?: @{};

              // FIXME - Should specify what key should be used in the dict, now just use "Value" for testing
              [self updatePayloadTabTitle:settings[@"Value"] ?: @"" tabIndex:idx];
          } else {
              [self updatePayloadTabTitle:@"" tabIndex:idx];
          }

        }];
    }
} // updateTabBarTitles

- (NSInteger)errorForManifest:(NSDictionary *)manifest updateTabBar:(BOOL)updateTabBar {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Update tab bar: %@", updateTabBar ? @"YES" : @"NO");

    // -----------------------------------------------------------------
    //  Update all tabs with saved values
    // -----------------------------------------------------------------
    NSArray *manifestContent = manifest[PFCManifestKeyManifestContent];

    NSString *manifestDomain = manifest[PFCManifestKeyDomain];
    DDLogDebug(@"Manifest domain: %@", manifestDomain);

    // -------------------------------------------------------------------------
    //  Add empty settings so the enumeration always will run atleast once
    // -------------------------------------------------------------------------
    NSArray *manifestSettings = @[ @{} ];
    NSString *payloadTabTitleIndex = manifest[PFCManifestKeyPayloadTabTitle] ?: @"";
    DDLogDebug(@"Payload tab title index: %@", payloadTabTitleIndex);

    if ([payloadTabTitleIndex length] != 0) {
        manifestSettings = [_profileEditor profileSettings][manifestDomain][@"Settings"] ?: @[ @{} ];
    }
    __block NSInteger combinedErrors = 0;

    NSMutableArray *settingsError = [[NSMutableArray alloc] init];

    DDLogDebug(@"Enumerating all manifest settings (%lu) for manifest domain: %@ and updating errors", (unsigned long)manifestSettings.count, manifestDomain);
    [manifestSettings enumerateObjectsUsingBlock:^(id _Nonnull __unused obj, NSUInteger idx, BOOL *_Nonnull __unused stop) {

      DDLogDebug(@"Tab index: %lu", (unsigned long)idx);
      if (idx < manifestSettings.count) {

          NSDictionary *settings;
          if ([manifest isEqualToDictionary:_selectedManifest] && idx == _selectedTab) {
              DDLogDebug(@"Tab is selected in the UI, using current manifest settings");

              settings = _settingsManifest;
          } else {
              settings = manifestSettings[idx] ?: @{};
          }
          DDLogDebug(@"Tab settings: %@", settings);

          NSDictionary *verificationReport =
              [[PFCManifestParser sharedParser] settingsErrorForManifestContent:manifestContent settings:settings displayKeys:_profileEditor.settings.displayKeys] ?: @{};
          [settingsError addObject:verificationReport];

          NSNumber *errorCount = @(verificationReport.allKeys.count) ?: @0;
          DDLogDebug(@"Tab errors: %ld", (long)errorCount.integerValue);

          combinedErrors += [errorCount integerValue];
          DDLogDebug(@"Manifest errors: %ld", (long)combinedErrors);

          if (updateTabBar && idx < _arrayManifestTabs.count) {
              [self updatePayloadTabErrorCount:errorCount tabIndex:idx];
          }
      } else if (updateTabBar && idx < _arrayManifestTabs.count) {
          [self updatePayloadTabErrorCount:@0 tabIndex:idx];
      }
    }];

    NSMutableDictionary *manifestDomainSettings = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    manifestDomainSettings[@"SettingsError"] = [settingsError copy] ?: @[];
    [_profileEditor profileSettings][manifestDomain] = [manifestDomainSettings copy];

    return combinedErrors;
} // updateTabBarErrors

- (NSUInteger)updateTabCountForManifestDomain:(NSString *)manifestDomain {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSUInteger settingsCount = [[_profileEditor profileSettings][manifestDomain][@"Settings"] count];
    DDLogDebug(@"Found: %ld settings for payload domain: %@", (long)settingsCount, manifestDomain);
    if (settingsCount == 0) {
        settingsCount = 1;
    }

    NSUInteger stackViewCount = _stackViewTabBar.views.count;
    if (settingsCount != stackViewCount) {

        DDLogDebug(@"Correcting tab count for manifest with domain: %@", manifestDomain);
        if (settingsCount < stackViewCount) {
            DDLogDebug(@"Settings count: %ld is less than stack view count: %ld", (long)settingsCount, (long)stackViewCount);

            while (settingsCount < stackViewCount) {
                [_stackViewTabBar removeView:_stackViewTabBar.views.lastObject];
                if (0 < _arrayManifestTabs.count && stackViewCount == _arrayManifestTabs.count) {
                    [_arrayManifestTabs removeObjectAtIndex:(stackViewCount - 1)];
                } else {
                    DDLogError(@"Array tab view count is not matching stack view, this might cause an inconsistent internal state");
                }
                stackViewCount = _stackViewTabBar.views.count;
            }

        } else if (stackViewCount < settingsCount) {
            DDLogDebug(@"Stack view count: %ld is less than settings count: %ld", (long)stackViewCount, (long)settingsCount);

            while (stackViewCount < settingsCount) {
                [self addTabShouldSaveSettings:NO];
                stackViewCount = _stackViewTabBar.views.count;
            }
        }
    }

    return settingsCount;
} // updateTabCountForManifestDomain

- (void)saveTabIndexSelected:(NSUInteger)tabIndexSelected forManifestDomain:(NSString *)manifestDomain {
    NSMutableDictionary *settingsManifestRoot = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    settingsManifestRoot[@"SelectedTab"] = @(tabIndexSelected);
    [_profileEditor profileSettings][manifestDomain] = [settingsManifestRoot mutableCopy];
} // saveTabIndexSelected:forManifestDomain

- (void)saveSelectedManifest {
    if (_selectedManifest.count != 0) {
        [self saveSettingsForManifestWithDomain:_selectedManifest[PFCManifestKeyDomain] settings:_settingsManifest manifestTabIndex:_selectedTab];
    }
}

- (void)saveSettingsForManifestWithDomain:(NSString *)manifestDomain settings:(NSMutableDictionary *)settings manifestTabIndex:(NSInteger)manifestTabIndex {
    DDLogDebug(@"Saving settings for manifest domain: %@", manifestDomain);
    DDLogDebug(@"Settings to save: %@", settings);

    // -------------------------------------------------------------------------
    //  Check that manifest array contains any settings dict, else return new
    // -------------------------------------------------------------------------
    NSMutableDictionary *manifestSettingsRoot = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    NSMutableArray *manifestSettings = [manifestSettingsRoot[@"Settings"] mutableCopy] ?: [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Check that manifest array contains correct amount of settings dicts
    //  If some is missing, add empty dicts to get the index matching correct
    // -------------------------------------------------------------------------
    NSInteger manifestSettingsCount = manifestSettings.count;
    DDLogDebug(@"Current manifest settings count: %ld", (long)manifestSettingsCount);

    // -------------------------------------------------------------------------
    //  Get current count of settings tabs
    // -------------------------------------------------------------------------
    NSInteger manifestTabCount = _arrayManifestTabs.count;
    DDLogDebug(@"Current manifest tab count: %ld", (long)manifestTabCount);

    // -------------------------------------------------------------------------
    //  Correct saved setting dicts to match tab count
    // -------------------------------------------------------------------------
    while (manifestSettingsCount < manifestTabCount) {
        DDLogDebug(@"Adding empty setting to match tab count...");
        [manifestSettings addObject:[[NSMutableDictionary alloc] init]];
        manifestSettingsCount = manifestSettings.count;
        DDLogDebug(@"Current manifest settings count: %ld", (long)manifestSettingsCount);
    }

    // -------------------------------------------------------------------------
    //  Save current settings for tab index sent to method
    // -------------------------------------------------------------------------
    if (manifestSettingsCount == 0 || manifestSettingsCount == manifestTabIndex) {
        DDLogDebug(@"Adding settings to endo of settings array");
        [manifestSettings addObject:[settings copy]];
    } else {
        DDLogDebug(@"Replacing current settings at index %ld", (long)manifestTabIndex);
        manifestSettings[manifestTabIndex] = [settings copy];
    }

    // -------------------------------------------------------------------------
    //  Save current settings to profile settings dict
    // -------------------------------------------------------------------------
    DDLogVerbose(@"Saving settings: %@", manifestSettings);
    manifestSettingsRoot[@"Settings"] = [manifestSettings mutableCopy];
    [_profileEditor profileSettings][manifestDomain] = [manifestSettingsRoot mutableCopy];
} // saveSettingsForManifestWithDomain:settings:manifestTabIndex

- (BOOL)shouldCloseTab:(NSUInteger)tabIndex sender:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // FIXME - This is added to allow for notification/confirmation of closing tabs
    return YES;
} // tabIndexShouldClose:sender

- (void)closeTab:(NSUInteger)tabIndex sender:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Get view that sent close notification and remove it form the stack view
    // -------------------------------------------------------------------------
    if (![sender isKindOfClass:[PFCProfileEditorManifestTabView class]]) {
        DDLogError(@"Class %@ is not allowed to send -tabIndexClose", [sender class]);
        return;
    }

    PFCProfileEditorManifestTabView *view = sender;
    if (view != nil) {
        if ([_stackViewTabBar.views containsObject:view]) {
            DDLogDebug(@"Removing tab view from stack view!");
            [_stackViewTabBar removeView:view];
        } else {
            DDLogError(@"StackView doesn't contain view that sent notification to close it's tab");
            DDLogError(@"Will NOT remove any views from StackView, this might cause an inconsistent internal state");
        }
    }

    // -------------------------------------------------------------------------
    //  Sanity check the array of views so the selection is valid
    // -------------------------------------------------------------------------
    if (_arrayManifestTabs.count <= 1 || _arrayManifestTabs.count < tabIndex) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Remove view from the view array
    // -------------------------------------------------------------------------
    DDLogVerbose(@"Removing index: %ld from _arrayPayloadTabs", (long)tabIndex);
    [_arrayManifestTabs removeObjectAtIndex:tabIndex];

    // -------------------------------------------------------------------------
    //  Remove settings from the settings array
    // -------------------------------------------------------------------------
    DDLogVerbose(@"Removing settings dict from manifest settings");
    [self removeSettingsForManifestWithDomain:_selectedManifest[PFCManifestKeyDomain] manifestTabIndex:tabIndex];

    // ----------------------------------------------------------------------------------------------------------------------
    //  If the currently selected tab sent the close notification, calculate and send what tab to select after it has closed
    // ----------------------------------------------------------------------------------------------------------------------
    if (tabIndex == _selectedTab) {
        DDLogVerbose(@"Currently selected tab was closed");

        if (tabIndex == _arrayManifestTabs.count) {

            // --------------------------------------------------------------------
            //  If the closed tab was last in the view, select the "new" last view
            // --------------------------------------------------------------------
            [self selectTab:(tabIndex - 1) saveSettings:NO sender:self];
        } else {

            // --------------------------------------------------------------------
            //  If none of the above, send same index as the closed tab to select
            //  The next adjacent one to the closed tab's right
            // --------------------------------------------------------------------
            [self selectTab:tabIndex saveSettings:NO sender:self];
        }
    } else if (tabIndex < _selectedTab) {
        DDLogVerbose(@"Tab to the left of currently selected tab was closed");

        // -------------------------------------------------------------------------
        //  Store the currently selected tab in local variable _tabIndexSelected
        // -------------------------------------------------------------------------
        DDLogVerbose(@"Setting tab index selected to: %ld", (_selectedTab - 1));
        [self setSelectedTab:(_selectedTab - 1)];

        // ---------------------------------------------------------------------
        //  Save the currently selected tab in user settings
        // ---------------------------------------------------------------------
        [self saveTabIndexSelected:_selectedTab forManifestDomain:_selectedManifest[PFCManifestKeyDomain]];

        // -----------------------------------------------------------------------
        //  Closed tab was left of the current selection, update the tab selected
        // -----------------------------------------------------------------------
        [self selectTab:_selectedTab saveSettings:NO sender:self];
    }

    // ---------------------------------------------------------------------
    //  Hide the tab bar when there's only one payload configured
    // ---------------------------------------------------------------------
    if (_arrayManifestTabs.count == 1) {

        // -----------------------------------------------------------------
        //  If there is only one tab remaining in the array, select it
        // -----------------------------------------------------------------
        [self selectTab:0 saveSettings:NO sender:self];

        // -----------------------------------------------------------------
        //  Hide the tab bar when there's only one payload configured
        // -----------------------------------------------------------------
        [self setTabBarHidden:YES];
    }

    [self updateTabBarTitles];
    [_profileEditor.library reloadManifest:_selectedManifest];
} // tabIndexClose:sender

- (void)updateTableViewSettingsFromManifestContentDict:(NSDictionary *)manifestContentDict atRow:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Sanity check so that:   Row isn't less than 0
    //                          Row is withing the count of the array
    //                          The array isn't empty
    // -------------------------------------------------------------------------
    if (row < 0 || _arrayManifestContent.count == 0 || _arrayManifestContent.count < row) {
        DDLogError(@"row error for selected manifest");
        return;
    }

    // -------------------------------------------------------------------------
    //  Verify that current manifest content dict has an identifier.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[@"Identifier"];
    if (identifier.length == 0) {
        DDLogError(@"No Identifier!");
        return;
    }

    // --------------------------------------------------------------------------------------------------
    //  Create and array of manifest content dicts originating from the current manifest content dict
    //  This means either just the current dict, or any subDicts depending on the current user selection
    // --------------------------------------------------------------------------------------------------
    NSMutableArray *manifestContentSubset = [[NSMutableArray alloc] init];
    for (NSDictionary *resolvedManifestContentDict in
         [[PFCManifestParser sharedParser] arrayFromManifestContentDict:manifestContentDict settings:_settingsManifest settingsLocal:_settingsLocalManifest parentKeys:nil]) {
        if ([[PFCManifestUtility sharedUtility] showManifestContentDict:resolvedManifestContentDict settings:_settingsManifest displayKeys:_profileEditor.settings.displayKeys]) {
            [manifestContentSubset addObject:resolvedManifestContentDict];
        }
    }

    if (manifestContentSubset.count == 0) {
        DDLogError(@"Nothing returned from arrayForManifestContentDict!");
        return;
    }

    [_tableViewManifestContent beginUpdates];

    // ---------------------------------------------------------------------------------------------------
    //  Remove all dicts starting at current row that contains current dict's 'Identifier' as 'ParentKey'
    //  Stop at first dict that doesn't match current dict's 'Identifier'.
    //  If row is the last row, just remove that row.
    // ---------------------------------------------------------------------------------------------------
    if (row == _arrayManifestContent.count) {
        [_arrayManifestContent removeObjectAtIndex:_arrayManifestContent.count];
    } else {

        // ---------------------------------------------------------------------
        //  Make range starting at dict after current row to end of array
        // ---------------------------------------------------------------------
        NSRange range = NSMakeRange(row + 1, _arrayManifestContent.count - (row + 1));

        // -------------------------------------------------------------------------------
        //  Keep count of how many rows matches current dict's 'Identifier' as 'ParentKey'
        // -------------------------------------------------------------------------------
        __block NSInteger rowCount = 0;
        [_arrayManifestContent enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]
                                                 options:NSEnumerationConcurrent
                                              usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                                if ([obj[PFCManifestKeyParentKey] containsObject:identifier]) {
                                                    rowCount++;
                                                } else {
                                                    *stop = YES;
                                                }
                                              }];

        // ---------------------------------------------------------------------------------------------------------
        //  Make range starting at current row to count of rows matching current dict's 'Identifier' as 'ParentKey'
        // ---------------------------------------------------------------------------------------------------------
        NSRange removeRange = NSMakeRange(row, rowCount + 1);

        // ---------------------------------------------------------------------
        //  Remove all objects originating from current manifest content dict
        // ---------------------------------------------------------------------
        [_arrayManifestContent removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeRange]];
    }

    // -------------------------------------------------------------------------
    //  Make range starting at current row to count of content dict's to add
    // -------------------------------------------------------------------------
    NSRange insertRange = NSMakeRange(row, manifestContentSubset.count);

    // -------------------------------------------------------------------------
    //  Insert the current dict and any sub keys depending selection
    // -------------------------------------------------------------------------
    [_arrayManifestContent insertObjects:manifestContentSubset atIndexes:[NSIndexSet indexSetWithIndexesInRange:insertRange]];
    // FIXME -  Here I realod the entire TableView, but could possibly just reload the changed indexes or from changed row to end.
    //          I saw problems when just doing a range update, should investigate to make more efficient.
    DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
    [_tableViewManifestContent reloadData];
    [_tableViewManifestContent endUpdates];
} // updateTableViewSettingsFromManifestContentDict:row

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)segmentedControl:(NSSegmentedControl *)segmentedControl {

    // -------------------------------------------------------------------------
    //  Make sure it's a settings segmented control
    // -------------------------------------------------------------------------
    if (![segmentedControl.superview.class isSubclassOfClass:PFCSegmentedControlCellView.class]) {
        DDLogError(@"SegmentedControl: %@ superview class is: %@", segmentedControl, segmentedControl.superview.class);
        return;
    }

    // -------------------------------------------------------------------------
    //  Get segmented control's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *segmentedControlTag = @(segmentedControl.tag);
    if (segmentedControlTag == nil) {
        DDLogError(@"SegmentedControl: %@ tag is nil", segmentedControl);
        return;
    }
    NSInteger row = segmentedControlTag.integerValue;

    // -----------------------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsSegmentedControl segmented control
    // -----------------------------------------------------------------------------------
    if (segmentedControl == [(PFCSegmentedControlCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO]
                                settingSegmentedControl]) {

        NSString *selectedSegment = [segmentedControl labelForSegment:segmentedControl.selectedSegment];
        if (selectedSegment.length == 0) {
            DDLogError(@"SegmentedControl: %@ selected segment is nil", segmentedControl);
            return;
        }

        NSMutableDictionary *manifestContentDict = [_arrayManifestContent[(NSUInteger)row] mutableCopy];
        manifestContentDict[PFCSettingsKeyValue] = @(segmentedControl.selectedSegment);
        _arrayManifestContent[(NSUInteger)row] = [manifestContentDict copy];

        // ---------------------------------------------------------------------
        //  Add subkeys for selected segmented control
        // ---------------------------------------------------------------------
        [self updateTableViewSettingsFromManifestContentDict:manifestContentDict atRow:row];
    }
} // segmentedControl

- (void)selectFile:(NSButton *)button {

    // -------------------------------------------------------------------------
    //  Get button's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *buttonTag = @(button.tag);
    if (buttonTag == nil) {
        DDLogError(@"Button: %@ has no tag", button);
        return;
    }
    NSInteger row = buttonTag.integerValue;

    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];

    NSMutableDictionary *settingsDict;
    if ([identifier length] != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"Manifest content dict doesn't have an identifier");
        return;
    }

    // -------------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsFile button
    // -------------------------------------------------------------------------
    // FIXME - Might be able to remove/change this check
    if (button == [(PFCFileCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingButtonAdd]) {

        // ---------------------------------------------------------------------
        //  Get open dialog prompt
        // ---------------------------------------------------------------------
        NSString *prompt = manifestContentDict[PFCManifestKeyFilePrompt] ?: @"Select File";

        // ---------------------------------------------------------------------
        //  Get open dialog allowed file types
        // ---------------------------------------------------------------------
        NSMutableArray *allowedFileTypes = [[NSMutableArray alloc] init];
        if (manifestContentDict[PFCManifestKeyAllowedFileTypes] != nil && [manifestContentDict[PFCManifestKeyAllowedFileTypes] isKindOfClass:[NSArray class]]) {
            [allowedFileTypes addObjectsFromArray:manifestContentDict[PFCManifestKeyAllowedFileTypes] ?: @[]];
        }

        if (manifestContentDict[PFCManifestKeyAllowedFileExtensions] != nil && [manifestContentDict[PFCManifestKeyAllowedFileExtensions] isKindOfClass:[NSArray class]]) {
            [allowedFileTypes addObjectsFromArray:manifestContentDict[PFCManifestKeyAllowedFileExtensions] ?: @[]];
        }

        // ---------------------------------------------------------------------
        //  Setup open dialog
        // ---------------------------------------------------------------------
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setTitle:prompt];
        [openPanel setPrompt:@"Select"];
        [openPanel setCanChooseFiles:YES];
        [openPanel setCanChooseDirectories:NO];
        [openPanel setCanCreateDirectories:NO];
        [openPanel setAllowsMultipleSelection:NO];

        if (allowedFileTypes.count != 0) {
            [openPanel setAllowedFileTypes:allowedFileTypes];
        }

        [openPanel beginSheetModalForWindow:_profileEditor.window
                          completionHandler:^(NSInteger result) {
                            if (result == NSModalResponseOK) {
                                NSArray *selectedURLs = openPanel.URLs;
                                NSURL *fileURL = selectedURLs.firstObject;

                                settingsDict[PFCSettingsKeyFilePath] = fileURL.path;
                                _settingsManifest[identifier] = [settingsDict copy];

                                [_tableViewManifestContent beginUpdates];
                                DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
                                [_tableViewManifestContent reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                                     columnIndexes:[NSIndexSet indexSetWithIndex:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"]]];
                                [_tableViewManifestContent endUpdates];
                            }
                          }];
    }
} // selectFile

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {

    // -------------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // -------------------------------------------------------------------------
    if (![[[popUpButton superview] class] isSubclassOfClass:[PFCPopUpButtonCellView class]] && ![[[popUpButton superview] class] isSubclassOfClass:[PFCPopUpButtonLeftCellView class]]) {
        DDLogError(@"PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }

    // -------------------------------------------------------------------------
    //  Get popup button's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *popUpButtonTag = @([popUpButton tag]);
    if (popUpButtonTag == nil) {
        DDLogError(@"PopUpButton: %@ has no tag", popUpButton);
        return;
    }
    NSInteger row = [popUpButtonTag integerValue];

    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];

    NSMutableDictionary *settingsDict;
    if ([identifier length] != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"Manifest content dict doesn't have an identifier");
        return;
    }

    // -------------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // -------------------------------------------------------------------------
    if (popUpButton ==
            [(PFCPopUpButtonCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingPopUpButton] ||
        popUpButton ==
            [(PFCPopUpButtonLeftCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingPopUpButton]) {

        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSString *selectedTitle = [popUpButton titleOfSelectedItem];
        settingsDict[PFCSettingsKeyValue] = selectedTitle;
        _settingsManifest[identifier] = [settingsDict copy];

        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [self updateTableViewSettingsFromManifestContentDict:manifestContentDict atRow:row];
    }
} // popUpButtonSelection

- (void)datePickerSelection:(NSDatePicker *)datePicker {

    // -------------------------------------------------------------------------
    //  Get date picker's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *datePickerTag = @([datePicker tag]);
    if (datePickerTag == nil) {
        DDLogError(@"DatePicker: %@ tag is nil", datePicker);
        return;
    }
    NSInteger row = [datePickerTag integerValue];

    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];

    NSMutableDictionary *settingsDict;
    if ([identifier length] != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"No key returned from manifest dict!");
        return;
    }

    // ------------------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsDatePickerNoTitle date picker
    // ------------------------------------------------------------------------------
    if (datePicker ==
        [(PFCDatePickerNoTitleCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingDatePicker]) {

        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [calendarUS setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];

        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSDate *datePickerDate = datePicker.dateValue;

        NSDateComponents *components = [calendarUS components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:datePickerDate];
        NSDate *date = [calendarUS dateFromComponents:components];

        settingsDict[PFCSettingsKeyValue] = date;
        _settingsManifest[identifier] = [settingsDict copy];

        // ---------------------------------------------------------------------
        //  Update description with time interval from today to selected date
        // ---------------------------------------------------------------------
        NSTextField *description =
            [(PFCDatePickerNoTitleCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO]
                settingDateDescription];
        [description setStringValue:[PFCGeneralUtility dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }
} // datePickerSelection

- (void)controlTextDidChange:(NSNotification *)sender {

    // -------------------------------------------------------------------------
    //  Make sure it's a text field
    // -------------------------------------------------------------------------
    if (![[[sender object] class] isSubclassOfClass:[NSTextField class]]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get current entered text
    // -------------------------------------------------------------------------
    NSString *inputText = [[[sender userInfo] valueForKey:@"NSFieldEditor"] string];

    // -------------------------------------------------------------------------
    //  Get text field's row in the table view
    // -------------------------------------------------------------------------
    NSTextField *textField = [sender object];
    NSNumber *textFieldTag = @(textField.tag);
    if (textFieldTag == nil) {
        return;
    }
    NSInteger row = textFieldTag.integerValue;

    // -------------------------------------------------------------------------
    //  Get current cell identifier in the manifest dict
    // -------------------------------------------------------------------------
    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];

    NSMutableDictionary *settingsDict;
    if (identifier.length != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"No key returned from manifest dict!");
        return;
    }

    // -------------------------------------------------------------------------
    //  Another verification of text field type
    // -------------------------------------------------------------------------
    if ([textField.superview.class isSubclassOfClass:PFCTextFieldHostPortCellView.class] || [textField.superview.class isSubclassOfClass:PFCTextFieldHostPortCheckboxCellView.class]) {
        if (textField == [[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextFieldHost]) {
            settingsDict[@"ValueHost"] = [inputText copy];
        } else if (textField == [[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextFieldPort]) {
            settingsDict[@"ValuePort"] = [inputText copy];
        } else {
            return;
        }

        if ([textField.superview respondsToSelector:@selector(showRequired:)]) {
            BOOL showRequired = NO;
            BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:_profileEditor.settings.displayKeys];
            BOOL requiredHost = [[PFCAvailability sharedInstance] requiredHostForManifestContentDict:manifestContentDict displayKeys:_profileEditor.settings.displayKeys];
            BOOL requiredPort = [[PFCAvailability sharedInstance] requiredPortForManifestContentDict:manifestContentDict displayKeys:_profileEditor.settings.displayKeys];

            if (required || requiredHost || requiredPort) {
                // FIXME - This should ask the current cellView class, which in turn should check any requirements from the dict. This is just the bare minimum implementation to show an example.
                if (required && ([settingsDict[PFCSettingsKeyValueHost] length] == 0 || [settingsDict[PFCSettingsKeyValuePort] length] == 0)) {
                    showRequired = YES;
                }

                if (requiredHost && [settingsDict[PFCSettingsKeyValueHost] length] == 0) {
                    showRequired = YES;
                }

                if (requiredPort && [settingsDict[PFCSettingsKeyValuePort] length] == 0) {
                    showRequired = YES;
                }

                [(PFCTextFieldHostPortCellView *)textField.superview showRequired:showRequired];
            }
        }
        _settingsManifest[identifier] = [settingsDict copy];
    } else if ([textField.superview.class isSubclassOfClass:[PFCTextFieldCheckboxCellView class]]) {
        if (textField == [[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextField]) {
            settingsDict[PFCSettingsKeyValueTextField] = [inputText copy];
            _settingsManifest[identifier] = [settingsDict copy];
        } else {
            return;
        }
    } else if ([textField.superview.class isSubclassOfClass:[PFCRadioButtonCellView class]]) {
        if (textField.identifier.length != 0) {
            settingsDict = [_settingsManifest[textField.identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            settingsDict[PFCSettingsKeyValue] = [inputText copy];
            _settingsManifest[textField.identifier] = [settingsDict copy];
        }
    } else {
        if (textField == [[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextField]) {
            settingsDict[PFCSettingsKeyValue] = [inputText copy];
            if ([textField.superview respondsToSelector:@selector(showRequired:)]) {
                if ([manifestContentDict[PFCManifestKeyRequired] boolValue] && [inputText length] == 0) {
                    [(PFCTextFieldCellView *)[textField superview] showRequired:YES];
                } else if ([manifestContentDict[PFCManifestKeyRequired] boolValue]) {
                    [(PFCTextFieldCellView *)[textField superview] showRequired:NO];
                }
            }
            _settingsManifest[identifier] = [settingsDict copy];
        } else {
            return;
        }
    }

    if ([_selectedManifest[PFCManifestKeyAllowMultiplePayloads] boolValue] && [_selectedManifest[PFCManifestKeyPayloadTabTitle] hasPrefix:identifier]) {
        [self updatePayloadTabTitle:[inputText copy] tabIndex:_selectedTab];
    }

    [self errorForManifest:_selectedManifest updateTabBar:YES];
    [_profileEditor.library reloadManifest:_selectedManifest];
} // controlTextDidChangex

- (void)radioButton:(NSButton *)radioButton {

    // -------------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *buttonTag = @(radioButton.tag);
    if (buttonTag == nil) {
        DDLogError(@"RadioButton: %@ tag is nil", radioButton);
        return;
    }
    NSInteger row = buttonTag.integerValue;

    // -------------------------------------------------------------------------
    //  Get current cell's key in the settings dict
    // -------------------------------------------------------------------------
    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    NSMutableDictionary *settingsDict;
    if ([identifier length] != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"No key returned from manifest dict!");
        return;
    }

    if ([[[radioButton superview] class] isSubclassOfClass:[PFCRadioButtonCellView class]]) {
        settingsDict[PFCSettingsKeyValueRadioButton] = radioButton.title;
    }

    _settingsManifest[identifier] = [settingsDict copy];

    [_tableViewManifestContent beginUpdates];
    DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
    [_tableViewManifestContent reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                         columnIndexes:[NSIndexSet indexSetWithIndex:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"]]];
    [_tableViewManifestContent endUpdates];
} // checkbox

- (void)checkbox:(NSButton *)checkbox {
    // -------------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // -------------------------------------------------------------------------
    NSNumber *buttonTag = @(checkbox.tag);
    if (buttonTag == nil) {
        DDLogError(@"Checkbox: %@ tag is nil", checkbox);
        return;
    }
    NSInteger row = buttonTag.integerValue;

    // -------------------------------------------------------------------------
    //  Get current checkbox state
    // -------------------------------------------------------------------------
    BOOL state = checkbox.state;

    // -------------------------------------------------------------------------
    //  Get current cell's key in the settings dict
    // -------------------------------------------------------------------------
    NSMutableDictionary *manifestContentDict = [_arrayManifestContent[row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    NSMutableDictionary *settingsDict;
    if ([identifier length] != 0) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        DDLogError(@"No key returned from manifest dict!");
        return;
    }

    if ([[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsEnabled class]]) {
        if (checkbox ==
            [(CellViewSettingsEnabled *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettingsEnabled"] row:row makeIfNecessary:NO] settingEnabled]) {
            settingsDict[PFCSettingsKeyEnabled] = @(state);
            _settingsManifest[identifier] = [settingsDict copy];

            if (!_showKeysDisabled) {
                [self updateTableViewSettingsFromManifest:_selectedManifest];
            } else {
                [_tableViewManifestContent beginUpdates];
                // FIXME - Should be able to just reload the current row, but the background doesn't change. Haven't looked into it yet, just realoads all until then.
                // NSRange allColumns = NSMakeRange(0, [[_tableViewSettings tableColumns] count]);
                //[_tableViewSettings reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:allColumns]];
                DDLogVerbose(@"RealodingTableViewFrom: %s", __PRETTY_FUNCTION__);
                [_tableViewManifestContent reloadData];
                [_tableViewManifestContent endUpdates];
            }
            return;
        }

    } else if ([[[checkbox superview] class] isSubclassOfClass:[PFCTextFieldCheckboxCellView class]] || [[[checkbox superview] class] isSubclassOfClass:[PFCTextFieldHostPortCheckboxCellView class]]) {
        if (checkbox == [(PFCTextFieldCheckboxCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO]
                            settingCheckbox] ||
            checkbox == [(PFCTextFieldHostPortCheckboxCellView *)[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO]
                            settingCheckbox]) {
            settingsDict[PFCSettingsKeyValueCheckbox] = @(state);
        }

    } else {
        if (checkbox == [[_tableViewManifestContent viewAtColumn:[_tableViewManifestContent columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingCheckbox]) {
            settingsDict[PFCSettingsKeyValue] = @(state);
        }
    }
    NSLog(@"settingsDict=%@", settingsDict);
    _settingsManifest[identifier] = [settingsDict copy];

    // -------------------------------------------------------------------------
    //  Add subkeys for selected state
    // -------------------------------------------------------------------------
    [self updateTableViewSettingsFromManifestContentDict:manifestContentDict atRow:row];
} // checkbox

- (void)removeSettingsForManifestWithDomain:(NSString *)manifestDomain manifestTabIndex:(NSInteger)manifestTabIndex {
    // -------------------------------------------------------------------------
    //  Remove 'Settings'
    // -------------------------------------------------------------------------
    NSMutableDictionary *manifestDomainSettings = [[_profileEditor profileSettings][manifestDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    NSMutableArray *manifestSettings = [manifestDomainSettings[@"Settings"] mutableCopy] ?: [[NSMutableArray alloc] init];
    if (manifestSettings.count != 0 || manifestTabIndex < manifestSettings.count) {
        [manifestSettings removeObjectAtIndex:manifestTabIndex];
        manifestDomainSettings[@"Settings"] = [manifestSettings mutableCopy];
        [_profileEditor profileSettings][manifestDomain] = [manifestDomainSettings mutableCopy];
    }

    // -------------------------------------------------------------------------
    //  Remove 'SettingsError'
    // -------------------------------------------------------------------------
    NSMutableArray *manifestSettingsError = [manifestDomainSettings[@"SettingsError"] mutableCopy] ?: [[NSMutableArray alloc] init];
    if (manifestSettingsError.count != 0 || manifestTabIndex < manifestSettingsError.count) {
        [manifestSettingsError removeObjectAtIndex:manifestTabIndex];
        manifestDomainSettings[@"SettingsError"] = [manifestSettingsError mutableCopy];
        [_profileEditor profileSettings][manifestDomain] = [manifestDomainSettings mutableCopy];
    }
} // removeSettingsForManifestWithDomain:manifestTabIndex

- (void)didClickRow:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if (row < 0 || _arrayManifestContent.count < row) {
        return;
    }

    /*
    if (![[_profileEditor splitViewWindow] isSubviewCollapsed:[[_profileEditor splitViewWindow] subviews][2]]) {
        [[_viewStatusInfo view] setHidden:YES];
        [[_viewInfoController view] setHidden:NO];
        [_viewInfoController updateInfoForManifestContentDict:_arraySettings[row]];
    }
     */
} // didClickRow

@end
