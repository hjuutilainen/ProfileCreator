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

@interface CellViewSettingsTextField : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingTextField;
@end

@interface CellViewSettingsPopUp : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
@end

@interface CellViewSettingsCheckbox : NSTableCellView
@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingDescription;
@end

@interface CellViewSettingsEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *settingEnabled;
@end

@interface CellViewSettingsMinOS : NSTableCellView
@property (weak) IBOutlet NSTextField *settingTextField;
@end