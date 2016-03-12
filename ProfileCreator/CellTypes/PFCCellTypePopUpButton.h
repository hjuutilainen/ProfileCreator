//
//  PFCCellTypePopUpButton.h
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
@class PFCProfileExport;

@interface PFCPopUpButtonCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonCellView *)populateCellView:(PFCPopUpButtonCellView *)cellView
                                    manifest:(NSDictionary *)manifest
                                    settings:(NSDictionary *)settings
                               settingsLocal:(NSDictionary *)settingsLocal
                                 displayKeys:(NSDictionary *)displayKeys
                                         row:(NSInteger)row
                                      sender:(id)sender;

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys;
+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads sender:(PFCProfileExport *)sender;

@end

@interface PFCPopUpButtonLeftCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonLeftCellView *)populateCellView:(PFCPopUpButtonLeftCellView *)cellView
                                        manifest:(NSDictionary *)manifest
                                        settings:(NSDictionary *)settings
                                   settingsLocal:(NSDictionary *)settingsLocal
                                     displayKeys:(NSDictionary *)displayKeys
                                             row:(NSInteger)row
                                          sender:(id)sender;

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys;
+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads sender:(PFCProfileExport *)sender;

@end

@interface PFCPopUpButtonNoTitleCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonNoTitleCellView *)populateCellView:(PFCPopUpButtonNoTitleCellView *)cellView
                                           manifest:(NSDictionary *)manifest
                                           settings:(NSDictionary *)settings
                                      settingsLocal:(NSDictionary *)settingsLocal
                                        displayKeys:(NSDictionary *)displayKeys
                                                row:(NSInteger)row
                                             sender:(id)sender;

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys;
+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads sender:(PFCProfileExport *)sender;

@end
