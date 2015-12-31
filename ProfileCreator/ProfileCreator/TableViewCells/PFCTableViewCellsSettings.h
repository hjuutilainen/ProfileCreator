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
- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsTextFieldNumber *)populateCellViewSettingsTextFieldNumber:(CellViewSettingsTextFieldNumber *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldNoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldNoTitle : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsTextFieldCheckbox *)populateCellViewSettingsTextFieldCheckbox:(CellViewSettingsTextFieldCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsTextFieldHostPortCheckbox *)populateCellViewSettingsTextFieldHostPortCheckbox:(CellViewSettingsTextFieldHostPortCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsPopUpNoTitle *)populateCellViewSettingsPopUpNoTitle:(CellViewSettingsPopUpNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsPopUpLeft *)populateCellViewSettingsPopUpLeft:(CellViewSettingsPopUpLeft *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsTextFieldNumberLeft *)populateCellViewSettingsTextFieldNumberLeft:(CellViewSettingsTextFieldNumberLeft *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckbox
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsCheckbox : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
- (CellViewSettingsCheckbox *)populateCellViewSettingsCheckbox:(CellViewSettingsCheckbox *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsCheckboxNoDescription
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsCheckboxNoDescription : NSTableCellView
@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSButton *settingCheckbox;
- (CellViewSettingsCheckboxNoDescription *)populateCellViewSettingsCheckboxNoDescription:(CellViewSettingsCheckboxNoDescription *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *settingEnabled;
- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTableView : NSTableCellView <NSTableViewDataSource, NSTableViewDelegate>
@property id sender;
@property NSInteger senderRow;
@property NSMutableArray *tableViewContent;
@property NSDictionary *tableViewColumnCellViews;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTableView *settingTableView;
@property (weak) IBOutlet NSButton *settingButtonAdd;
- (IBAction)settingButtonAdd:(id)sender;
@property (weak) IBOutlet NSButton *settingButtonRemove;
- (IBAction)settingButtonRemove:(id)sender;
- (void)popUpButtonSelection:(id)sender;
- (CellViewSettingsTableView *)populateCellViewSettingsTableView:(CellViewSettingsTableView *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
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
- (CellViewSettingsFile *)populateCellViewSettingsFile:(CellViewSettingsFile *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsSegmentedControl
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsSegmentedControl : NSTableCellView
@property (weak) IBOutlet NSSegmentedControl *settingSegmentedControl;
- (CellViewSettingsSegmentedControl *)populateCellViewSettingsSegmentedControl:(CellViewSettingsSegmentedControl *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTextFieldHostPort
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTextFieldHostPort : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextFieldHost;
@property (weak) IBOutlet NSTextField *settingTextFieldPort;
- (CellViewSettingsTextFieldHostPort *)populateCellViewSettingsTextFieldHostPort:(CellViewSettingsTextFieldHostPort *)cellView manifestDict:(NSDictionary *)manifestDict settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end