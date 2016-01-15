//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
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
@property NSString *clickedPayloadTableViewIdentifier;

// ProfilePayloads
@property (weak)    IBOutlet NSView *viewProfilePayloadsSuperview;
@property (weak)    IBOutlet NSView *viewProfilePayloadsSplitView;
@property (weak)    IBOutlet PFCPayloadLibraryTableView *tableViewProfilePayloads;
@property (readwrite)        NSMutableArray *arrayProfilePayloads;
@property (readwrite)        NSInteger tableViewProfilePayloadsSelectedRow;
@property (readwrite)        NSInteger tableViewProfilePayloadsClickedRow;
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
@property (readwrite)        NSInteger tableViewPayloadLibraryClickedRow;
@property (readwrite)        NSInteger segmentedControlPayloadLibrarySelectedSegment;
- (IBAction)tableViewPayloadLibrary:(id)sender;
- (IBAction)segmentedControlLibrary:(id)sender;

// PayloadLibrary Arrays
@property (readwrite)        NSMutableArray *arrayPayloadLibraryApple;

@property (readwrite)        NSMutableArray *arrayPayloadLibraryUserPreferences;
@property (readwrite)        NSMutableDictionary *payloadLibraryUserPreferencesSettings;

@property (readwrite)        NSMutableArray *arrayPayloadLibraryCustom;
@property (readwrite)        NSMutableDictionary *payloadLibraryCustomSettings;

// SettingsView
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsError;
@property (weak)    IBOutlet NSTableView *tableViewSettings;
@property (readwrite)        NSMutableArray *arraySettings;



- (IBAction)menuItemShowInFinder:(id)sender;

@property NSString *profileName;
@property int profileType;
@property NSArray *customMenu;
@property BOOL advancedSettings;
@property (strong) IBOutlet NSWindow *sheetProfileName;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileName;
- (IBAction)buttonCancelSheetProfileName:(id)sender;
@property (weak) IBOutlet NSButton *buttonSaveSheetProfileName;
- (IBAction)buttonSaveSheetProfileName:(id)sender;
@property id parentObject;
@property BOOL columnMenuEnabledHidden;
@property NSDictionary *profileDict;
@property NSMutableDictionary *tableViewSettingsSettings;
@property NSMutableDictionary *tableViewSettingsCurrentSettings;
@property BOOL columnSettingsEnabledHidden;

@property (weak) IBOutlet NSButton *buttonCancel;
- (IBAction)buttonCancel:(id)sender;

@property (weak) IBOutlet NSButton *buttonSave;
- (IBAction)buttonSave:(id)sender;

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
#pragma mark Class PFCPayloadLibraryTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface PFCPayloadLibraryTableView : NSTableView
@property id <PFCPayloadLibraryTableViewDelegate>tableViewMenuDelegate;
@end