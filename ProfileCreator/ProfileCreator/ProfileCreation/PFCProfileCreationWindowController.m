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
#import "PFCSplitViewPayloadLibrary.h"

@interface PFCProfileCreationWindowController ()

@end

@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
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
        _payloadLibraryUserPreferencesSettings = [[NSMutableDictionary alloc] init];
        _payloadLibraryCustomSettings = [[NSMutableDictionary alloc] init];
        
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindowController Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Setup Main Window
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    [self insertSubview:_viewProfilePayloadsSuperview inSuperview:_viewProfilePayloadsSplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    [self insertSubview:_viewPayloadLibrarySuperview inSuperview:_viewPayloadLibrarySplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    [self insertSubview:_viewSettingsSuperView inSuperview:_viewSettingsSplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    [self insertSubview:_viewSettingsHeader inSuperview:_viewSettingsHeaderSplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    [self insertSubview:_viewProfileHeader inSuperview:_viewProfileHeaderSplitView cTop:0 cBottom:0 cRight:0 cLeft:0];
    
    // Setup KVO observers
    [self addObserver:self forKeyPath:@"profileName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"advancedSettings" options:NSKeyValueObservingOptionNew context:nil];
    
    // Setup TableViews
    [self setupTableViews];
    
    [self showProfileHeader];
    [self setProfileName:_profileDict[@"Config"][@"Name"] ?: @"Profile"];
} // windowDidLoad

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindow Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

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
                
                // Close
            } else if ( returnCode == NSAlertSecondButtonReturn ) {
                [self setWindowShouldClose:YES];
                [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
                
                // Cancel
            } else if ( returnCode == NSAlertThirdButtonReturn ) {
                [self setWindowShouldClose:NO];
            }
        }];
        
        return NO;
    }
} // windowShouldClose

- (void)closeWindow {
    [[self window] performClose:self];
} // closeWindow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCProfileCreationWindowController Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)setupTableViews {
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
    
    [self selectTableViewProfilePayloads:nil];
    [self setTableViewProfilePayloadsSelectedRow:-1];
    [_tableViewProfilePayloads setTableViewMenuDelegate:self];
    [[_tableViewProfilePayloads layer] setBorderWidth:0.0f];
    [_tableViewProfilePayloads reloadData];
    
    [self selectTableViewPayloadLibrary:nil];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [_tableViewPayloadLibrary setTableViewMenuDelegate:self];
    [[_tableViewPayloadLibrary layer] setBorderWidth:0.0f];
    [_tableViewPayloadLibrary reloadData];
    
    [self hideSettingsHeader];
} // initializeMenu

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
            NSMutableDictionary *manifestDict = [[NSDictionary dictionaryWithContentsOfURL:manifestURL] mutableCopy];
            if ( [manifestDict count] != 0 ) {
                NSString *manifestDomain = manifestDict[@"Domain"] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain] ||
                    [manifestDomain isEqualToString:@"com.apple.general"]
                    ) {
                    [_arrayProfilePayloads addObject:[manifestDict copy]];
                } else {
                    [_arrayPayloadLibraryApple addObject:[manifestDict copy]];
                }
            } else {
                NSLog(@"[ERROR] Manifest %@ was empty!", [manifestURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort menu arrays
        // ---------------------------------------------------------------------
        [_arrayProfilePayloads sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        [_arrayPayloadLibraryApple sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
        
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
        
        // Set this here, shoudl move to it's own action in intialize insted
        [self setArrayPayloadLibrary:_arrayPayloadLibraryApple];
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
            NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
            NSDictionary *manifestDict = [PFCManifestCreationParser manifestForPlistAtURL:plistURL settingsDict:&settingsDict];
            if ( [manifestDict count] != 0 ) {
                NSString *manifestDomain = manifestDict[@"Domain"] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain]
                    ) {
                    [_arrayProfilePayloads addObject:manifestDict];
                } else {
                    [_arrayPayloadLibraryUserPreferences addObject:manifestDict];
                }
                
                _payloadLibraryUserPreferencesSettings[manifestDomain] = [settingsDict copy];
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id) __unused object change:(NSDictionary *)change context:(void *) __unused context {
    if ( [keyPath isEqualToString:@"advancedSettings"] ) {
        [self updateTableColumnsSettings];
    } else if ( [keyPath isEqualToString:@"profileName"] ) {
        NSString *newProfileName = change[@"new"];
        if ( [newProfileName length] != 0 ) {
            [[self window] setTitle:newProfileName];
        }
    }
} // observeValueForKeyPath:ofObject:change:context

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
                
            } else {
                NSString *identifier = manifestDict[@"Identifier"];
                NSDictionary *cellSettingsDict = _tableViewSettingsCurrentSettings[identifier];
                
                // ---------------------------------------------------------------------
                //  TextField
                // ---------------------------------------------------------------------
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
            
            NSDictionary *errorDict = [[PFCPayloadVerification sharedInstance] verifyManifest:menuDict[@"ManifestContent"] settingsDict:manifestSettings];
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
                CellViewMenuLibrary *cellView = [_tableViewProfilePayloads makeViewWithIdentifier:@"CellViewMenuLibrary" owner:self];
                [cellView setIdentifier:nil];
                return [cellView populateCellViewMenuLibrary:cellView menuDict:menuDict errorCount:nil row:row];
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
            return 20;
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
            return 80;
        } else if ( [cellType isEqualToString:@"File"] ) {
            return 192;
        } else if ( [cellType isEqualToString:@"TableView"] ) {
            return 212;
        }
    } else if ( [[tableView identifier] isEqualToString:@"TableViewMenuEnabled"] ) {
        return 42;
    } else if ( [[tableView identifier] isEqualToString:@"TableViewMenuDisabled"] ) {
        return 32;
    }
    return 1;
} // tableView:heightOfRow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Source Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayForTableViewWithIdentifier:(NSString *)tableViewIdentifier {
    if ( [tableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        return [_arrayProfilePayloads copy];
    } else if ( [tableViewIdentifier isEqualToString:@"TableViewMenuDisabled"] ) {
        return [_arrayPayloadLibrary copy];
    } else {
        return nil;
    }
} // arrayForTableViewWithIdentifier

- (NSMutableArray *)arrayForPayloadLibrary:(NSInteger )payloadLibrary {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            return [_arrayPayloadLibraryApple mutableCopy];
            break;
        case kPFCPayloadLibraryUserPreferences:
            return [_arrayPayloadLibraryUserPreferences mutableCopy];
            break;
        case kPFCPayloadLibraryCustom:
            return [_arrayPayloadLibraryCustom mutableCopy];
            break;
        default:
            return nil;
            break;
    }
} // arrayForPayloadLibrary

- (void)saveArray:(NSMutableArray *)arrayPayloadLibrary forPayloadLibrary:(NSInteger)payloadLibrary {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            [self setArrayPayloadLibraryApple:[arrayPayloadLibrary mutableCopy]];
            break;
        case kPFCPayloadLibraryUserPreferences:
            [self setArrayPayloadLibraryUserPreferences:[arrayPayloadLibrary mutableCopy]];
            break;
        case kPFCPayloadLibraryCustom:
            [self setArrayPayloadLibraryCustom:[arrayPayloadLibrary mutableCopy]];
            break;
        default:
            break;
    }
} // saveArray:forPayloadLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateTableColumnsSettings {
    for ( NSTableColumn *column in [_tableViewSettings tableColumns] ) {
        if ( [[column identifier] isEqualToString:@"ColumnSettingsEnabled"] ) {
            [column setHidden:!_advancedSettings];
        } else if ( [[column identifier] isEqualToString:@"ColumnMinOS"] ) {
            [column setHidden:YES];
        }
    }
} // updateTableColumnsSettings

- (void)updatePayloadErrorCount {
    if ( [_selectedPayloadTableViewIdentifier isEqualToString:@"TableViewMenuEnabled"] ) {
        if ( 0 <= _tableViewProfilePayloadsSelectedRow && _tableViewProfilePayloadsSelectedRow <= [_arrayProfilePayloads count] ) {
            NSInteger columnIndex = [_tableViewProfilePayloads columnWithIdentifier:@"ColumnMenu"];
            [_tableViewProfilePayloads reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_tableViewProfilePayloadsSelectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView CellView Actions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

// FIXME - All of these could possible move to it's own class to clean up this window controller and make the available to other parts if needed

//- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
// Works fine, but can't click the buttons
//return [_viewPayloadLibraryMenu convertRect:[_viewPayloadLibraryMenu bounds] fromView:splitView];
//}

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
    [self updatePayloadErrorCount];
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
            
            if ( payloadLibrary == _segmentedControlPayloadLibrarySelectedSegment ) {
                [_tableViewPayloadLibrary beginUpdates];
                [_arrayPayloadLibrary addObject:cellDict];
                [_arrayPayloadLibrary sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [_tableViewPayloadLibrary reloadData];
                [_tableViewPayloadLibrary endUpdates];
            } else {
                NSMutableArray *arrayPayloadLibrarySource = [self arrayForPayloadLibrary:payloadLibrary];
                [arrayPayloadLibrarySource addObject:cellDict];
                [arrayPayloadLibrarySource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [self saveArray:arrayPayloadLibrarySource forPayloadLibrary:payloadLibrary];
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
            if ( tableViewMenuEnabledSelectedRow == row && payloadLibrary == _segmentedControlPayloadLibrarySelectedSegment ) {
                
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
                settingsDict[@"PayloadLibrary"] = @(_segmentedControlPayloadLibrarySelectedSegment);
                _tableViewSettingsSettings[payloadDomain] = [settingsDict copy];
            }
        }
    } else {
        NSLog(@"[ERROR] Checkbox superview class is not CellViewMenuEnabled: %@", [[checkbox superview] class]);
    }
} // checkboxMenuEnabled

- (void)showSettingsHeader {
    [_constraintSettingsHeaderHeight setConstant:47.0f];
    [self setSettingsHeaderHidden:NO];
}

- (void)showProfileHeader {
    [_constraintProfileHeaderHeight setConstant:47.0f];
    [self setProfileHeaderHidden:NO];
}

- (void)hideSettingsHeader {
    [_constraintSettingsHeaderHeight setConstant:0.0f];
    [self setSettingsHeaderHidden:YES];
}

- (void)hideProfileHeader {
    [_constraintProfileHeaderHeight setConstant:0.0f];
    [self setProfileHeaderHidden:NO];
}

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

- (NSArray *)manifestContentForMenuItem:(NSDictionary *)menuDict {
    NSMutableArray *combinedSettings = [[NSMutableArray alloc] init];
    if ( [menuDict count] != 0 ) {
        if ( menuDict[@"SavedSettings"] != nil ) {
            return menuDict[@"SavedSettings"];
        } else {
            NSArray *settings = menuDict[@"ManifestContent"];
            
            for ( NSDictionary *setting in settings ) {
                NSMutableDictionary *combinedSettingDict = [setting mutableCopy];
                combinedSettingDict[@"Enabled"] = @YES;
                [combinedSettings addObject:[combinedSettingDict copy]];
            }
            
            if ( [combinedSettings count] != 0 ) {
                /*
                // ---------------------------------------------------------------------
                //  Add padding row to top of table view
                // ---------------------------------------------------------------------
                [combinedSettings insertObject:@{ @"CellType" : @"Padding",
                                                  @"Enabled" : @YES } atIndex:0];
                */
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
            
            NSMutableArray *selectedSegmentArray;
            if ( _tableViewPayloadLibrarySelectedRowSegment == [_segmentedControlLibrary selectedSegment] ) {
                selectedSegmentArray = _arrayPayloadLibrary;
            } else {
                selectedSegmentArray = [self arrayForPayloadLibrary:_tableViewPayloadLibrarySelectedRowSegment];
            }
            
            NSMutableDictionary *currentMenuDict = [[selectedSegmentArray objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
            if ( [_tableViewSettingsCurrentSettings count] != 0 ) {
                NSString *menuDomain = currentMenuDict[@"Domain"];
                _tableViewSettingsSettings[menuDomain] = [_tableViewSettingsCurrentSettings copy];
            }
            currentMenuDict[@"SavedSettings"] = [_arraySettings copy];
            [selectedSegmentArray replaceObjectAtIndex:_tableViewPayloadLibrarySelectedRow withObject:[currentMenuDict copy]];
        }
    } else {
        //NSLog(@"No settings selected!");
    }
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCancel:(id)sender {
    [[self window] performClose:self];
} // buttonCancel

- (IBAction)buttonCancelSheetProfileName:(id)sender {
    [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    [_sheetProfileName orderOut:self];
} // buttonCancelSheetProfileName

- (IBAction)buttonPopOverSettings:(id)sender {
    [_popOverSettings showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
} // buttonPopOverSettings

- (IBAction)buttonSave:(id)sender {
    if ( [_profileDict[@"Config"][@"Name"] isEqualToString:@"Untitled..."] ) {
        
        // -------------------------------------------------------------------------
        //  Populate sheet with the current name, and disable the save button
        //  When typing the save button state is handled in -controlTextDidChange
        // -------------------------------------------------------------------------
        [_buttonSaveSheetProfileName setEnabled:NO];
        [_textFieldSheetProfileName setStringValue:@"Untitled..."];
        
        [[NSApp mainWindow] beginSheet:_sheetProfileName completionHandler:^(NSModalResponse __unused returnCode) {
            // All actions are handled in the IBActions: -buttonCancelSheetProfileName, -buttonSaveSheetProfileName
        }];
    } else {
        [self saveProfile];
    }
} // buttonSave

- (IBAction)buttonSaveSheetProfileName:(id)sender {
    
    // -----------------------------------------------------------------------------------------
    //  Verify that the parent object (PFCController) responds to renameProfileWithName:newName
    // -----------------------------------------------------------------------------------------
    // FIXME -  This is just for testing, and feels weak to search for Name, and also limits the possibility to have profiles with the same name.
    //          Should use a unique identifier instead of name to identify the profile.
    //          -(void)renameProfileWithIdentifier: or -(void)renameProfileWithDomain
    if ( [_parentObject respondsToSelector:@selector(renameProfileWithName:newName:)] ) {
        
        // -----------------------------------------------------------------------------------------
        //  Call -(void)renameProfileWithName:newName to rename profile in the main menu
        // -----------------------------------------------------------------------------------------
        [_parentObject renameProfileWithName:@"Untitled..." newName:[_textFieldSheetProfileName stringValue]];
        
        // -----------------------------------------------------------------------------------------
        //  Update the profile dict stored in this window controller with the same name
        // -----------------------------------------------------------------------------------------
        NSMutableDictionary *profileDict = [_profileDict mutableCopy];
        NSMutableDictionary *configDict = [_profileDict[@"Config"] mutableCopy];
        configDict[@"Name"] = [_textFieldSheetProfileName stringValue];
        profileDict[@"Config"] = [configDict copy];
        [self setProfileDict:[profileDict copy]];
        
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
        [_sheetProfileName orderOut:self];
        
        [self saveProfile];
    } else {
        
        // FIXME - If renaming fails here, should notify the user
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
        [_sheetProfileName orderOut:self];
    }
} // buttonSaveSheetProfileName

- (IBAction)selectTableViewProfilePayloads:(id)sender {
    
    // -------------------------------------------------------------------------
    //  Save the current settings before changing payload in the settings view
    // -------------------------------------------------------------------------
    [self saveCurrentSettings];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewPayloadLibrary deselectAll:self];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [self setTableViewProfilePayloadsSelectedRow:[_tableViewProfilePayloads selectedRow]];
    
    [_tableViewSettings beginUpdates];
    [_arraySettings removeAllObjects];
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewProfilePayloadsSelectedRow && _tableViewProfilePayloadsSelectedRow <= [_arrayProfilePayloads count] ) {
        
        // ------------------------------------------------------------------------------------
        //  Update the SelectedTableViewIdentifier with the current TableView identifier
        // ------------------------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:[_tableViewProfilePayloads identifier]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current settings from the saved settings dict (by using the payload domain)
        // ------------------------------------------------------------------------------------
        NSMutableDictionary *currentMenuDict = [[_arrayProfilePayloads objectAtIndex:_tableViewProfilePayloadsSelectedRow] mutableCopy];
        [self setTableViewSettingsCurrentSettings:[_tableViewSettingsSettings[currentMenuDict[@"Domain"] ?: @""] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current manifest content dict array from the selected manifest
        //  If the manifest content dict array is empty, show "Error Reading Settings"
        // ------------------------------------------------------------------------------------
        NSArray *manifestContentArray = [self manifestContentForMenuItem:_arrayProfilePayloads[_tableViewProfilePayloadsSelectedRow]];
        if ( [manifestContentArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[manifestContentArray copy]];
            [_viewSettingsError setHidden:YES];
            [_textFieldSettingsHeaderTitle setStringValue:currentMenuDict[@"Title"] ?: @""];
            NSImage *icon = [[NSBundle mainBundle] imageForResource:currentMenuDict[@"IconName"]];
            if ( icon ) {
                [_imageViewSettingsHeaderIcon setImage:icon];
            }
            if ( _settingsHeaderHidden ) {
                [self showSettingsHeader];
            }
        } else {
            if ( ! _settingsHeaderHidden ) {
                [self hideSettingsHeader];
            }
            [_viewSettingsError setHidden:NO];
        }
    } else {
        if ( ! _settingsHeaderHidden ) {
            [self hideSettingsHeader];
        }
        [self setSelectedPayloadTableViewIdentifier:nil];
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
}

- (IBAction)selectTableViewPayloadLibrary:(id)sender {
    
    // -------------------------------------------------------------------------
    //  Save the current settings before changing payload in the settings view
    // -------------------------------------------------------------------------
    [self saveCurrentSettings];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewProfilePayloads deselectAll:self];
    [self setTableViewProfilePayloadsSelectedRow:-1];
    [self setTableViewPayloadLibrarySelectedRow:[_tableViewPayloadLibrary selectedRow]];
    [self setTableViewPayloadLibrarySelectedRowSegment:[_segmentedControlLibrary selectedSegment]];
    
    [_tableViewSettings beginUpdates];
    [_arraySettings removeAllObjects];

    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewPayloadLibrarySelectedRow && _tableViewPayloadLibrarySelectedRow <= [_arrayPayloadLibrary count] ) {
        
        // ------------------------------------------------------------------------------------
        //  Update the SelectedTableViewIdentifier with the current TableView identifier
        // ------------------------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current settings from the saved settings dict (by using the payload domain)
        // ------------------------------------------------------------------------------------
        NSMutableDictionary *currentMenuDict = [[_arrayPayloadLibrary objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
        [self setTableViewSettingsCurrentSettings:[_tableViewSettingsSettings[currentMenuDict[@"Domain"] ?: @""] mutableCopy] ?: [[NSMutableDictionary alloc] init]];

        // ------------------------------------------------------------------------------------
        //  Load the current manifest content dict array from the selected manifest
        //  If the manifest content dict array is empty, show "Error Reading Settings"
        // ------------------------------------------------------------------------------------
        NSArray *manifestContentArray = [self manifestContentForMenuItem:_arrayPayloadLibrary[_tableViewPayloadLibrarySelectedRow]];
        if ( [manifestContentArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[manifestContentArray copy]];
            [_viewSettingsError setHidden:YES];
            [_textFieldSettingsHeaderTitle setStringValue:currentMenuDict[@"Title"] ?: @""];
            NSImage *icon = [[NSBundle mainBundle] imageForResource:currentMenuDict[@"IconName"]];
            if ( icon ) {
                [_imageViewSettingsHeaderIcon setImage:icon];
            } else {
                NSURL *iconURL = [NSURL fileURLWithPath:currentMenuDict[@"IconPath"] ?: @""];
                if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
                    NSImage *icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
                    if ( icon ) {
                        [_imageViewSettingsHeaderIcon setImage:icon];
                    }
                }
                
                iconURL = [NSURL fileURLWithPath:currentMenuDict[@"IconPathBundle"] ?: @""];
                if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
                    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[iconURL path]];
                    if ( icon ) {
                        [_imageViewSettingsHeaderIcon setImage:icon];
                    }
                }
            }
            if ( _settingsHeaderHidden ) {
                [self showSettingsHeader];
            }
        } else {
            if ( ! _settingsHeaderHidden ) {
                [self hideSettingsHeader];
            }
            [_viewSettingsError setHidden:NO];
        }
    } else {
        if ( ! _settingsHeaderHidden ) {
            [self hideSettingsHeader];
        }
        
        // ---------------------------------------------------------------------
        //  Unset the SelectedTableViewIdentifier
        // ---------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:nil];
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
}

- (IBAction)selectSegmentedControlLibrary:(id)sender {
    
    NSInteger selectedSegment = [_segmentedControlLibrary selectedSegment];
    
    // -------------------------------------------------------------------------
    //  If the selected segment already is selected, stop here
    // -------------------------------------------------------------------------
    if ( _segmentedControlPayloadLibrarySelectedSegment == selectedSegment ) {
        return;
    }
    
    // --------------------------------------------------------------------------------------------
    //  If a search is NOT active in the previous selected segment, save the previous segment array
    //  ( If a search IS active, the previous segment array was saved when the search was started )
    // --------------------------------------------------------------------------------------------
    if ( ! [self isSearchingPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment] ) {
        [self saveArray:_arrayPayloadLibrary forPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
    }
    
    [self setSegmentedControlPayloadLibrarySelectedSegment:selectedSegment];
    
    // --------------------------------------------------------------------------------------------
    //  If a search is saved in the selected segment, restore that search when loading the segment array
    //  If a search is NOT saved, restore the whole segment array instead
    // --------------------------------------------------------------------------------------------
    if ( [self isSearchingPayloadLibrary:selectedSegment] ) {
        [_searchFieldProfileLibrary setStringValue:[self searchStringForPayloadLibrary:selectedSegment] ?: @""];
        [self searchFieldProfileLibrary:nil];
    } else {
        [_searchFieldProfileLibrary setStringValue:@""];
        [_tableViewPayloadLibrary beginUpdates];
        [_arrayPayloadLibrary removeAllObjects];
        [self setArrayPayloadLibrary:[self arrayForPayloadLibrary:selectedSegment]];
        [_tableViewPayloadLibrary reloadData];
        [_tableViewPayloadLibrary endUpdates];
    }
    
    // --------------------------------------------------------------------------------------------
    //  If the currently selected payload is in the selected segment, restore that selection in the TableView
    // --------------------------------------------------------------------------------------------x
    if ( 0 <= _tableViewPayloadLibrarySelectedRow && _tableViewPayloadLibrarySelectedRowSegment == selectedSegment ) {
        [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:_tableViewPayloadLibrarySelectedRow] byExtendingSelection:NO];
    }
} // selectSegmentedControlLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PayloadLibrary Search Field
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)searchFieldProfileLibrary:(id)sender {
    
    // -------------------------------------------------------------------------------------------------
    //  Check if this is the beginning of a search, if so save the complete array before removing items
    // -------------------------------------------------------------------------------------------------
    if ( ! [self isSearchingPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment] ) {
        [self setIsSearchingPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment isSearching:YES];
        [self saveArray:_arrayPayloadLibrary forPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
    }
    
    NSString *searchString = [_searchFieldProfileLibrary stringValue];
    [_tableViewPayloadLibrary beginUpdates];
    if ( ! [searchString length] ) {
        
        // ---------------------------------------------------------------------
        //  If user pressed (x) or deleted the search, restore the whole array
        // ---------------------------------------------------------------------
        [self restoreSearchForPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
    } else {
        
        // ---------------------------------------------------------------------
        //  If this is a search, store the search string if user changes segment
        // ---------------------------------------------------------------------
        [self setSearchStringForPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment searchString:[searchString copy]];
        
        // ---------------------------------------------------------------------
        //  Get the whole array for the current segment to filter
        // ---------------------------------------------------------------------
        NSMutableArray *currentPayloadLibrary = [self arrayForPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
        
        // FIXME - Should add a setting to choose what the search should match. A pull down menu with some predicate choices like all, keys, settings (default), title, type, contains, is equal etc.
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"Title CONTAINS[cd] %@", searchString];
        
        // ------------------------------------------------------------------------
        //  Filter the array and update the content array with the matched results
        // ------------------------------------------------------------------------
        NSMutableArray *matchedObjects = [[currentPayloadLibrary filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        [self setArrayPayloadLibrary:matchedObjects];
    }
    
    [_tableViewPayloadLibrary reloadData];
    [_tableViewPayloadLibrary endUpdates];
} // searchFieldProfileLibrary

- (void)setSearchStringForPayloadLibrary:(NSInteger)payloadLibrary searchString:(NSString *)searchString {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            [self setSearchStringPayloadLibraryApple:searchString];
            break;
        case kPFCPayloadLibraryUserPreferences:
            [self setSearchStringPayloadLibraryUserPreferences:searchString];
            break;
        case kPFCPayloadLibraryCustom:
            [self setSearchStringPayloadLibraryCustom:searchString];
            break;
        default:
            break;
    }
} // setSearchStringForPayloadLibrary:searchString

- (NSString *)searchStringForPayloadLibrary:(NSInteger)payloadLibrary {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            return _searchStringPayloadLibraryApple;
            break;
        case kPFCPayloadLibraryUserPreferences:
            return _searchStringPayloadLibraryUserPreferences;
            break;
        case kPFCPayloadLibraryCustom:
            return _searchStringPayloadLibraryCustom;
            break;
        default:
            return nil;
            break;
    }
} // searchStringForPayloadLibrary

- (void)restoreSearchForPayloadLibrary:(NSInteger)payloadLibrary {
    [self setArrayPayloadLibrary:[self arrayForPayloadLibrary:payloadLibrary]];
    [self setIsSearchingPayloadLibrary:payloadLibrary isSearching:NO];
    [self setSearchStringForPayloadLibrary:payloadLibrary searchString:nil];
} // restoreSearchForPayloadLibrary

- (void)setIsSearchingPayloadLibrary:(NSInteger)payloadLibrary isSearching:(BOOL)isSearching {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            [self setIsSearchingPayloadLibraryApple:isSearching];
            break;
        case kPFCPayloadLibraryUserPreferences:
            [self setIsSearchingPayloadLibraryUserPreferences:isSearching];
            break;
        case kPFCPayloadLibraryCustom:
            [self setIsSearchingPayloadLibraryCustom:isSearching];
            break;
        default:
            break;
    }
} // setIsSearchingPayloadLibrary:isSearching

- (BOOL)isSearchingPayloadLibrary:(NSInteger)payloadLibrary {
    switch (payloadLibrary) {
        case kPFCPayloadLibraryApple:
            return _isSearchingPayloadLibraryApple;
            break;
        case kPFCPayloadLibraryUserPreferences:
            return _isSearchingPayloadLibraryUserPreferences;
            break;
        case kPFCPayloadLibraryCustom:
            return _isSearchingPayloadLibraryCustom;
            break;
        default:
            return NO;
            break;
    }
} // isSearchingPayloadLibrary:payloadLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PayloadMenu Context Menu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)validateMenu:(NSMenu*)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row {
    
    // ---------------------------------------------------------------------
    //  Store which TableView and row the user right clicked on.
    // ---------------------------------------------------------------------
    [self setClickedPayloadTableViewIdentifier:tableViewIdentifier];
    [self setClickedPayloadTableViewRow:row];
    NSArray *tableViewArray = [self arrayForTableViewWithIdentifier:tableViewIdentifier];
    
    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if ( row < 0 || [tableViewArray count] < row ) {
        menu = nil;
        return;
    }
    
    NSDictionary *manifestDict = [tableViewArray objectAtIndex:row];
    
    // -------------------------------------------------------------------------------
    //  MenuItem - "Show Original In Finder"
    //  Remove this menu item unless key 'PlistPath' is set in the manifest
    // -------------------------------------------------------------------------------
    NSMenuItem *menuItemShowOriginalInFinder = [menu itemWithTitle:@"Show Original In Finder"];
    if ( [manifestDict[@"PlistPath"] length] != 0 ) {
        [menuItemShowOriginalInFinder setEnabled:YES];
    } else {
        [menu removeItem:menuItemShowOriginalInFinder];
    }
} // validateMenu:forTableViewWithIdentifier:row

- (IBAction)menuItemShowInFinder:(id)sender {
    
    NSArray *tableViewArray = [self arrayForTableViewWithIdentifier:_clickedPayloadTableViewIdentifier];
    
    // ----------------------------------------------------------------------------------------
    //  Sanity check so that row isn't less than 0 and that it's within the count of the array
    // ----------------------------------------------------------------------------------------
    if ( _clickedPayloadTableViewRow < 0 || [tableViewArray count] < _clickedPayloadTableViewRow ) {
        return;
    }
    
    NSDictionary *manifestDict = [tableViewArray objectAtIndex:_clickedPayloadTableViewRow];
    
    // ----------------------------------------------------------------------------------------
    //  If key 'PlistPath' is set, check if it's a valid path. If it is, open it in Finder
    // ----------------------------------------------------------------------------------------
    if ( [manifestDict[@"PlistPath"] length] != 0 ) {
        NSError *error = nil;
        NSString *filePath = manifestDict[@"PlistPath"] ?: @"";
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if ( [fileURL checkResourceIsReachableAndReturnError:&error] ) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ fileURL ]];
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
} // menuItemShowInFinder

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class: PFCPayloadLibraryTableView
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation PFCPayloadLibraryTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    
    // ------------------------------------------------------------------------------
    //  Get what row in the TableView the mouse is pointing at when the user clicked
    // ------------------------------------------------------------------------------
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    
    if ( row < 0 ) {
        return nil;
    }
    
    // ----------------------------------------------------------------------------------------
    //  Get what table view responded when the user clicked
    // ----------------------------------------------------------------------------------------
    NSString *tableViewIdentifier = [self identifier];
    
    // ----------------------------------------------------------------------------------------
    //  Create an instance of the context menu bound to the TableView's menu outlet
    // ----------------------------------------------------------------------------------------
    NSMenu *menu = [[self menu] copy];
    [menu setAutoenablesItems:NO];
    
    // -----------------------------------------------------------------------------------------------------------
    //  Send menu to delegate for validation to add, enable and disable menu items depending on TableView and row
    // -----------------------------------------------------------------------------------------------------------
    [_delegate validateMenu:menu forTableViewWithIdentifier:tableViewIdentifier row:row];
    
    return menu;
} // menuForEvent

@end