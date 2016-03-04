//
//  PFCProfileCreationWindowController.h
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

#import "PFCManifestLibrary.h"
#import "PFCProfileCreationInfoView.h"
#import "PFCProfileCreationTab.h"
#import "PFCSplitViews.h"
#import "PFCTableViews.h"
#import "PFCViews.h"
#import "RFOverlayScrollView.h"
#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationWindowController
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileEditor
    : NSWindowController <NSSplitViewDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, PFCTableViewDelegate, PFCProfileCreationInfoDelegate, PFCProfileCreationTabDelegate>

// -------------------------------------------------------------------------
//  Unsorted
// -------------------------------------------------------------------------
@property BOOL advancedSettings;
@property id parentObject;

// -------------------------------------------------------------------------
//  Window
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSSplitView *splitViewWindow;
@property BOOL windowShouldClose;

// -------------------------------------------------------------------------
//  General
// -------------------------------------------------------------------------
@property NSDictionary *profileDict;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property NSDictionary *selectedManifest;

// -------------------------------------------------------------------------
//  Profile Header
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewProfileHeaderSplitView;
@property (weak) IBOutlet NSView *viewProfileHeader;
@property (weak) IBOutlet NSTableView *tableViewProfileHeader;
@property (weak) IBOutlet NSTextField *textFieldProfileName;
@property (weak) IBOutlet NSTextField *textFieldProfileIdentifier;
@property (weak) IBOutlet NSTextField *textFieldProfileIdentifierFormat;

@property (strong) IBOutlet NSLayoutConstraint *constraintProfileHeaderHeight;
@property NSString *profileUUID;
@property (readwrite) NSString *profileName;
@property NSString *profileIdentifier;
@property NSString *profileIdentifierFormat;
@property (readwrite) NSString *profileDescription;
@property (readwrite) BOOL profileHeaderHidden;

- (IBAction)selectTableViewProfileHeader:(id)sender;

// -------------------------------------------------------------------------
//  Profile Settings
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewProfileSettings;
@property (weak) IBOutlet NSButton *checkboxPlatformOSX;
@property (weak) IBOutlet NSButton *checkboxPlatformiOS;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXMaxVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMaxVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonCertificateSigning;
@property (weak) IBOutlet NSPopUpButton *popUpButtonCertificateEncryption;
@property BOOL includePlatformOSX;
@property NSString *osxMaxVersion;
@property NSString *osxMinVersion;
@property BOOL includePlatformiOS;
@property NSString *iosMaxVersion;
@property NSString *iosMinVersion;
@property BOOL showAdvancedSettings;
@property BOOL signProfile;
@property BOOL encryptProfile;

// -------------------------------------------------------------------------
//  Payload
// -------------------------------------------------------------------------
@property (weak) IBOutlet PFCSplitViewPayloadLibrary *splitViewPayload;
@property NSString *selectedPayloadTableViewIdentifier;

// -------------------------------------------------------------------------
//  PayloadProfile
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewPayloadProfileSuperview;
@property (weak) IBOutlet NSView *viewPayloadProfileSplitView;
@property (weak) IBOutlet PFCTableView *tableViewPayloadProfile;
@property (readwrite) NSMutableArray *arrayPayloadProfile;
@property (readwrite) NSInteger tableViewPayloadProfileSelectedRow;

- (IBAction)selectTableViewPayloadProfile:(id)sender;

// -------------------------------------------------------------------------
//  PayloadLibrary
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewPayloadLibrarySuperview;
@property (weak) IBOutlet RFOverlayScrollView *viewPayloadLibraryScrollView;
@property (weak) IBOutlet NSView *viewPayloadLibrarySplitView;
@property (weak) IBOutlet NSView *viewPayloadLibraryMenuSuperview;
@property (weak) IBOutlet NSView *viewPayloadLibraryNoMatches;
@property (weak) IBOutlet NSView *viewPayloadLibraryNoManifests;
@property (weak) IBOutlet PFCTableView *tableViewPayloadLibrary;
@property (readwrite) NSMutableArray *arrayPayloadLibrary;
@property (readwrite) NSInteger tableViewPayloadLibrarySelectedRow;
@property (readwrite) NSInteger tableViewPayloadLibrarySelectedRowSegment;
@property (readwrite) NSInteger segmentedControlPayloadLibrarySelectedSegment;

- (IBAction)selectTableViewPayloadLibrary:(id)sender;
- (void)selectPayloadLibrary:(PFCPayloadLibrary)payloadLibrary;

// PayloadLibraryApple
@property (readwrite) NSMutableArray *arrayPayloadLibraryApple;
@property (readwrite) BOOL isSearchingPayloadLibraryApple;
@property (readwrite) NSString *searchStringPayloadLibraryApple;

// PayloadLibraryUserPreferences
@property (readwrite) NSMutableArray *arrayPayloadLibraryUserPreferences;
@property (readwrite) BOOL isSearchingPayloadLibraryUserPreferences;
@property (readwrite) NSString *searchStringPayloadLibraryUserPreferences;

// PayladLibraryCustom
@property (readwrite) NSMutableArray *arrayPayloadLibraryCustom;
@property (readwrite) BOOL isSearchingPayloadLibraryCustom;
@property (readwrite) NSString *searchStringPayloadLibraryCustom;

// PayladLibraryMCX
@property (readwrite) NSMutableArray *arrayPayloadLibraryMCX;
@property (readwrite) BOOL isSearchingPayloadLibraryMCX;
@property (readwrite) NSString *searchStringPayloadLibraryMCX;

// -------------------------------------------------------------------------
//  PayloadFooter
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewPayloadFooterSuperview;
@property (weak) IBOutlet NSView *viewPayloadFooterSearch;
@property (weak) IBOutlet NSSearchField *searchFieldPayloadLibrary;
@property (weak) IBOutlet NSButton *buttonAdd;
@property (strong) IBOutlet NSLayoutConstraint *constraintSearchFieldLeading;
@property (weak) IBOutlet NSMenu *menuButtonAdd;
@property (readwrite) BOOL searchNoMatchesHidden;
@property (readwrite) BOOL libraryNoManifestsHidden;
@property (readwrite) BOOL buttonAddHidden;
@property (readwrite) BOOL payloadLibrarySplitViewCollapsed;

- (IBAction)searchFieldPayloadLibrary:(id)sender;
- (IBAction)buttonAdd:(id)sender;

// -------------------------------------------------------------------------
//  SettingsHeader
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewSettingsHeaderSplitView;
@property (weak) IBOutlet NSView *viewSettingsHeader;
@property (weak) IBOutlet NSImageView *imageViewSettingsHeaderIcon;
@property (weak) IBOutlet NSTextField *textFieldSettingsHeaderTitle;
@property (strong) IBOutlet NSLayoutConstraint *constraintSettingsHeaderHeight;
@property (readwrite) BOOL settingsHeaderHidden;

// -------------------------------------------------------------------------
//  PayloadTabBar
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSStackView *stackViewTabBar;
@property BOOL tabBarHidden;
@property BOOL tabBarButtonHidden;
@property NSUInteger tabIndexSelected;
@property NSMutableArray *arrayPayloadTabs;

- (IBAction)buttonAddPayload:(id)sender;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewSettingsSuperView;
@property (weak) IBOutlet NSView *viewSettingsSplitView;
@property (weak) IBOutlet NSView *viewSettingsStatus;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorSettingsStatusLoading;
@property (weak) IBOutlet NSTextField *textFieldSettingsStatus;
@property (weak) IBOutlet PFCTableView *tableViewSettings;
@property (readwrite) NSMutableArray *arraySettings;
@property (readwrite) NSMutableDictionary *settingsProfile;
@property (readwrite) NSMutableDictionary *settingsManifest;
@property (readwrite) NSMutableDictionary *settingsLocalManifest;
@property (readwrite) BOOL settingsHidden;
@property (readwrite) BOOL showSettingsLocal;
@property (readwrite) BOOL settingsStatusLoading;
@property (readwrite) BOOL settingsStatusHidden;

// -------------------------------------------------------------------------
//  SettingsFooter
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSPopover *popOverSettings;
@property (weak) IBOutlet NSButton *buttonCancel;
@property (weak) IBOutlet NSButton *buttonSave;
@property (weak) IBOutlet NSButton *buttonToggleInfo;
@property BOOL showKeysDisabled;
@property BOOL showKeysHidden;
@property BOOL showKeysSupervised;

- (IBAction)buttonPopOverSettings:(id)sender;
- (IBAction)buttonCancel:(id)sender;
- (IBAction)buttonSave:(id)sender;
- (IBAction)buttonToggleInfo:(id)sender;

// -------------------------------------------------------------------------
//  InfoHeader
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewInfoHeaderSplitView;
@property (weak) IBOutlet PFCViewInfo *viewInfoHeader;

// -------------------------------------------------------------------------
//  Info
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewInfoSplitView;
@property (weak) IBOutlet PFCViewInfo *viewInfoNoSelection;
@property (strong) PFCProfileCreationInfoView *viewInfoController;
@property (readwrite) BOOL infoSplitViewCollapsed;

// -------------------------------------------------------------------------
//  InfoFooter
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewInfoFooterSplitView;

// -------------------------------------------------------------------------
//  Payload Context Menu
// -------------------------------------------------------------------------
@property (readwrite) NSString *clickedPayloadTableViewIdentifier;
@property (readwrite) NSInteger clickedPayloadTableViewRow;
- (IBAction)menuItemShowInFinder:(id)sender;

// -------------------------------------------------------------------------
//  Sheet - Profile Name
// -------------------------------------------------------------------------
@property (strong) IBOutlet NSWindow *sheetProfileName;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileNameTitle;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileNameMessage;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileName;
@property (weak) IBOutlet NSButton *buttonSaveSheetProfileName;

- (IBAction)buttonCancelSheetProfileName:(id)sender;
- (IBAction)buttonSaveSheetProfileName:(id)sender;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
- (void)checkbox:(NSButton *)checkbox;
- (void)checkboxMenuEnabled:(NSButton *)checkbox;
- (void)datePickerSelection:(NSDatePicker *)datePicker;
- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton;
- (void)selectFile:(NSButton *)button;
- (void)segmentedControl:(NSSegmentedControl *)segmentedControl;
- (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate;
- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender;
@end
