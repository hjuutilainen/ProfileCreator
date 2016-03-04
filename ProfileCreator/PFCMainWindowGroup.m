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
#import "PFCProfileUtility.h"
#import "PFCTableViewCellsProfiles.h"
#import "RFOverlayScrollView.h"

@interface PFCMainWindowGroup ()

@property PFCMainWindow *mainWindow;
@property PFCMainWindowGroupTitle *groupTitle;

@property (weak) IBOutlet NSView *viewGroupTitle;
@property (weak) IBOutlet RFOverlayScrollView *scrollViewGroup;

@property NSMutableArray *arrayGroup;
@property NSInteger maxRows;
@property (weak) IBOutlet NSLayoutConstraint *layoutConstraintGroupTitleHeight;

@end

@implementation PFCMainWindowGroup

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithGroup:(PFCProfileGroups)group mainWindow:(PFCMainWindow *)mainWindow {
    self = [super initWithNibName:@"PFCMainWindowGroup" bundle:nil];
    if (self != nil) {
        _arrayGroup = [[NSMutableArray alloc] init];
        _group = group;
        _mainWindow = mainWindow;
        [self view];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];

    switch (_group) {
    case kPFCProfileGroupAll:
        [self setupGroupAll];
        break;

    case kPFCProfileGroups:
        [self setupGroupTitle];
        [self setupGroupGroup];
        break;
    case kPFCProfileSmartGroups:
        [self setupGroupTitle];
        [self setupGroupSmartGroup];
        break;

    default:
        break;
    }
}

- (void)setupGroupTitle {
    _groupTitle = [[PFCMainWindowGroupTitle alloc] initWithGroup:_group sender:self];
    [PFCGeneralUtility insertSubview:[_groupTitle view] inSuperview:_viewGroupTitle hidden:NO];
}

- (void)setupGroupAll {
    [self setMaxRows:1];

    [_viewGroupTitle setHidden:YES];
    [_layoutConstraintGroupTitleHeight setConstant:0.0f];

    // -------------------------------------------------------------------------
    //  Add the only item "All Profiles" to table view.
    // -------------------------------------------------------------------------
    [_arrayGroup addObject:@{ @"Config" : @{PFCProfileGroupKeyName : @"All Profiles", PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString]} }];

    [_tableViewGroup reloadData];
}

- (void)setupGroupSmartGroup {
    [self setMaxRows:10];

    // -------------------------------------------------------------------------
    //  Add all saved groups
    // -------------------------------------------------------------------------
    [self readSavedGroups];
}

- (void)setupGroupGroup {
    [self setMaxRows:10];

    // -------------------------------------------------------------------------
    //  Register for dragging destination
    // -------------------------------------------------------------------------
    [_tableViewGroup registerForDraggedTypes:@[ PFCProfileDraggingType ]];

    // -------------------------------------------------------------------------
    //  Add all saved groups
    // -------------------------------------------------------------------------
    [self readSavedGroups];
}

- (void)readSavedGroups {
    NSURL *groupSaveFolder = [PFCGeneralUtility profileCreatorFolder:[self saveFolder]];
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
    if (_maxRows < (int)[_arrayGroup count]) {
        [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)_maxRows) tableView:_scrollViewGroup];
    } else {
        [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)[_arrayGroup count]) tableView:_scrollViewGroup];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrayGroup count];
} // numberOfRowsInTableView

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropOn) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
} // tableView:validateDrop:proposedRow:proposedDropOperation

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSData *draggingData = [[info draggingPasteboard] dataForType:PFCProfileDraggingType];
    NSArray *profileUUIDs = [NSKeyedUnarchiver unarchiveObjectWithData:draggingData];
    if ([profileUUIDs count] != 0) {
        [self insertProfileUUIDs:profileUUIDs inTableViewWithIdentifier:[tableView identifier] row:row];
    }
    return YES;
} // tableView:acceptDrop:row:dropOperation

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCTableViewDelegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)deleteKeyPressedForTableView:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Check if any rows are selected, else return here
    // -------------------------------------------------------------------------
    NSIndexSet *selectedRows = [sender selectedRowIndexes];
    DDLogDebug(@"Selected rows: %@", selectedRows);

    if ([selectedRows count] == 0) {
        return NO;
    }

    // -------------------------------------------------------------------------
    //  Multiple selections is not enabled for groups, therefor just extract the selected row from the row indexes
    // -------------------------------------------------------------------------
    NSInteger selectedRow = [selectedRows firstIndex];
    DDLogDebug(@"Selected row: %ld", (long)selectedRow);

    if (selectedRow != NSNotFound) {
        NSDictionary *groupDict = _arrayGroup[selectedRow] ?: @{};

        NSString *groupName = groupDict[@"Config"][PFCProfileGroupKeyName] ?: @"";
        NSString *groupUUID = groupDict[@"Config"][PFCProfileGroupKeyUUID] ?: @"";

        PFCAlert *alert = [[PFCAlert alloc] initWithDelegate:self];
        [alert showAlertDeleteGroups:@[ groupName ] alertInfo:@{ PFCAlertTagKey : PFCAlertTagDeleteGroups, @"GroupUUID" : groupUUID, @"TableViewIdentifier" : [sender identifier] }];
    }

    return YES;
} // deleteKeyPressedForTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCAlert Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)alertReturnCode:(NSInteger)returnCode alertInfo:(NSDictionary *)alertInfo {
    NSString *alertTag = alertInfo[PFCAlertTagKey];
    if ([alertTag isEqualToString:PFCAlertTagDeleteGroups]) {
        if (returnCode == NSAlertSecondButtonReturn) { // Delete
            [self deleteGroupWithUUID:alertInfo[@"GroupUUID"] ?: @""];
        }
    }
} // alertReturnCode:alertInfo

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
        _arrayGroup[row] = [group copy];

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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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
    _arrayGroup[row] = [group copy];
    NSError *error = nil;
    if (![self saveGroup:[group copy] error:&error]) {
        [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                               completionHandler:^(NSModalResponse returnCode){

                                               }];
    }
} // insertProfileUUIDs:inTableViewWithIdentifier:row

- (void)removeProfilesWithUUIDs:(NSArray *)profileUUIDs fromGroupWithUUID:(NSString *)groupUUID {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSInteger index = [_arrayGroup indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull dict, NSUInteger idx, BOOL *_Nonnull stop) {
      return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:groupUUID];
    }];
    DDLogDebug(@"Group index: %ld", (long)index);

    if (index != NSNotFound) {
        NSMutableDictionary *group = [_arrayGroup[index] mutableCopy];
        NSMutableDictionary *groupConfig = [group[@"Config"] mutableCopy];
        if ([groupConfig count] != 0) {
            NSMutableArray *profiles = [groupConfig[PFCProfileGroupKeyProfiles] mutableCopy];
            [profiles removeObjectsInArray:profileUUIDs];
            groupConfig[PFCProfileGroupKeyProfiles] = [profiles copy];
            group[@"Config"] = [groupConfig copy];

            _arrayGroup[index] = [group copy];

            [self selectGroup:self];

            NSError *error = nil;
            if (![self saveGroup:group error:&error]) {
                [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                                       completionHandler:^(NSModalResponse returnCode){

                                                       }];
            }
        }
    }
}

- (void)deleteProfilesWithUUIDs:(NSArray *)profileUUIDs {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [[_arrayGroup copy] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dict, NSUInteger idx, BOOL *_Nonnull stop) {
      NSMutableDictionary *group = [dict mutableCopy] ?: @{};
      NSMutableDictionary *groupConfig = [dict[@"Config"] mutableCopy];
      if ([groupConfig count] != 0) {
          NSMutableArray *profiles = [groupConfig[PFCProfileGroupKeyProfiles] mutableCopy] ?: [[NSMutableArray alloc] init];
          [profiles removeObjectsInArray:profileUUIDs];
          groupConfig[PFCProfileGroupKeyProfiles] = [profiles copy];
          group[@"Config"] = [groupConfig copy];
          _arrayGroup[idx] = [group copy];
          NSError *error = nil;
          if (![self saveGroup:group error:&error]) {
              [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                                     completionHandler:^(NSModalResponse returnCode){

                                                     }];
          }
      }
    }];
}

- (NSUInteger)indexOfProfileWithUUID:(NSString *)uuid {
    NSUInteger index = NSNotFound;
    if ([_arrayGroup containsObject:uuid]) {
        index = [_arrayGroup indexOfObjectPassingTest:^BOOL(NSString *_Nonnull string, NSUInteger idx, BOOL *_Nonnull stop) {
          return [string isEqualToString:uuid];
        }];
    }
    return index;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Groups
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)createNewGroupOfType:(PFCProfileGroups)group {
    NSNumber *index = @([self insertProfileGroupInTableView:@{
        PFCRuntimeKeyPath : [PFCGeneralUtility newPathInGroupFolder:[self saveFolder]],
        @"Config" : @{PFCProfileGroupKeyName : PFCDefaultProfileGroupName, PFCProfileGroupKeyUUID : [[NSUUID UUID] UUIDString]}
    }]);

    if (_mainWindow) {
        [_mainWindow updateGroupSelection:group];
    }

    [_tableViewGroup selectRowIndexes:[NSIndexSet indexSetWithIndex:[index integerValue]] byExtendingSelection:NO];
    [[[_tableViewGroup viewAtColumn:[[_tableViewGroup tableColumns] indexOfObject:[_tableViewGroup tableColumnWithIdentifier:@"GroupName"]] row:[index integerValue] makeIfNecessary:NO] textField]
        selectText:self];

    // ---------------------------------------------------------------------
    //  Adjust table view height to content
    // ---------------------------------------------------------------------
    if (_maxRows < (int)[_arrayGroup count]) {
        [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)_maxRows) tableView:_scrollViewGroup];
    } else {
        [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)[_arrayGroup count]) tableView:_scrollViewGroup];
    }
} // createNewGroupOfType

- (void)deleteGroupWithUUID:(NSString *)uuid {
    NSInteger index = [_arrayGroup indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull dict, NSUInteger idx, BOOL *_Nonnull stop) {
      return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:uuid];
    }];
    DDLogDebug(@"Group index: %ld", (long)index);

    NSURL *groupURL;
    if (index != NSNotFound) {

        NSDictionary *group = _arrayGroup[index];
        NSString *groupPath = group[PFCRuntimeKeyPath];
        groupURL = [NSURL fileURLWithPath:groupPath];

        [_tableViewGroup beginUpdates];
        [_arrayGroup removeObjectAtIndex:index];
        [_tableViewGroup reloadData];
        [_tableViewGroup endUpdates];

        // ---------------------------------------------------------------------
        //  Adjust table view height to content
        // ---------------------------------------------------------------------
        if (_maxRows < (int)[_arrayGroup count]) {
            [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)_maxRows) tableView:_scrollViewGroup];
        } else {
            [PFCGeneralUtility setTableViewHeight:(PFCTableViewGroupRowHeight * (int)[_arrayGroup count]) tableView:_scrollViewGroup];
        }
    }

    NSError *error = nil;
    if ([groupURL checkResourceIsReachableAndReturnError:&error]) {

        DDLogDebug(@"Removing group plist at path: %@", [groupURL path]);
        if (![[NSFileManager defaultManager] removeItemAtURL:groupURL error:&error]) {
            DDLogError(@"%@", [error localizedDescription]);
        }
    } else {
        DDLogError(@"%@", [error localizedDescription]);
    }
}

- (PFCFolders)saveFolder {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Group: %ld", (long)_group);

    switch (_group) {
    case kPFCProfileGroups:
        return kPFCFolderSavedProfileGroups;
        break;
    case kPFCProfileSmartGroups:
        return kPFCFolderSavedProfileSmartGroups;
    default:
        return NSNotFound;
        break;
    }
}

- (BOOL)saveGroup:(NSDictionary *)groupDict error:(NSError **)error {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSURL *groupSaveFolder = [PFCGeneralUtility profileCreatorFolder:[self saveFolder]];
    DDLogDebug(@"Group save folder: %@", [groupSaveFolder path]);
    if (![groupSaveFolder checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:groupSaveFolder withIntermediateDirectories:YES attributes:nil error:error]) {
            return NO;
        }
    }

    NSString *groupPath = groupDict[PFCRuntimeKeyPath] ?: [PFCGeneralUtility newPathInGroupFolder:[self saveFolder]];
    DDLogDebug(@"Group save path: %@", groupPath);

    NSURL *groupURL = [NSURL fileURLWithPath:groupPath];
    NSDictionary *groupConfig = groupDict[@"Config"];
    return [groupConfig writeToURL:groupURL atomically:YES];
} // saveGroup:error

- (NSArray *)profileArrayForGroup:(NSDictionary *)group {
    switch (_group) {
    case kPFCProfileGroupAll:
        return [[PFCProfileUtility sharedUtility] allProfileUUIDs] ?: @[];
        break;

    case kPFCProfileGroups:
        return group[@"Config"][PFCProfileGroupKeyProfiles] ?: @[];
        break;

    case kPFCProfileSmartGroups:
        return [self profileArrayForSmartGroup:group];
        break;

    default:
        return @[];
        break;
    }
}

- (NSArray *)profileArrayForSmartGroup:(NSDictionary *)group {
    return @[];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)selectGroup:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSInteger selectedRow = [_tableViewGroup selectedRow];
    DDLogDebug(@"Table view groups selected row: %ld", (long)selectedRow);

    if ([_arrayGroup count] <= selectedRow) {
        return;
    }

    // ---------------------------------------------------------------------
    //  Load the current group dict from the array
    // ---------------------------------------------------------------------
    NSMutableDictionary *group = [_arrayGroup[selectedRow] mutableCopy];

    if (_mainWindow) {
        [_mainWindow selectGroup:group groupType:_group profileArray:[self profileArrayForGroup:group]];
    }
}

@end
