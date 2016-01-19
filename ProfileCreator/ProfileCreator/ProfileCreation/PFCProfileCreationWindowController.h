//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFCCustomViews.h"
#import "RFOverlayScrollView.h"
#import "PFCSplitViews.h"
@class PFCPayloadLibraryTableView;

typedef NS_ENUM(NSInteger, PFCPayloadLibraries) {
    /** Profile Library Apple **/
    kPFCPayloadLibraryApple,
    /** Profile Library ~/Library/Preferences **/
    kPFCPayloadLibraryUserPreferences,
    /** Profile Library Custom **/
    kPFCPayloadLibraryCustom
};

@protocol PFCPayloadLibraryTableViewDelegate <NSObject>
-(void)validateMenu:(NSMenu*)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row;
@end

@interface PFCProfileCreationWindowController : NSWindowController <NSSplitViewDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, PFCPayloadLibraryTableViewDelegate>

// -------------------------------------------------------------------------
//  Unsorted
// -------------------------------------------------------------------------
@property BOOL advancedSettings;
@property id parentObject;

// -------------------------------------------------------------------------
//  Window
// -------------------------------------------------------------------------
@property BOOL windowShouldClose;
@property (weak) IBOutlet NSSplitView *splitViewWindow;

// -------------------------------------------------------------------------
//  General
// -------------------------------------------------------------------------
@property NSDictionary *profileDict;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property NSMutableDictionary *settingsProfile;
@property NSMutableDictionary *settingsManifest;

// -------------------------------------------------------------------------
//  Payload
// -------------------------------------------------------------------------
@property (weak)    IBOutlet PFCSplitViewPayloadLibrary *splitViewPayload;
@property NSString *selectedPayloadTableViewIdentifier;

// -------------------------------------------------------------------------
//  Payload Header
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewPayloadHeaderSplitView;
@property (weak)    IBOutlet NSView *viewPayloadHeader;
@property (weak)    IBOutlet NSTextField *textFieldProfileName;
@property (strong)  IBOutlet NSLayoutConstraint *constraintPayloadHeaderHeight;
@property (readwrite)        NSString *profileName;
@property (readwrite)        BOOL payloadHeaderHidden;

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
@property (readwrite)        NSMutableDictionary *payloadLibraryUserPreferencesSettings;

// PayladLibraryCustom
@property (readwrite)        NSMutableArray *arrayPayloadLibraryCustom;
@property (readwrite)        BOOL isSearchingPayloadLibraryCustom;
@property (readwrite)        NSString *searchStringPayloadLibraryCustom;
@property (readwrite)        NSMutableDictionary *payloadLibraryCustomSettings;

// -------------------------------------------------------------------------
//  PayloadFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewPayloadFooterSuperview;
@property (weak)    IBOutlet NSView *viewPayloadFooterSearch;
@property (weak)    IBOutlet NSSearchField *searchFieldPayloadLibrary;
@property (weak)    IBOutlet NSButton *buttonAdd;
@property (strong)  IBOutlet NSLayoutConstraint *constraintSearchFieldLeading;
@property (readwrite)        BOOL searchNoMatchesHidden;
@property (readwrite)        BOOL buttonAddHidden;
@property (readwrite)        BOOL payloadLibrarySplitViewCollapsed;
- (IBAction)searchFieldPayloadLibrary:(id)sender;
- (IBAction)buttonAdd:(id)sender;

// -------------------------------------------------------------------------
//  SettingsHeader
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsHeaderSplitView;
@property (weak)    IBOutlet NSView *viewSettingsHeader;
@property (weak)    IBOutlet NSImageView *imageViewSettingsHeaderIcon;
@property (weak)    IBOutlet NSTextField *textFieldSettingsHeaderTitle;
@property (strong)  IBOutlet NSLayoutConstraint *constraintSettingsHeaderHeight;
@property (readwrite)        BOOL settingsHeaderHidden;
@property (readwrite)        BOOL settingsErrorHidden;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsError;
@property (weak)    IBOutlet NSTableView *tableViewSettings;
@property (readwrite)        NSMutableArray *arraySettings;

// -------------------------------------------------------------------------
//  SettingsFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSPopover *popOverSettings;
@property (weak)    IBOutlet NSButton *buttonCancel;
@property (weak)    IBOutlet NSButton *buttonSave;
@property (weak)    IBOutlet NSButton *buttonToggleInfo;
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
@property (weak)    IBOutlet PFCViewInfo *viewInfo;
@property (readwrite)        BOOL infoSplitViewCollapsed;


// -------------------------------------------------------------------------
//  InfoFooter
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewInfoFooterSplitView;

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
- (BOOL)updateSubKeysForDict:(NSDictionary *)cellDict valueString:(NSString *)valueString row:(NSInteger)row;
- (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate;
- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class: PFCPayloadLibraryTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface PFCPayloadLibraryTableView : NSTableView
@property id <PFCPayloadLibraryTableViewDelegate>tableViewMenuDelegate;
@end