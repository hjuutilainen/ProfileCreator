//
//  PFCTableViewCellsSettings.h
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsCheckbox : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
- (CellViewSettingsCheckbox *)populateCellViewSettingsCheckbox:(CellViewSettingsCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
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
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldTrailing;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
- (void)showRequired:(BOOL)show;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNumber
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldNumber : NSTableCellView
@property NSNumber *stepperValue;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
@property (weak) IBOutlet NSTextField *settingUnit;
@property (weak) IBOutlet NSStepper *settingStepper;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;
- (CellViewSettingsTextFieldNumber *)populateCellViewSettingsTextFieldNumber:(CellViewSettingsTextFieldNumber *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldNoTitle : NSTableCellView
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldTrailing;
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
- (void)showRequired:(BOOL)show;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldCheckbox : NSTableCellView
@property BOOL checkboxState;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextFieldCheckbox *)populateCellViewSettingsTextFieldCheckbox:(CellViewSettingsTextFieldCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldHostPortCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldHostPortCheckbox : NSTableCellView
@property BOOL checkboxState;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextFieldHost;
@property (weak) IBOutlet NSTextField *settingTextFieldPort;
- (CellViewSettingsTextFieldHostPortCheckbox *)populateCellViewSettingsTextFieldHostPortCheckbox:(CellViewSettingsTextFieldHostPortCheckbox *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTemplates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTemplates : NSTableCellView
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
- (CellViewSettingsTemplates *)populateCellViewTemplates:(CellViewSettingsTemplates *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsPopUpNoTitle : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
- (CellViewSettingsPopUpNoTitle *)populateCellViewSettingsPopUpNoTitle:(CellViewSettingsPopUpNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPopUpLeft
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsPopUpLeft : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
- (CellViewSettingsPopUpLeft *)populateCellViewSettingsPopUpLeft:(CellViewSettingsPopUpLeft *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNumberLeft
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldNumberLeft : NSTableCellView
@property NSNumber *stepperValue;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
@property (weak) IBOutlet NSStepper *settingStepper;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;
- (CellViewSettingsTextFieldNumberLeft *)populateCellViewSettingsTextFieldNumberLeft:(CellViewSettingsTextFieldNumberLeft *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckboxNoDescription
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsCheckboxNoDescription : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
- (CellViewSettingsCheckboxNoDescription *)populateCellViewSettingsCheckboxNoDescription:(CellViewSettingsCheckboxNoDescription *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *settingEnabled;
- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
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
#pragma mark CellViewSettingsDatePicker
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsDatePicker : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingDateDescription;
@property (weak) IBOutlet NSDatePicker *settingDatePicker;
- (CellViewSettingsDatePicker *)populateCellViewDatePicker:(CellViewSettingsDatePicker *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsDatePickerNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsDatePickerNoTitle : NSTableCellView
@property (weak) IBOutlet NSDatePicker *settingDatePicker;
@property (weak) IBOutlet NSTextField *settingDateDescription;
- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldDaysHoursNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldDaysHoursNoTitle : NSTableCellView
@property id sender;
@property NSString *cellIdentifier;
@property NSNumber *stepperValueRemovalIntervalDays;
@property NSNumber *stepperValueRemovalIntervalHours;
@property (weak) IBOutlet NSTextField *settingDays;
@property (weak) IBOutlet NSStepper *settingStepperDays;
@property (weak) IBOutlet NSTextField *settingHours;
@property (weak) IBOutlet NSStepper *settingStepperHours;
- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTableView : NSTableCellView <NSTableViewDataSource, NSTableViewDelegate>
@property id sender;
@property NSString *senderIdentifier;
@property NSMutableArray *tableViewContent;
@property NSDictionary *tableViewColumnCellViews;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTableView *settingTableView;
@property (weak) IBOutlet NSSegmentedControl *settingSegmentedControlButton;
- (IBAction)segmentedControlButton:(id)sender;
- (void)popUpButtonSelection:(id)sender;
- (void)checkbox:(NSButton *)checkbox;
- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsFile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsFile : NSTableCellView
@property id fileInfoProcessor;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSView *settingFileView;
@property (weak) IBOutlet NSButton *settingButtonAdd;
@property (weak) IBOutlet NSTextField *settingFileViewPrompt;
@property (weak) IBOutlet NSTextField *settingFileTitle;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel1;
@property (weak) IBOutlet NSTextField *settingFileDescription1;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel2;
@property (weak) IBOutlet NSTextField *settingFileDescription2;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel3;
@property (weak) IBOutlet NSTextField *settingFileDescription3;
@property (weak) IBOutlet NSImageView *settingFileIcon;
- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsSegmentedControl
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsSegmentedControl : NSTableCellView
@property (weak) IBOutlet NSSegmentedControl *settingSegmentedControl;
- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView manifest:(NSDictionary *)manifest row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldHostPort
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldHostPort : NSTableCellView
@property (weak) IBOutlet NSImageView *imageViewRequired;
@property (strong) IBOutlet NSLayoutConstraint *constraintTextFieldPortTrailing;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextFieldHost;
@property (weak) IBOutlet NSTextField *settingTextFieldPort;
- (CellViewSettingsTextFieldHostPort *)populateCellViewSettingsTextFieldHostPort:(CellViewSettingsTextFieldHostPort *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender;
- (void)showRequired:(BOOL)show;
@end