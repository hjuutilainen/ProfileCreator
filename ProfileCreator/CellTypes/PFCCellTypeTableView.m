//
//  PFCCellTypeTableView.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCellTypeTableView.h"
#import "PFCConstants.h"
#import "PFCTableViewCellsSettingsTableView.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCLog.h"

@interface PFCTableViewCellView ()

@property id sender;
@property NSString *senderIdentifier;
@property NSMutableArray *tableViewContent;
@property NSDictionary *tableViewColumnCellViews;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTableView *settingTableView;
@property (weak) IBOutlet NSSegmentedControl *settingSegmentedControlButton;

@end

@implementation PFCTableViewCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (void)controlTextDidChange:(NSNotification *)sender {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a text field
    // ---------------------------------------------------------------------
    if ( ! [[[sender object] class] isSubclassOfClass:[NSTextField class]] ) {
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get text field's row in the table view
    // ---------------------------------------------------------------------
    NSTextField *textField = [sender object];
    NSNumber *textFieldTag = @([textField tag]);
    if ( textFieldTag == nil ) {
        DDLogError(@"TextField: %@ has no tag", textFieldTag);
        return;
    }
    NSInteger row = [textFieldTag integerValue];
    
    NSString *columnIdentifier = [(CellViewTextField *)[textField superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Get current text and current cell dict
    // ---------------------------------------------------------------------
    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
    NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:row] mutableCopy];
    
    // ---------------------------------------------------------------------
    //  Another verification of text field type
    // ---------------------------------------------------------------------
    if ( [[[textField superview] class] isSubclassOfClass:[CellViewTextField class]] ) {
        if ( textField == [[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] textField] ) {
            NSMutableDictionary *columnDict = cellDict[columnIdentifier];
            columnDict[PFCSettingsKeyValue] = [inputText copy];
            cellDict[columnIdentifier] = columnDict;
        } else {
            return;
        }
        
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
    }
} // controlTextDidChange

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_tableViewContent count];
} // numberOfRowsInTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Verify the table view content array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if ( [_tableViewContent count] < row || [_tableViewContent count] == 0 ) {
        return nil;
    }
    
    NSDictionary *settings = _tableViewContent[(NSUInteger)row];
    NSString *tableColumnIdentifier = [tableColumn identifier];
    NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnIdentifier];
    NSString *cellType = tableColumnCellViewDict[@"CellType"];
    
    if ( [cellType isEqualToString:@"TextField"] ) {
        CellViewTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewTextField" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewTextField:cellView settings:settings[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        CellViewPopUpButton *cellView = [tableView makeViewWithIdentifier:@"CellViewPopUpButton" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewPopUpButton:cellView settings:settings[tableColumnIdentifier]  columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        CellViewCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewCheckbox" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewCheckbox:cellView settings:settings[tableColumnIdentifier]  columnIdentifier:[tableColumn identifier] row:row sender:self];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        CellViewTextFieldNumber *cellView = [tableView makeViewWithIdentifier:@"CellViewTextFieldNumber" owner:self];
        [cellView setIdentifier:nil];
        return [cellView populateCellViewTextFieldNumber:cellView settings:settings[tableColumnIdentifier] columnIdentifier:[tableColumn identifier] row:row sender:self];
    }
    
    return nil;
} // tableView:viewForTableColumn:row

- (NSInteger)insertRowInTableView:(NSDictionary *)rowDict {
    NSInteger index = [_settingTableView selectedRow];
    index++;
    [_settingTableView beginUpdates];
    [_settingTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationSlideDown];
    [_settingTableView scrollRowToVisible:index];
    [_tableViewContent insertObject:rowDict atIndex:(NSUInteger)index];
    [_settingTableView endUpdates];
    return index;
} // insertRowInTableView

- (void)updateTableViewSavedContent {
    if ( _sender && [_senderIdentifier length] != 0 ) {
        NSMutableDictionary *settings = [[(PFCProfileEditor *)_sender settingsManifest][_senderIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        settings[PFCSettingsKeyTableViewContent] = [_tableViewContent copy];
        [(PFCProfileEditor *)_sender settingsManifest][_senderIdentifier] = [settings mutableCopy];
    }
} // updateTableViewSavedContent

- (IBAction)segmentedControlButton:(id)sender {
    switch ( [sender selectedSegment] ) {
        case 0:
            [self buttonAdd];
            break;
            
        case 1:
            [self buttonRemove];
            break;
        default:
            break;
    }
} // segmentedControlButton

- (void)buttonAdd {
    
    if ( ! _tableViewContent ) {
        _tableViewContent = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *newRowDict = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnKeys = [_tableViewColumnCellViews allKeys];
    for ( NSString *tableColumnKey in tableColumnKeys ) {
        NSMutableDictionary *tableColumnDict = [[NSMutableDictionary alloc] init];
        NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnKey];
        NSString *cellType = tableColumnCellViewDict[@"CellType"];
        
        if ( [cellType isEqualToString:@"TextField"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
        } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
            tableColumnDict[@"Value"] = tableColumnCellViewDict[@"DefaultValue"] ?: @"";
            tableColumnDict[@"AvailableValues"] = tableColumnCellViewDict[@"AvailableValues"] ?: @[];
        }
        newRowDict[tableColumnKey] = tableColumnDict;
    }
    
    [self insertRowInTableView:[newRowDict copy]];
    [self updateTableViewSavedContent];
} // buttonAdd

- (void)buttonRemove {
    NSIndexSet *indexes = [_settingTableView selectedRowIndexes];
    [_tableViewContent removeObjectsAtIndexes:indexes];
    [_settingTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideDown];
    [self updateTableViewSavedContent];
} // buttonRemove

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // ---------------------------------------------------------------------
    if ( ! [[[popUpButton superview] class] isSubclassOfClass:[CellViewPopUpButton class]] ) {
        DDLogError(@"PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get popup button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *popUpButtonTag = @([popUpButton tag]);
    if ( popUpButtonTag == nil ) {
        DDLogError(@"PopUpButton: %@ has no tag", popUpButton);
        return;
    }
    NSInteger row = [popUpButtonTag integerValue];
    
    NSString *columnIdentifier = [(CellViewPopUpButton *)[popUpButton superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if ( popUpButton == [(CellViewPopUpButton *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] popUpButton] ) {
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSString *selectedTitle = [popUpButton titleOfSelectedItem];
        NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = selectedTitle;
        cellDict[columnIdentifier] = columnDict;
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [_settingTableView beginUpdates];
        [_settingTableView reloadData];
        [_settingTableView endUpdates];
    }
} // popUpButtonSelection

- (void)checkbox:(NSButton *)checkbox {
    
    // ---------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        DDLogError(@"Checkbox: %@ has no tag", checkbox);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    NSString *columnIdentifier = [(CellViewCheckbox *)[checkbox superview] columnIdentifier];
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if ( checkbox == [(CellViewCheckbox *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] checkbox] ) {
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        BOOL state = [checkbox state];
        NSMutableDictionary *cellDict = [[_tableViewContent objectAtIndex:(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = @(state);
        cellDict[columnIdentifier] = columnDict;
        [_tableViewContent replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        [self updateTableViewSavedContent];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [_settingTableView beginUpdates];
        [_settingTableView reloadData];
        [_settingTableView endUpdates];
    }
} // checkbox


- (PFCTableViewCellView *)populateCellView:(PFCTableViewCellView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // -------------------------------------------------------------------------
    //  Set sender and sender properties to be used later
    // -------------------------------------------------------------------------
    [self setSender:sender];
    [self setSenderIdentifier:manifest[PFCManifestKeyIdentifier] ?: @""];
    
    // -------------------------------------------------------------------------
    //  Set TableColumn DataSource and Delegate to self
    // -------------------------------------------------------------------------
    [[cellView settingTableView] setDataSource:self];
    [[cellView settingTableView] setDelegate:self];
    
    // -------------------------------------------------------------------------
    //  Initialize the TableView content from settings
    // -------------------------------------------------------------------------
    if ( ! _tableViewContent ) {
        if ( [settings[PFCSettingsKeyTableViewContent] count] != 0 ) {
            _tableViewContent = [settings[PFCSettingsKeyTableViewContent] mutableCopy] ?: [[NSMutableArray alloc] init];
        } else {
            _tableViewContent = [settingsLocal[PFCSettingsKeyTableViewContent] mutableCopy] ?: [[NSMutableArray alloc] init];
        }
    }
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // -------------------------------------------------------------------------
    //  Title
    // -------------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // -------------------------------------------------------------------------
    //  Description
    // -------------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];
    
    // -------------------------------------------------------------------------
    //  Add columns from manifest
    // -------------------------------------------------------------------------
    
    // Remove the current columns if there are any
    for ( NSTableColumn *tableColumn in [[[cellView settingTableView] tableColumns] copy] ) {
        [[cellView settingTableView] removeTableColumn:tableColumn];
    }
    
    // Add columns from manifest
    NSMutableDictionary *tableColumnsCellViews = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnsArray = manifest[PFCManifestKeyTableViewColumns] ?: @[];
    for ( NSDictionary *tableColumnDict in tableColumnsArray ) {
        NSString *tableColumnTitle = tableColumnDict[PFCManifestKeyTableViewColumnTitle] ?: @"";
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:tableColumnTitle];
        [tableColumn setTitle:tableColumnTitle];
        [[cellView settingTableView] addTableColumn:tableColumn];
        tableColumnsCellViews[tableColumnTitle] = tableColumnDict;
    }
    [self setTableViewColumnCellViews:[tableColumnsCellViews copy]];
    
    // ---------------------------------------------------------------------
    //  If only one column, remove header view
    // ---------------------------------------------------------------------
    if ( [tableColumnsArray count] <= 1 ) {
        [[cellView settingTableView] setHeaderView:nil];
    } else {
        [[cellView settingTableView] setHeaderView:[[NSTableHeaderView alloc] init]];
    }
    
    // ---------------------------------------------------------------------
    //  Update table view content
    // ---------------------------------------------------------------------
    [[cellView settingTableView] beginUpdates];
    [[cellView settingTableView] sizeToFit];
    [[cellView settingTableView] reloadData];
    [[cellView settingTableView] endUpdates];
    
    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTableView] setEnabled:enabled];
    [[cellView settingSegmentedControlButton] setEnabled:enabled];
    
    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

@end