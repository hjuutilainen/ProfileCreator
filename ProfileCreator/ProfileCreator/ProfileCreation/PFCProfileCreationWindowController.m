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
#import "PFCController.h"
#import "PFCPayloadVerification.h"

@interface PFCProfileCreationWindowController ()

@end

@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender {
    self = [super initWithWindowNibName:@"PFCProfileCreationWindowController"];
    if (self != nil) {
        
        _arrayProfilePayloads = [[NSMutableArray alloc] init];
        _arrayPayloadLibrary = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryApple = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryUserPreferences = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryCustom = [[NSMutableArray alloc] init];
        _arraySettings = [[NSMutableArray alloc] init];
        
        
        
        
        _tableViewSettingsSettings = [profileDict[@"Config"][@"Settings"] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        _tableViewSettingsCurrentSettings = [[NSMutableDictionary alloc] init];
        
        _parentObject = sender;
        
        _advancedSettings = NO;
        _columnMenuEnabledHidden = YES;
        _columnSettingsEnabledHidden = YES;
        
        _profileDict = profileDict ?: @{};
        
        [[self window] setDelegate:self];
        _windowShouldClose = NO;
    }
    return self;
} // init

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"advancedSettings" context:nil];
    [self removeObserver:self forKeyPath:@"profileName" context:nil];
} // dealloc

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Setup Main Window
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    [self insertSubview:_viewProfilePayloadsSuperview inSuperview:_viewProfilePayloadsSplitView cTop:-1 cBottom:0 cRight:-1 cLeft:-1];
    [self insertSubview:_viewPayloadLibrarySuperview inSuperview:_viewPayloadLibrarySplitView cTop:-1 cBottom:0 cRight:-1 cLeft:-1];
    [self insertSubview:_viewSettingsSuperView inSuperview:_viewSettingsSplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    
    // Setup KVO observers
    [self addObserver:self forKeyPath:@"profileName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"advancedSettings" options:NSKeyValueObservingOptionNew context:nil];
    
    // Setup TableViews
    [self initializeTableViewMenu];
    
    [self setProfileName:_profileDict[@"Config"][@"Name"] ?: @"Profile"];
} // windowDidLoad

- (void)initializeTableViewMenu {
    [self updateTableColumnsSettings];
    
    NSMutableArray *enabledPayloadDomains = [NSMutableArray array];
    for ( NSString *payloadDomain in [_tableViewSettingsSettings allKeys] ) {
        NSDictionary *payloadDict = _tableViewSettingsSettings[payloadDomain];
        if ( [payloadDict[@"Selected"] boolValue] ) {
            [enabledPayloadDomains addObject:payloadDomain];
        }
    }
    
    [self setupManifestLibraryApple:[enabledPayloadDomains copy]];
    [self setupManifestLibraryUserLibrary:[enabledPayloadDomains copy]];
    
    [self tableViewProfilePayloads:nil];
    [self setTableViewProfilePayloadsSelectedRow:-1];
    [_tableViewProfilePayloads setTableViewMenuDelegate:self];
    [_tableViewProfilePayloads reloadData];
    
    [self tableViewPayloadLibrary:nil];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [_tableViewPayloadLibrary setTableViewMenuDelegate:self];
    [_tableViewPayloadLibrary reloadData];
    
} // initializeMenu

- (void)setupMenuProfilesCustom {
    if ( ! _customMenu ) {
        NSLog(@"[ERROR] No custom menu available!");
        return;
    }
    
    [_arrayProfilePayloads addObjectsFromArray:_customMenu];
} // setupMenuProfilesCustom

- (void)setupManifestLibraryApple:(NSArray *)enabledPayloadDomains {
    
    NSError *error = nil;
    
    [_arrayProfilePayloads removeAllObjects];
    [_arrayPayloadLibrary removeAllObjects];
    
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
                NSString *manifestDomain = manifestDict[@"Domain"] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain] ||
                    [manifestDomain isEqualToString:@"com.apple.general"]
                    ) {
                    [_arrayProfilePayloads addObject:manifestDict];
                } else {
                    [_arrayPayloadLibrary addObject:manifestDict];
                }
            } else {
                NSLog(@"[ERROR] Manifest %@ was empty!", [manifestURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort menu arrays
        // ---------------------------------------------------------------------
        [_arrayProfilePayloads sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        [_arrayPayloadLibrary sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        
        // ---------------------------------------------------------------------
        //  Find index of menu item com.apple.general
        // ---------------------------------------------------------------------
        NSUInteger idx = [_arrayProfilePayloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"Domain"] isEqualToString:@"com.apple.general"];
        }];
        
        // ---------------------------------------------------------------------
        //  Move menu item com.apple.general to the top of the menu array
        // ---------------------------------------------------------------------
        if (idx != NSNotFound) {
            NSDictionary *generalSettingsDict = [_arrayProfilePayloads objectAtIndex:idx];
            [_arrayProfilePayloads removeObjectAtIndex:idx];
            [_arrayProfilePayloads insertObject:generalSettingsDict atIndex:0];
        } else {
            NSLog(@"[ERROR] No menu item with domain com.apple.general was found!");
        }
    } else {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
} // setupMenu

- (void)setupManifestLibraryUserLibrary:(NSArray *)enabledPayloadDomains {
    
    NSError *error = nil;
    
    NSURL *userLibraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
                                                                   inDomain:NSUserDomainMask
                                                          appropriateForURL:nil
                                                                     create:NO
                                                                      error:&error];
    if ( userLibraryURL == nil ) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        return;
    }
    
    NSURL *userLibraryPreferencesURL = [userLibraryURL URLByAppendingPathComponent:@"Preferences"];
    if ( ! [userLibraryPreferencesURL checkResourceIsReachableAndReturnError:&error] ) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
        return;
    } else {
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:userLibraryPreferencesURL
                                                             includingPropertiesForKeys:@[]
                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                  error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension='plist'"];
        for ( NSURL *plistURL in [dirContents filteredArrayUsingPredicate:predicate] ) {
            NSDictionary *manifestDict = [PFCManifestCreationParser manifestForPlistAtURL:plistURL];
            if ( [manifestDict count] != 0 ) {
                NSString *manifestDomain = manifestDict[@"Domain"] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain]
                    ) {
                    [_arrayProfilePayloads addObject:manifestDict];
                } else {
                    [_arrayPayloadLibraryUserPreferences addObject:manifestDict];
                }
            } else {
                NSLog(@"[ERROR] Plist: %@ was empty!", [plistURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort menu arrays
        // ---------------------------------------------------------------------
        [_arrayProfilePayloads sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        [_arrayPayloadLibraryUserPreferences sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        
        // ---------------------------------------------------------------------
        //  Find index of menu item com.apple.general
        // ---------------------------------------------------------------------
        NSUInteger idx = [_arrayProfilePayloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"Domain"] isEqualToString:@"com.apple.general"];
        }];
        
        // ---------------------------------------------------------------------
        //  Move menu item com.apple.general to the top of the menu array
        // ---------------------------------------------------------------------
        if (idx != NSNotFound) {
            NSDictionary *generalSettingsDict = [_arrayProfilePayloads objectAtIndex:idx];
            [_arrayProfilePayloads removeObjectAtIndex:idx];
            [_arrayProfilePayloads insertObject:generalSettingsDict atIndex:0];
        } else {
            NSLog(@"[ERROR] No menu item with domain com.apple.general was found!");
        }
    }
}


- (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview cTop:(int)cTop cBottom:(int)cBottom cRight:(int)cRight cLeft:(int)cLeft {
    [superview addSubview:subview positioned:NSWindowAbove relativeTo:nil];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    NSArray *constraintsArray;
    NSString *constraintLeft = [NSString stringWithFormat:@"-(%d)-", cLeft ?: 0];
    NSString *constraintRight = [NSString stringWithFormat:@"-(%d)-", cRight ?: 0];
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|%@[subview]%@|", constraintLeft, constraintRight]
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    
    NSString *constraintTop = [NSString stringWithFormat:@"-(%d)-", cTop ?: 0];
    NSString *constraintBottom = [NSString stringWithFormat:@"-(%d)-", cBottom ?: 0];
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@[subview]%@|", constraintTop, constraintBottom]
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    [superview setHidden:NO];
    [subview setHidden:NO];
}

- (void)updateTableColumnsSettings {
    for ( NSTableColumn *column in [_tableViewSettings tableColumns] ) {
        if ( [[column identifier] isEqualToString:@"ColumnSettingsEnabled"] ) {
            [column setHidden:!_advancedSettings];
        } else if ( [[column identifier] isEqualToString:@"ColumnMinOS"] ) {
            [column setHidden:YES];
        }
    }
} // updateTableColumnsSettings

- (void)updateMenuErrorCount {
    if ( [_selectedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        if ( 0 <= _tableViewProfilePayloadsSelectedRow && _tableViewProfilePayloadsSelectedRow <= [_arrayProfilePayloads count] ) {
            NSInteger columnIndex = [_tableViewProfilePayloads columnWithIdentifier:@"ColumnMenu"];
            [_tableViewProfilePayloads reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_tableViewProfilePayloadsSelectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#pragma unused(object, change, context)
    if ( [keyPath isEqualToString:@"advancedSettings"] ) {
        [self updateTableColumnsSettings];
    } else if ( [keyPath isEqualToString:@"profileName"] ) {
        NSString *newProfileName = change[@"new"];
        if ( [newProfileName length] != 0 ) {
            [[self window] setTitle:newProfileName];
        }
    }
} // observeValueForKeyPath

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:@"TableViewMenuEnabled"] ) {
        return (NSInteger)[_arrayProfilePayloads count];
    } else if ( [[tableView identifier] isEqualToString:@"TableViewMenuDisabled"] ) {
        return (NSInteger)[_arrayPayloadLibrary count];
    } else if ( [[tableView identifier] isEqualToString:@"TableViewSettings"] ) {
        return (NSInteger)[_arraySettings count];
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
        if ( [_arraySettings count] < row || [_arraySettings count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _arraySettings[(NSUInteger)row];
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
                    //  TextFieldHostPort
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
                    CellViewSettingsTextFieldHostPort *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPort" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldHostPort:cellView manifestDict:manifestDict settingDict:cellSettingsDict row:row sender:self];
                    
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
    } else if ( [tableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the menu array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayProfilePayloads count] < row || [_arrayProfilePayloads count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *menuDict = _arrayProfilePayloads[(NSUInteger)row];
        
        if ( [tableColumnIdentifier isEqualToString:@"ColumnMenu"] ) {
            NSString *cellType = menuDict[@"CellType"];
            
            NSDictionary *manifestSettings;
            if ( _tableViewProfilePayloadsSelectedRow == -1 && _tableViewPayloadLibrarySelectedRow == -1 ) {
                NSDictionary *domain = menuDict[@"Domain"];
                manifestSettings = _tableViewSettingsSettings[domain];
            } else {
                manifestSettings = _tableViewSettingsCurrentSettings;
            }
            
            NSDictionary *errorDict = [[PFCPayloadVerification sharedInstance] verifyManifest:menuDict[@"PayloadKeys"] settingsDict:manifestSettings];
            NSNumber *errorCount;
            if ( [errorDict count] != 0 ) {
                errorCount = @([errorDict[@"Error"] count]);
            }
            
            if ( [cellType isEqualToString:@"Menu"] ) {
                CellViewMenu *cellView = [tableView makeViewWithIdentifier:@"CellViewMenu" owner:self];
                [cellView setIdentifier:nil];
                return [cellView populateCellViewMenu:cellView menuDict:menuDict errorCount:errorCount row:row];
            } else {
                NSLog(@"[ERROR] Unknown CellType: %@", cellType);
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView menuDict:menuDict row:row sender:self];
        }
    } else if ( [tableViewIdentifier isEqualToString:@"TableViewMenuDisabled"] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the menu array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayPayloadLibrary count] < row || [_arrayPayloadLibrary count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *menuDict = _arrayPayloadLibrary[(NSUInteger)row];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnMenu"] ) {
            NSString *cellType = menuDict[@"CellType"];
            
            if ( [cellType isEqualToString:@"Menu"] ) {
                CellViewMenu *cellView = [_tableViewProfilePayloads makeViewWithIdentifier:@"CellViewMenu" owner:self];
                [cellView setIdentifier:nil];
                return [cellView populateCellViewMenu:cellView menuDict:menuDict errorCount:nil row:row];
            } else {
                NSLog(@"[ERROR] Unknown CellType: %@", cellType);
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [_tableViewProfilePayloads makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
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
        if ( [_arraySettings count] <= 0 ) {
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Get current cell's manifest dict identifier
        // ---------------------------------------------------------------------
        NSDictionary *cellDict = _arraySettings[(NSUInteger)row];
        NSString *cellType = cellDict[@"CellType"];
        if ( ! [cellType isEqualToString:@"Padding"] ) {
            NSString *identifier = cellDict[@"Identifier"];
            if ( [identifier length] == 0 ) {
                //NSLog(@"No Identifier for cell dict: %@", cellDict);
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
        if ( [_arraySettings count] < row || [_arraySettings count] == 0 ) {
            return 1;
        }
        
        NSDictionary *profileDict = _arraySettings[(NSUInteger)row];
        
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
    } else if (
               [[tableView identifier] isEqualToString:@"TableViewMenuEnabled"] ||
               [[tableView identifier] isEqualToString:@"TableViewMenuDisabled"]
               ) {
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
    
    if ( [[sender object] isEqualTo:_textFieldSheetProfileName] ) {
        NSDictionary *userInfo = [sender userInfo];
        NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
        if ( [inputText isEqualToString:@"Untitled..."] || [inputText length] == 0 ) {
            [_buttonSaveSheetProfileName setEnabled:NO];
        } else {
            [_buttonSaveSheetProfileName setEnabled:YES];
        }
        return;
    }
    
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
    NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:row] mutableCopy];
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
        
        if ( [[textField superview] respondsToSelector:@selector(showRequired:)] ) {
            BOOL showRequired = NO;
            BOOL required = [cellDict[@"Required"] boolValue];
            BOOL requiredHost = [cellDict[@"RequiredHost"] boolValue];
            BOOL requiredPort = [cellDict[@"RequiredPort"] boolValue];
            
            if ( required || requiredHost || requiredPort ) {
                if ( required && ( [settingsDict[@"ValueHost"] length] == 0 || [settingsDict[@"ValuePort"] length] == 0 ) ) {
                    showRequired = YES;
                }
                
                if ( requiredHost && [settingsDict[@"ValueHost"] length] == 0 ) {
                    showRequired = YES;
                }
                
                if ( requiredPort && [settingsDict[@"ValuePort"] length] == 0 ) {
                    showRequired = YES;
                }
                
                [(CellViewSettingsTextFieldHostPort *)[textField superview] showRequired:showRequired];
            }
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
            if ( [[textField superview] respondsToSelector:@selector(showRequired:)] ) {
                if ( [cellDict[@"Required"] boolValue] && [inputText length] == 0 ) {
                    [(CellViewSettingsTextField *)[textField superview] showRequired:YES];
                } else if ( [cellDict[@"Required"] boolValue] ) {
                    [(CellViewSettingsTextField *)[textField superview] showRequired:NO];
                }
            }
        } else {
            NSLog(@"[ERROR] Unknown text field!");
            return;
        }
    }
    
    _tableViewSettingsCurrentSettings[identifier] = [settingsDict copy];
    [self updateMenuErrorCount];
} // controlTextDidChange

- (void)checkboxMenuEnabled:(NSButton *)checkbox {
    
    // ---------------------------------------------------------------------
    //  Get checkbox's row in the table view
    // ---------------------------------------------------------------------
    NSNumber *buttonTag = @([checkbox tag]);
    if ( buttonTag == nil ) {
        NSLog(@"[ERROR] Checkbox: %@ tag is nil", checkbox);
        return;
    }
    NSInteger row = [buttonTag integerValue];
    
    if ( [[[checkbox superview] class] isSubclassOfClass:[CellViewMenuEnabled class]] ) {
        
        // ---------------------------------------------------------------------
        //  Check if checbox is in table view menu ENABLED
        // ---------------------------------------------------------------------
        if ( ( row < [_arrayProfilePayloads count] ) && checkbox == [(CellViewMenuEnabled *)[_tableViewProfilePayloads viewAtColumn:[_tableViewProfilePayloads columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox] ) {
            
            // ---------------------------------------------------------------------
            //  Store the cell dict for move
            // ---------------------------------------------------------------------
            NSDictionary *cellDict = [_arrayProfilePayloads objectAtIndex:row];
            NSString *payloadDomain = cellDict[@"Domain"];
            NSInteger payloadLibrary = [_tableViewSettingsSettings[payloadDomain][@"PayloadLibrary"] integerValue];
            
            // ---------------------------------------------------------------------
            //  Remove the cell dict from table view menu ENABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewMenuEnabledSelectedRow = [_tableViewProfilePayloads selectedRow];
            [_tableViewProfilePayloads beginUpdates];
            [_arrayProfilePayloads removeObjectAtIndex:(NSUInteger)row];
            [_tableViewProfilePayloads reloadData];
            [_tableViewProfilePayloads endUpdates];
            
            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if ( 0 <= tableViewMenuEnabledSelectedRow && tableViewMenuEnabledSelectedRow != row ) {
                NSInteger selectedRow = ( row < tableViewMenuEnabledSelectedRow ) ? ( tableViewMenuEnabledSelectedRow - 1 ) : tableViewMenuEnabledSelectedRow;
                [_tableViewProfilePayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
                [self setTableViewProfilePayloadsSelectedRow:selectedRow];
            }
            
            // ---------------------------------------------------------------------
            //  Add the cell dict to table view menu DISABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewPayloadLibrarySelectedRow = [_tableViewPayloadLibrary selectedRow];
            
            if ( payloadLibrary == _segmentedControlLibrarySelectedSegment ) {
                [_tableViewPayloadLibrary beginUpdates];
                [_arrayPayloadLibrary addObject:cellDict];
                [_arrayPayloadLibrary sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [_tableViewPayloadLibrary reloadData];
                [_tableViewPayloadLibrary endUpdates];
            } else {
                NSMutableArray *arrayPayloadLibrarySource = [self arrayForPayloadLibrary:payloadLibrary];
                [arrayPayloadLibrarySource addObject:cellDict];
                [arrayPayloadLibrarySource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [self savePayloadLibraryArray:arrayPayloadLibrarySource payloadLibrary:payloadLibrary];
            }
            
            // -----------------------------------------------------------------------------
            //  If item in table view DISABLED was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if ( 0 <= tableViewPayloadLibrarySelectedRow && tableViewMenuEnabledSelectedRow != row ) {
                [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:tableViewPayloadLibrarySelectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadLibrarySelectedRow:tableViewPayloadLibrarySelectedRow];
            }
            
            // -----------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view DISABLED
            // -----------------------------------------------------------------------------
            if ( tableViewMenuEnabledSelectedRow == row && payloadLibrary == _segmentedControlLibrarySelectedSegment ) {
                
                // ---------------------------------------------------------------------
                //  Deselect items in table view ENABLED
                // ---------------------------------------------------------------------
                [_tableViewProfilePayloads deselectAll:self];
                [self setTableViewProfilePayloadsSelectedRow:-1];
                
                // ---------------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // ---------------------------------------------------------------------
                NSUInteger row = [_arrayPayloadLibrary indexOfObject:cellDict];
                if ( row != NSNotFound ) {
                    [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    [[self window] makeFirstResponder:_tableViewPayloadLibrary];
                    [self setTableViewPayloadLibrarySelectedRow:row];
                    [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
                }
                
                [_tableViewSettingsCurrentSettings removeObjectForKey:@"Selected"];
                [_tableViewSettingsCurrentSettings removeObjectForKey:@"PayloadLibrary"];
            } else {
                NSMutableDictionary *settingsDict = [_tableViewSettingsSettings[payloadDomain] mutableCopy] ?: [NSMutableDictionary dictionary];
                [settingsDict removeObjectForKey:@"Selected"];
                [settingsDict removeObjectForKey:@"PayloadLibrary"];
                if ( [settingsDict count] == 0 ) {
                    [_tableViewSettingsSettings removeObjectForKey:payloadDomain];
                } else {
                    _tableViewSettingsSettings[payloadDomain] = [settingsDict copy];
                }
            }
            
            // ---------------------------------------------------------------------
            //  Check if checkbox is in table view menu DISABLED
            // ---------------------------------------------------------------------
        } else if ( ( row < [_arrayPayloadLibrary count] ) && checkbox == [(CellViewMenuEnabled *)[_tableViewPayloadLibrary viewAtColumn:[_tableViewPayloadLibrary columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox] ) {
            
            // ---------------------------------------------------------------------
            //  Store the cell dict for move
            // ---------------------------------------------------------------------
            NSDictionary *cellDict = [_arrayPayloadLibrary objectAtIndex:row];
            NSString *payloadDomain = cellDict[@"Domain"];
            
            // ---------------------------------------------------------------------
            //  Remove the cell dict from table view menu DISABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewMenuDisabledSelectedRow = [_tableViewPayloadLibrary selectedRow];
            [_tableViewPayloadLibrary beginUpdates];
            [_arrayPayloadLibrary removeObjectAtIndex:(NSUInteger)row];
            [_tableViewPayloadLibrary reloadData];
            [_tableViewPayloadLibrary endUpdates];
            
            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if ( 0 <= tableViewMenuDisabledSelectedRow && tableViewMenuDisabledSelectedRow != row ) {
                NSInteger selectedRow = ( row < tableViewMenuDisabledSelectedRow ) ? ( tableViewMenuDisabledSelectedRow - 1 ) : tableViewMenuDisabledSelectedRow;
                [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadLibrarySelectedRow:selectedRow];
            }
            
            // ---------------------------------------------------------------------
            //  Add the cell dict to table view menu ENABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewMenuEnabledSelectedRow = [_tableViewProfilePayloads selectedRow];
            [_tableViewProfilePayloads beginUpdates];
            [_arrayProfilePayloads addObject:cellDict];
            [_arrayProfilePayloads sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
            [_tableViewProfilePayloads reloadData];
            [_tableViewProfilePayloads endUpdates];
            
            // -----------------------------------------------------------------------------
            //  If item in table view ENABLED was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if ( 0 <= tableViewMenuEnabledSelectedRow && tableViewMenuDisabledSelectedRow != row ) {
                [_tableViewProfilePayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:tableViewMenuEnabledSelectedRow] byExtendingSelection:NO];
                [self setTableViewProfilePayloadsSelectedRow:tableViewMenuEnabledSelectedRow];
            }
            
            // ---------------------------------------------------------------------
            //  Find index of menu item com.apple.general
            // ---------------------------------------------------------------------
            NSUInteger idx = [_arrayProfilePayloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                return [[item objectForKey:@"Domain"] isEqualToString:@"com.apple.general"];
            }];
            
            // ---------------------------------------------------------------------
            //  Move menu item com.apple.general to the top of the menu array
            // ---------------------------------------------------------------------
            if ( idx != NSNotFound ) {
                NSDictionary *generalSettingsDict = [_arrayProfilePayloads objectAtIndex:idx];
                [_arrayProfilePayloads removeObjectAtIndex:idx];
                [_arrayProfilePayloads insertObject:generalSettingsDict atIndex:0];
            } else {
                NSLog(@"[ERROR] No menu item with domain com.apple.general was found!");
            }
            
            // -----------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view ENABLED
            // -----------------------------------------------------------------------------
            if ( tableViewMenuDisabledSelectedRow == row ) {
                
                // ---------------------------------------------------------------------
                //  Deselect items in table view DISABLED
                // ---------------------------------------------------------------------
                [_tableViewPayloadLibrary deselectAll:self];
                [self setTableViewPayloadLibrarySelectedRow:-1];
                
                // ---------------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // ---------------------------------------------------------------------
                NSUInteger row = [_arrayProfilePayloads indexOfObject:cellDict];
                if ( row != NSNotFound ) {
                    [_tableViewProfilePayloads selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    [[self window] makeFirstResponder:_tableViewProfilePayloads];
                    [self setTableViewProfilePayloadsSelectedRow:row];
                    [self setSelectedPayloadTableViewIdentifier:[_tableViewProfilePayloads identifier]];
                }
                
                _tableViewSettingsCurrentSettings[@"Selected"] = @YES;
            } else {
                NSMutableDictionary *settingsDict = [_tableViewSettingsSettings[payloadDomain] mutableCopy] ?: [NSMutableDictionary dictionary];
                settingsDict[@"Selected"] = @YES;
                settingsDict[@"PayloadLibrary"] = @(_segmentedControlLibrarySelectedSegment);
                _tableViewSettingsSettings[payloadDomain] = [settingsDict copy];
            }
        }
    } else {
        NSLog(@"[ERROR] Checkbox superview class is not CellViewMenuEnabled: %@", [[checkbox superview] class]);
    }
} // checkboxMenuEnabled



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
    NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:row] mutableCopy];
    NSString *identifier = cellDict[@"Identifier"];
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_tableViewSettingsCurrentSettings[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    if (
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
    if ( [self updateSubKeysForDict:cellDict valueString:state ? @"True" : @"False" row:row] ) {
        [_tableViewSettings beginUpdates];
        [_tableViewSettings reloadData];
        [_tableViewSettings endUpdates];
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
    
    NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
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
    
    NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
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
        if ( [self updateSubKeysForDict:cellDict valueString:selectedTitle row:row] ) {
            [_tableViewSettings beginUpdates];
            [_tableViewSettings reloadData];
            [_tableViewSettings endUpdates];
        }
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
    
    NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
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
            NSMutableDictionary *cellDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
            cellDict[@"Value"] = @([segmentedControl selectedSegment]);
            [_arraySettings replaceObjectAtIndex:(NSUInteger)row withObject:[cellDict copy]];
        } else {
            NSLog(@"[ERROR] SegmentedControl: %@ selected segment is nil", segmentedControl);
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected segmented control
        // ---------------------------------------------------------------------
        if ( [self updateSubKeysForDict:[_arraySettings objectAtIndex:(NSUInteger)row] valueString:selectedSegment row:row] ) {
            [_tableViewSettings beginUpdates];
            [_tableViewSettings reloadData];
            [_tableViewSettings endUpdates];
        }
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
        if ( row < [_arraySettings count] ) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((row + 1), [_arraySettings count]-(row + 1))];
            [[_arraySettings copy] enumerateObjectsAtIndexes:indexes options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                        [_arraySettings removeObjectAtIndex:(row + 1)];
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
                                //NSLog(@"[DEBUG] Removing row: %ld", (row + 1));
                                //NSLog(@"[DEBUG] Removing dict: %@", [_tableViewSettingsItemsEnabled objectAtIndex:(row + 1)]);
                                [_arraySettings removeObjectAtIndex:(row + 1)];
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
                [_arraySettings insertObject:[mutableValueDict copy] atIndex:row];
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

- (void)saveCurrentSettings {
    if ( [_selectedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        
        // ---------------------------------------------------------------------
        //  Save current settings in menu dict
        // ---------------------------------------------------------------------
        if ( 0 <= _tableViewProfilePayloadsSelectedRow ) {
            NSMutableDictionary *currentMenuDict = [[_arrayProfilePayloads objectAtIndex:_tableViewProfilePayloadsSelectedRow] mutableCopy];
            if ( [_tableViewSettingsCurrentSettings count] != 0 ) {
                NSString *menuDomain = currentMenuDict[@"Domain"];
                _tableViewSettingsSettings[menuDomain] = [_tableViewSettingsCurrentSettings copy];
            }
            currentMenuDict[@"SavedSettings"] = [_arraySettings copy];
            [_arrayProfilePayloads replaceObjectAtIndex:_tableViewProfilePayloadsSelectedRow withObject:[currentMenuDict copy]];
        }
        
    } else if ( [_selectedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuDisabled"] ) {
        
        // ---------------------------------------------------------------------
        //  Save current settings in menu dict
        // ---------------------------------------------------------------------
        if ( 0 <= _tableViewPayloadLibrarySelectedRow ) {
            NSMutableDictionary *currentMenuDict = [[_arrayPayloadLibrary objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
            if ( [_tableViewSettingsCurrentSettings count] != 0 ) {
                NSString *menuDomain = currentMenuDict[@"Domain"];
                _tableViewSettingsSettings[menuDomain] = [_tableViewSettingsCurrentSettings copy];
            }
            currentMenuDict[@"SavedSettings"] = [_arraySettings copy];
            [_arrayPayloadLibrary replaceObjectAtIndex:_tableViewPayloadLibrarySelectedRow withObject:[currentMenuDict copy]];
        }
    } else {
        //NSLog(@"No settings selected!");
    }
}

- (IBAction)buttonCancel:(id)sender {
    [[self window] performClose:self];
}

- (BOOL)windowShouldClose:(id)sender {
    
    if ( _windowShouldClose ) {
        [self setWindowShouldClose:NO];
        if ( [_parentObject respondsToSelector:@selector(removeControllerForProfileDictWithName:)] ) {
            [_parentObject removeControllerForProfileDictWithName:_profileDict[@"Config"][@"Name"]];
        }
        return YES;
    }
    
    if ( [self settingsSaved] ) {
        return YES;
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Save & Close"];
        [alert addButtonWithTitle:@"Close"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Unsaved Settings"];
        [alert setInformativeText:@"If you close this window, all unsaved settings will be lost. Are you sure you want to close the window?"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[self window] completionHandler:^(NSInteger returnCode) {
            
            // Save & Close
            if ( returnCode == NSAlertFirstButtonReturn ) {
                [self setWindowShouldClose:YES];
                [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
                //[[self window] close];
                
                // Close
            } else if ( returnCode == NSAlertSecondButtonReturn ) {
                [self setWindowShouldClose:YES];
                [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
                //[[self window] close];
                
                // Cancel
            } else if ( returnCode == NSAlertThirdButtonReturn ) {
                [self setWindowShouldClose:NO];
            }
        }];
        
        return NO;
    }
}

- (void)closeWindow {
    [[self window] performClose:self];
}

- (BOOL)settingsSaved {
    
    NSString *profilePath = _profileDict[@"Path"];
    if ( [profilePath length] == 0 ) {
        return NO;
    }
    
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    
    if ( ! [profileURL checkResourceIsReachableAndReturnError:nil] ) {
        return NO;
    }
    
    NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
    if ( [profileDict count] == 0 ) {
        return NO;
    } else {
        return [profileDict[@"Settings"] isEqualToDictionary:_tableViewSettingsSettings];
    }
}

- (IBAction)buttonSave:(id)sender {
    [_buttonSaveSheetProfileName setEnabled:NO];
    if ( [_profileDict[@"Config"][@"Name"] isEqualToString:@"Untitled..."] ) {
        [_textFieldSheetProfileName setStringValue:@"Untitled..."];
        [[NSApp mainWindow] beginSheet:_sheetProfileName completionHandler:^(NSModalResponse __unused returnCode) {
            
        }];
    } else {
        [self saveProfile];
    }
}

- (void)saveProfile {
    
    // Save current settings
    [self saveCurrentSettings];
    
    NSError *error = nil;
    NSURL *savedProfilesFolderURL = [PFCController profileCreatorFolder:kPFCFolderSavedProfiles];
    if ( ! [savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        if ( ! [[NSFileManager defaultManager] createDirectoryAtURL:savedProfilesFolderURL withIntermediateDirectories:YES attributes:nil error:&error] ) {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
    
    NSString *profilePath = _profileDict[@"Path"];
    if ( [profilePath length] == 0 ) {
        profilePath = [PFCController newProfilePath];
    }
    
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    NSMutableDictionary *profileDict = [_profileDict mutableCopy];
    NSMutableDictionary *configurationDict = [_profileDict[@"Config"] mutableCopy];
    
    NSMutableDictionary *settings = [_tableViewSettingsSettings mutableCopy];
    for ( NSString *domain in [settings allKeys] ) {
        if ( [settings[domain][@"UUID"] length] == 0 ) {
            NSMutableDictionary *domainDict = [settings[domain] mutableCopy];
            domainDict[@"UUID"] = [[NSUUID UUID] UUIDString];
            settings[domain] = [domainDict copy];
        }
    }
    _tableViewSettingsSettings = [settings mutableCopy];
    
    configurationDict[@"Settings"] = [settings copy];
    if ( [configurationDict writeToURL:profileURL atomically:YES] ) {
        profileDict[@"Config"] = [configurationDict copy];
        [self setProfileDict:[profileDict copy]];
        NSString *newProfileName = _profileDict[@"Config"][@"Name"];
        if ( [newProfileName length] != 0 ) {
            [[self window] setTitle:newProfileName];
        }
    } else {
        NSLog(@"Save failed!");
    }
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

- (IBAction)buttonCancelSheetProfileName:(id)sender {
    [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    [_sheetProfileName orderOut:self];
}

- (IBAction)buttonSaveSheetProfileName:(id)sender {
    if ( [_parentObject respondsToSelector:@selector(removeControllerForProfileDictWithName:)] ) {
        [_parentObject renameProfileWithName:@"Untitled..." newName:[_textFieldSheetProfileName stringValue]];
        
        NSMutableDictionary *profileDict = [_profileDict mutableCopy];
        NSMutableDictionary *configDict = [_profileDict[@"Config"] mutableCopy];
        configDict[@"Name"] = [_textFieldSheetProfileName stringValue];
        profileDict[@"Config"] = [configDict copy];
        [self setProfileDict:[profileDict copy]];
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
        [_sheetProfileName orderOut:self];
        [self saveProfile];
    } else {
        NSLog(@"Parent doesnt respond to rename profile!");
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
        [_sheetProfileName orderOut:self];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions NEW
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)tableViewProfilePayloads:(id)sender {
    
    [self saveCurrentSettings];
    
    [_tableViewPayloadLibrary deselectAll:self];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [self setTableViewProfilePayloadsSelectedRow:[_tableViewProfilePayloads selectedRow]];
    
    [_tableViewSettings beginUpdates];
    [_arraySettings removeAllObjects];
    
    if ( 0 <= _tableViewProfilePayloadsSelectedRow ) {
        
        NSMutableDictionary *currentMenuDict = [[_arrayProfilePayloads objectAtIndex:_tableViewProfilePayloadsSelectedRow] mutableCopy];
        NSString *menuDomain = currentMenuDict[@"Domain"];
        [self setTableViewSettingsCurrentSettings:[_tableViewSettingsSettings[menuDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        [self setSelectedPayloadTableViewIdentifier:[_tableViewProfilePayloads identifier]];
        NSArray *settingsArray = [self settingsForMenuItem:_arrayProfilePayloads[_tableViewProfilePayloadsSelectedRow]];
        if ( [settingsArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[settingsArray copy]];
            [_viewSettingsError setHidden:YES];
        } else {
            [_viewSettingsError setHidden:NO];
        }
    } else {
        [self setSelectedPayloadTableViewIdentifier:nil];
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
}

- (IBAction)tableViewPayloadLibrary:(id)sender {
    
    [self saveCurrentSettings];
    
    [_tableViewProfilePayloads deselectAll:self];
    [self setTableViewProfilePayloadsSelectedRow:-1];
    [self setTableViewPayloadLibrarySelectedRow:[_tableViewPayloadLibrary selectedRow]];
    
    [_tableViewSettings beginUpdates];
    [_arraySettings removeAllObjects];
    
    if ( 0 <= _tableViewPayloadLibrarySelectedRow ) {
        NSMutableDictionary *currentMenuDict = [[_arrayPayloadLibrary objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
        NSString *menuDomain = currentMenuDict[@"Domain"];
        [self setTableViewSettingsCurrentSettings:[_tableViewSettingsSettings[menuDomain] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
        NSArray *settingsArray = [self settingsForMenuItem:_arrayPayloadLibrary[_tableViewPayloadLibrarySelectedRow]];
        if ( [settingsArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[settingsArray copy]];
            [_viewSettingsError setHidden:YES];
        } else {
            [_viewSettingsError setHidden:NO];
        }
    } else {
        [self setSelectedPayloadTableViewIdentifier:nil];
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
}

- (IBAction)segmentedControlLibrary:(id)sender {
    
    NSInteger selectedSegment = [_segmentedControlLibrary selectedSegment];
    if ( _segmentedControlLibrarySelectedSegment == selectedSegment ) {
        return;
    }
    
    switch (_segmentedControlLibrarySelectedSegment) {
        case 0:
            [self setArrayPayloadLibraryApple:[_arrayPayloadLibrary mutableCopy]];
            break;
            
        case 1:
            [self setArrayPayloadLibraryUserPreferences:[_arrayPayloadLibrary mutableCopy]];
            break;
            
        case 2:
            [self setArrayPayloadLibraryCustom:[_arrayPayloadLibrary mutableCopy]];
            break;
        default:
            NSLog(@"Unknown!");
            break;
    }
    
    [self setSegmentedControlLibrarySelectedSegment:selectedSegment];
    
    [_tableViewPayloadLibrary beginUpdates];
    [_arrayPayloadLibrary removeAllObjects];
    
    switch (_segmentedControlLibrarySelectedSegment) {
        case 0:
            [self setArrayPayloadLibrary:[_arrayPayloadLibraryApple mutableCopy]];
            break;
            
        case 1:
            [self setArrayPayloadLibrary:[_arrayPayloadLibraryUserPreferences mutableCopy]];
            break;
            
        case 2:
            [self setArrayPayloadLibrary:[_arrayPayloadLibraryCustom mutableCopy]];
            break;
        default:
            NSLog(@"Unknown!");
            break;
    }
    
    [_tableViewPayloadLibrary reloadData];
    [_tableViewPayloadLibrary endUpdates];
    
}

- (NSMutableArray *)arrayForPayloadLibrary:(NSInteger )payloadLibrary {
    switch (payloadLibrary) {
        case 0:
            return [_arrayPayloadLibraryApple mutableCopy];
            break;
            
        case 1:
            return [_arrayPayloadLibraryUserPreferences mutableCopy];
            break;
            
        case 2:
            return [_arrayPayloadLibraryCustom mutableCopy];
            break;
        default:
            NSLog(@"Unknown!");
            return nil;
            break;
    }
}

- (void)savePayloadLibraryArray:(NSMutableArray *)arrayPayloadLibrary payloadLibrary:(NSInteger)payloadLibrary {
    switch (payloadLibrary) {
        case 0:
            [self setArrayPayloadLibraryApple:[arrayPayloadLibrary mutableCopy]];
            break;
            
        case 1:
            [self setArrayPayloadLibraryUserPreferences:[arrayPayloadLibrary mutableCopy]];
            break;
            
        case 2:
            [self setArrayPayloadLibraryCustom:[arrayPayloadLibrary mutableCopy]];
            break;
        default:
            NSLog(@"Unknown!");
            break;
    }
}

- (IBAction)menuItemShowInFinder:(id)sender {
    NSError *error = nil;
    NSDictionary *manifestDict;
    if ( [_clickedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        manifestDict = [_arrayProfilePayloads objectAtIndex:_tableViewProfilePayloadsClickedRow];
    } else if ( [_clickedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuDisabled"] ) {
        manifestDict = [_arrayPayloadLibrary objectAtIndex:_tableViewPayloadLibraryClickedRow];
    } else {
        NSLog(@"[ERROR] Unknown table view identifier: %@", _clickedPayloadTableViewIdentifier);
        return;
    }
    
    if ( [manifestDict[@"PlistPath"] length] != 0 ) {
        NSString *filePath = manifestDict[@"PlistPath"] ?: @"";
        NSLog(@"filePath=%@", filePath);
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if ( [fileURL checkResourceIsReachableAndReturnError:&error] ) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
}

- (void)validateMenu:(NSMenu*)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row {
    
    [self setClickedPayloadTableViewIdentifier:tableViewIdentifier];

    if ( [tableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        if ( 0 <= row && [_arrayProfilePayloads count] <= row ) {
            menu = nil;
            return;
        }
        
        [self setTableViewProfilePayloadsClickedRow:row];
        
        NSMenuItem *menuItemShowOriginalInFinder = [menu itemWithTitle:@"Show Original In Finder"];
        NSDictionary *manifestDict = [_arrayProfilePayloads objectAtIndex:row];
        if ( [manifestDict[@"PlistPath"] length] != 0 ) {
            [menuItemShowOriginalInFinder setEnabled:YES];
        } else {
            [menu removeItem:menuItemShowOriginalInFinder];
        }
    } else if ( [tableViewIdentifier isEqualToString:@"TableViewMenuDisabled"] ) {
        
        if ( 0 <= row && [_arrayPayloadLibrary count] <= row ) {
            menu = nil;
            return;
        }
        
        [self setTableViewPayloadLibraryClickedRow:row];
        
        // MenuItem "Show Original In Finder"
        NSMenuItem *menuItemShowOriginalInFinder = [menu itemWithTitle:@"Show Original In Finder"];
        NSDictionary *manifestDict = [_arrayPayloadLibrary objectAtIndex:row];
        if ( [manifestDict[@"PlistPath"] length] != 0 ) {
            [menuItemShowOriginalInFinder setEnabled:YES];
        } else {
            [menu removeItem:menuItemShowOriginalInFinder];
        }
    } else {
        NSLog(@"[ERROR] Unknown table view identifier: %@", tableViewIdentifier);
    }
}

@end

@implementation PFCPayloadLibraryTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    
    if ( row < 0 ) {
        return [super menuForEvent:theEvent];
    }
    
    NSString *tableViewIdentifier = [self identifier];
    NSMenu *menu = [[self menu] copy];
    [menu setAutoenablesItems:NO];
    [_delegate validateMenu:menu forTableViewWithIdentifier:tableViewIdentifier row:row];
    
    return menu;
}

@end