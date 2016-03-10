//
//  PFCMainWindowGroup.h
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

#import "PFCMainWindowGroupTitle.h"
#import <Cocoa/Cocoa.h>
@class PFCMainWindow;

@interface PFCMainWindowGroup : NSViewController <NSTableViewDelegate, NSTableViewDataSource, PFCAlertDelegate, PFCTableViewDelegate>

@property PFCProfileGroups group;
@property (weak) IBOutlet NSView *viewGroup;
@property (weak) IBOutlet PFCTableView *tableViewGroup;

- (id)initWithGroup:(PFCProfileGroups)group mainWindow:(PFCMainWindow *)mainWindow;

- (void)createNewGroupOfType:(PFCProfileGroups)group;
- (void)deleteGroupWithUUID:(NSString *)uuid;

- (NSUInteger)indexOfProfileWithUUID:(NSString *)uuid;
- (void)removeProfilesWithUUIDs:(NSArray *)profileUUIDs fromGroupWithUUID:(NSString *)groupUUID;
- (void)deleteProfilesWithUUIDs:(NSArray *)profileUUIDs;

- (IBAction)selectGroup:(id)sender;

@end
