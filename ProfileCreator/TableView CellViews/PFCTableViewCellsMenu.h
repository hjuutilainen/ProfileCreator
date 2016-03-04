//
//  PFCTableViewMenuCells.h
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

@interface PFCTableViewMenuCells : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenu : NSTableCellView
@property (weak) IBOutlet NSTextField *errorCount;
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSTextField *menuDescription;
@property (weak) IBOutlet NSImageView *menuIcon;
- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount payloadCount:(NSNumber *)payloadCount row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuEnabled
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenuEnabled : NSTableCellView
@property (weak) IBOutlet NSButton *menuCheckbox;
- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView manifestDict:(NSDictionary *)manifestDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewMenuLibrary
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewMenuLibrary : NSTableCellView
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSImageView *menuIcon;
- (CellViewMenuLibrary *)populateCellViewMenuLibrary:(CellViewMenuLibrary *)cellView manifestDict:(NSDictionary *)manifestDict errorCount:(NSNumber *)errorCount row:(NSInteger)row;
@end
