//
//  PFCCellTypePopUpButton.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCellTypePopUpButton.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCPopUpButtonCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonCellView *)populateCellView:(PFCPopUpButtonCellView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewPopUpButton:settings:row

@end

@interface PFCPopUpButtonLeftCellView ()

@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonLeftCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonLeftCellView *)populateCellView:(PFCPopUpButtonLeftCellView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewPopUpButtonLeft:settings:row

@end

@interface PFCPopUpButtonNoTitleCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingDescription;

@end

@implementation PFCPopUpButtonNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCPopUpButtonNoTitleCellView *)populateCellView:(PFCPopUpButtonNoTitleCellView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    NSString *selectedItem;
    if ( [settings[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settings[PFCSettingsKeyValue];
    } else if (  [manifest[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifest[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[PFCSettingsKeyValue] length] != 0 ) {
        selectedItem = settingsLocal[PFCSettingsKeyValue];
    }
    
    if ( [selectedItem length] != 0 ) {
        [[cellView settingPopUpButton] selectItemWithTitle:selectedItem];
    } else if ( [[[cellView settingPopUpButton] itemArray] count] != 0 ) {
        [[cellView settingPopUpButton] selectItemAtIndex:0];
    }
    
    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ( [manifest[PFCManifestKeyIndentLeft] boolValue] ) {
        [[cellView constraintLeading] setConstant:102];
    } else if ( manifest[PFCManifestKeyIndentLevel] != nil ) {
        CGFloat constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:manifest[PFCManifestKeyIndentLevel] baseConstant:@8];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:8];
    }
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsPopUpButtonNoTitle:settings:row

@end
