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
                return [self populateCellViewTextField:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
                CellViewSettingsTextFieldNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNoTitle" owner:self];
                return [self populateCellViewTextFieldNoTitle:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
                CellViewSettingsPopUp *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUp" owner:self];
                return [self populateCellViewPopUp:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"Checkbox"] ) {
                CellViewSettingsCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckbox" owner:self];
                return [self populateCellViewCheckbox:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {
                CellViewSettingsDatePickerNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsDatePickerNoTitle" owner:self];
                return [self populateCellViewDatePickerNoTitle:cellView settingDict:settingDict row:row];
            } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
                CellViewSettingsTextFieldDaysHoursNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldDaysHoursNoTitle" owner:self];
                return [self populateCellViewSettingsTextFieldDaysHoursNoTitle:cellView settingDict:settingDict row:row];
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnSettingsEnabled"] ) {
            if ( [settingDict[@"Hidden"] boolValue] ) {
                return nil;
            }
            
            if ( [cellType isEqualToString:@"Padding"] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
            } else {
                CellViewSettingsEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsEnabled" owner:self];
                return [self populateCellViewEnabled:cellView settingDict:settingDict row:row];
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
                return [self populateCellViewMenu:cellView menuDict:menuDict row:row];
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [self populateCellViewEnabled:cellView menuDict:menuDict row:row];
        }
    }
    return nil;
} // tableView:viewForTableColumn:row

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
                   [cellType isEqualToString:@"TextFieldNoTitle"] ) {
            return 62;
        }else if (
                  [cellType isEqualToString:@"TextField"] ||
                  [cellType isEqualToString:@"PopUpButton"] ) {
            return 81;
        } else if (
                   [cellType isEqualToString:@"Checkbox"] ) {
            return 52;
        } else if (
                   [cellType isEqualToString:@"DatePickerNoTitle"] ||
                   [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
            return 39;
        }
    } else if (
               [[tableView identifier] isEqualToString:@"TableViewMenu"] ) {
        return 44;
    }
    return 1;
} // tableView:heightOfRow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Populate Menu CellViews
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CellViewMenuEnabled *)populateCellViewEnabled:(CellViewMenuEnabled *)cellView menuDict:(NSDictionary *)menuDict row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setState:[menuDict[@"Enabled"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setHidden:[menuDict[@"Required"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView menuCheckbox] setAction:@selector(checkbox:)];
    [[cellView menuCheckbox] setTarget:self];
    [[cellView menuCheckbox] setTag:row];
    
    return cellView;
} // populateCellViewEnabled:menuDict:row

- (CellViewMenu *)populateCellViewMenu:(CellViewMenu *)cellView menuDict:(NSDictionary *)menuDict row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView menuTitle] setStringValue:menuDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView menuDescription] setStringValue:menuDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[NSBundle mainBundle] imageForResource:menuDict[@"Image"]];
    if ( icon ) {
        [[cellView menuIcon] setImage:icon];
    } else {
        NSURL *iconURL = [NSURL fileURLWithPath:menuDict[@"ImagePath"] ?: @""];
        if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
            NSImage *icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
            if ( icon ) {
                [[cellView menuIcon] setImage:icon];
            }
        }
    }
    
    return cellView;
} // populateCellViewMenu:menuDict:row

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Populate Settings CellViews
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CellViewSettingsEnabled *)populateCellViewEnabled:(CellViewSettingsEnabled *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setState:[settingDict[@"Enabled"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Required
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setHidden:[settingDict[@"Required"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingEnabled] setAction:@selector(checkbox:)];
    [[cellView settingEnabled] setTarget:self];
    [[cellView settingEnabled] setTag:row];
    
    return cellView;
} // populateCellViewEnabled:settingDict:row

- (CellViewSettingsTextField *)populateCellViewTextField:(CellViewSettingsTextField *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setStringValue:settingDict[@"Value"] ?: @""];
    [[cellView settingTextField] setTag:row];
    
    return cellView;
} // populateCellViewTextField:settingDict:row

- (CellViewSettingsTextFieldNoTitle *)populateCellViewTextFieldNoTitle:(CellViewSettingsTextFieldNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingTextField] setStringValue:settingDict[@"Value"] ?: @""];
    [[cellView settingTextField] setTag:row];
    
    return cellView;
} // populateCellViewTextField:settingDict:row

- (CellViewSettingsPopUp *)populateCellViewPopUp:(CellViewSettingsPopUp *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:settingDict[@"Title"] ?: @""];
    if ( enabled ) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] addItemsWithTitles:settingDict[@"AvailableValues"] ?: @[]];
    [[cellView settingPopUpButton] selectItemWithTitle:settingDict[@"Value"] ?: settingDict[@"DefaultValue"]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingPopUpButton] setAction:@selector(popUpButtonSelection:)];
    [[cellView settingPopUpButton] setTarget:self];
    [[cellView settingPopUpButton] setTag:row];
    
    return cellView;
} // populateCellViewPopUp:settingDict:row

- (CellViewSettingsCheckbox *)populateCellViewCheckbox:(CellViewSettingsCheckbox *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Title (Checkbox)
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setTitle:settingDict[@"Title"] ?: @""];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setState:[settingDict[@"Value"] boolValue]];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingCheckbox] setAction:@selector(checkbox:)];
    [[cellView settingCheckbox] setTarget:self];
    [[cellView settingCheckbox] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:settingDict[@"Description"] ?: @""];
    
    return cellView;
} // populateCellViewCheckbox:settingDict:row

- (CellViewSettingsDatePickerNoTitle *)populateCellViewDatePickerNoTitle:(CellViewSettingsDatePickerNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    //BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setDateValue:settingDict[@"Value"] ?: [NSDate date]];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Set minimum value selectable to tomorrow
    // ---------------------------------------------------------------------
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *dateTomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    [[cellView settingDatePicker] setMinDate:dateTomorrow];
    
    // ---------------------------------------------------------------------
    //  Enabled
    // ---------------------------------------------------------------------
    //[[cellView settingDatePicker] setEnabled:enabled];
    
    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:self];
    [[cellView settingDatePicker] setTag:row];
    
    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
    [[cellView settingDescription] setStringValue:[self dateIntervalFromNowToDate:datePickerDate] ?: @""];
    
    return cellView;
} // populateCellViewCheckbox:settingDict:row

- (CellViewSettingsTextFieldDaysHoursNoTitle *)populateCellViewSettingsTextFieldDaysHoursNoTitle:(CellViewSettingsTextFieldDaysHoursNoTitle *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row {
    
    BOOL enabled = [settingDict[@"Enabled"] boolValue];
    
    NSNumber *seconds = settingDict[@"Value"] ?: @0;
    
    NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier: @"en_US"]];
    NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour;
    
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:[seconds doubleValue]];
    
    NSDateComponents *components = [calendarUS components:unitFlags fromDate:startDate toDate:endDate options:0];
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    
    // ---------------------------------------------------------------------
    //  Days
    // ---------------------------------------------------------------------
    [[cellView settingDays] setStringValue:[@(days) stringValue] ?: @""];
    [[cellView settingDays] setEnabled:enabled];
    [[cellView settingDays] setTag:row];
    [[cellView settingDays] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalDays" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepperDays] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalDays" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    // ---------------------------------------------------------------------
    //  Hours
    // ---------------------------------------------------------------------
    [[cellView settingHours] setStringValue:[@(hours) stringValue] ?: @""];
    [[cellView settingHours] setEnabled:enabled];
    [[cellView settingHours] setTag:row];
    [[cellView settingHours] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalHours" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];
    [[cellView settingStepperHours] bind:@"value" toObject:self withKeyPath:@"stepperValueRemovalIntervalHours" options:@{ NSContinuouslyUpdatesValueBindingOption : @YES }];

    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)checkbox:(NSButton *)checkbox {
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        return;
    }
    
    if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewMenuEnabled class]] ) {
        if ( checkbox == [(CellViewMenuEnabled *)[_tableViewMenu viewAtColumn:[_tableViewMenu columnWithIdentifier:@"ColumnMenuEnabled"] row:[buttonTag integerValue] makeIfNecessary:NO] menuCheckbox] ) {
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewMenuItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Enabled"] = @(state);
            [_tableViewMenuItemsEnabled replaceObjectAtIndex:(NSUInteger)[buttonTag integerValue] withObject:[cellDict copy]];
        }
    } else if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsEnabled class]] ) {
        if ( checkbox == [(CellViewSettingsEnabled *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettingsEnabled"] row:[buttonTag integerValue] makeIfNecessary:NO] settingEnabled] ) {
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Enabled"] = @(state);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)[buttonTag integerValue] withObject:[cellDict copy]];
            [_tableViewSettings reloadData];
        }
    } else if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsCheckbox class]] ) {
        if ( checkbox == [(CellViewSettingsCheckbox *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:[buttonTag integerValue] makeIfNecessary:NO] settingCheckbox] ) {
            BOOL state = [checkbox state];
            NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:[buttonTag integerValue]] mutableCopy];
            cellDict[@"Value"] = @(state);
            [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)[buttonTag integerValue] withObject:[cellDict copy]];
            [_tableViewSettings reloadData];
        }
    }
} // checkbox

- (void)datePickerSelection:(NSDatePicker *)datePicker {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings date picker
    // ---------------------------------------------------------------------
    if ( [[[datePicker superview] class] isSubclassOfClass:[CellViewSettingsDatePickerNoTitle class]] ) {
        
        // ---------------------------------------------------------------------
        //  Get date picker's row in the table view
        // ---------------------------------------------------------------------
        NSNumber *datePickerTag = @([datePicker tag]);
        if ( datePickerTag != nil ) {
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
        }
    }
} // datePickerSelection

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

- (void)popUpButtonSelection:(NSPopUpButton *)popUpButton {
    
    // ---------------------------------------------------------------------
    //  Make sure it's a settings popup button
    // ---------------------------------------------------------------------
    if ( [[[popUpButton superview] class] isSubclassOfClass:[CellViewSettingsPopUp class]] ) {
        
        // ---------------------------------------------------------------------
        //  Get popup button's row in the table view
        // ---------------------------------------------------------------------
        NSNumber *popUpButtonTag = @([popUpButton tag]);
        if ( popUpButtonTag != nil ) {
            NSInteger row = [popUpButtonTag integerValue];
            
            // ---------------------------------------------------------------------
            //  Another verification this is a CellViewSettingsPopUp popup button
            // ---------------------------------------------------------------------
            if ( popUpButton == [(CellViewSettingsPopUp *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettings"] row:row makeIfNecessary:NO] settingPopUpButton] ) {
                
                // ---------------------------------------------------------------------
                //  Save selection
                // ---------------------------------------------------------------------
                NSString *selectedTitle = [popUpButton titleOfSelectedItem];
                NSMutableDictionary *cellDict = [[_tableViewSettingsItemsEnabled objectAtIndex:(NSUInteger)row] mutableCopy];
                cellDict[@"Value"] = selectedTitle;
                [_tableViewSettingsItemsEnabled replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
                
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
                        [_tableViewSettingsItemsEnabled enumerateObjectsAtIndexes:indexes options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ( valueKeys[obj[@"ParentKey"]] != nil ) {
                                [_tableViewSettingsItemsEnabled removeObjectAtIndex:idx];
                            } else {
                                *stop = YES;
                            }
                        }];
                    }
                    
                    // ---------------------------------------------------------------------
                    //  Check if any sub keys exist for selected value
                    // ---------------------------------------------------------------------
                    NSArray *valueKeyArray = [valueKeys[selectedTitle] mutableCopy] ?: @[];
                    for ( NSDictionary *valueDict in valueKeyArray ) {
                        if ( [valueDict count] != 0 ) {
                            row++;
                            NSMutableDictionary *mutableValueDict = [valueDict mutableCopy];
                            
                            // ---------------------------------------------------------------------
                            //  Add sub key to table view below setting
                            // ---------------------------------------------------------------------
                            mutableValueDict[@"ParentKey"] = selectedTitle;
                            [_tableViewSettingsItemsEnabled insertObject:[mutableValueDict copy] atIndex:row];
                        }
                    }
                }
                
                [_tableViewSettings reloadData];
            }
        }
    }
} // popUpButtonSelection

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
        }
    }
    return [combinedSettings copy];
} // settingsForMenuItem

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
            [self->_tableViewSettingsItemsEnabled insertObject:@{ @"CellType" : @"Padding" } atIndex:0];
            [self->_tableViewSettingsItemsEnabled addObject:@{ @"CellType" : @"Padding" }];
            [self->_viewErrorReadingSettings setHidden:YES];
        } else {
            [self->_viewErrorReadingSettings setHidden:NO];
        }
    }
    
    [self->_tableViewSettings reloadData];
    [self->_tableViewSettings endUpdates];
} // tableViewMenu

@end
