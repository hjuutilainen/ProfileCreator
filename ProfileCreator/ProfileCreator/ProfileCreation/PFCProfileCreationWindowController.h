//
//  PFCProfileCreationWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCProfileCreationWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property BOOL advancedSettings;

// TableView Menu
@property (weak) IBOutlet NSTableView *tableViewMenu;
- (IBAction)tableViewMenu:(id)sender;
@property NSInteger tableViewMenuSelectedRow;
@property NSMutableArray *tableViewMenuItemsEnabled;
@property NSMutableArray *tableViewMenuItemsDisabled;
@property BOOL columnMenuEnabledHidden;

// TableView Settings

@property (weak) IBOutlet NSTableView *tableViewSettings;
@property NSMutableArray *tableViewSettingsItemsEnabled;
@property NSMutableArray *tableViewSettingsItemsDisabled;
@property BOOL columnSettingsEnabledHidden;

@property (weak) IBOutlet NSView *viewSettingsSuperView;
@property (strong) IBOutlet NSView *viewErrorReadingSettings;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
- (void)checkbox:(NSButton *)checkbox;
- (void)datePickerSelection:(NSDatePicker *)datePicker;
- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton;
- (void)selectFile:(NSButton *)button;
- (void)segmentedControl:(NSSegmentedControl *)segmentedControl;
- (BOOL)updateSubKeysForDict:(NSDictionary *)cellDict valueString:(NSString *)valueString row:(NSInteger)row;

- (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate;

@end
