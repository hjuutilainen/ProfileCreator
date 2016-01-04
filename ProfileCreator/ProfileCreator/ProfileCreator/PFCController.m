//
//  PFCController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCController.h"
#import "PFCManifestCreationParser.h"
#import "PFCTableViewCellsProfiles.h"

@implementation PFCController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {
        _profileWindows = [[NSMutableDictionary alloc] init];
        _tableViewProfilesItems = [[NSMutableArray alloc] init];
        _savedProfiles = [[NSMutableDictionary alloc] init];
    }
    return self;
} // init

+ (NSURL *)profileCreatorFolder:(NSInteger)folder {
    
    switch (folder) {
        case kPFCFolderUserApplicationSupport:
        {
            NSURL *userApplicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                                   inDomain:NSUserDomainMask
                                                                          appropriateForURL:nil
                                                                                     create:NO
                                                                                      error:nil];
            
            return [userApplicationSupport URLByAppendingPathComponent:@"ProfileCreator"];
        }
            break;
            
        case kPFCFolderSavedProfiles:
        {
            return [[self profileCreatorFolder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"Profiles"];
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSArray *)savedProfileURLs {
    NSURL *savedProfilesFolderURL = [PFCController profileCreatorFolder:kPFCFolderSavedProfiles];
    if ( ! [savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        return nil;
    } else {
        NSArray *savedProfilesContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:savedProfilesFolderURL
                                                                      includingPropertiesForKeys:@[]
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                           error:nil];
        
        return [savedProfilesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension == 'pfcconf'"]];
    }
}

- (void)setupViewNoProfiles {
    [_viewTableViewProfilesSuperview addSubview:_viewNoProfiles positioned:NSWindowAbove relativeTo:nil];
    [_viewNoProfiles setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSArray *constraintsArray;
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_viewNoProfiles]-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(_viewNoProfiles)];
    [_viewTableViewProfilesSuperview addConstraints:constraintsArray];
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_viewNoProfiles]-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(_viewNoProfiles)];
    [_viewTableViewProfilesSuperview addConstraints:constraintsArray];
    [_viewTableViewProfilesSuperview setHidden:NO];
    [_viewNoProfiles setHidden:YES];
} // setupSettings

- (void)addSavedProfiles {
    NSArray *savedProfiles = [self savedProfileURLs];
    if ( [savedProfiles count] == 0 ) {
        [_viewNoProfiles setHidden:NO];
    } else {
        for ( NSURL *profileURL in savedProfiles ) {
            NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
            if ( [profileDict count] == 0 ) {
                NSLog(@"[ERROR] Couldn't read profile at path: %@", [profileURL path]);
                continue;
            }
            
            NSString *name = profileDict[@"Name"];
            if ( [name length] == 0 ) {
                NSLog(@"[ERROR] Profile doesn't contain a name!");
                continue;
            }
            
            NSDictionary *savedProfileDict = @{ @"URL" : [profileURL path],
                                                @"Dict" : profileDict };
            
            _savedProfiles[name] = savedProfileDict;
            
            // FIXME - Add sanity checking to see if this actually is a profile save
            
            [_tableViewProfilesItems addObject:profileDict];
        }
        
        [_tableViewProfiles reloadData];
    }
} // addSavedProfiles

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate Methods NSApplicationDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib {
    [_tableViewProfiles setTarget:self];
    [_tableViewProfiles setDoubleAction:@selector(openProfileCreationWindow:)];
    [self setupViewNoProfiles];
    [self addSavedProfiles];
}

- (void)applicationWillFinishLaunching:(NSNotification *) __unused notification {
    // Not configured correctly, doesn't get called.
} // applicationWillFinishLaunching

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:@"TableViewProfiles"] ) {
        return (NSInteger)[_tableViewProfilesItems count];
    } else {
        return 0;
    }
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *tableViewIdentifier = [tableView identifier];
    if ( [tableViewIdentifier isEqualToString:@"TableViewProfiles"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_tableViewProfilesItems count] < row || [_tableViewProfilesItems count] == 0 ) {
            return nil;
        }
        
        NSDictionary *profileDict = _tableViewProfilesItems[(NSUInteger)row];
        
        CellViewProfile *cellView = [tableView makeViewWithIdentifier:@"CellViewProfile" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewProfile:cellView profileDict:profileDict row:row];
    }
    return nil;
}

- (NSInteger)insertProfileInTableView:(NSDictionary *)profileDict {
    NSInteger index = [_tableViewProfiles selectedRow];
    index++;
    [_tableViewProfiles beginUpdates];
    [_tableViewProfiles insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationSlideDown];
    [_tableViewProfiles scrollRowToVisible:index];
    [_tableViewProfilesItems insertObject:profileDict atIndex:(NSUInteger)index];
    [_tableViewProfiles endUpdates];
    [_viewNoProfiles setHidden:YES];
    return index;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCreateProfile:(id)sender {
    
    PFCProfileCreationWindowController *controller = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeApple
                                                                                                         profileDict:@{}];
    if ( controller ) {
        NSString *profileFileName = [NSString stringWithFormat:@"%@.pfcconf", [[NSUUID UUID] UUIDString]];
        NSURL *profileURL = [[PFCController profileCreatorFolder:kPFCFolderSavedProfiles] URLByAppendingPathComponent:profileFileName];
        
        NSDictionary *profileDict = @{ @"URL" : [profileURL path],
                                       @"Dict" : @{ @"Name" : @"Untitled..." },
                                       @"Controller" : controller };
        
        [self insertProfileInTableView:profileDict];
        [[controller window] makeKeyAndOrderFront:self];
    }
} // buttonCreateProfile

- (void)openProfileCreationWindow:(id)sender {
    NSInteger row = [sender clickedRow];
    if ( 0 <= row && row <= [_tableViewProfilesItems count] ) {
        NSMutableDictionary *profileDict = [_tableViewProfilesItems[row] mutableCopy];
        PFCProfileCreationWindowController *controller;
        if ( profileDict[@"Controller"] != nil ) {
            controller = profileDict[@"Controller"];
        } else {
            controller = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeApple
                                                                             profileDict:@{}];
            profileDict[@"Controller"] = controller;
            [_tableViewProfilesItems replaceObjectAtIndex:row withObject:[profileDict copy]];
        }
        [[controller window] makeKeyAndOrderFront:self];
    }
}

- (IBAction)buttonRemoveProfile:(id)sender {
    
    NSIndexSet *indexes = [_tableViewProfiles selectedRowIndexes];
    
    if ( [indexes count] == 0 ) {
        NSLog(@"No profile selected");
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Delete"];
    [alert setMessageText:@"Delete profile"];
    [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete %lu %@?", (unsigned long)[indexes count], ([indexes count] == 1) ? @"profile" : @"profiles"]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSInteger returnCode) {
        if ( returnCode == NSAlertSecondButtonReturn ) { // Delete
            [_tableViewProfilesItems removeObjectsAtIndexes:indexes];
            [_tableViewProfiles removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectNone];
            if ( [_tableViewProfilesItems count] == 0 ) {
                [_viewNoProfiles setHidden:NO];
            }
        }
    }];
    
    
}

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
                _profileWindowController = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeCustom
                                                                                               profileDict:@{}];
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
                _profileWindowController = [[PFCProfileCreationWindowController alloc] initWithProfileType:kPFCProfileTypeCustom
                                                                                               profileDict:@{}];
                [_profileWindowController setCustomMenu:menuArray];
            }
            [[_profileWindowController window] makeKeyAndOrderFront:self];
        }
    }];
}

@end
