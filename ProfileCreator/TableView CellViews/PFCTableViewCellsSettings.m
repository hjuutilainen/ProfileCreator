//
//  PFCTableViewCellsSettings.m
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

#import "PFCTableViewCellsSettings.h"
#import "PFCProfileEditor.h"
#import "PFCTableViewCellsSettingsTableView.h"
#import "PFCFileInfoProcessors.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCLog.h"
#import "NSColor+PFCColors.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsEnabled

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    BOOL required = NO;
    if ( manifest[PFCManifestKeyRequired] != nil ) {
        required = [manifest[PFCManifestKeyRequired] boolValue];
    } else if ( manifest[PFCManifestKeyRequiredHost] != nil ) {
        required = [manifest[PFCManifestKeyRequiredHost] boolValue];
    } else if ( manifest[PFCManifestKeyRequiredPort] != nil ) {
        required = [manifest[PFCManifestKeyRequiredPort] boolValue];
    }
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setAction:@selector(checkbox:)];
    [[cellView settingEnabled] setTarget:sender];
    [[cellView settingEnabled] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:required];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:enabled];
    
    return cellView;
} // populateCellViewEnabled:settings:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPadding
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsPadding
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
@end

// FIXME - CellViews below are still being tested

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsTemplates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsTemplates

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewSettingsTemplates *)populateCellViewTemplates:(CellViewSettingsTemplates *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] removeAllItems];
    [[cellView settingPopUpButton] addItemsWithTitles:manifest[PFCManifestKeyAvailableValues] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settings[PFCSettingsKeyValue] ?: manifest[PFCManifestKeyDefaultValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:sender];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // CellViewSettingsTemplates

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsMinOS
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@implementation CellViewSettingsMinOS
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect
@end
