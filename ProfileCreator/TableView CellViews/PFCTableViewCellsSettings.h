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
#pragma mark CellViewSettingsEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *settingEnabled;
- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView
                                            manifest:(NSDictionary *)manifest
                                            settings:(NSDictionary *)settings
                                       settingsLocal:(NSDictionary *)settingsLocal
                                                 row:(NSInteger)row
                                              sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewSettingsPadding
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsPadding : NSTableCellView
@end

// FIXME - CellViews below are still being tested

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
#pragma mark CellViewSettingsTemplates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewSettingsTemplates : NSTableCellView
@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;
- (CellViewSettingsTemplates *)populateCellViewTemplates:(CellViewSettingsTemplates *)cellView
                                                manifest:(NSDictionary *)manifest
                                                settings:(NSDictionary *)settings
                                           settingsLocal:(NSDictionary *)settingsLocal
                                                     row:(NSInteger)row
                                                  sender:(id)sender;
@end