//
//  PFCMainWindowGroup.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCMainWindow.h"
#import "PFCMainWindowGroup.h"
#import "PFCTableViewCellsProfiles.h"
#import "RFOverlayScrollView.h"

@interface PFCMainWindowGroup ()

@property PFCProfileGroups group;
@property PFCMainWindow *mainWindow;
@property PFCMainWindowGroupTitle *groupTitle;

@property (weak) IBOutlet NSView *viewGroupTitle;

@property (weak) IBOutlet RFOverlayScrollView *scrollViewGroup;
@property (weak) IBOutlet PFCTableView *tableViewGroup;

- (IBAction)selectGroup:(id)sender;

@property NSMutableArray *arrayGroup;

@end

@implementation PFCMainWindowGroup

- (id)initWithGroup:(PFCProfileGroups)group mainWindow:(PFCMainWindow *)mainWindow {
    self = [super initWithNibName:@"PFCMainWindowGroup" bundle:nil];
    if (self != nil) {
        _arrayGroup = [[NSMutableArray alloc] init];
        _group = group;
        _mainWindow = mainWindow;
        _groupTitle = [[PFCMainWindowGroupTitle alloc] initWithGroup:group sender:self];
        [self view];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGroup];
}

- (void)setupGroup {
    [PFCGeneralUtility insertSubview:[_groupTitle view] inSuperview:_viewGroupTitle hidden:NO];
    switch (_group) {
        case kPFCProfileGroups:
            [self setupGroupGroup];
            break;
        case kPFCProfileSmartGroups:
            [self setupGroupSmartGroup];
            break;
            
        default:
            break;
    }
}

- (void)setupGroupSmartGroup {
    
}

- (void)setupGroupGroup {
    
    // -------------------------------------------------------------------------
    //  Register for dragging destination
    // -------------------------------------------------------------------------
    [_tableViewGroup registerForDraggedTypes:@[ PFCProfileDraggingType ]];
    
    NSURL *groupSaveFolder = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfileGroups];
    if (![groupSaveFolder checkResourceIsReachableAndReturnError:nil]) {
        DDLogDebug(@"Found no group folder!");
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Put all profile group plist URLs in an array
    // -------------------------------------------------------------------------
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:groupSaveFolder includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    // -------------------------------------------------------------------------
    //  Insert all groups matching predicate in groups table view
    // -------------------------------------------------------------------------
    NSPredicate *predicateManifestGroups = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.pathExtension == '%@'", PFCProfileGroupExtension]];
    NSArray *groupURLs = [dirContents filteredArrayUsingPredicate:predicateManifestGroups];
    for (NSURL *groupURL in groupURLs ?: @[]) {
        NSMutableDictionary *newGroup = [[NSMutableDictionary alloc] init];
        NSDictionary *group = [NSDictionary dictionaryWithContentsOfURL:groupURL];
        if ([group count] != 0) {
            newGroup[PFCRuntimeKeyPath] = [groupURL path];
            newGroup[@"Config"] = group;
            [self insertProfileGroupInTableView:newGroup];
        }
    }
    
    // -------------------------------------------------------------------------
    //  Adjust table view height to content
    // -------------------------------------------------------------------------
    [PFCGeneralUtility setTableViewHeight:PFCTableViewGroupRowHeight* (int)[_arrayGroup count] tableView:_scrollViewGroup];
}

- (void)createNewGroupOfType:(PFCProfileGroups)group {
    NSNumber *index = @([self insertProfileGroupInTableView:@{
                                                              PFCRuntimeKeyPath : [PFCGeneralUtility newProfileGroupPath],
                                                              @"Config" : @{PFCProfileGroupKeyName : PFCDefaultProfileGroupName, PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString]}
                                                              }]);
    //[self selectTableViewProfileGroupsRow:[index integerValue]];
    [_tableViewGroup selectRowIndexes:[NSIndexSet indexSetWithIndex:[index integerValue]] byExtendingSelection:NO];
    [[[_tableViewGroup viewAtColumn:[[_tableViewGroup tableColumns] indexOfObject:[_tableViewGroup tableColumnWithIdentifier:@"GroupName"]] row:[index integerValue] makeIfNecessary:NO] textField]
     selectText:self];
    
    // ---------------------------------------------------------------------
    //  Adjust table view height to content
    // ---------------------------------------------------------------------
    [PFCGeneralUtility setTableViewHeight:PFCTableViewGroupRowHeight * (int)[_arrayGroup count] tableView:_scrollViewGroup];
} // createNewGroupOfType

- (NSInteger)insertProfileGroupInTableView:(NSDictionary *)profileDict {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    NSInteger index = [_tableViewGroup selectedRow];
    index++;
    [_tableViewGroup beginUpdates];
    [_tableViewGroup insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationEffectNone];
    [_tableViewGroup scrollRowToVisible:index];
    [_arrayGroup insertObject:profileDict atIndex:(NSUInteger)index];
    [_tableViewGroup endUpdates];
    return index;
} // insertProfileGroupInTableView

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropOn) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    NSData *draggingData = [[info draggingPasteboard] dataForType:PFCProfileDraggingType];
    NSArray *profileUUIDs = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    if ([profileUUIDs count] != 0) {
        [self insertProfileUUIDs:profileUUIDs inTableViewWithIdentifier:[tableView identifier] row:row];
    }
    return YES;
}

- (void)insertProfileUUIDs:(NSArray *)profileUUIDs inTableViewWithIdentifier:(NSString *)identifier row:(NSInteger)row {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableDictionary *group = [_arrayGroup[row] mutableCopy];
    NSMutableDictionary *groupConfig = [group[@"Config"] mutableCopy];
    NSMutableArray *profiles = [groupConfig[PFCProfileGroupKeyProfiles] mutableCopy] ?: [[NSMutableArray alloc] init];
    for (NSString *uuid in profileUUIDs) {
        if (![profiles containsObject:uuid]) {
            [profiles addObject:uuid];
        }
    }
    groupConfig[PFCProfileGroupKeyProfiles] = [profiles copy];
    group[@"Config"] = [groupConfig copy];
    [_arrayGroup replaceObjectAtIndex:row withObject:[group copy]];
    NSError *error = nil;
    if (![self saveGroup:[group copy] error:&error]) {
        [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                               completionHandler:^(NSModalResponse returnCode){
                                                   
                                               }];
    }
} // insertProfileUUIDs:inTableViewWithIdentifier:row

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSControl Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    
    // FIXME -  Should possibly get this somewhere else, but felt nice to get the info form the actual object
    //          The only thing is to get the actual table view, now only groups is available
    NSInteger row = [_tableViewGroup rowForView:[[notification object] superview]];
    
    if (row < [_arrayGroup count]) {
        NSMutableDictionary *group = [_arrayGroup[row] mutableCopy];
        NSMutableDictionary *groupConfig = [group[@"Config"] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        
        NSDictionary *userInfo = [notification userInfo];
        NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
        BOOL reloadTableView = NO;
        if ([inputText length] == 0) {
            inputText = PFCDefaultProfileGroupName;
            reloadTableView = YES;
        }
        DDLogDebug(@"New name for group: %@", inputText);
        
        groupConfig[PFCProfileGroupKeyName] = inputText ?: @"";
        group[@"Config"] = [groupConfig copy];
        [_arrayGroup replaceObjectAtIndex:row withObject:[group copy]];
        
        if (reloadTableView) {
            [_tableViewGroup reloadData];
        }
        
        NSError *error = nil;
        if (![self saveGroup:group error:&error]) {
            [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                                   completionHandler:^(NSModalResponse returnCode){
                                                       
                                                   }];
        }
    }
}

- (BOOL)saveGroup:(NSDictionary *)groupDict error:(NSError **)error {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSURL *groupSaveFolder = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfileGroups];
    DDLogDebug(@"Group save folder: %@", [groupSaveFolder path]);
    if (![groupSaveFolder checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:groupSaveFolder withIntermediateDirectories:YES attributes:nil error:error]) {
            return NO;
        }
    }
    
    NSString *groupPath = groupDict[PFCRuntimeKeyPath] ?: [PFCGeneralUtility newProfileGroupPath];
    DDLogDebug(@"Group save path: %@", groupPath);
    
    NSURL *groupURL = [NSURL fileURLWithPath:groupPath];
    NSDictionary *groupConfig = groupDict[@"Config"];
    return [groupConfig writeToURL:groupURL atomically:YES];
} // saveGroup:error

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrayGroup count];
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *tableColumnIdentifier = [tableColumn identifier];
    if (![tableColumnIdentifier isEqualToString:@"Padding"]) {
        // ---------------------------------------------------------------------
        //  Verify the profile array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ([_arrayGroup count] == 0 || [_arrayGroup count] < row) {
            return nil;
        }
        
        id cellView = [tableView makeViewWithIdentifier:tableColumnIdentifier owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellView:cellView group:_group profileDict:_arrayGroup[(NSUInteger)row] row:row];
    }
    return nil;
} // tableView:viewForTableColumn:row

- (IBAction)selectGroup:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSInteger selectedRow = [_tableViewGroup selectedRow];
    DDLogDebug(@"Table view groups selected row: %ld", (long)selectedRow);
    
    if ( [_arrayGroup count] <= selectedRow ) {
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Load the current group dict from the array
    // ---------------------------------------------------------------------
    NSMutableDictionary *group = [_arrayGroup[selectedRow] mutableCopy];
    
    // ---------------------------------------------------------------------
    //  Load the current group profile array from the selected group dict
    // ---------------------------------------------------------------------
    NSArray *groupProfileUUIDArray = group[@"Config"][PFCProfileGroupKeyProfiles] ?: @[];
    DDLogDebug(@"Selected group profile UUID array: %@", groupProfileUUIDArray);
    
    if ( _mainWindow ) {
        [_mainWindow selectedGroupOfType:_group profileArray:groupProfileUUIDArray];
    }
}

@end
