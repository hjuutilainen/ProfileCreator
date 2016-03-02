//
//  PFCMainWindowGroup.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFCMainWindowGroupTitle.h"
@class PFCMainWindow;

@interface PFCMainWindowGroup : NSViewController <NSTableViewDelegate, NSTableViewDataSource, PFCAlertDelegate, PFCTableViewDelegate>

@property (weak) IBOutlet NSView *viewGroup;
@property (weak) IBOutlet PFCTableView *tableViewGroup;

- (id)initWithGroup:(PFCProfileGroups)group mainWindow:(PFCMainWindow *)mainWindow;
- (void)createNewGroupOfType:(PFCProfileGroups)group;
- (void)removeProfilesWithUUIDs:(NSArray *)profileUUIDs fromGroupWithUUID:(NSString *)groupUUID;
- (void)deleteGroupWithUUID:(NSString *)uuid;

@end
