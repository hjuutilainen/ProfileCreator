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

@interface PFCMainWindowGroup : NSViewController

@property (weak) IBOutlet NSView *viewGroup;

- (id)initWithGroup:(PFCProfileGroups)group mainWindow:(PFCMainWindow *)mainWindow;
- (void)createNewGroupOfType:(PFCProfileGroups)group;

@end
