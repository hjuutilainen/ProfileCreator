//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PFCPayloadLibraryTableView;

typedef NS_ENUM(NSInteger, PFCPayloadLibraries) {
    /** Profile Library Apple **/
    kPFCPayloadLibraryApple,
    /** Profile Library /User/Library/Preferences **/
    kPFCPayloadLibraryUserPreferences,
    /** Profile Library Custom **/
    kPFCPayloadLibraryCustom
};

@protocol PFCPayloadLibraryTableViewDelegate <NSObject>
-(void)validateMenu:(NSMenu*)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row;
@end

@interface PFCProfileCreationWindowController : NSWindowController <NSSplitViewDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, PFCPayloadLibraryTableViewDelegate>

// Window
@property BOOL windowShouldClose;

// Random
@property NSString *selectedPayloadTableViewIdentifier;

// ProfilePayloads
@property (weak)    IBOutlet NSView *viewProfilePayloadsSuperview;
@property (weak)    IBOutlet NSView *viewProfilePayloadsSplitView;
@property (weak)    IBOutlet PFCPayloadLibraryTableView *tableViewProfilePayloads;
@property (readwrite)        NSMutableArray *arrayProfilePayloads;
@property (readwrite)        NSInteger tableViewProfilePayloadsSelectedRow;
- (IBAction)tableViewProfilePayloads:(id)sender;

// PayloadLibrary
@property (weak)    IBOutlet NSView *viewPayloadLibrarySuperview;
@property (weak)    IBOutlet NSView *viewPayloadLibrarySplitView;
@property (weak)    IBOutlet NSView *viewPayloadLibraryMenu;
@property (weak)    IBOutlet PFCPayloadLibraryTableView *tableViewPayloadLibrary;
@property (weak)    IBOutlet NSSegmentedControl *segmentedControlLibrary;
@property (readwrite)        NSMutableArray *arrayPayloadLibrary;
@property (readwrite)        NSInteger tableViewPayloadLibrarySelectedRow;
@property (readwrite)        NSInteger tableViewPayloadLibrarySelectedRowSegment;
@property (readwrite)        NSInteger segmentedControlPayloadLibrarySelectedSegment;
- (IBAction)tableViewPayloadLibrary:(id)sender;
- (IBAction)segmentedControlLibrary:(id)sender;

// PayloadLibraryFooter
@property (weak)    IBOutlet NSSearchField *searchFieldProfileLibrary;
- (IBAction)searchFieldProfileLibrary:(id)sender;

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

// SettingsView
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsError;
@property (weak)    IBOutlet NSTableView *tableViewSettings;
@property (readwrite)        NSMutableArray *arraySettings;

// SettingsViewFooter
@property (weak)    IBOutlet NSPopover *popOverSettings;
@property (weak)    IBOutlet NSButton *buttonCancel;
@property (weak)    IBOutlet NSButton *buttonSave;
- (IBAction)buttonPopOverSettings:(id)sender;
- (IBAction)buttonCancel:(id)sender;
- (IBAction)buttonSave:(id)sender;

// PayloadItemsContextMeny
@property (readwrite)        NSString *clickedPayloadTableViewIdentifier;
@property (readwrite)        NSInteger clickedPayloadTableViewRow;
- (IBAction)menuItemShowInFinder:(id)sender;

// SheetProfileName
@property (strong)  IBOutlet NSWindow *sheetProfileName;
@property (weak)    IBOutlet NSTextField *textFieldSheetProfileName;
@property (weak)    IBOutlet NSButton *buttonSaveSheetProfileName;
- (IBAction)buttonCancelSheetProfileName:(id)sender;
- (IBAction)buttonSaveSheetProfileName:(id)sender;














@property NSString *profileName;
@property int profileType;
@property NSArray *customMenu;
@property BOOL advancedSettings;
@property id parentObject;
@property BOOL columnMenuEnabledHidden;
@property NSDictionary *profileDict;
@property NSMutableDictionary *tableViewSettingsSettings;
@property NSMutableDictionary *tableViewSettingsCurrentSettings;
@property BOOL columnSettingsEnabledHidden;

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
- (void)initializeTableViewMenu;
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