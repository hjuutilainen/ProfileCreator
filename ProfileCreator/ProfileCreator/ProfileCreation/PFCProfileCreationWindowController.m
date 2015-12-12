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

@interface PFCProfileCreationWindowController ()

@end

@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super initWithWindowNibName:@"PFCProfileCreationWindowController"];
    if (self != nil) {
        _tableViewMenuItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewMenuItemsDisabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsDisabled = [[NSMutableArray alloc] init];
        
        _advancedSettings = NO;
        _columnMenuEnabledHidden = YES;
        _columnSettingsEnabledHidden = YES;
        _tableViewMenuSelectedRow = -1;
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
    [self updateTableColumnsMenu];
    [self updateTableColumnsSettings];
    [self setupMenu];
    [self setupSettingsErrorView];
    [_tableViewMenu reloadData];
} // initializeMenu

- (void)setupMenu {
    
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
            [column setHidden:!self->_advancedSettings];
        }
    }
} // updateTableColumnsMenu

- (void)updateTableColumnsSettings {
    for ( NSTableColumn *column in [_tableViewSettings tableColumns] ) {
        if ( [[column identifier] isEqualToString:@"ColumnSettingsEnabled"] ) {
            [column setHidden:!self->_advancedSettings];
        } else if ( [[column identifier] isEqualToString:@"ColumnMinOS"] ) {
            [column setHidden:YES];
        }
    }
} // updateTableColumnsSettings

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#pragma unused(object, change, context)
    if ( [keyPath isEqualToString:@"advancedSettings"] ) {
        [self updateTableColumnsMenu];
        [_tableViewMenu reloadData];
        
        [self updateTableColumnsSettings];
        [_tableViewSettings reloadData];
    }
} // observeValueForKeyPath

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:@"TableViewMenu"] ) {
        return (NSInteger)[self->_tableViewMenuItemsEnabled count];
    } else if ( [[tableView identifier] isEqualToString:@"TableViewSettings"] ) {
        return (NSInteger)[self->_tableViewSettingsItemsEnabled count];
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
        NSDictionary *settingDict = _tableViewSettingsItemsEnabled[(NSUInteger)row];
        NSString *cellType = settingDict[@"CellType"];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnSettings"] ) {
            if ( [cellType isEqualToString:@"Padding"] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
            } else if ( [cellType isEqualToString:@"TextField"] ) {
                CellViewSettingsTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextField" owner:self];
                return [cellView populateCellViewTextField:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
                CellViewSettingsTextFieldNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNoTitle" owner:self];
                return [cellView populateCellViewTextFieldNoTitle:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
                CellViewSettingsPopUp *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUp" owner:self];
                return [cellView populateCellViewPopUp:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"Checkbox"] ) {
                CellViewSettingsCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckbox" owner:self];
                return [cellView populateCellViewSettingsCheckbox:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {
                CellViewSettingsDatePickerNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsDatePickerNoTitle" owner:self];
                return [cellView populateCellViewDatePickerNoTitle:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
                CellViewSettingsTextFieldDaysHoursNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldDaysHoursNoTitle" owner:self];
                return [cellView populateCellViewSettingsTextFieldDaysHoursNoTitle:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"TableView"] ) {
                CellViewSettingsTableView *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTableView" owner:self];
                return [cellView populateCellViewSettingsTableView:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"File"] ) {
                CellViewSettingsFile *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsFile" owner:self];
                return [cellView populateCellViewSettingsFile:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
                CellViewSettingsSegmentedControl *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsSegmentedControl" owner:self];
                return [cellView populateCellViewSettingsSegmentedControl:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
                CellViewSettingsTextFieldHostPort *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPort" owner:self];
                return [cellView populateCellViewSettingsTextFieldHostPort:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
                CellViewSettingsCheckboxNoDescription *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckboxNoDescription" owner:self];
                return [cellView populateCellViewSettingsCheckboxNoDescription:cellView settingDict:settingDict row:row sender:self];
            } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
                CellViewSettingsPopUpNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUpNoTitle" owner:self];
                return [cellView populateCellViewSettingsPopUpNoTitle:cellView settingDict:settingDict row:row sender:self];
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnSettingsEnabled"] ) {
            if ( [settingDict[@"Hidden"] boolValue] ) {
                return nil;
            }
            
            if ( [cellType isEqualToString:@"Padding"] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
            } else {
                CellViewSettingsEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsEnabled" owner:self];
                return [cellView populateCellViewEnabled:cellView settingDict:settingDict row:row sender:self];
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
        if ( [_tableViewSettingsItemsEnabled count] <= 0 ) {
            return;
        }
        NSDictionary *profileDict = _tableViewSettingsItemsEnabled[(NSUInteger)row];
        if ( [profileDict[@"Enabled"] boolValue] ) {
            [rowView setBackgroundColor:[NSColor clearColor]];
        } else {
            [rowView setBackgroundColor:[NSColor lightGrayColor]];
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
        
        NSDictionary *profileDict = self->_tableViewSettingsItemsEnabled[(NSUInteger)row];
        NSString *cellType = profileDict[@"CellType"];
        if ( [cellType isEqualToString:@"Padding"] ) {
            return 30;
        } else if (
                   [cellType isEqualToString:@"TextFieldNoTitle"] ||
                   [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
            return 54;
        } else if (
                   [cellType isEqualToString:@"TextField"] ||
                   [cellType isEqualToString:@"TextFieldHostPort"] ||
                   [cellType isEqualToString:@"PopUpButton"] ) {
            return 81;
        } else if (
                   [cellType isEqualToString:@"Checkbox"] ) {
            return 52;
        } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
            return 30;
        } else if (
                   [cellType isEqualToString:@"DatePickerNoTitle"] ||
                   [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
            return 39;
        } else if ( [cellType isEqualToString:@"TableView"] ) {
            return 250;
        } else if ( [cellType isEqualToString:@"File"] ) {
            return 192;
        } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
            return 38;
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
    //  Another verification this is a CellViewSettingsTextField text field
    // ---------------------------------------------------------------------
    if ( textField == [[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingTextField] ) {
        NSDictionary *userInfo = [sender userInfo];
        NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
        NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:row] mutableCopy];
        cellDict[@"Value"] = inputText;
        [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
    }
}

- (void)checkbox:(NSButton *)checkbox {
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        NSLog(@"[ERROR] Checkbox: %@ tag is nil", checkbox);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    
    if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewMenuEnabled class]] ) {
        if ( checkbox == [(CellViewMenuEnabled *)[_tableViewMenu viewAtColumn:[_tableViewMenu columnWithIdentifier:@"ColumnMenuEnabled"] row:[buttonTag integerValue] makeIfNecessary:NO] menuCheckbox] ) {
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewMenuItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Enabled"] = @(state);
            [_tableViewMenuItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        }
    } else if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsEnabled class]] ) {
        if ( checkbox == [(CellViewSettingsEnabled *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettingsEnabled"] row:[buttonTag integerValue] makeIfNecessary:NO] settingEnabled] ) {
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Enabled"] = @(state);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
            [_tableViewSettings reloadData];
        }
    } else if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsCheckbox class]] ) {
        if ( checkbox == [(CellViewSettingsCheckbox *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:[buttonTag integerValue] makeIfNecessary:NO] settingCheckbox] ) {
            
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Value"] = @(state);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
            
            // ---------------------------------------------------------------------
            //  Add subkeys for selected state
            // ---------------------------------------------------------------------
            [self updateSubKeysForDict:cellDict valueString:state ? @"True" : @"False" row:row];
            [_tableViewSettings reloadData];
        }
    } else if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsCheckboxNoDescription class]] ) {
        if ( checkbox == [(CellViewSettingsCheckboxNoDescription *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:[buttonTag integerValue] makeIfNecessary:NO] settingCheckbox] ) {
            
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Value"] = @(state);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
            
            // ---------------------------------------------------------------------
            //  Add subkeys for selected state
            // ---------------------------------------------------------------------
            [self updateSubKeysForDict:cellDict valueString:state ? @"True" : @"False" row:row];
            [_tableViewSettings reloadData];
        }
    }
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
        
        NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
        cellDict[@"Value"] = date;
        [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        
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
        NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
        cellDict[@"Value"] = selectedTitle;
        [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        [self updateSubKeysForDict:cellDict valueString:selectedTitle row:row];
        [_tableViewSettings reloadData];
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
    
    // ---------------------------------------------------------------------
    //  Another verification this is a CellViewSettingsFile button
    // ---------------------------------------------------------------------
    if ( button == [(CellViewSettingsFile *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingButtonAdd] ) {
        
        NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
        
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
                cellDict[@"FilePath"] = [fileURL path];
                [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
                [_tableViewSettings reloadData];
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
        if ( [selectedSegment length] == 0 ) {
            NSLog(@"[ERROR] SegmentedControl: %@ selected segment is nil", segmentedControl);
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected segmented control
        // ---------------------------------------------------------------------
        [self updateSubKeysForDict:[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] valueString:selectedSegment row:row];
        [_tableViewSettings reloadData];
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
            NSArray *settings = menuDict[@"DomainKeys"];
            for ( NSDictionary *setting in settings ) {
                NSMutableDictionary *combinedSettingDict = [setting mutableCopy];
                combinedSettingDict[@"Enabled"] = @YES;
                [combinedSettings addObject:[combinedSettingDict copy]];
            }
            
            if ( [combinedSettings count] != 0 ) {
                [combinedSettings insertObject:@{ @"CellType" : @"Padding",
                                                  @"Enabled" : @YES } atIndex:0];
                [combinedSettings addObject:@{ @"CellType" : @"Padding",
                                               @"Enabled" : @YES }];
            }
        }
    }
    return [combinedSettings copy];
} // settingsForMenuItem

- (void)updateSubKeysForDict:(NSDictionary *)cellDict valueString:(NSString *)valueString row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Handle sub keys
    // ---------------------------------------------------------------------
    NSDictionary *valueKeys = cellDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] != 0 ) {
        
        // ---------------------------------------------------------------------
        //  Remove any previous sub keys
        // ---------------------------------------------------------------------
        if ( row < [_tableViewSettingsItemsEnabled count] ) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((row + 1), [_tableViewSettingsItemsEnabled count]-(row + 1))];
            __block NSArray *parentKeyArray;
            [_tableViewSettingsItemsEnabled enumerateObjectsAtIndexes:indexes options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                // ----------------------------------------------------------------------
                //  Check if parent key exist in value keys (if it's added by the caller)
                // ----------------------------------------------------------------------
                if ( valueKeys[obj[@"ParentKey"]] != nil ) {
                    
                    parentKeyArray = valueKeys[obj[@"ParentKey"]];
                    [_tableViewSettingsItemsEnabled removeObjectAtIndex:(row + 1)];
                } else {
                    
                    // ----------------------------------------------------------------------------------------
                    //  Check if parent key exist in parents value keys (if it's added by the caller's parent)
                    // ----------------------------------------------------------------------------------------
                    // FIXME - This implementation is flawed, only reaches second level of nesting, should remove all nesting not limited to level
                    for ( NSDictionary *parentKeyDict in parentKeyArray ) {
                        if ( parentKeyDict[@"ValueKeys"][obj[@"ParentKey"]] != nil ) {
                            [_tableViewSettingsItemsEnabled removeObjectAtIndex:(row + 1)];
                            return;
                        }
                    }
                    
                    *stop = YES;
                }
            }];
        }
        
        // ---------------------------------------------------------------------
        //  Check if any sub keys exist for selected value
        // ---------------------------------------------------------------------
        NSArray *valueKeyArray = [valueKeys[valueString] mutableCopy] ?: @[];
        for ( NSDictionary *valueDict in valueKeyArray ) {
            if ( [valueDict count] != 0 ) {
                row++;
                NSMutableDictionary *mutableValueDict = [valueDict mutableCopy];
                
                // ---------------------------------------------------------------------
                //  Add sub key to table view below setting
                // ---------------------------------------------------------------------
                mutableValueDict[@"ParentKey"] = valueString;
                [_tableViewSettingsItemsEnabled insertObject:[mutableValueDict copy] atIndex:row];
            }
        }
    }
}

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
        currentMenuDict[@"SavedSettings"] = [self->_tableViewSettingsItemsEnabled copy];
        [_tableViewMenuItemsEnabled replaceObjectAtIndex:self->_tableViewMenuSelectedRow withObject:[currentMenuDict copy]];
    }
    
    // ---------------------------------------------------------------------
    //  Set _tableViewMenuSelectedRow to new selection
    // ---------------------------------------------------------------------
    [self setTableViewMenuSelectedRow:[_tableViewMenu selectedRow]];
    
    [self->_tableViewSettings beginUpdates];
    [self->_tableViewSettingsItemsEnabled removeAllObjects];
    
    if ( 0 <= _tableViewMenuSelectedRow ) {
        NSArray *settingsArray = [self settingsForMenuItem:self->_tableViewMenuItemsEnabled[self->_tableViewMenuSelectedRow]];
        if ( [settingsArray count] != 0 ) {
            [self->_tableViewSettingsItemsEnabled addObjectsFromArray:[settingsArray copy]];
            [self->_viewErrorReadingSettings setHidden:YES];
        } else {
            [self->_viewErrorReadingSettings setHidden:NO];
        }
    }
    
    [self->_tableViewSettings reloadData];
    [self->_tableViewSettings endUpdates];
} // tableViewMenu

@end
