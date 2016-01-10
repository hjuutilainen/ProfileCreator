//
//  PFCController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PFCProfileCreationWindowController.h"

typedef NS_ENUM(NSInteger, PFCFolders) {
    /** ProfileCreator in user application support **/
    kPFCFolderUserApplicationSupport,
    /** Profile Save Folder **/
    kPFCFolderSavedProfiles
};

@interface PFCController : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSWindow *window;

@property PFCProfileCreationWindowController *profileWindowController;

@property BOOL initialized; // Temporary
@property (weak) IBOutlet NSMenu *menuAdvancedOptions;

// Te be used when opening multiple profile windows
@property NSMutableDictionary *profileWindows;

@property (weak) IBOutlet NSView *viewTableViewProfilesSuperview;
@property (weak) IBOutlet NSView *viewNoProfiles;

@property (weak) IBOutlet NSTableView *tableViewProfiles;
@property NSMutableArray *tableViewProfilesItems;
@property NSMutableDictionary *savedProfiles;

@property (weak) IBOutlet NSSegmentedControl *segmentedControlAddRemove;
- (IBAction)segmentedControlAddRemove:(id)sender;

+ (NSString *)newProfilePath;
+ (NSURL *)profileCreatorFolder:(NSInteger)folder;
- (void)removeControllerForProfileDictWithName:(NSString *)name;
- (void)renameProfileWithName:(NSString *)name newName:(NSString *)newName;

@end
