//
//  PFCTableViewCellsSettingsTableView.h
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

@interface PFCTableViewCellsSettingsTableView : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewTextField : NSTableCellView
@property NSString *columnIdentifier;
- (CellViewTextField *)populateCellViewTextField:(CellViewTextField *)cellView settings:(NSDictionary *)settings columnIdentifier:(NSString *)columnIdentifier row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPopUpButton
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewPopUpButton : NSTableCellView
@property NSString *columnIdentifier;
@property (weak) IBOutlet NSPopUpButton *popUpButton;
- (CellViewPopUpButton *)populateCellViewPopUpButton:(CellViewPopUpButton *)cellView
                                            settings:(NSDictionary *)settings
                                    columnIdentifier:(NSString *)columnIdentifier
                                                 row:(NSInteger)row
                                              sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewTextFieldNumber
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewTextFieldNumber : NSTableCellView
@property NSString *columnIdentifier;
@property (weak) IBOutlet NSNumberFormatter *settingNumberFormatter;
- (CellViewTextFieldNumber *)populateCellViewTextFieldNumber:(CellViewTextFieldNumber *)cellView
                                                    settings:(NSDictionary *)settings
                                            columnIdentifier:(NSString *)columnIdentifier
                                                         row:(NSInteger)row
                                                      sender:(id)sender;
@end
