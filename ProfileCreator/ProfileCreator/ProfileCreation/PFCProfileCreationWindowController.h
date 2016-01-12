//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PFCPayloadLibraryes) {
    /** Profile Library Apple **/
    kPFCPayloadLibraryApple,
    /** Profile Library /User/Library/Preferences **/
    kPFCPayloadLibraryUserPreferences,
    /** Profile Library Custom **/
    kPFCPayloadLibraryCustom
};

@interface PFCProfileCreationWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>

// Window
@property BOOL windowShouldClose;

// Random
@property NSString *selectedPayloadTableViewIdentifier;

// ProfilePayloads
@property (weak)    IBOutlet NSView *viewProfilePayloadsSuperview;
@property (weak)    IBOutlet NSView *viewProfilePayloadsSplitView;
@property (weak)    IBOutlet NSTableView *tableViewProfilePayloads;
@property (readwrite)        NSMutableArray *arrayProfilePayloads;
@property (readwrite)        NSInteger tableViewProfilePayloadsSelectedRow;
- (IBAction)tableViewProfilePayloads:(id)sender;

// PayloadLibrary
@property (weak)    IBOutlet NSView *viewPayloadLibrarySuperview;
@property (weak)    IBOutlet NSView *viewPayloadLibrarySplitView;
@property (weak)    IBOutlet NSTableView *tableViewPayloadLibrary;
@property (weak)    IBOutlet NSSegmentedControl *segmentedControlLibrary;
@property (readwrite)        NSMutableArray *arrayPayloadLibrary;
@property (readwrite)        NSInteger tableViewPayloadLibrarySelectedRow;
@property (readwrite)        NSInteger segmentedControlLibrarySelectedSegment;
- (IBAction)tableViewPayloadLibrary:(id)sender;
- (IBAction)segmentedControlLibrary:(id)sender;

// PayloadLibrary Arrays
@property (readwrite)        NSMutableArray *arrayPayloadLibraryApple;
@property (readwrite)        NSMutableArray *arrayPayloadLibraryUserPreferences;
@property (readwrite)        NSMutableArray *arrayPayloadLibraryCustom;

// SettingsView
@property (weak)    IBOutlet NSView *viewSettingsSuperView;
@property (weak)    IBOutlet NSView *viewSettingsSplitView;
@property (weak)    IBOutlet NSView *viewSettingsError;
@property (weak)    IBOutlet NSTableView *tableViewSettings;
@property (readwrite)        NSMutableArray *arraySettings;




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
