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

#import <Cocoa/Cocoa.h>
#import "PFCViews.h"
#import "RFOverlayScrollView.h"
#import "PFCSplitViews.h"
#import "PFCProfileCreationInfoView.h"
#import "PFCProfileCreationTab.h"
@class PFCPayloadLibraryTableView;
@class PFCSettingsTableView;

typedef NS_ENUM(NSInteger, PFCPayloadLibraries) {
    /** Profile Library Apple **/
    kPFCPayloadLibraryApple,
    /** Profile Library ~/Library/Preferences **/
    kPFCPayloadLibraryUserPreferences,
    /** Profile Library Custom **/
    kPFCPayloadLibraryCustom
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark Protocol: PFCPayloadLibraryTableViewDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCPayloadLibraryTableViewDelegate <NSObject>
-(void)validateMenu:(NSMenu*)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark Protocol: PFCSettingsTableViewDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCSettingsTableViewDelegate <NSObject>
- (void)didClickRow:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationWindowController
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileCreationWindowController : NSWindowController <NSSplitViewDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, PFCPayloadLibraryTableViewDelegate, PFCSettingsTableViewDelegate, PFCProfileCreationInfoDelegate>

// -------------------------------------------------------------------------
//  Unsorted
// -------------------------------------------------------------------------
@property                   BOOL advancedSettings;

@property id parentObject;

// -------------------------------------------------------------------------
//  Window
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSSplitView *splitViewWindow;
@property                    BOOL windowShouldClose;

// -------------------------------------------------------------------------
//  General
// -------------------------------------------------------------------------
@property                    NSDictionary *profileDict;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property                    NSDictionary *selectedManifest;

// -------------------------------------------------------------------------
//  Profile Header
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewProfileHeaderSplitView;
@property (weak)    IBOutlet NSView *viewProfileHeader;
@property (weak)    IBOutlet NSTableView *tableViewProfileHeader;
@property (weak)    IBOutlet NSTextField *textFieldProfileName;
@property (strong)  IBOutlet NSLayoutConstraint *constraintProfileHeaderHeight;
@property                    NSString *profileUUID;
@property (readwrite)        NSString *profileName;
@property (readwrite)        NSString *profileDescription;
@property (readwrite)        BOOL profileHeaderHidden;
- (IBAction)selectTableViewProfileHeader:(id)sender;

// -------------------------------------------------------------------------
//  Profile Settings
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewProfileSettings;
@property (weak) IBOutlet NSButton *checkboxPlatformOSX;
@property (weak) IBOutlet NSButton *checkboxPlatformiOS;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXLowest;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXHighest;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSLowest;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSHighest;
@property                 BOOL includePlatformOSX;
@property                 BOOL includePlatformiOS;
@property                 BOOL showAdvancedSettings;

// -------------------------------------------------------------------------
//  Payload
// -------------------------------------------------------------------------
@property (weak)    IBOutlet PFCSplitViewPayloadLibrary *splitViewPayload;
@property                    NSString *selectedPayloadTableViewIdentifier;

// -------------------------------------------------------------------------
//  PayloadProfile
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewPayloadProfileSuperview;
@property (weak)    IBOutlet NSView *viewPayloadProfileSplitView;
@property (weak)    IBOutlet PFCPayloadLibraryTableView *tableViewPayloadProfile;
@property (readwrite)        NSMutableArray *arrayPayloadProfile;
@property (readwrite)        NSInteger tableViewPayloadProfileSelectedRow;
- (IBAction)selectTableViewPayloadProfile:(id)sender;

// -------------------------------------------------------------------------
//  PayloadLibrary
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewPayloadLibrarySuperview;
@property (weak)    IBOutlet RFOverlayScrollView *viewPayloadLibraryScrollView;
@property (weak)    IBOutlet NSView *viewPayloadLibrarySplitView;
@property (weak)    IBOutlet NSView *viewPayloadLibraryMenu;
@property (weak)    IBOutlet NSView *viewPayloadLibraryMenuSuperview;
@property (weak)    IBOutlet NSBox *linePayloadLibraryMenuTop;
@property (weak)    IBOutlet NSBox *linePayloadLibraryMenuBottom;
@property (weak)    IBOutlet NSView *viewPayloadLibraryNoMatches;
@property (weak)    IBOutlet PFCPayloadLibraryTableView *tableViewPayloadLibrary;
@property (weak)    IBOutlet NSSegmentedControl *segmentedControlPayloadLibrary;
@property (readwrite)        NSMutableArray *arrayPayloadLibrary;
@property (readwrite)        NSInteger tableViewPayloadLibrarySelectedRow;
@property (readwrite)        NSInteger tableViewPayloadLibrarySelectedRowSegment;
@property (readwrite)        NSInteger segmentedControlPayloadLibrarySelectedSegment;
- (IBAction)selectTableViewPayloadLibrary:(id)sender;
- (IBAction)selectSegmentedControlPayloadLibrary:(id)sender;

// PayloadLibraryApple
@property (readwrite)        NSMutableArray *arrayPayloadLibraryApple;
@property (readwrite)        BOOL isSearchingPayloadLibraryApple;
@property (readwrite)        NSString *searchStringPayloadLibraryApple;

// PayloadLibraryUserPreferences
@property (readwrite)        NSMutableArray *arrayPayloadLibraryUserPreferences;
@property (readwrite)        BOOL isSearchingPayloadLibraryUserPreferences;
@property (readwrite)        NSString *searchStringPayloadLibraryUserPreferences;

// PayladLibraryCustom
@property (readwrite)        NSMutableArray *arrayPayloadLibraryCustom;
@property (readwrite)        BOOL isSearchingPayloadLibraryCustom;
@property (readwrite)        NSString *searchStringPayloadLibraryCustom;

// -------------------------------------------------------------------------
//  PayloadFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewPayloadFooterSuperview;
@property (weak)    IBOutlet NSView *viewPayloadFooterSearch;
@property (weak)    IBOutlet NSSearchField *searchFieldPayloadLibrary;
@property (weak)    IBOutlet NSButton *buttonAdd;
@property (strong)  IBOutlet NSLayoutConstraint *constraintSearchFieldLeading;
@property (weak)    IBOutlet NSMenu *menuButtonAdd;
@property (readwrite)        BOOL searchNoMatchesHidden;
@property (readwrite)        BOOL buttonAddHidden;
@property (readwrite)        BOOL payloadLibrarySplitViewCollapsed;
- (IBAction)searchFieldPayloadLibrary:(id)sender;
- (IBAction)buttonAdd:(id)sender;
- (IBAction)menuItemAddMobileconfig:(id)sender;
- (IBAction)menuItemAddPlist:(id)sender;


// -------------------------------------------------------------------------
//  SettingsHeader
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsHeaderSplitView;
@property (weak)    IBOutlet NSView *viewSettingsHeader;
@property (weak)    IBOutlet NSImageView *imageViewSettingsHeaderIcon;
@property (weak)    IBOutlet NSTextField *textFieldSettingsHeaderTitle;
@property (strong)  IBOutlet NSLayoutConstraint *constraintSettingsHeaderHeight;
@property (readwrite)        BOOL settingsHeaderHidden;

// -------------------------------------------------------------------------
//  PayloadTabBar
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSStackView *stackViewTabBar;
@property                 BOOL tabBarHidden;
@property                 BOOL tabBarButtonHidden;
@property                 NSInteger tabIndexSelected;
@property                 NSMutableArray *arrayPayloadTabs;
- (IBAction)buttonAddPayload:(id)sender;


// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsStatus;
@property (weak)    IBOutlet NSProgressIndicator *progressIndicatorSettingsStatusLoading;
@property (weak)    IBOutlet NSTextField *textFieldSettingsStatus;
@property (weak)    IBOutlet PFCSettingsTableView *tableViewSettings;
@property (readwrite)        NSMutableArray *arraySettings;
@property (readwrite)        NSMutableDictionary *settingsProfile;
@property (readwrite)        NSMutableDictionary *settingsManifest;
@property (readwrite)        NSMutableDictionary *settingsLocal;
@property (readwrite)        NSMutableDictionary *settingsLocalManifest;
@property (readwrite)        BOOL settingsHidden;
@property (readwrite)        BOOL showSettingsLocal;
@property (readwrite)        BOOL settingsStatusLoading;
@property (readwrite)        BOOL settingsStatusHidden;

// -------------------------------------------------------------------------
//  SettingsFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSPopover *popOverSettings;
@property (weak)    IBOutlet NSButton *buttonCancel;
@property (weak)    IBOutlet NSButton *buttonSave;
@property (weak)    IBOutlet NSButton *buttonToggleInfo;
@property                    BOOL showKeysDisabled;
@property                    BOOL showKeysHidden;
- (IBAction)buttonPopOverSettings:(id)sender;
- (IBAction)buttonCancel:(id)sender;
- (IBAction)buttonSave:(id)sender;
- (IBAction)buttonToggleInfo:(id)sender;

// -------------------------------------------------------------------------
//  InfoHeader
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewInfoHeaderSplitView;
@property (weak)    IBOutlet PFCViewInfo *viewInfoHeader;

// -------------------------------------------------------------------------
//  Info
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewInfoSplitView;
@property (weak)    IBOutlet PFCViewInfo *viewInfoNoSelection;
@property (strong)           PFCProfileCreationInfoView *viewInfoController;
@property (readwrite)        BOOL infoSplitViewCollapsed;


// -------------------------------------------------------------------------
//  InfoFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewInfoFooterSplitView;

// -------------------------------------------------------------------------
//  Payload Context Menu
// -------------------------------------------------------------------------
@property (readwrite)        NSString *clickedPayloadTableViewIdentifier;
@property (readwrite)        NSInteger clickedPayloadTableViewRow;
- (IBAction)menuItemShowInFinder:(id)sender;

// -------------------------------------------------------------------------
//  Sheet - Profile Name
// -------------------------------------------------------------------------
@property (strong)  IBOutlet NSWindow *sheetProfileName;
@property (weak)    IBOutlet NSTextField *textFieldSheetProfileName;
@property (weak)    IBOutlet NSButton *buttonSaveSheetProfileName;
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class: PFCPayloadLibraryTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface PFCPayloadLibraryTableView : NSTableView
@property id <PFCPayloadLibraryTableViewDelegate>tableViewDelegate;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class: PFCSettingsTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface PFCSettingsTableView : NSTableView
@property id <PFCSettingsTableViewDelegate>tableViewDelegate;
@end