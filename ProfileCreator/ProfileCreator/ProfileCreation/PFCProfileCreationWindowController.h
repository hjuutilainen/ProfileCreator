//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFOverlayScrollView.h"
#import "PFCSplitViewPayloadLibrary.h"
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
@property NSArray *customMenu;
@property BOOL advancedSettings;
@property id parentObject;
@property BOOL columnMenuEnabledHidden;
@property BOOL columnSettingsEnabledHidden;
@property NSMutableDictionary *tableViewSettingsSettings;
@property NSMutableDictionary *tableViewSettingsCurrentSettings;

// -------------------------------------------------------------------------
//  Window
// -------------------------------------------------------------------------
@property BOOL windowShouldClose;

// -------------------------------------------------------------------------
//  General
// -------------------------------------------------------------------------
@property int profileType;
@property NSDictionary *profileDict;

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
@property (readwrite)        NSString *profileName;
@property (readwrite)        BOOL payloadHeaderHidden;
@property (strong)  IBOutlet NSLayoutConstraint *constraintPayloadHeaderHeight;

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
@property (readwrite)        BOOL payloadLibraryCollapsed;
- (IBAction)searchFieldPayloadLibrary:(id)sender;

// -------------------------------------------------------------------------
//  SettingsHeader
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsHeaderSplitView;
@property (weak)    IBOutlet NSView *viewSettingsHeader;
@property (weak)    IBOutlet NSImageView *imageViewSettingsHeaderIcon;
@property (weak)    IBOutlet NSTextField *textFieldSettingsHeaderTitle;
@property (readwrite)        BOOL settingsHeaderHidden;
@property (strong)  IBOutlet NSLayoutConstraint *constraintSettingsHeaderHeight;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsError;
@property (readwrite)        NSMutableArray *arraySettings;
@property (weak)    IBOutlet NSTableView *tableViewSettings;

// -------------------------------------------------------------------------
//  SettingsFooter
// -------------------------------------------------------------------------
@property (weak)    IBOutlet NSPopover *popOverSettings;
@property (weak)    IBOutlet NSButton *buttonCancel;
@property (weak)    IBOutlet NSButton *buttonSave;
- (IBAction)buttonPopOverSettings:(id)sender;
- (IBAction)buttonCancel:(id)sender;
- (IBAction)buttonSave:(id)sender;

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