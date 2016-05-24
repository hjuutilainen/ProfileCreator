//
//  PFCCellTypeTableView.m
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

#import "PFCAvailability.h"
#import "PFCCellTypeTableView.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditorManifest.h"
#import "PFCProfileExport.h"
#import "PFCTableViewCellTypeCheckbox.h"
#import "PFCTableViewCellTypePopUpButton.h"
#import "PFCTableViewCellTypeProtocol.h"
#import "PFCTableViewCellTypeTextField.h"
#import "PFCTableViewCellTypes.h"

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
    if (![[[sender object] class] isSubclassOfClass:[NSTextField class]]) {
        return;
    }

    // ---------------------------------------------------------------------
    //  Get text field's row in the table view
    // ---------------------------------------------------------------------
    NSTextField *textField = [sender object];
    NSNumber *textFieldTag = @(textField.tag);
    if (textFieldTag == nil) {
        DDLogError(@"TextField: %@ has no tag", textFieldTag);
        return;
    }
    NSInteger row = textFieldTag.integerValue;

    NSString *columnIdentifier = [(PFCTableViewTextFieldCellView *)[textField superview] columnIdentifier];

    // ---------------------------------------------------------------------
    //  Get current text and current cell dict
    // ---------------------------------------------------------------------
    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
    NSMutableDictionary *cellDict = [_tableViewContent[(NSUInteger)row] mutableCopy];

    // ---------------------------------------------------------------------
    //  Another verification of text field type
    // ---------------------------------------------------------------------
    if ([[[textField superview] class] isSubclassOfClass:[PFCTableViewTextFieldCellView class]]) {
        if (textField == [[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] textField]) {
            NSMutableDictionary *columnDict = cellDict[columnIdentifier];
            columnDict[PFCSettingsKeyValue] = [inputText copy];
            cellDict[columnIdentifier] = columnDict;
        } else {
            return;
        }

        _tableViewContent[(NSUInteger)row] = [cellDict copy];
        [self updateTableViewSavedContent];
    }
} // controlTextDidChange

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (NSInteger)_tableViewContent.count;
} // numberOfRowsInTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Verify the table view content array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if (_tableViewContent.count < row || _tableViewContent.count == 0) {
        return nil;
    }

    return [[PFCTableViewCellTypes sharedInstance] cellViewForTableViewCellType:_tableViewColumnCellViews[tableColumn.identifier][PFCManifestKeyCellType]
                                                                     columnDict:_tableViewColumnCellViews[tableColumn.identifier]
                                                                      tableView:tableView
                                                                       settings:_tableViewContent[(NSUInteger)row][tableColumn.identifier]
                                                               columnIdentifier:tableColumn.identifier
                                                                            row:row
                                                                         sender:self];
} // tableView:viewForTableColumn:row

- (NSInteger)insertRowInTableView:(NSDictionary *)rowDict {
    NSInteger index = _settingTableView.selectedRow;
    index++;
    [_settingTableView beginUpdates];
    [_settingTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)index] withAnimation:NSTableViewAnimationSlideDown];
    [_settingTableView scrollRowToVisible:index];
    [_tableViewContent insertObject:rowDict atIndex:(NSUInteger)index];
    [_settingTableView endUpdates];
    return index;
} // insertRowInTableView

- (void)updateTableViewSavedContent {
    if (_sender && _senderIdentifier.length != 0) {
        NSMutableDictionary *settings = [[(PFCProfileEditorManifest *)_sender settingsManifest][_senderIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        settings[PFCSettingsKeyTableViewContent] = [_tableViewContent copy];
        [(PFCProfileEditorManifest *)_sender settingsManifest][_senderIdentifier] = [settings mutableCopy];
    }
} // updateTableViewSavedContent

- (IBAction)segmentedControlButton:(id)sender {
    switch ([sender selectedSegment]) {
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

    if (!_tableViewContent) {
        _tableViewContent = [[NSMutableArray alloc] init];
    }

    NSMutableDictionary *newRowDict = [[NSMutableDictionary alloc] init];
    for (NSString *tableColumnKey in _tableViewColumnCellViews.allKeys ?: @[]) {
        NSMutableDictionary *tableColumnDict = [[NSMutableDictionary alloc] init];
        NSDictionary *tableColumnCellViewDict = _tableViewColumnCellViews[tableColumnKey];
        NSString *cellType = tableColumnCellViewDict[PFCManifestKeyCellType];

        if ([cellType isEqualToString:PFCTableViewCellTypeTextField]) {
            tableColumnDict[PFCSettingsKeyValue] = tableColumnCellViewDict[PFCManifestKeyDefaultValue] ?: @"";
        } else if ([cellType isEqualToString:PFCTableViewCellTypePopUpButton]) {
            tableColumnDict[PFCSettingsKeyValue] = tableColumnCellViewDict[PFCManifestKeyDefaultValue] ?: @"";
            tableColumnDict[PFCManifestKeyAvailableValues] = tableColumnCellViewDict[PFCManifestKeyAvailableValues] ?: @[];
        } else if ([cellType isEqualToString:PFCTableViewCellTypeCheckbox]) {
            tableColumnDict[PFCSettingsKeyValue] = @([tableColumnCellViewDict[PFCManifestKeyDefaultValue] boolValue] ?: NO);
        }
        newRowDict[tableColumnKey] = tableColumnDict;
    }

    [self insertRowInTableView:[newRowDict copy]];
    [self updateTableViewSavedContent];
} // buttonAdd

- (void)buttonRemove {
    [_tableViewContent removeObjectsAtIndexes:_settingTableView.selectedRowIndexes];
    [_settingTableView removeRowsAtIndexes:_settingTableView.selectedRowIndexes withAnimation:NSTableViewAnimationSlideDown];
    [self updateTableViewSavedContent];
} // buttonRemove

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {

    // ---------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // ---------------------------------------------------------------------
    if (![[[popUpButton superview] class] isSubclassOfClass:[PFCTableViewPopUpButtonCellView class]]) {
        DDLogError(@"PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }

    // ---------------------------------------------------------------------
    //  Get popup button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *popUpButtonTag = @(popUpButton.tag);
    if (popUpButtonTag == nil) {
        DDLogError(@"PopUpButton: %@ has no tag", popUpButton);
        return;
    }
    NSInteger row = popUpButtonTag.integerValue;

    NSString *columnIdentifier = [(PFCTableViewPopUpButtonCellView *)[popUpButton superview] columnIdentifier];

    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if (popUpButton == [(PFCTableViewPopUpButtonCellView *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] popUpButton]) {

        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSString *selectedTitle = popUpButton.titleOfSelectedItem;
        NSMutableDictionary *cellDict = [_tableViewContent[(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = selectedTitle;
        cellDict[columnIdentifier] = columnDict;
        _tableViewContent[(NSUInteger)row] = [cellDict copy];
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
    NSNumber *buttonTag = @(checkbox.tag);
    if (buttonTag == nil) {
        DDLogError(@"Checkbox: %@ has no tag", checkbox);
        return;
    }
    NSInteger row = buttonTag.integerValue;
    NSString *columnIdentifier = [(PFCTableViewCheckboxCellView *)[checkbox superview] columnIdentifier];

    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if (checkbox == [(PFCTableViewCheckboxCellView *)[_settingTableView viewAtColumn:[_settingTableView columnWithIdentifier:columnIdentifier] row:row makeIfNecessary:NO] checkbox]) {

        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        BOOL state = (BOOL)checkbox.state;
        NSMutableDictionary *cellDict = [_tableViewContent[(NSUInteger)row] mutableCopy];
        NSMutableDictionary *columnDict = cellDict[columnIdentifier];
        columnDict[PFCSettingsKeyValue] = @(state);
        cellDict[columnIdentifier] = columnDict;
        _tableViewContent[(NSUInteger)row] = [cellDict copy];
        [self updateTableViewSavedContent];

        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [_settingTableView beginUpdates];
        [_settingTableView reloadData];
        [_settingTableView endUpdates];
    }
} // checkbox

- (instancetype)populateCellView:(PFCTableViewCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // -------------------------------------------------------------------------
    //  Set sender and sender properties to be used later
    // -------------------------------------------------------------------------
    [self setSender:sender];
    [self setSenderIdentifier:manifestContentDict[PFCManifestKeyIdentifier] ?: @""];

    // -------------------------------------------------------------------------
    //  Set TableColumn DataSource and Delegate to self
    // -------------------------------------------------------------------------
    [[cellView settingTableView] setDataSource:self];
    [[cellView settingTableView] setDelegate:self];

    // -------------------------------------------------------------------------
    //  Initialize the TableView content from settings
    // -------------------------------------------------------------------------
    if (!_tableViewContent) {
        if ([settingsUser[PFCSettingsKeyTableViewContent] count] != 0) {
            if ([settingsUser[PFCSettingsKeyTableViewContent] count] != 0) {
                [self setTableViewContent:[settingsUser[PFCSettingsKeyTableViewContent] mutableCopy]];
            } else {
                [self setTableViewContent:[manifestContentDict[PFCManifestKeyDefaultValue] mutableCopy] ?: [[NSMutableArray alloc] init]];
            }
        } else {
            if ([settingsLocal[PFCSettingsKeyTableViewContent] count] != 0) {
                [self setTableViewContent:[settingsLocal[PFCSettingsKeyTableViewContent] mutableCopy]];
            } else {
                [self setTableViewContent:[manifestContentDict[PFCManifestKeyDefaultValue] mutableCopy] ?: [[NSMutableArray alloc] init]];
            }
        }
    }

    // -------------------------------------------------------------------------
    //  Get availability overrides
    // -------------------------------------------------------------------------
    NSDictionary *overrides = [[PFCAvailability sharedInstance] overridesForManifestContentDict:manifestContentDict manifest:manifest settings:settings displayKeys:displayKeys];

    // -------------------------------------------------------------------------
    //  Get required state for this cell view
    // -------------------------------------------------------------------------
    BOOL required = NO;
    if (overrides[PFCManifestKeyRequired] != nil) {
        required = [overrides[PFCManifestKeyRequired] boolValue];
    } else {
        required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    }

    // -------------------------------------------------------------------------
    //  Determine if UI should be enabled or disabled
    //  If 'required', it cannot be disabled
    // -------------------------------------------------------------------------
    BOOL enabled = YES;
    if (!required) {
        if (settingsUser[PFCSettingsKeyEnabled] != nil) {
            enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
        } else if (overrides[PFCSettingsKeyEnabled] != nil) {
            enabled = [overrides[PFCSettingsKeyEnabled] boolValue];
        }
    }

    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    NSString *title = manifestContentDict[PFCManifestKeyTitle] ?: @"";
    if (title.length != 0) {
        title = [NSString stringWithFormat:@"%@%@", title, (supervisedOnly) ? @" (supervised only)" : @""];
        [[cellView settingTitle] setStringValue:title];
        if (enabled) {
            [[cellView settingTitle] setTextColor:[NSColor blackColor]];
        } else {
            [[cellView settingTitle] setTextColor:[NSColor grayColor]];
        }
    } else {
        [[cellView settingTitle] removeFromSuperview];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingDescription]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingDescription)]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    NSString *description = manifestContentDict[PFCManifestKeyDescription] ?: @"";
    if (description.length != 0) {
        [[cellView settingDescription] setStringValue:description];
    } else {
        [[cellView settingDescription] removeFromSuperview];
        if (title.length != 0) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_settingTitle]-[settingTableView]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(_settingTitle, _settingTableView)]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[_settingTableView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_settingTableView)]];
        }
    }

    // -------------------------------------------------------------------------
    //  Add columns from manifestContentDict
    // -------------------------------------------------------------------------

    // Remove the current columns if there are any
    for (NSTableColumn *tableColumn in [[[cellView settingTableView] tableColumns] copy]) {
        [[cellView settingTableView] removeTableColumn:tableColumn];
    }

    // Add columns from manifestContentDict
    NSMutableDictionary *tableColumnsCellViews = [[NSMutableDictionary alloc] init];
    NSArray *tableColumnsArray = manifestContentDict[PFCManifestKeyTableViewColumns] ?: @[];
    for (NSDictionary *tableColumnDict in tableColumnsArray) {
        if ([[PFCAvailability sharedInstance] showSelf:tableColumnDict displayKeys:displayKeys]) {
            NSString *tableColumnTitle = tableColumnDict[PFCManifestKeyTableViewColumnTitle] ?: @"";
            if (tableColumnTitle.length == 0) {
                if (tableColumnDict[PFCManifestKeyPayloadKey] != nil) {
                    tableColumnTitle = tableColumnDict[PFCManifestKeyPayloadKey] ?: @"";
                } else if (manifestContentDict[PFCManifestKeyPayloadKey]) {
                    tableColumnTitle = manifestContentDict[PFCManifestKeyPayloadKey] ?: @"";
                }
            }
            NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:tableColumnDict[PFCManifestKeyIdentifier]];
            [tableColumn setTitle:tableColumnTitle];
            if ([tableColumnDict[PFCManifestKeyTableViewColumnWidth] isKindOfClass:[NSNumber class]]) {
                [tableColumn setMaxWidth:[tableColumnDict[PFCManifestKeyTableViewColumnWidth] floatValue]];
                [tableColumn setMinWidth:[tableColumnDict[PFCManifestKeyTableViewColumnWidth] floatValue]];
            }
            [[cellView settingTableView] addTableColumn:tableColumn];
            tableColumnsCellViews[tableColumnDict[PFCManifestKeyIdentifier]] = tableColumnDict;
        }
    }
    [self setTableViewColumnCellViews:[tableColumnsCellViews copy]];

    // ---------------------------------------------------------------------
    //  If only one column, remove header view
    // ---------------------------------------------------------------------
    if (tableColumnsArray.count <= 1) {
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
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingTableView] setEnabled:enabled];
    [[cellView settingSegmentedControlButton] setEnabled:enabled];

    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    // FIXME - Write verification
    return @{};
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TableView'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey, PFCManifestKeyTableViewColumns ]
                                   manifestContentDict:manifestContentDict]) {
        return;
    }

    // Should probably check this aswell when exporting.
    NSArray *tableViewColumns = manifestContentDict[PFCManifestKeyTableViewColumns];

    // -------------------------------------------------------------------------
    //  Get value for current PayloadKey
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    NSArray *tableViewContentArray = contentDictSettings[PFCSettingsKeyTableViewContent] ?: manifestContentDict[PFCManifestKeyDefaultValue];

    // Do some more and better checking here, like if it's required etc.
    if (tableViewContentArray.count == 0) {
        DDLogInfo(@"No content for current payload key.");
        return;
    }

    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [item[PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
    }];

    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if (index != NSNotFound) {
        payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
    } else {
        payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }

    id value;
    if ([manifestContentDict[PFCManifestKeyPayloadValueType] isEqualToString:@"Dict"]) {
        NSMutableDictionary *tableViewPayloadDict = [[NSMutableDictionary alloc] init];
        for (NSDictionary *tableViewColumnDict in tableViewContentArray) {
            [sender createPayloadDictFromTableViewColumns:tableViewColumns settings:tableViewColumnDict payloadDict:&tableViewPayloadDict];
        }
        value = [tableViewPayloadDict copy] ?: @{};
    } else {
        // -------------------------------------------------------------------------
        //  Create array from TableView settings
        // -------------------------------------------------------------------------
        NSMutableArray *tableViewPayloadArray = [payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] mutableCopy] ?: [[NSMutableArray alloc] init];
        for (NSDictionary *tableViewColumnDict in tableViewContentArray) {
            [sender createPayloadArrayFromTableViewColumns:tableViewColumns settings:tableViewColumnDict payloads:&tableViewPayloadArray];
        }
        value = [tableViewPayloadArray copy] ?: @[];
    }

    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = value;

    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if (index != NSNotFound) {
        [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  TableView
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForTableViewColumns:manifestContentDict[PFCManifestKeyTableViewColumns] ?: @[]
                                                  manifestContentDict:manifestContentDict
                                                             manifest:manifest
                                                        parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

@end
