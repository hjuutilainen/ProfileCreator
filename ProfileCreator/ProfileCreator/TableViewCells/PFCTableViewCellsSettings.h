//
//  PFCTableViewCellsSettings.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTableViewCellsSettings : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPadding
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsPadding : NSTableCellView
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextField : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldNoTitle : NSTableCellView
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUp
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsPopUp : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsCheckbox : NSTableCellView
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
- (CellViewSettingsCheckbox *)populateCellViewCheckbox:(CellViewSettingsCheckbox *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *settingEnabled;
- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsMinOS
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsMinOS : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTextField;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsDatePickerNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsDatePickerNoTitle : NSTableCellView
@property (weak) IBOutlet NSDatePicker *settingDatePicker;
@property (weak) IBOutlet NSTextField *settingDescription;
- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldDaysHoursNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldDaysHoursNoTitle : NSTableCellView
@property NSNumber *stepperValueRemovalIntervalDays;
@property NSNumber *stepperValueRemovalIntervalHours;
@property (weak) IBOutlet NSTextField *settingDays;
@property (weak) IBOutlet NSStepper *settingStepperDays;
@property (weak) IBOutlet NSTextField *settingHours;
@property (weak) IBOutlet NSStepper *settingStepperHours;
- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTableView : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTableView *settingTableView;
@property (weak) IBOutlet NSButton *settingButtonAdd;
@property (weak) IBOutlet NSButton *settingButtonRemove;
- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsFile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsFile : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSView *settingFileView;
@property (weak) IBOutlet NSButton *settingButtonAdd;
@property (weak) IBOutlet NSTextField *settingFileViewPrompt;
@property (weak) IBOutlet NSTextField *settingFileTitle;
@property (weak) IBOutlet NSTextField *settingFileDescription;
@property (weak) IBOutlet NSImageView *settingFileIcon;
- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end