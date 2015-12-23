//
//  PFCTableViewCellsSettingsTableView.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-13.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsSettingsTableView.h"
#import "PFCTableViewCellsSettings.h"

@implementation PFCTableViewCellsSettingsTableView
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewTextField *)populateCellViewTextField:(CellViewTextField *)cellView settingDict:(NSDictionary *)settingDict columnIdentifier:(NSString *)columnIdentifier row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settingDict[@"Value"] ?: @"";
    if ( [value length] == 0 ) {
        if ( [settingDict[@"DefaultValue"] length] != 0 ) {
            value = settingDict[@"DefaultValue"] ?: @"";
        }
    }
    [[cellView textField] setDelegate:sender];
    [[cellView textField] setStringValue:value];
    [[cellView textField] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ( [settingDict[@"PlaceholderValue"] length] != 0 ) {
        [[cellView textField] setPlaceholderString:settingDict[@"PlaceholderValue"] ?: @""];
    } else {
        [[cellView textField] setPlaceholderString:@""];
    }
    
    return cellView;
} // populateCellViewTextField:settingDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPopUpButton
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewPopUpButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewPopUpButton *)populateCellViewPopUpButton:(CellViewPopUpButton *)cellView settingDict:(NSDictionary *)settingDict columnIdentifier:(NSString *)columnIdentifier row:(NSInteger)row sender:(id)sender {

    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView popUpButton] removeAllItems];
    [[cellView popUpButton] addItemsWithTitles:settingDict[@"AvailableValues"] ?: @[]];
    [[cellView popUpButton] selectItemWithTitle:settingDict[@"Value"] ?: settingDict[@"DefaultValue"]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView popUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView popUpButton] setTarget:sender];
    [[cellView popUpButton] setTag:row];
    
    return cellView;
} // populateCellViewPopUp:settingDict:row
@end