//
//  PFCTableViewCellsProfiles.h
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

@interface PFCTableViewCellsProfiles : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewProfile : NSTableCellView
@property (weak) IBOutlet NSTextField *menuTitle;
@property (weak) IBOutlet NSTextField *menuDescription;
@property (weak) IBOutlet NSImageView *menuIcon;
- (CellViewProfile *)populateCellViewProfile:(CellViewProfile *)cellView profileDict:(NSDictionary *)profileDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfileGroup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewProfileGroup : NSTableCellView
@property (weak) IBOutlet NSTextField *menuTitle;
- (CellViewProfileGroup *)populateCellViewProfileGroup:(CellViewProfileGroup *)cellView profileDict:(NSDictionary *)profileDict row:(NSInteger)row;
@end