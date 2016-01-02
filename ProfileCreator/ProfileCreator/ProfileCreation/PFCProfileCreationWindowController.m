//
//  PFCProfileCreationWindowController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCProfileCreationWindowController.h"
#import "PFCTableViewCellsMenu.h"
#import "PFCTableViewCellsSettings.h"
#import "PFCManifestCreationParser.h"

@interface PFCProfileCreationWindowController ()

@end

@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileType:(int)profileType {
    self = [super initWithWindowNibName:@"PFCProfileCreationWindowController"];
    if (self != nil) {
        _tableViewMenuItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewMenuItemsDisabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsDisabled = [[NSMutableArray alloc] init];
        _tableViewSettingsSettings = [[NSMutableDictionary alloc] init];
        _tableViewSettingsCurrentSettings = [[NSMutableDictionary alloc] init];
        
        _advancedSettings = NO;
        _columnMenuEnabledHidden = YES;
        _columnSettingsEnabledHidden = YES;
        _tableViewMenuSelectedRow = -1; // None selected
        _profileType = profileType;
    }
    return self;
} // init

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"advancedSettings" context:nil];
} // dealloc

- (void)windowDidLoad {
    [super windowDidLoad];
    [self addObserver:self forKeyPath:@"advancedSettings" options:NSKeyValueObservingOptionNew context:nil];
    [self initializeTableViewMenu];
} // windowDidLoad

- (void)initializeTableViewMenu {
    [self setupSettingsErrorView];
    [self updateTableColumnsMenu];
    [self updateTableColumnsSettings];
    [self setupMenu];
    [_tableViewMenu reloadData];
} // initializeMenu

- (void)setupMenu {
    switch (_profileType) {
        case kPFCProfileTypeApple:
            [self setupMenuProfilesApple];
            break;
        case kPFCProfileTypeCustom:
            [self setupMenuProfilesCustom];
            break;
        default:
            break;
    }
} // setupMenu

- (void)setupMenuProfilesCustom {
    if ( ! _customMenu ) {
        NSLog(@"[ERROR] No custom menu available!");
        return;
    }
    
    [_tableViewMenuItemsEnabled addObjectsFromArray:_customMenu];
} // setupMenuProfilesCustom

- (void)setupMenuProfilesApple {
    
    NSError *error = nil;
    
    // ---------------------------------------------------------------------
    //  Get URL to manifest folder inside ProfileCreator.app
    // ---------------------------------------------------------------------
    NSURL *profileManifestFolderURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Manifests"];
    if ( [profileManifestFolderURL checkResourceIsReachableAndReturnError:&error] ) {
        
        // ---------------------------------------------------------------------
        //  Put all profile manifest plist URLs in an array
        // ---------------------------------------------------------------------
        NSArray *manifestPlists = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:profileManifestFolderURL
                                                                includingPropertiesForKeys:@[]
                                                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                     error:nil];
        
        // ---------------------------------------------------------------------
        //  Loop through all profile manifests and add them to the menu array
        // ---------------------------------------------------------------------
        NSPredicate *predicateManifestPlists = [NSPredicate predicateWithFormat:@"self.pathExtension == 'plist'"];
        for ( NSURL *manifestURL in [manifestPlists filteredArrayUsingPredicate:predicateManifestPlists] ) {
            NSDictionary *manifestDict = [NSDictionary dictionaryWithContentsOfURL:manifestURL];
            if ( [manifestDict count] != 0 ) {
                [_tableViewMenuItemsEnabled addObject:manifestDict];
            } else {
                NSLog(@"[ERROR] Manifest %@ was empty!", [manifestURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort menu array
        // ---------------------------------------------------------------------
        [_tableViewMenuItemsEnabled sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        
        // ---------------------------------------------------------------------
        //  Find index of menu item com.apple.general
        // ---------------------------------------------------------------------
        NSUInteger idx = [_tableViewMenuItemsEnabled indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"Domain"] isEqualToString:@"com.apple.general"];
        }];
        
        // ---------------------------------------------------------------------
        //  Move menu item com.apple.general to the top of the menu array
        // ---------------------------------------------------------------------
        if (idx != NSNotFound) {
            NSDictionary *generalSettingsDict = [_tableViewMenuItemsEnabled objectAtIndex:idx];
            [_tableViewMenuItemsEnabled removeObjectAtIndex:idx];
            [_tableViewMenuItemsEnabled insertObject:generalSettingsDict atIndex:0];
        } else {
            NSLog(@"[ERROR] No menu item with domain com.apple.general was found!");
        }
    } else {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
} // setupMenu

- (void)setupSettingsErrorView {
    [_viewSettingsSuperView addSubview:_viewErrorReadingSettings positioned:NSWindowAbove relativeTo:nil];
    [_viewErrorReadingSettings setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSArray *constraintsArray;
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_viewErrorReadingSettings]-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(_viewErrorReadingSettings)];
    [_viewSettingsSuperView addConstraints:constraintsArray];
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_viewErrorReadingSettings]-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(_viewErrorReadingSettings)];
    [_viewSettingsSuperView addConstraints:constraintsArray];
    [_viewSettingsSuperView setHidden:NO];
    [_viewErrorReadingSettings setHidden:YES];
} // setupSettings

- (void)updateTableColumnsMenu {
    for ( NSTableColumn *column in [_tableViewMenu tableColumns] ) {
        if ( [[column identifier] isEqualToString:@"ColumnMenuEnabled"] ) {
            [column setHidden:!_advancedSettings];
        }
    }
} // updateTableColumnsMenu

- (void)updateTableColumnsSettings {
    for ( NSTableColumn *column in [_tableViewSettings tableColumns] ) {
        if ( [[column identifier] isEqualToString:@"ColumnSettingsEnabled"] ) {
            [column setHidden:!_advancedSettings];
        } else if ( [[column identifier] isEqualToString:@"ColumnMinOS"] ) {
            [column setHidden:YES];
        }
    }
} // updateTableColumnsSettings

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#pragma unused(object, change, context)
    if ( [keyPath isEqualToString:@"advancedSettings"] ) {
        NSInteger row = [_tableViewMenu selectedRow];
        [self updateTableColumnsMenu];
        [_tableViewMenu reloadData];
        [_tableViewMenu selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        
        [self updateTableColumnsSettings];
        [self tableViewMenu:nil];
    }
} // observeValueForKeyPath

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:@"TableViewMenu"] ) {
        return (NSInteger)[_tableViewMenuItemsEnabled count];
    } else if ( [[tableView identifier] isEqualToString:@"TableViewSettings"] ) {
        return (NSInteger)[_tableViewSettingsItemsEnabled count];
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
    if ( [tableViewIdentifier isEqualToString:@"TableViewSettings"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_tableViewSettingsItemsEnabled count] < row || [_tableViewSettingsItemsEnabled count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _tableViewSettingsItemsEnabled[(NSUInteger)row];
        NSString *cellType = manifestDict[@"CellType"];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnSettings"] ) {
            
            // ---------------------------------------------------------------------
            //  Padding
            // ---------------------------------------------------------------------
            if ( [cellType isEqualToString:@"Padding"] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
                
                // ---------------------------------------------------------------------
                //  TextField
                // ---------------------------------------------------------------------
            } else {
                
                NSString *identifier = manifestDict[@"Identifier"];
                NSDictionary *cellSettingsDict = _tableViewSettingsCurrentSettings[identifier];
                
                if ( [cellType isEqualToString:@"TextField"] ) {
                    CellViewSettingsTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextField" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewTextField:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
                    CellViewSettingsTextFieldNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewTextFieldNoTitle:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButton
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
                    CellViewSettingsPopUp *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUp" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewPopUp:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  Checkbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"Checkbox"] ) {
                    CellViewSettingsCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsCheckbox:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  DatePickerNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {
                    CellViewSettingsDatePickerNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsDatePickerNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewDatePickerNoTitle:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldDaysHoursNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
                    CellViewSettingsTextFieldDaysHoursNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldDaysHoursNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldDaysHoursNoTitle:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TableView
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TableView"] ) {
                    CellViewSettingsTableView *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTableView" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTableView:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  File
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"File"] ) {
                    CellViewSettingsFile *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsFile" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsFile:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  SegmentedControl
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
                    CellViewSettingsSegmentedControl *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsSegmentedControl" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsSegmentedControl:cellView manifestDict:manifestDict settingDict:manifestDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldHostPort
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
                    CellViewSettingsTextFieldHostPort *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPort" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldHostPort:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  CheckboxNoDescription
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
                    CellViewSettingsCheckboxNoDescription *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckboxNoDescription" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsCheckboxNoDescription:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButtonNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
                    CellViewSettingsPopUpNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUpNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsPopUpNoTitle:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNumber
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
                    CellViewSettingsTextFieldNumber *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNumber" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldNumber:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldCheckbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldCheckbox"] ) {
                    CellViewSettingsTextFieldCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldCheckbox:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldHostPortCheckbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
                    CellViewSettingsTextFieldHostPortCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPortCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldHostPortCheckbox:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButtonLeft
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
                    CellViewSettingsPopUpLeft *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUpLeft" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsPopUpLeft:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNumberLeft
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
                    CellViewSettingsTextFieldNumberLeft *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNumberLeft" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldNumberLeft:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                }
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnSettingsEnabled"] ) {
            if ( [manifestDict[@"Hidden"] boolValue] ) {
                return nil;
            }
            
            if ( [cellType isEqualToString:@"Padding"] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
            } else {
                
                NSString *identifier = manifestDict[@"Identifier"];
                NSDictionary *cellSettingsDict = _tableViewSettingsCurrentSettings[identifier];
                
                CellViewSettingsEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsEnabled" owner:self];
                [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                return [cellView populateCellViewEnabled:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
            }
        }
    } else if ( [tableViewIdentifier isEqualToString:@"TableViewMenu"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the menu array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_tableViewMenuItemsEnabled count] < row || [_tableViewMenuItemsEnabled count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *menuDict = _tableViewMenuItemsEnabled[(NSUInteger)row];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnMenu"] ) {
            NSString *cellType = menuDict[@"CellType"];
            if ( [cellType isEqualToString:@"Menu"] ) {
                CellViewMenu *cellView = [tableView makeViewWithIdentifier:@"CellViewMenu" owner:self];
                return [cellView populateCellViewMenu:cellView menuDict:menuDict row:row];
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView menuDict:menuDict row:row sender:self];
        }
    }
    return nil;
} // tableView:viewForTableColumn:row

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if ( [[tableView identifier] isEqualToString:@"TableViewSettings"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_tableViewSettingsItemsEnabled count] <= 0 ) {
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Get current cell's manifest dict identifier
        // ---------------------------------------------------------------------
        NSDictionary *cellDict = _tableViewSettingsItemsEnabled[(NSUInteger)row];
        NSString *cellType = cellDict[@"CellType"];
        if ( ! [cellType isEqualToString:@"Padding"] ) {
            NSString *identifier = cellDict[@"Identifier"];
            if ( [identifier length] == 0 ) {
                NSLog(@"No Identifier for cell dict: %@", cellDict);
                return;
            }
            
            // ---------------------------------------------------------------------
            //  It the cell is disabled, change cell background to grey
            // ---------------------------------------------------------------------
            if ( _tableViewSettingsCurrentSettings[identifier][@"Enabled"] != nil ) {
                if ( ! [_tableViewSettingsCurrentSettings[identifier][@"Enabled"] boolValue] ) {
                    [rowView setBackgroundColor:[NSColor quaternaryLabelColor]];
                    return;
                }
            }
            
            [rowView setBackgroundColor:[NSColor clearColor]];
        }
    }
} // tableView:didAddRowView:forRow

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ( [[tableView identifier] isEqualToString:@"TableViewSettings"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_tableViewSettingsItemsEnabled count] < row || [_tableViewSettingsItemsEnabled count] == 0 ) {
            return 1;
        }
        
        NSDictionary *profileDict = _tableViewSettingsItemsEnabled[(NSUInteger)row];
        
        NSString *cellType = profileDict[@"CellType"];
        if ( [cellType isEqualToString:@"Padding"] ) {
            return 30;
        } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
            return 33;
        } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
            return 38;
        } else if (
                   [cellType isEqualToString:@"DatePickerNoTitle"] ||
                   [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
            return 39;
        } else if (
                   [cellType isEqualToString:@"Checkbox"] ) {
            return 52;
        } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
            return 53;
        } else if (
                   [cellType isEqualToString:@"TextFieldNoTitle"] ||
                   [cellType isEqualToString:@"PopUpButtonNoTitle"] ||
                   [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
            return 54;
        } else if (
                   [cellType isEqualToString:@"TextField"] ||
                   [cellType isEqualToString:@"TextFieldHostPort"] ||
                   [cellType isEqualToString:@"PopUpButton"] ||
                   [cellType isEqualToString:@"TextFieldNumber"] ||
                   [cellType isEqualToString:@"TextFieldCheckbox"] ||
                   [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
            return 81;
        } else if ( [cellType isEqualToString:@"File"] ) {
            return 192;
        } else if ( [cellType isEqualToString:@"TableView"] ) {
            return 212;
        }
    } else if ( [[tableView identifier] isEqualToString:@"TableViewMenu"] ) {
        return 44;
    }
    return 1;
} // tableView:heightOfRow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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
        NSLog(@"[ERROR] TextField: %@ tag is nil", textFieldTag);
        return;
    }
    NSInteger row = [textFieldTag integerValue];
    
    // ---------------------------------------------------------------------
    //  Get current entered text
    // ---------------------------------------------------------------------
    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
    
    // ---------------------------------------------------------------------
    //  Get current cell identifier in the manifest dict
    // ---------------------------------------------------------------------
    NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Another verification of text field type
    // ---------------------------------------------------------------------
    if (
        [[[textField superview] class] isSubclassOfClass:[CellViewSettingsTextFieldHostPort class]] ||
        [[[textField superview] class] isSubclassOfClass:[CellViewSettingsTextFieldHostPortCheckbox class]]
        ) {
        if ( textField == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextFieldHost] ) {
            settingsDict[@"ValueHost"] = [inputText copy];
        } else if ( textField == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextFieldPort] ) {
            settingsDict[@"ValuePort"] = [inputText copy];
        } else {
            NSLog(@"[ERROR] Unknown text field!");
            return;
        }
    } else if ( [[[textField superview] class] isSubclassOfClass:[CellViewSettingsTextFieldCheckbox class]] ) {
        if ( textField == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextField] ) {
            settingsDict[@"ValueTextField"] = [inputText copy];
        } else {
            NSLog(@"[ERROR] Unknown text field!");
            return;
        }
    } else {
        if ( textField == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextField] ) {
            settingsDict[@"Value"] = [inputText copy];
        } else {
            NSLog(@"[ERROR] Unknown text field!");
            return;
        }
    }
    
    _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
} // controlTextDidChange

- (void)checkbox:(NSButton *)checkbox {
    
    // ---------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        NSLog(@"[ERROR] Checkbox: %@ tag is nil", checkbox);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    
    // ---------------------------------------------------------------------
    //  Get current checkbox state
    // ---------------------------------------------------------------------
    BOOL state = [checkbox state];
    
    // ---------------------------------------------------------------------
    //  Get current cell's key in the settings dict
    // ---------------------------------------------------------------------
    NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewMenuEnabled class]] ) {
        if ( checkbox == [(CellViewMenuEnabled *)[_tableViewMenu viewAtColumn:[_tableViewMenu columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox] ) {
            NSMutableDictionary *cellDict = [[_tableViewMenuItemsEnabled objectAtIndex:row] mutableCopy];
            settingsDict[@"Enabled"] = @(state);
            [_tableViewMenuItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
            return;
        }
        
    } else if (
               [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsEnabled class]]
               ) {
        if ( checkbox == [(CellViewSettingsEnabled *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettingsEnabled"] row:row makeIfNecessary:NO] settingEnabled] ) {
            settingsDict[@"Enabled"] = @(state);
            _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
            [_tableViewSettings beginUpdates];
            [_tableViewSettings reloadData];
            [_tableViewSettings endUpdates];
            return;
        }
        
        
    } else if (
               [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsTextFieldCheckbox class]] ||
               [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsTextFieldHostPortCheckbox class]]
               ) {
        if ( checkbox == [(CellViewSettingsTextFieldCheckbox *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingCheckbox] ) {
            settingsDict[@"ValueCheckbox"] = @(state);
        }
        
        
    } else {
        if ( checkbox == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingCheckbox] ) {
            settingsDict[@"Value"] = @(state);
        }
    }
    
    _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
    
    // ---------------------------------------------------------------------
    //  Add subkeys for selected state
    // ---------------------------------------------------------------------
    [self updateSubKeysForDict:cellDict valueString:state ? @"True" : @"False" row:row];
    [_tableViewSettings beginUpdates];
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
} // checkbox

- (void)datePickerSelection:(NSDatePicker *)datePicker {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings date picker
    // ---------------------------------------------------------------------
    if ( ! [[[datePicker superview] class] isSubclassOfClass:[CellViewSettingsDatePickerNoTitle class]] ) {
        NSLog(@"[ERROR] DatePicker: %@ superview class is: %@", datePicker, [[datePicker superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get date picker's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *datePickerTag = @([datePicker tag]);
    if ( datePickerTag == nil ) {
        NSLog(@"[ERROR] DatePicker: %@ tag is nil", datePicker);
        return;
    }
    NSInteger row = [datePickerTag integerValue];
    
    NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsDatePickerNoTitle date picker
    // ---------------------------------------------------------------------
    if ( datePicker == [(CellViewSettingsDatePickerNoTitle *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingDatePicker] ) {
        
        unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier: @"en_US"]];
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSDate *datePickerDate = [datePicker dateValue];
        
        NSDateComponents* components = [calendarUS components:flags fromDate:datePickerDate];
        NSDate* date = [calendarUS dateFromComponents:components];
        
        
        settingsDict[@"Value"] = date;
        _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
        
        // ---------------------------------------------------------------------
        //  Update description with time interval from today to selected date
        // ---------------------------------------------------------------------
        NSTextField *description = [(CellViewSettingsDatePickerNoTitle *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingDescription];
        [description setStringValue:[self dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }
} // datePickerSelection

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // ---------------------------------------------------------------------
    if (
        ! [[[popUpButton superview] class] isSubclassOfClass:[CellViewSettingsPopUp class]] &&
        ! [[[popUpButton superview] class] isSubclassOfClass:[CellViewSettingsPopUpNoTitle class]] ) {
        NSLog(@"[ERROR] PopUpButton: %@ superview class is: %@", popUpButton, [[popUpButton superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get popup button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *popUpButtonTag = @([popUpButton tag]);
    if ( popUpButtonTag == nil ) {
        NSLog(@"[ERROR] PopUpButton: %@ tag is nil", popUpButton);
        return;
    }
    NSInteger row = [popUpButtonTag integerValue];
    
    NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsPopUp popup button
    // ---------------------------------------------------------------------
    if (
        popUpButton == [(CellViewSettingsPopUp *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingPopUpButton] ||
        popUpButton == [(CellViewSettingsPopUpNoTitle *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingPopUpButton]) {
        
        // ---------------------------------------------------------------------
        //  Save selection
        // ---------------------------------------------------------------------
        NSString *selectedTitle = [popUpButton titleOfSelectedItem];
        settingsDict[@"Value"] = selectedTitle;
        _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [self updateSubKeysForDict:cellDict valueString:selectedTitle row:row];
        [_tableViewSettings beginUpdates];
        [_tableViewSettings reloadData];
        [_tableViewSettings endUpdates];
    }
} // popUpButtonSelection

- (void)selectFile:(NSButton *)button {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings button
    // ---------------------------------------------------------------------
    if ( ! [[[button superview] class] isSubclassOfClass:[CellViewSettingsFile class]] ) {
        NSLog(@"[ERROR] Button: %@ superview class is: %@", button, [[button superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get button's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([button tag]);
    if ( buttonTag == nil ) {
        NSLog(@"[ERROR] Button: %@ tag is nil", button);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    
    NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsFile button
    // ---------------------------------------------------------------------
    if ( button == [(CellViewSettingsFile *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingButtonAdd] ) {
        
        // --------------------------------------------------------------
        //  Get open dialog settings from dict
        // --------------------------------------------------------------
        NSString *prompt = cellDict[@"FilePrompt"] ?: @"Select File";
        NSArray *allowedFileTypes = @[];
        if ( cellDict[@"AllowedFileTypes"] != nil && [cellDict[@"AllowedFileTypes"] isKindOfClass:[NSArray class]] ) {
            allowedFileTypes = cellDict[@"AllowedFileTypes"] ?: @[];
        }
        
        // --------------------------------------------------------------
        //  Setup open dialog for current settings
        // --------------------------------------------------------------
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setTitle:prompt];
        [openPanel setPrompt:@"Select"];
        [openPanel setCanChooseFiles:YES];
        [openPanel setCanChooseDirectories:NO];
        [openPanel setCanCreateDirectories:NO];
        [openPanel setAllowsMultipleSelection:NO];
        
        if ( [allowedFileTypes count] != 0 ) {
            [openPanel setAllowedFileTypes:allowedFileTypes];
        }
        
        [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
            if ( result == NSModalResponseOK ) {
                NSArray *selectedURLs = [openPanel URLs];
                NSURL *fileURL = [selectedURLs firstObject];
                
                settingsDict[@"FilePath"] = [fileURL path];
                _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
                
                [_tableViewSettings beginUpdates];
                [_tableViewSettings reloadData];
                [_tableViewSettings endUpdates];
            }
        }];
    }
} // selectFile

- (void)segmentedControl:(NSSegmentedControl *)segmentedControl {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings segmented control
    // ---------------------------------------------------------------------
    if ( ! [[[segmentedControl superview] class] isSubclassOfClass:[CellViewSettingsSegmentedControl class]] ) {
        NSLog(@"[ERROR] SegmentedControl: %@ superview class is: %@", segmentedControl, [[segmentedControl superview] class]);
        return;
    }
    
    // ---------------------------------------------------------------------
    //  Get segmented control's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *segmentedControlTag = @([segmentedControl tag]);
    if ( segmentedControlTag == nil ) {
        NSLog(@"[ERROR] SegmentedControl: %@ tag is nil", segmentedControl);
        return;
    }
    NSInteger row = [segmentedControlTag integerValue];
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsSegmentedControl segmented control
    // ---------------------------------------------------------------------
    if ( segmentedControl == [(CellViewSettingsSegmentedControl *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingSegmentedControl] ) {
        
        NSString *selectedSegment = [segmentedControl labelForSegment:[segmentedControl selectedSegment]];
        if ( [selectedSegment length] != 0 ) {
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
            cellDict[@"Value"] = @([segmentedControl selectedSegment]);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        } else {
            NSLog(@"[ERROR] SegmentedControl: %@ selected segment is nil", segmentedControl);
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected segmented control
        // ---------------------------------------------------------------------
        [self updateSubKeysForDict:[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] valueString:selectedSegment row:row];
        [_tableViewSettings beginUpdates];
        [_tableViewSettings reloadData];
        [_tableViewSettings endUpdates];
    }
    
} // segmentedControl

- (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate {
    
    // ---------------------------------------------------------------------
    //  Set allowed date units to year, month and day
    // ---------------------------------------------------------------------
    unsigned int allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    // ---------------------------------------------------------------------
    //  Use calendar US
    // ---------------------------------------------------------------------
    NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier: @"en_US"]];
    
    // ---------------------------------------------------------------------
    //  Remove all components except the allowed date units
    // ---------------------------------------------------------------------
    NSDateComponents* components = [calendarUS components:allowedUnits fromDate:futureDate];
    NSDate* date = [calendarUS dateFromComponents:components];
    NSDate *currentDate = [calendarUS dateFromComponents:[calendarUS components:allowedUnits fromDate:[NSDate date]]];
    
    // ---------------------------------------------------------------------
    //  Calculate the date interval
    // ---------------------------------------------------------------------
    NSTimeInterval secondsBetween = [date timeIntervalSinceDate:currentDate];
    
    // ---------------------------------------------------------------------
    //  Create date formatter to create the date in spelled out string format
    // ---------------------------------------------------------------------
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    [dateComponentsFormatter setAllowedUnits:allowedUnits];
    [dateComponentsFormatter setMaximumUnitCount:3];
    [dateComponentsFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStyleFull];
    [dateComponentsFormatter setCalendar:calendarUS];
    
    return [dateComponentsFormatter stringFromTimeInterval:secondsBetween];
} // dateIntervalFromNowToDate

- (NSArray *)settingsForMenuItem:(NSDictionary *)menuDict {
    NSMutableArray *combinedSettings = [[NSMutableArray alloc] init];
    if ( [menuDict count] != 0 ) {
        if ( menuDict[@"SavedSettings"] != nil ) {
            return menuDict[@"SavedSettings"];
        } else {
            NSArray *settings = menuDict[@"PayloadKeys"];
            
            for ( NSDictionary *setting in settings ) {
                NSMutableDictionary *combinedSettingDict = [setting mutableCopy];
                combinedSettingDict[@"Enabled"] = @YES;
                [combinedSettings addObject:[combinedSettingDict copy]];
            }
            
            if ( [combinedSettings count] != 0 ) {
                
                // ---------------------------------------------------------------------
                //  Add padding row to top of table view
                // ---------------------------------------------------------------------
                [combinedSettings insertObject:@{ @"CellType" : @"Padding",
                                                  @"Enabled" : @YES } atIndex:0];
                
                // ---------------------------------------------------------------------
                //  Add padding row to end of table view
                // ---------------------------------------------------------------------
                [combinedSettings addObject:@{ @"CellType" : @"Padding",
                                               @"Enabled" : @YES }];
            }
        }
    }
    return [combinedSettings copy];
} // settingsForMenuItem

- (BOOL)updateSubKeysForDict:(NSDictionary *)cellDict valueString:(NSString *)valueString row:(NSInteger)row {
    
    __block BOOL updatedTableView = NO;
    
    // ---------------------------------------------------------------------
    //  Handle sub keys
    // ---------------------------------------------------------------------
    NSDictionary *valueKeys = cellDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] != 0 ) {
        
        // ---------------------------------------------------------------------
        //  Remove any previous sub keys
        // ---------------------------------------------------------------------
        __block NSArray *parentKeyArray;
        if ( row < [_tableViewSettingsItemsEnabled count] ) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((row + 1), [_tableViewSettingsItemsEnabled count]-(row + 1))];
            [[_tableViewSettingsItemsEnabled copy] enumerateObjectsAtIndexes:indexes options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //NSLog(@"idx=%lu", (unsigned long)idx);
                //NSLog(@"obj=%@", obj);
                
                // ----------------------------------------------------------------------
                //  Check if parent key exist in value keys (if it's added by the caller)
                // ----------------------------------------------------------------------
                if ( valueKeys[obj[@"ParentKey"]] != nil ) {
                    
                    parentKeyArray = valueKeys[obj[@"ParentKey"]];
                    if ( ! [[valueKeys[valueString] class] isSubclassOfClass:[NSArray class]] || ! [parentKeyArray isEqualToArray:valueKeys[valueString]] ) {
                        //NSLog(@"[DEBUG] Removing row: %ld", (row + 1));
                        //NSLog(@"[DEBUG] Removing dict: %@", [_tableViewSettingsItemsEnabled objectAtIndex:(row + 1)]);
                        [_tableViewSettingsItemsEnabled removeObjectAtIndex:(row + 1)];
                        updatedTableView = YES;
                    }
                } else {
                    
                    // ----------------------------------------------------------------------------------------
                    //  Check if parent key exist in parents value keys (if it's added by the caller's parent)
                    // ----------------------------------------------------------------------------------------
                    // FIXME - This implementation is flawed, only reaches second level of nesting, should remove all nesting not limited to level
                    if ( ! [[valueKeys[valueString] class] isSubclassOfClass:[NSArray class]] || ! [parentKeyArray isEqualToArray:valueKeys[valueString]] ) {
                        for ( NSDictionary *parentKeyDict in parentKeyArray ) {
                            if ( parentKeyDict[@"ValueKeys"][obj[@"ParentKey"]] != nil ) {
                                NSLog(@"[DEBUG] Removing row: %ld", (row + 1));
                                NSLog(@"[DEBUG] Removing dict: %@", [_tableViewSettingsItemsEnabled objectAtIndex:(row + 1)]);
                                [_tableViewSettingsItemsEnabled removeObjectAtIndex:(row + 1)];
                                updatedTableView = YES;
                                return;
                            }
                            
                        }
                    }
                    *stop = YES;
                }
            }];
        }
        
        // ---------------------------------------------------------------------------
        //  If selected object (valueString) in dict valueKeys is not an array, stop.
        // ---------------------------------------------------------------------------
        if ( ! [[valueKeys[valueString] class] isSubclassOfClass:[NSArray class]] ) {
            return updatedTableView;
        }
        
        // ---------------------------------------------------------------------
        //  Check if any sub keys exist for selected value
        // ---------------------------------------------------------------------
        NSArray *valueKeyArray = [valueKeys[valueString] mutableCopy] ?: @[];
        if ( ! [parentKeyArray ?: @[] isEqualToArray:valueKeyArray] ) {
            for ( NSDictionary *valueDict in valueKeyArray ) {
                if ( [valueDict count] == 0 ) {
                    continue;
                }
                
                NSMutableDictionary *mutableValueDict;
                if ( [valueDict[@"SharedKey"] length] != 0 ) {
                    NSString *sharedKey = valueDict[@"SharedKey"];
                    NSLog(@"sharedKey=%@", sharedKey);
                    NSDictionary *valueKeysShared = cellDict[@"ValueKeysShared"];
                    if ( [valueKeysShared count] != 0 ) {
                        mutableValueDict = valueKeysShared[sharedKey];
                    } else {
                        NSLog(@"Shared Key is defined, but no ValueKeysShared dict was found!");
                        continue;
                    }
                } else {
                    mutableValueDict = [valueDict mutableCopy];
                }
                
                row++;
                // ---------------------------------------------------------------------
                //  Add sub key to table view below setting
                // ---------------------------------------------------------------------
                mutableValueDict[@"ParentKey"] = valueString;
                //NSLog(@"[DEBUG] Adding row: %ld", row);
                //NSLog(@"[DEBUG] Adding dict: %@", [mutableValueDict copy]);
                [_tableViewSettingsItemsEnabled insertObject:[mutableValueDict copy] atIndex:row];
                updatedTableView = YES;
            }
        }
    }
    
    return updatedTableView;
} // updateSubKeysForDict:valueString:row

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)tableViewMenu:(id) __unused sender {
    
    // ---------------------------------------------------------------------
    //  Save current settings in menu dict
    // ---------------------------------------------------------------------
    if ( 0 <= _tableViewMenuSelectedRow ) {
        NSMutableDictionary *currentMenuDict = [[self->_tableViewMenuItemsEnabled objectAtIndex:self->_tableViewMenuSelectedRow] mutableCopy];
        if ( [_tableViewSettingsCurrentSettings count] != 0 ) {
            NSString *menuDomain = currentMenuDict[@"Domain"];
            _tableViewSettingsSettings[menuDomain] = [_tableViewSettingsCurrentSettings copy];
        }
        currentMenuDict[@"SavedSettings"] = [self->_tableViewSettingsItemsEnabled copy];
        [_tableViewMenuItemsEnabled replaceObjectAtIndex:self->_tableViewMenuSelectedRow withObject:[currentMenuDict copy]];
    }
    
    // ---------------------------------------------------------------------
    //  Set _tableViewMenuSelectedRow to new selection
    // ---------------------------------------------------------------------
    [self setTableViewMenuSelectedRow:[_tableViewMenu selectedRow]];
    
    [_tableViewSettings beginUpdates];
    [_tableViewSettingsItemsEnabled removeAllObjects];
    
    if ( 0 <= _tableViewMenuSelectedRow ) {
        NSMutableDictionary *currentMenuDict = [[self->_tableViewMenuItemsEnabled objectAtIndex:self->_tableViewMenuSelectedRow] mutableCopy];
        NSString *menuDomain = currentMenuDict[@"Domain"];
        [self setTableViewSettingsCurrentSettings:[_tableViewSettingsSettings[menuDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        NSArray *settingsArray = [self settingsForMenuItem:_tableViewMenuItemsEnabled[_tableViewMenuSelectedRow]];
        if ( [settingsArray count] != 0 ) {
            [_tableViewSettingsItemsEnabled addObjectsFromArray:[settingsArray copy]];
            [_viewErrorReadingSettings setHidden:YES];
        } else {
            [_viewErrorReadingSettings setHidden:NO];
        }
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
} // tableViewMenu

- (IBAction)buttonCancel:(id)sender {
}

- (IBAction)buttonSave:(id)sender {
    
    NSLog(@"savedSettingsArray=%@", _tableViewSettingsCurrentSettings);
}

- (NSDictionary *)savedSettingsForCellType:(NSString *)cellType cellDict:(NSDictionary *)cellDict {
    NSMutableDictionary *savedSettingsDict = [[NSMutableDictionary alloc] init];
    
    // ---------------------------------------------------------------------
    //  Key
    // ---------------------------------------------------------------------
    if ( [cellDict[@"Key"] length] == 0 ) {
        NSLog(@"[ERROR] No key defined in dict!");
        return @{};
    } else {
        savedSettingsDict[@"Key"] = cellDict[@"Key"];
    }
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    savedSettingsDict[@"Enabled"] = @([cellDict[@"Enabled"] boolValue]);
    
    // ---------------------------------------------------------------------
    //  Save settings for each cell type
    //  TextField
    // ---------------------------------------------------------------------
    if ( [cellType isEqualToString:@"TextField"] ) {
        if ( [cellDict[@"Value"] length] != 0 ) {
            savedSettingsDict[@"Value"] = cellDict[@"Value"];
        }
        
        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        NSString *selectedValue;
        if ( [cellDict[@"Value"] length] != 0 ) {
            selectedValue = cellDict[@"Value"];
        } else if ( [cellDict[@"DefaultValue"] length] != 0 ) {
            selectedValue = cellDict[@"DefaultValue"];
        } else {
            NSLog(@"[ERROR] Unknown selection in popUpButton!");
            return @{};
        }
        
        savedSettingsDict[@"Value"] = selectedValue;
        
        /* To be used when exporting probably
         id valueKeyValue = cellDict[@"ValueKeys"][selectedValue];
         NSString *keyValueType = [PFCManifestCreationParser typeStringFromValue:valueKeyValue];
         NSLog(@"keyValueType=%@", keyValueType);
         if ( [keyValueType isEqualToString:@"Array"] ) {
         for ( NSDictionary *nestedCellDict in (NSArray *)valueKeyValue ) {
         
         }
         }
         */
    }
    
    return [savedSettingsDict copy];
}

@end
