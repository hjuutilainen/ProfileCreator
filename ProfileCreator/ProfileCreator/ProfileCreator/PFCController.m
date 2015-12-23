//
//  PFCController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCController.h"
#import "PFCManifestCreationParser.h"

@implementation PFCController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {
        _profileWindows = [[NSMutableArray alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate Methods NSApplicationDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *) __unused notification {
    
    
} // applicationWillFinishLaunching

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCreateProfile:(id)sender {
    if ( ! _profileWindowController ) {
        _profileWindowController = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeApple];
    }
    [[_profileWindowController window] makeKeyAndOrderFront:self];
} // buttonCreateProfile

- (IBAction)buttonOpenPlist:(id)sender {
    // --------------------------------------------------------------
    //  Setup open dialog for current settings
    // --------------------------------------------------------------
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Open Plist"];
    [openPanel setPrompt:@"Select"];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel setAllowedFileTypes:@[@"com.apple.property-list"]];
    
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if ( result == NSModalResponseOK ) {
            NSArray *selectedURLs = [openPanel URLs];
            NSURL *fileURL = [selectedURLs firstObject];
            NSDictionary *fileManifest = [PFCManifestCreationParser manifestForPlistAtURL:fileURL];
            if ( ! _profileWindowController ) {
                _profileWindowController = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeCustom];
                [_profileWindowController setCustomMenu:@[ fileManifest ]];
            }
            [[_profileWindowController window] makeKeyAndOrderFront:self];
        }
    }];
}
- (IBAction)buttonOpenFoldera:(id)sender {
    // --------------------------------------------------------------
    //  Setup open dialog for current settings
    // --------------------------------------------------------------
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Open Folder"];
    [openPanel setPrompt:@"Select"];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if ( result == NSModalResponseOK ) {
            NSArray *selectedURLs = [openPanel URLs];
            NSURL *folderURL = [selectedURLs firstObject];
            
            NSArray * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folderURL
                                                                  includingPropertiesForKeys:@[]
                                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                       error:nil];
            NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='plist'"];
            NSMutableArray *menuArray = [[NSMutableArray alloc] init];
            for ( NSURL *plistURL in [dirContents filteredArrayUsingPredicate:fltr] ) {
                
                NSDictionary *fileManifest = [PFCManifestCreationParser manifestForPlistAtURL:plistURL];
                [menuArray addObject:fileManifest];
            }
            
            if ( ! _profileWindowController ) {
                NSLog(@"Initing with custom!");
                _profileWindowController = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeCustom];
                [_profileWindowController setCustomMenu:menuArray];
            }
            [[_profileWindowController window] makeKeyAndOrderFront:self];
        }
    }];
}

@end
