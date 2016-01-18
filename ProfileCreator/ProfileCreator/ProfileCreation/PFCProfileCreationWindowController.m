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
#import "PFCConstants.h"
#import "PFCController.h"
#import "PFCPayloadVerification.h"
#import "PFCSplitViewPayloadLibrary.h"
#import "PFCManifestTools.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCTableViewIdentifierPayloadProfile = @"TableViewIdentifierPayloadProfile";
NSString *const PFCTableViewIdentifierPayloadLibrary = @"TableViewIdentifierPayloadLibrary";
NSString *const PFCTableViewIdentifierPayloadSettings = @"TableViewIdentifierPayloadSettings";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Implementation
////////////////////////////////////////////////////////////////////////////////
@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender {
    self = [super initWithWindowNibName:@"PFCProfileCreationWindowController"];
    if (self != nil) {
        
        // ---------------------------------------------------------------------
        //  Initialize Passed Objects
        // ---------------------------------------------------------------------
        _parentObject = sender;
        _profileDict = profileDict ?: @{};
        
        // ---------------------------------------------------------------------
        //  Initialize Arrays
        // ---------------------------------------------------------------------
        _arrayPayloadProfile = [[NSMutableArray alloc] init];
        _arrayPayloadLibrary = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryApple = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryUserPreferences = [[NSMutableArray alloc] init];
        _arrayPayloadLibraryCustom = [[NSMutableArray alloc] init];
        _arraySettings = [[NSMutableArray alloc] init];
        
        // ---------------------------------------------------------------------
        //  Initialize Dicts
        // ---------------------------------------------------------------------
        _payloadLibraryUserPreferencesSettings = [[NSMutableDictionary alloc] init];
        _payloadLibraryCustomSettings = [[NSMutableDictionary alloc] init];
        
        // ---------------------------------------------------------------------
        //  Initialize Settings
        // ---------------------------------------------------------------------
        _settingsProfile = [profileDict[@"Config"][PFCProfileTemplateKeySettings] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        _settingsManifest = [[NSMutableDictionary alloc] init];
        
        // ---------------------------------------------------------------------
        //  Initialize BOOLs (for clarity)
        // ---------------------------------------------------------------------
        _advancedSettings = NO;
        _windowShouldClose = NO;
    }
    return self;
} // init

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"advancedSettings" context:nil];
} // dealloc

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindowController Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // ---------------------------------------------------------------------
    //  Set window delegate to self to respond to -(void)windowShouldClose
    //  Also set window background color to white
    // ---------------------------------------------------------------------
    [[self window] setDelegate:self];
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    
    // ---------------------------------------------------------------------
    //  Add content views to window
    // ---------------------------------------------------------------------
    [self insertSubview:_viewPayloadProfileSuperview inSuperview:_viewPayloadProfileSplitView hidden:NO];
    [self insertSubview:_viewPayloadLibrarySuperview inSuperview:_viewPayloadLibrarySplitView hidden:NO];
    [self insertSubview:_viewPayloadLibraryMenu inSuperview:_viewPayloadLibraryMenuSuperview hidden:NO];
    [self insertSubview:_viewSettingsSuperView inSuperview:_viewSettingsSplitView hidden:NO];
    
    // ---------------------------------------------------------------------
    //  Add header views to window
    // ---------------------------------------------------------------------
    [self insertSubview:_viewSettingsHeader inSuperview:_viewSettingsHeaderSplitView hidden:NO];
    [self insertSubview:_viewPayloadHeader inSuperview:_viewPayloadHeaderSplitView hidden:NO];
    
    // ---------------------------------------------------------------------
    //  Add error views to content views
    // ---------------------------------------------------------------------
    [self insertSubview:_viewSettingsError inSuperview:_viewSettingsSplitView hidden:NO];
    [self insertSubview:_viewPayloadLibraryNoMatches inSuperview:_viewPayloadLibrarySplitView hidden:NO];
    
    // FIXME - Temporary for testing
    [_viewPayloadLibraryNoMatches setHidden:NO];
    [_viewSettingsError setHidden:NO];
    
    // ---------------------------------------------------------------------
    //  Register KVO observers
    // ---------------------------------------------------------------------
    [self addObserver:self forKeyPath:@"advancedSettings" options:NSKeyValueObservingOptionNew context:nil];
    
    // ---------------------------------------------------------------------
    //  Setup TableViews
    // ---------------------------------------------------------------------
    [self setupTableViews];
    [self showPayloadHeader];
    
    // ---------------------------------------------------------------------
    //  Initialize property 'profileName'
    // ---------------------------------------------------------------------
    [self setProfileName:_profileDict[@"Config"][PFCProfileTemplateKeyName] ?: @"Profile"];
} // windowDidLoad

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindow Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)windowShouldClose:(id)sender {
    
    // ------------------------------------------------------------------------------------
    //  Check if property (BOOL)windowShouldClose is true
    //  If true the user has seen this warning and acted upon it, and the window can close
    // ------------------------------------------------------------------------------------
    if ( _windowShouldClose ) {
        [self setWindowShouldClose:NO];
        if ( [_parentObject respondsToSelector:@selector(removeControllerForProfileDictWithName:)] ) {
            [_parentObject removeControllerForProfileDictWithName:_profileDict[@"Config"][PFCProfileTemplateKeyName]];
        }
        return YES;
    }
    
    if ( [self settingsSaved] ) {
        return YES;
    } else {
        
        // ---------------------------------------------------------------------
        //  Show modal alert if there are any unsaved settings
        // ---------------------------------------------------------------------
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
                // FIXME - Actually should save the profile here
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
    
    // FIXME - Comment this
    [self updateTableColumnsSettings];
    
    // ------------------------------------------------------------------------------------------
    //  Populate (NSMutableArray)enabledPayloadDomains with all manifest domains that's selected
    // ------------------------------------------------------------------------------------------
    NSMutableArray *enabledPayloadDomains = [NSMutableArray array];
    for ( NSString *payloadDomain in [_settingsProfile allKeys] ) {
        NSDictionary *settingsManifest = _settingsProfile[payloadDomain];
        if ( [settingsManifest[PFCSettingsKeySelected] boolValue] ) {
            [enabledPayloadDomains addObject:payloadDomain];
        }
    }
    
    // ---------------------------------------------------------------------
    //  Setup Payload Arrays
    // ---------------------------------------------------------------------
    [self setupManifestLibraryApple:[enabledPayloadDomains copy]];
    [self setupManifestLibraryUserLibrary:[enabledPayloadDomains copy]];
    [self setArrayPayloadLibrary:_arrayPayloadLibraryApple];
    [self sortArrayPayloadProfile];
    
    
    // ---------------------------------------------------------------------
    //  TableView Payload Profile
    // ---------------------------------------------------------------------
    [self selectTableViewPayloadProfile:nil];
    [self setTableViewPayloadProfileSelectedRow:-1];
    [_tableViewPayloadProfile setTableViewMenuDelegate:self];
    [[_tableViewPayloadProfile layer] setBorderWidth:0.0f];
    [_tableViewPayloadProfile reloadData];
    
    // ---------------------------------------------------------------------
    //  TableView Payload Library
    // ---------------------------------------------------------------------
    [self selectTableViewPayloadLibrary:nil];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [_tableViewPayloadLibrary setTableViewMenuDelegate:self];
    [[_tableViewPayloadLibrary layer] setBorderWidth:0.0f];
    [_tableViewPayloadLibrary reloadData];
    
    [self hideSettingsHeader];
} // setupTableViews

- (void)sortArrayPayloadProfile {
    
    // -------------------------------------------------------------------------
    //  Sort array payload profile
    // -------------------------------------------------------------------------
    [_arrayPayloadProfile sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
    
    // -------------------------------------------------------------------------
    //  Find index of menu item com.apple.general
    // -------------------------------------------------------------------------
    NSUInteger idx = [_arrayPayloadProfile indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyDomain] isEqualToString:@"com.apple.general"];
    }];
    
    // -------------------------------------------------------------------------
    //  Move menu item com.apple.general to the top of array payload profile
    // -------------------------------------------------------------------------
    if (idx != NSNotFound) {
        NSDictionary *generalSettingsDict = [_arrayPayloadProfile objectAtIndex:idx];
        [_arrayPayloadProfile removeObjectAtIndex:idx];
        [_arrayPayloadProfile insertObject:generalSettingsDict atIndex:0];
    } else {
        NSLog(@"[ERROR] No menu item with domain com.apple.general was found!");
    }
} // sortArrayPayloadProfile

- (void)setupManifestLibraryApple:(NSArray *)enabledPayloadDomains {
    
    NSError *error = nil;
    
    [_arrayPayloadProfile removeAllObjects];
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
                NSString *manifestDomain = manifestDict[PFCManifestKeyDomain] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain] ||
                    [manifestDomain isEqualToString:@"com.apple.general"]
                    ) {
                    [_arrayPayloadProfile addObject:[manifestDict copy]];
                } else {
                    [_arrayPayloadLibraryApple addObject:[manifestDict copy]];
                }
            } else {
                NSLog(@"[ERROR] Manifest %@ was empty!", [manifestURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort array
        // ---------------------------------------------------------------------
        [_arrayPayloadLibraryApple sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
    } else {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
} // setupManifestLibraryApple

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
                NSString *manifestDomain = manifestDict[PFCManifestKeyDomain] ?: @"";
                if (
                    [enabledPayloadDomains containsObject:manifestDomain]
                    ) {
                    [_arrayPayloadProfile addObject:manifestDict];
                } else {
                    [_arrayPayloadLibraryUserPreferences addObject:manifestDict];
                }
                
                _payloadLibraryUserPreferencesSettings[manifestDomain] = [settingsDict copy];
            } else {
                NSLog(@"[ERROR] Plist: %@ was empty!", [plistURL lastPathComponent]);
            }
        }
        
        // ---------------------------------------------------------------------
        //  Sort array
        // ---------------------------------------------------------------------
        [_arrayPayloadLibraryUserPreferences sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
    }
} // setupManifestLibraryUserLibrary


- (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden {
    [superview addSubview:subview positioned:NSWindowAbove relativeTo:nil];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    [superview setHidden:NO];
    [subview setHidden:hidden];
} // insertSubview:inSuperview:hidden

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id) __unused object change:(NSDictionary *)change context:(void *) __unused context {
    if ( [keyPath isEqualToString:@"advancedSettings"] ) {
        [self updateTableColumnsSettings];
    }
} // observeValueForKeyPath:ofObject:change:context

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ( splitView == _splitViewPayload && dividerIndex == 0 ) {
        return proposedMaximumPosition - 96;
    } else {
        return proposedMaximumPosition;
    }
} // splitView:constrainMaxCoordinate:ofSubviewAt

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ( splitView == _splitViewPayload && dividerIndex == 0 ) {
        return proposedMinimumPosition + 88;
    } else {
        return proposedMinimumPosition;
    }
} // splitView:constrainMinCoordinate:ofSubviewAt

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if ( splitView == _splitViewPayload && subview == _viewPayloadLibrarySplitView ) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    id splitView = [notification object];
    if ( splitView == _splitViewPayload ) {
        if ( [_splitViewPayload isSubviewCollapsed:[[_splitViewPayload subviews] objectAtIndex:1]] ) {
            [self hidePayloadFooter];
        } else if ( _payloadLibraryCollapsed ) {
            [self showPayloadFooter];
            
        }
    }
} // splitViewDidResizeSubviews

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        return (NSInteger)[_arrayPayloadProfile count];
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadLibrary] ) {
        return (NSInteger)[_arrayPayloadLibrary count];
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadSettings] ) {
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
    if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadSettings] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arraySettings count] < row || [_arraySettings count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestContentDict = _arraySettings[(NSUInteger)row];
        NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnSettings"] ) {
            
            // ---------------------------------------------------------------------
            //  Padding
            // ---------------------------------------------------------------------
            if ( [cellType isEqualToString:PFCCellTypePadding] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
                
            } else {
                NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
                NSDictionary *cellSettingsDict = _settingsManifest[identifier];
                
                // ---------------------------------------------------------------------
                //  TextField
                // ---------------------------------------------------------------------
                if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
                    CellViewSettingsTextField *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextField" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewTextField:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldHostPort
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ) {
                    CellViewSettingsTextFieldHostPort *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPort" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldHostPort:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ) {
                    CellViewSettingsTextFieldNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewTextFieldNoTitle:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButton
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypePopUpButton] ) {
                    CellViewSettingsPopUp *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUp" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewPopUp:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  Checkbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeCheckbox] ) {
                    CellViewSettingsCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsCheckbox:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  DatePickerNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ) {
                    CellViewSettingsDatePickerNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsDatePickerNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewDatePickerNoTitle:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldDaysHoursNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
                    CellViewSettingsTextFieldDaysHoursNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldDaysHoursNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldDaysHoursNoTitle:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TableView
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
                    CellViewSettingsTableView *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTableView" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTableView:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  File
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
                    CellViewSettingsFile *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsFile" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsFile:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  SegmentedControl
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
                    CellViewSettingsSegmentedControl *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsSegmentedControl" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsSegmentedControl:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  CheckboxNoDescription
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
                    CellViewSettingsCheckboxNoDescription *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsCheckboxNoDescription" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsCheckboxNoDescription:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButtonNoTitle
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ) {
                    CellViewSettingsPopUpNoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUpNoTitle" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsPopUpNoTitle:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNumber
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumber] ) {
                    CellViewSettingsTextFieldNumber *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNumber" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldNumber:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldCheckbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ) {
                    CellViewSettingsTextFieldCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldCheckbox:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldHostPortCheckbox
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
                    CellViewSettingsTextFieldHostPortCheckbox *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldHostPortCheckbox" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldHostPortCheckbox:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  PopUpButtonLeft
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
                    CellViewSettingsPopUpLeft *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsPopUpLeft" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsPopUpLeft:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                    
                    // ---------------------------------------------------------------------
                    //  TextFieldNumberLeft
                    // ---------------------------------------------------------------------
                } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
                    CellViewSettingsTextFieldNumberLeft *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsTextFieldNumberLeft" owner:self];
                    [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                    return [cellView populateCellViewSettingsTextFieldNumberLeft:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
                }
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnSettingsEnabled"] ) {
            // FIXME -  Should hidden be used, and should that be in the manifest?
            //          The idea was to hide automatic preferences for window size etc, but allow with an advanced option to show those aswell
            if ( [manifestContentDict[@"Hidden"] boolValue] ) {
                return nil;
            }
            
            if ( [cellType isEqualToString:PFCCellTypePadding] ) {
                return [tableView makeViewWithIdentifier:@"CellViewSettingsPadding" owner:self];
            } else {
                
                NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
                NSDictionary *cellSettingsDict = _settingsManifest[identifier];
                
                CellViewSettingsEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewSettingsEnabled" owner:self];
                [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
                return [cellView populateCellViewEnabled:cellView manifestDict:manifestContentDict settingDict:cellSettingsDict row:row sender:self];
            }
        }
    } else if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the menu array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayPayloadProfile count] < row || [_arrayPayloadProfile count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _arrayPayloadProfile[(NSUInteger)row];
        
        if ( [tableColumnIdentifier isEqualToString:@"ColumnMenu"] ) {
            NSString *cellType = manifestDict[PFCManifestKeyCellType];
            
            NSDictionary *manifestSettings;
            if ( _tableViewPayloadProfileSelectedRow == -1 && _tableViewPayloadLibrarySelectedRow == -1 ) {
                NSDictionary *domain = manifestDict[PFCManifestKeyDomain];
                manifestSettings = _settingsProfile[domain];
            } else {
                manifestSettings = _settingsManifest;
            }
            
            NSDictionary *errorDict = [[PFCPayloadVerification sharedInstance] verifyManifest:manifestDict[PFCManifestKeyManifestContent] settingsDict:manifestSettings];
            NSNumber *errorCount;
            if ( [errorDict count] != 0 ) {
                errorCount = @([errorDict[@"Error"] count]);
            }
            
            if ( [cellType isEqualToString:@"Menu"] ) {
                CellViewMenu *cellView = [tableView makeViewWithIdentifier:@"CellViewMenu" owner:self];
                [cellView setIdentifier:nil];
                return [cellView populateCellViewMenu:cellView manifestDict:manifestDict errorCount:errorCount row:row];
            } else {
                NSLog(@"[ERROR] Unknown CellType: %@", cellType);
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [tableView makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView manifestDict:manifestDict row:row sender:self];
        }
    } else if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadLibrary] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the menu array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arrayPayloadLibrary count] < row || [_arrayPayloadLibrary count] == 0 ) {
            return nil;
        }
        
        NSString *tableColumnIdentifier = [tableColumn identifier];
        NSDictionary *manifestDict = _arrayPayloadLibrary[(NSUInteger)row];
        if ( [tableColumnIdentifier isEqualToString:@"ColumnMenu"] ) {
            NSString *cellType = manifestDict[PFCManifestKeyCellType];
            
            if ( [cellType isEqualToString:@"Menu"] ) {
                CellViewMenuLibrary *cellView = [_tableViewPayloadProfile makeViewWithIdentifier:@"CellViewMenuLibrary" owner:self];
                [cellView setIdentifier:nil];
                return [cellView populateCellViewMenuLibrary:cellView manifestDict:manifestDict errorCount:nil row:row];
            } else {
                NSLog(@"[ERROR] Unknown CellType: %@", cellType);
            }
        } else if ( [tableColumnIdentifier isEqualToString:@"ColumnMenuEnabled"] ) {
            CellViewMenuEnabled *cellView = [_tableViewPayloadProfile makeViewWithIdentifier:@"CellViewMenuEnabled" owner:self];
            return [cellView populateCellViewEnabled:cellView manifestDict:manifestDict row:row sender:self];
        }
    }
    return nil;
} // tableView:viewForTableColumn:row

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadSettings] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arraySettings count] <= 0 ) {
            return;
        }
        
        // ---------------------------------------------------------------------
        //  Get current cell's manifest dict identifier
        // ---------------------------------------------------------------------
        NSDictionary *manifestContentDict = _arraySettings[(NSUInteger)row];
        NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
        if ( ! [cellType isEqualToString:PFCCellTypePadding] ) {
            NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
            if ( [identifier length] == 0 ) {
                //NSLog(@"No Identifier for cell dict: %@", cellDict);
                return;
            }
            
            // ---------------------------------------------------------------------
            //  It the cell is disabled, change cell background to grey
            // ---------------------------------------------------------------------
            if ( _settingsManifest[identifier][PFCManifestKeyEnabled] != nil ) {
                if ( ! [_settingsManifest[identifier][PFCManifestKeyEnabled] boolValue] ) {
                    [rowView setBackgroundColor:[NSColor quaternaryLabelColor]];
                    return;
                }
            }
            
            [rowView setBackgroundColor:[NSColor clearColor]];
        }
    }
} // tableView:didAddRowView:forRow

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadSettings] ) {
        
        // ---------------------------------------------------------------------
        //  Verify the settings array isn't empty, if so stop here
        // ---------------------------------------------------------------------
        if ( [_arraySettings count] < row || [_arraySettings count] == 0 ) {
            return 1;
        }
        
        NSDictionary *manifestContentDict = _arraySettings[(NSUInteger)row];
        
        NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
        if ( [cellType isEqualToString:PFCCellTypePadding] ) {
            return 20;
        } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
            return 33;
        } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
            return 38;
        } else if (
                   [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
            return 39;
        } else if (
                   [cellType isEqualToString:PFCCellTypeCheckbox] ) {
            return 52;
        } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
            return 53;
        } else if (
                   [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ||
                   [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
            return 54;
        } else if (
                   [cellType isEqualToString:PFCCellTypeTextField] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ||
                   [cellType isEqualToString:PFCCellTypePopUpButton] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldNumber] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ||
                   [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
            return 80;
        } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
            return 192;
        } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
            return 212;
        }
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        return 42;
    } else if ( [[tableView identifier] isEqualToString:PFCTableViewIdentifierPayloadLibrary] ) {
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
    if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        return [_arrayPayloadProfile copy];
    } else if ( [tableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadLibrary] ) {
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
    if ( [_selectedPayloadTableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        if ( 0 <= _tableViewPayloadProfileSelectedRow && _tableViewPayloadProfileSelectedRow <= [_arrayPayloadProfile count] ) {
            NSInteger columnIndex = [_tableViewPayloadProfile columnWithIdentifier:@"ColumnMenu"];
            [_tableViewPayloadProfile reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:_tableViewPayloadProfileSelectedRow] columnIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];
        }
    }
} // updatePayloadErrorCount

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
        if ( [inputText isEqualToString:PFCDefaultProfileName] || [inputText length] == 0 ) {
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
    NSMutableDictionary *manifestContentDict = [[_arraySettings objectAtIndex:row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
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
            BOOL required = [manifestContentDict[PFCManifestKeyRequired] boolValue];
            BOOL requiredHost = [manifestContentDict[PFCManifestKeyRequiredHost] boolValue];
            BOOL requiredPort = [manifestContentDict[PFCManifestKeyRequiredPort] boolValue];
            
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
                if ( [manifestContentDict[PFCManifestKeyRequired] boolValue] && [inputText length] == 0 ) {
                    [(CellViewSettingsTextField *)[textField superview] showRequired:YES];
                } else if ( [manifestContentDict[PFCManifestKeyRequired] boolValue] ) {
                    [(CellViewSettingsTextField *)[textField superview] showRequired:NO];
                }
            }
        } else {
            NSLog(@"[ERROR] Unknown text field!");
            return;
        }
    }
    
    _settingsManifest[identifier] = [settingsDict copy];
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
        if ( ( row < [_arrayPayloadProfile count] ) && checkbox == [(CellViewMenuEnabled *)[_tableViewPayloadProfile viewAtColumn:[_tableViewPayloadProfile columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox] ) {
            
            // ---------------------------------------------------------------------
            //  Store the cell dict for move
            // ---------------------------------------------------------------------
            NSDictionary *manifestDict = [_arrayPayloadProfile objectAtIndex:row];
            NSString *payloadDomain = manifestDict[PFCManifestKeyDomain];
            NSInteger payloadLibrary = [_settingsProfile[payloadDomain][@"PayloadLibrary"] integerValue];
            
            // ---------------------------------------------------------------------
            //  Remove the cell dict from table view menu ENABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewPayloadProfileSelectedRow = [_tableViewPayloadProfile selectedRow];
            [_tableViewPayloadProfile beginUpdates];
            [_arrayPayloadProfile removeObjectAtIndex:(NSUInteger)row];
            [_tableViewPayloadProfile reloadData];
            [_tableViewPayloadProfile endUpdates];
            
            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if ( 0 <= tableViewPayloadProfileSelectedRow && tableViewPayloadProfileSelectedRow != row ) {
                NSInteger selectedRow = ( row < tableViewPayloadProfileSelectedRow ) ? ( tableViewPayloadProfileSelectedRow - 1 ) : tableViewPayloadProfileSelectedRow;
                [_tableViewPayloadProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadProfileSelectedRow:selectedRow];
            }
            
            // ---------------------------------------------------------------------
            //  Add the cell dict to table view menu DISABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewPayloadLibrarySelectedRow = [_tableViewPayloadLibrary selectedRow];
            
            if ( payloadLibrary == _segmentedControlPayloadLibrarySelectedSegment ) {
                [_tableViewPayloadLibrary beginUpdates];
                [_arrayPayloadLibrary addObject:manifestDict];
                [_arrayPayloadLibrary sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [_tableViewPayloadLibrary reloadData];
                [_tableViewPayloadLibrary endUpdates];
            } else {
                NSMutableArray *arrayPayloadLibrarySource = [self arrayForPayloadLibrary:payloadLibrary];
                [arrayPayloadLibrarySource addObject:manifestDict];
                [arrayPayloadLibrarySource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
                [self saveArray:arrayPayloadLibrarySource forPayloadLibrary:payloadLibrary];
            }
            
            // -----------------------------------------------------------------------------
            //  If item in table view DISABLED was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if ( 0 <= tableViewPayloadLibrarySelectedRow && tableViewPayloadProfileSelectedRow != row ) {
                [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:tableViewPayloadLibrarySelectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadLibrarySelectedRow:tableViewPayloadLibrarySelectedRow];
            }
            
            // -----------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view DISABLED
            // -----------------------------------------------------------------------------
            if ( tableViewPayloadProfileSelectedRow == row && payloadLibrary == _segmentedControlPayloadLibrarySelectedSegment ) {
                
                // ---------------------------------------------------------------------
                //  Deselect items in table view ENABLED
                // ---------------------------------------------------------------------
                [_tableViewPayloadProfile deselectAll:self];
                [self setTableViewPayloadProfileSelectedRow:-1];
                
                // ---------------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // ---------------------------------------------------------------------
                NSUInteger row = [_arrayPayloadLibrary indexOfObject:manifestDict];
                if ( row != NSNotFound ) {
                    [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    [[self window] makeFirstResponder:_tableViewPayloadLibrary];
                    [self setTableViewPayloadLibrarySelectedRow:row];
                    [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadLibrary identifier]];
                }
                
                [_settingsManifest removeObjectForKey:@"Selected"];
                [_settingsManifest removeObjectForKey:@"PayloadLibrary"];
            } else {
                NSMutableDictionary *settingsDict = [_settingsProfile[payloadDomain] mutableCopy] ?: [NSMutableDictionary dictionary];
                [settingsDict removeObjectForKey:@"Selected"];
                [settingsDict removeObjectForKey:@"PayloadLibrary"];
                if ( [settingsDict count] == 0 ) {
                    [_settingsProfile removeObjectForKey:payloadDomain];
                } else {
                    _settingsProfile[payloadDomain] = [settingsDict copy];
                }
            }
            
            // ---------------------------------------------------------------------
            //  Check if checkbox is in table view menu DISABLED
            // ---------------------------------------------------------------------
        } else if ( ( row < [_arrayPayloadLibrary count] ) && checkbox == [(CellViewMenuEnabled *)[_tableViewPayloadLibrary viewAtColumn:[_tableViewPayloadLibrary columnWithIdentifier:@"ColumnMenuEnabled"] row:row makeIfNecessary:NO] menuCheckbox] ) {
            
            // ---------------------------------------------------------------------
            //  Store the cell dict for move
            // ---------------------------------------------------------------------
            NSDictionary *manifestDict = [_arrayPayloadLibrary objectAtIndex:row];
            NSString *payloadDomain = manifestDict[PFCManifestKeyDomain];
            
            // ---------------------------------------------------------------------
            //  Remove the cell dict from table view menu DISABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewPayloadLibrarySelectedRow = [_tableViewPayloadLibrary selectedRow];
            [_tableViewPayloadLibrary beginUpdates];
            [_arrayPayloadLibrary removeObjectAtIndex:(NSUInteger)row];
            [_tableViewPayloadLibrary reloadData];
            [_tableViewPayloadLibrary endUpdates];
            
            // ----------------------------------------------------------------------
            //  If current cell dict wasn't selected, restore selection after reload
            // ----------------------------------------------------------------------
            if ( 0 <= tableViewPayloadLibrarySelectedRow && tableViewPayloadLibrarySelectedRow != row ) {
                NSInteger selectedRow = ( row < tableViewPayloadLibrarySelectedRow ) ? ( tableViewPayloadLibrarySelectedRow - 1 ) : tableViewPayloadLibrarySelectedRow;
                [_tableViewPayloadLibrary selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadLibrarySelectedRow:selectedRow];
            }
            
            // ---------------------------------------------------------------------
            //  Add the cell dict to table view menu ENABLED
            // ---------------------------------------------------------------------
            NSInteger tableViewPayloadProfileSelectedRow = [_tableViewPayloadProfile selectedRow];
            [_tableViewPayloadProfile beginUpdates];
            [_arrayPayloadProfile addObject:manifestDict];
            [_arrayPayloadProfile sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Title" ascending:YES]]];
            [_tableViewPayloadProfile reloadData];
            [_tableViewPayloadProfile endUpdates];
            
            // -----------------------------------------------------------------------------
            //  If item in table view ENABLED was selected, restore selection after reload
            // -----------------------------------------------------------------------------
            if ( 0 <= tableViewPayloadProfileSelectedRow && tableViewPayloadLibrarySelectedRow != row ) {
                [_tableViewPayloadProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:tableViewPayloadProfileSelectedRow] byExtendingSelection:NO];
                [self setTableViewPayloadProfileSelectedRow:tableViewPayloadProfileSelectedRow];
            }
            
            [self sortArrayPayloadProfile];
            
            // -----------------------------------------------------------------------------
            //  If current cell dict was selected, move selection to table view ENABLED
            // -----------------------------------------------------------------------------
            if ( tableViewPayloadLibrarySelectedRow == row ) {
                
                // ---------------------------------------------------------------------
                //  Deselect items in table view DISABLED
                // ---------------------------------------------------------------------
                [_tableViewPayloadLibrary deselectAll:self];
                [self setTableViewPayloadLibrarySelectedRow:-1];
                
                // ---------------------------------------------------------------------
                //  Find index of moved cell dict and select it
                // ---------------------------------------------------------------------
                NSUInteger row = [_arrayPayloadProfile indexOfObject:manifestDict];
                if ( row != NSNotFound ) {
                    [_tableViewPayloadProfile selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                    [[self window] makeFirstResponder:_tableViewPayloadProfile];
                    [self setTableViewPayloadProfileSelectedRow:row];
                    [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadProfile identifier]];
                }
                
                _settingsManifest[@"Selected"] = @YES;
            } else {
                NSMutableDictionary *settingsDict = [_settingsProfile[payloadDomain] mutableCopy] ?: [NSMutableDictionary dictionary];
                settingsDict[@"Selected"] = @YES;
                settingsDict[@"PayloadLibrary"] = @(_segmentedControlPayloadLibrarySelectedSegment);
                _settingsProfile[payloadDomain] = [settingsDict copy];
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
    NSMutableDictionary *manifestContentDict = [[_arraySettings objectAtIndex:row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
    } else {
        NSLog(@"[ERROR] No key returned from manifest dict!");
        return;
    }
    
    if (
        [[[checkbox superview] class] isSubclassOfClass:[CellViewSettingsEnabled class]]
        ) {
        if ( checkbox == [(CellViewSettingsEnabled *)[_tableViewSettings viewAtColumn:[_tableViewSettings columnWithIdentifier:@"ColumnSettingsEnabled"] row:row makeIfNecessary:NO] settingEnabled] ) {
            settingsDict[@"Enabled"] = @(state);
            _settingsManifest[identifier] = [settingsDict copy];
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
    
    _settingsManifest[identifier] = [settingsDict copy];
    
    // ---------------------------------------------------------------------
    //  Add subkeys for selected state
    // ---------------------------------------------------------------------
    if ( [self updateSubKeysForDict:manifestContentDict valueString:state ? @"True" : @"False" row:row] ) {
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
    
    NSMutableDictionary *manifestContentDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
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
        _settingsManifest[identifier] = [settingsDict copy];
        
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
    
    NSMutableDictionary *manifestContentDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
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
        _settingsManifest[identifier] = [settingsDict copy];
        
        // ---------------------------------------------------------------------
        //  Add subkeys for selected title
        // ---------------------------------------------------------------------
        if ( [self updateSubKeysForDict:manifestContentDict valueString:selectedTitle row:row] ) {
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
    
    NSMutableDictionary *manifestContentDict = [[_arraySettings objectAtIndex:(NSUInteger)row] mutableCopy];
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    
    NSMutableDictionary *settingsDict;
    if ( [identifier length] != 0 ) {
        settingsDict = [_settingsManifest[identifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
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
        NSString *prompt = manifestContentDict[PFCManifestKeyFilePrompt] ?: @"Select File";
        NSArray *allowedFileTypes = @[];
        if ( manifestContentDict[PFCManifestKeyAllowedFileTypes] != nil && [manifestContentDict[PFCManifestKeyAllowedFileTypes] isKindOfClass:[NSArray class]] ) {
            allowedFileTypes = manifestContentDict[PFCManifestKeyAllowedFileTypes] ?: @[];
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
                _settingsManifest[identifier] = [settingsDict copy];
                
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

- (NSArray *)manifestContentForMenuItem:(NSDictionary *)manifestDict {
    NSMutableArray *combinedSettings = [[NSMutableArray alloc] init];
    if ( [manifestDict count] != 0 ) {
        NSArray *settings = manifestDict[PFCManifestKeyManifestContent];
        
        for ( NSDictionary *setting in settings ) {
            NSMutableDictionary *combinedSettingDict = [setting mutableCopy];
            combinedSettingDict[@"Enabled"] = @YES;
            [combinedSettings addObject:[combinedSettingDict copy]];
        }
        
        if ( [combinedSettings count] != 0 ) {
            
            // ---------------------------------------------------------------------
            //  Add padding row to top of table view
            // ---------------------------------------------------------------------
            [combinedSettings insertObject:@{ PFCManifestKeyCellType : PFCCellTypePadding,
                                              PFCManifestKeyEnabled  : @YES } atIndex:0];
            
            // ---------------------------------------------------------------------
            //  Add padding row to end of table view
            // ---------------------------------------------------------------------
            [combinedSettings addObject:@{ PFCManifestKeyCellType : PFCCellTypePadding,
                                           PFCManifestKeyEnabled  : @YES }];
        }
    }
    return [combinedSettings copy];
} // manifestContentForMenuItem

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
#pragma mark Saving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)settingsSaved {
    
    // -------------------------------------------------------------------------
    //  Check if there's a path saved for the profile
    // -------------------------------------------------------------------------
    NSString *profilePath = _profileDict[PFCRuntimeKeyPath];
    if ( [profilePath length] == 0 ) {
        return NO;
    }
    
    // -------------------------------------------------------------------------
    //  Check if the path saved exists
    // -------------------------------------------------------------------------
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    if ( ! [profileURL checkResourceIsReachableAndReturnError:nil] ) {
        return NO;
    }
    
    // ---------------------------------------------------------------------------
    //  Check that all settings in the template on disk math the current settings
    // ---------------------------------------------------------------------------
    NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
    if ( [profileDict count] == 0 ) {
        return NO;
    } else {
        [self saveSelectedManifest];
        return [profileDict[PFCProfileTemplateKeySettings] isEqualToDictionary:_settingsProfile];
    }
} // settingsSaved

- (void)saveProfile {
    
    NSError *error = nil;
    
    // -------------------------------------------------------------------------
    //  Save the selected manifest settings before saving the profile template
    // -------------------------------------------------------------------------
    [self saveSelectedManifest];
    
    // -------------------------------------------------------------------------
    //  Create the profile template save folder if it does not exist
    // -------------------------------------------------------------------------
    NSURL *savedProfilesFolderURL = [PFCController profileCreatorFolder:kPFCFolderSavedProfiles];
    if ( ! [savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        if ( ! [[NSFileManager defaultManager] createDirectoryAtURL:savedProfilesFolderURL withIntermediateDirectories:YES attributes:nil error:&error] ) {
            // FIXME - Should notify the user here that the save folder could not be created
            NSLog(@"[ERROR] %@", [error localizedDescription]);
            return;
        }
    }
    
    // ----------------------------------------------------------------------------
    //  Get the path to this profile template, or if never saved create a new path
    // ----------------------------------------------------------------------------
    NSString *profilePath = _profileDict[PFCRuntimeKeyPath];
    if ( [profilePath length] == 0 ) {
        profilePath = [PFCController newProfilePath];
    }
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    
    
    NSMutableDictionary *profileDict = [_profileDict mutableCopy];
    NSMutableDictionary *configurationDict = [_profileDict[@"Config"] mutableCopy];
    
    // ---------------------------------------------------------------------------------
    //  Verify all domains have a saved UUID to reuse if updating the profie
    //  This way the updated profile gets updated (overwritten) instead of added as new
    // ---------------------------------------------------------------------------------
    NSMutableDictionary *settingsProfile = [_settingsProfile mutableCopy];
    for ( NSString *domain in [settingsProfile allKeys] ) {
        if ( [settingsProfile[domain][PFCProfileTemplateKeyUUID] length] == 0 ) {
            NSMutableDictionary *settingsManifest = [settingsProfile[domain] mutableCopy];
            settingsManifest[PFCProfileTemplateKeyUUID] = [[NSUUID UUID] UUIDString];
            settingsProfile[domain] = [settingsManifest copy];
        }
    }
    
    [self setSettingsProfile:[settingsProfile mutableCopy]];
    configurationDict[PFCProfileTemplateKeyName] = _profileName ?: @"";
    configurationDict[PFCProfileTemplateKeySettings] = [settingsProfile copy];
    
    // ---------------------------------------------------------------------------------
    //  Write the profile template to disk and update
    // ---------------------------------------------------------------------------------
    if ( [configurationDict writeToURL:profileURL atomically:YES] ) {
        profileDict[@"Config"] = [configurationDict copy];
        [self setProfileDict:[profileDict copy]];
        // FIXME - Should update the profile dict stored in PFCController with a delegate call
    } else {
        // FIXME - Should notify the user that the save failed!
        NSLog(@"[ERROR] Saving profile template failed!");
    }
} // saveProfile

- (void)saveSelectedManifest {
    
    if ( [_selectedPayloadTableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadProfile] ) {
        
        // ---------------------------------------------------------------------
        //  Save current settings in manifest dict
        // ---------------------------------------------------------------------
        if ( 0 <= _tableViewPayloadProfileSelectedRow && _tableViewPayloadProfileSelectedRow <= [_arrayPayloadProfile count] ) {
            NSMutableDictionary *manifestDict = [[_arrayPayloadProfile objectAtIndex:_tableViewPayloadProfileSelectedRow] mutableCopy];
            if ( [_settingsManifest count] != 0 ) {
                NSString *manifestDomain = manifestDict[PFCManifestKeyDomain];
                if ( [manifestDomain length] != 0 ) {
                    _settingsProfile[manifestDomain] = [_settingsManifest copy];
                } else {
                    NSLog(@"[ERROR] No domain found for manifest when saving current selection");
                }
            }
        }
    } else if ( [_selectedPayloadTableViewIdentifier isEqualToString:PFCTableViewIdentifierPayloadLibrary] ) {
        
        // ---------------------------------------------------------------------
        //  Save current settings in manifest dict
        // ---------------------------------------------------------------------
        if ( 0 <= _tableViewPayloadLibrarySelectedRow ) {
            
            // ---------------------------------------------------------------------------------------------------------------
            //  Check what segment the currently selected manifest belongs to.
            //  If not the currently selected segment, read the manifest from the manifest's segment's array
            // ---------------------------------------------------------------------------------------------------------------
            NSMutableArray *selectedSegmentArray;
            if ( _tableViewPayloadLibrarySelectedRowSegment == [_segmentedControlPayloadLibrary selectedSegment] ) {
                selectedSegmentArray = _arrayPayloadLibrary;
            } else {
                selectedSegmentArray = [self arrayForPayloadLibrary:_tableViewPayloadLibrarySelectedRowSegment];
            }
            
            if ( _tableViewPayloadLibrarySelectedRowSegment <= [selectedSegmentArray count] ) {
                NSMutableDictionary *manifestDict = [[selectedSegmentArray objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
                if ( [_settingsManifest count] != 0 ) {
                    NSString *manifestDomain = manifestDict[PFCManifestKeyDomain];
                    if ( [manifestDomain length] != 0 ) {
                        _settingsProfile[manifestDomain] = [_settingsManifest copy];
                    } else {
                        NSLog(@"[ERROR] No domain found for manifest when saving current selection");
                    }
                }
            }
        }
    }
} // saveSelectedManifest

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showSettingsHeader {
    [_constraintSettingsHeaderHeight setConstant:47.0f];
    [self setSettingsHeaderHidden:NO];
} // showSettingsHeader

- (void)hideSettingsHeader {
    [_constraintSettingsHeaderHeight setConstant:0.0f];
    [self setSettingsHeaderHidden:YES];
} // hideSettingsHeader

- (void)showPayloadHeader {
    [_constraintPayloadHeaderHeight setConstant:47.0f];
    [self setPayloadHeaderHidden:NO];
} // showPayloadHeader

- (void)hidePayloadHeader {
    [_constraintPayloadHeaderHeight setConstant:0.0f];
    [self setPayloadHeaderHidden:NO];
} // hidePayloadHeader

- (void)showPayloadFooter {
    [self setPayloadLibraryCollapsed:YES];
    [_viewPayloadFooterSearch setHidden:NO];
    [_linePayloadLibraryMenuTop setHidden:NO];
    [_linePayloadLibraryMenuBottom setHidden:NO];
    [self insertSubview:_viewPayloadLibraryMenu inSuperview:_viewPayloadLibraryMenuSuperview hidden:NO];
} // showPayloadFooter

- (void)hidePayloadFooter {
    [self setPayloadLibraryCollapsed:YES];
    [_viewPayloadFooterSearch setHidden:YES];
    [_linePayloadLibraryMenuTop setHidden:YES];
    [_linePayloadLibraryMenuBottom setHidden:YES];
    [self insertSubview:_viewPayloadLibraryMenu inSuperview:_viewPayloadFooterSuperview hidden:NO];
} // hidePayloadFooter

- (void)showSettingsError {
    [self setSettingsErrorHidden:NO];
    [_viewSettingsSuperView setHidden:YES];
    [_viewSettingsError setHidden:NO];
} // showSettingsError

- (void)hideSettingsError {
    [self setSettingsErrorHidden:YES];
    [_viewSettingsError setHidden:YES];
    [_viewSettingsSuperView setHidden:NO];
} // hideSettingsError

- (void)showSearchNoMatches {
    [self setSearchNoMatchesHidden:NO];
    [_viewPayloadLibraryNoMatches setHidden:NO];
    [_viewPayloadLibraryScrollView setHidden:YES];
} // showSearchNoMatches

- (void)hideSearchNoMatches {
    [self setSearchNoMatchesHidden:YES];
    [_viewPayloadLibraryNoMatches setHidden:YES];
    [_viewPayloadLibraryScrollView setHidden:NO];
} // hideSearchNoMatches

- (void)collapsePayloadLibrary {
    // FIXME - Write this for when opening an imported profile or locally installed profile
} // collapsePayloadLibrary

- (void)uncollapsePayloadLibrary {
    
    // -------------------------------------------------------------------------
    //  Get the instances, frames and sizes of the subviews
    // -------------------------------------------------------------------------
    NSView *profilePayloads  = [[_splitViewPayload subviews] objectAtIndex:0];
    NSRect profilePayloadsFrame = [profilePayloads frame];
    
    NSView *payloadLibrary = [[_splitViewPayload subviews] objectAtIndex:1];
    NSRect payloadLibraryFrame = [payloadLibrary frame];
    
    CGFloat dividerThickness = [_splitViewPayload dividerThickness];
    
    // -------------------------------------------------------------------------
    //  Calculate new sizes for the subviews
    // -------------------------------------------------------------------------
    profilePayloadsFrame.size.height = ( profilePayloadsFrame.size.height - payloadLibraryFrame.size.height - dividerThickness );
    payloadLibraryFrame.origin.x = profilePayloadsFrame.size.height + dividerThickness;
    
    // -------------------------------------------------------------------------
    //  Set new sizes
    // -------------------------------------------------------------------------
    [profilePayloads setFrameSize:profilePayloadsFrame.size];
    [payloadLibrary setFrame:payloadLibraryFrame];
    
    // -------------------------------------------------------------------------
    //  Update the UI
    // -------------------------------------------------------------------------
    [payloadLibrary setHidden:NO];
    [_splitViewPayload display];
    
    // -------------------------------------------------------------------------
    //  Update the property
    // -------------------------------------------------------------------------
    [self setPayloadLibraryCollapsed:NO];
} // uncollapsePayloadLibrary

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
    if ( [_profileDict[@"Config"][PFCProfileTemplateKeyName] isEqualToString:PFCDefaultProfileName] ) {
        
        // -------------------------------------------------------------------------
        //  Populate sheet with the current name, and disable the save button
        //  When typing the save button state is handled in -controlTextDidChange
        // -------------------------------------------------------------------------
        [_buttonSaveSheetProfileName setEnabled:NO];
        [_textFieldSheetProfileName setStringValue:PFCDefaultProfileName];
        
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
        [_parentObject renameProfileWithName:PFCDefaultProfileName newName:[_textFieldSheetProfileName stringValue]];
        
        // -----------------------------------------------------------------------------------------
        //  Update the profile dict stored in this window controller with the same name
        // -----------------------------------------------------------------------------------------
        NSMutableDictionary *profileDict = [_profileDict mutableCopy];
        NSMutableDictionary *configDict = [_profileDict[@"Config"] mutableCopy];
        configDict[PFCProfileTemplateKeyName] = [_textFieldSheetProfileName stringValue];
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

- (IBAction)selectTableViewPayloadProfile:(id)sender {
    
    // -----------------------------------------------------------------------------------
    //  Save the selected manifest settings before changing manifest in the settings view
    // -----------------------------------------------------------------------------------
    [self saveSelectedManifest];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewPayloadLibrary deselectAll:self];
    [self setTableViewPayloadLibrarySelectedRow:-1];
    [self setTableViewPayloadProfileSelectedRow:[_tableViewPayloadProfile selectedRow]];
    
    [_tableViewSettings beginUpdates];
    [_arraySettings removeAllObjects];
    
    // ----------------------------------------------------------------------------------------
    //  If selection is within the table view, update the settings view. Else leave it empty
    // ----------------------------------------------------------------------------------------
    if ( 0 <= _tableViewPayloadProfileSelectedRow && _tableViewPayloadProfileSelectedRow <= [_arrayPayloadProfile count] ) {
        
        // ------------------------------------------------------------------------------------
        //  Update the SelectedTableViewIdentifier with the current TableView identifier
        // ------------------------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:[_tableViewPayloadProfile identifier]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current settings from the saved settings dict (by using the payload domain)
        // ------------------------------------------------------------------------------------
        NSMutableDictionary *manifestDict = [[_arrayPayloadProfile objectAtIndex:_tableViewPayloadProfileSelectedRow] mutableCopy];
        [self setSettingsManifest:[_settingsProfile[manifestDict[PFCManifestKeyDomain] ?: @""] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current manifest content dict array from the selected manifest
        //  If the manifest content dict array is empty, show "Error Reading Settings"
        // ------------------------------------------------------------------------------------
        NSArray *manifestContentArray = [self manifestContentForMenuItem:_arrayPayloadProfile[_tableViewPayloadProfileSelectedRow]];
        if ( [manifestContentArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[manifestContentArray copy]];
            [_viewSettingsError setHidden:YES];
            [_textFieldSettingsHeaderTitle setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];
            NSImage *icon = [PFCManifestTools iconForManifest:manifestDict];
            if ( icon ) {
                [_imageViewSettingsHeaderIcon setImage:icon];
            }
            
            if ( _settingsHeaderHidden ) {
                [self showSettingsHeader];
            }
            
            if ( ! _settingsErrorHidden ) {
                [self hideSettingsError];
            }
        } else {
            if ( ! _settingsHeaderHidden ) {
                [self hideSettingsHeader];
            }
            
            if ( _settingsErrorHidden ) {
                [self showSettingsError];
            }
        }
    } else {
        if ( ! _settingsHeaderHidden ) {
            [self hideSettingsHeader];
        }
        
        if ( ! _settingsErrorHidden ) {
            [self hideSettingsError];
        }
        
        // ---------------------------------------------------------------------
        //  Unset the SelectedTableViewIdentifier
        // ---------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:nil];
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
} // selectTableViewPayloadProfile

- (IBAction)selectTableViewPayloadLibrary:(id)sender {
    
    // -----------------------------------------------------------------------------------
    //  Save the selected manifest settings before changing manifest in the settings view
    // -----------------------------------------------------------------------------------
    [self saveSelectedManifest];
    
    // -------------------------------------------------------------------------
    //  Update the selection properties with the current value
    // -------------------------------------------------------------------------
    [_tableViewPayloadProfile deselectAll:self];
    [self setTableViewPayloadProfileSelectedRow:-1];
    [self setTableViewPayloadLibrarySelectedRow:[_tableViewPayloadLibrary selectedRow]];
    [self setTableViewPayloadLibrarySelectedRowSegment:[_segmentedControlPayloadLibrary selectedSegment]];
    
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
        NSMutableDictionary *manifestDict = [[_arrayPayloadLibrary objectAtIndex:_tableViewPayloadLibrarySelectedRow] mutableCopy];
        [self setSettingsManifest:[_settingsProfile[manifestDict[PFCManifestKeyDomain] ?: @""] mutableCopy] ?: [[NSMutableDictionary alloc] init]];
        
        // ------------------------------------------------------------------------------------
        //  Load the current manifest content dict array from the selected manifest
        //  If the manifest content dict array is empty, show "Error Reading Settings"
        // ------------------------------------------------------------------------------------
        NSArray *manifestContentArray = [self manifestContentForMenuItem:_arrayPayloadLibrary[_tableViewPayloadLibrarySelectedRow]];
        if ( [manifestContentArray count] != 0 ) {
            [_arraySettings addObjectsFromArray:[manifestContentArray copy]];
            [_viewSettingsError setHidden:YES];
            [_textFieldSettingsHeaderTitle setStringValue:manifestDict[PFCManifestKeyTitle] ?: @""];
            NSImage *icon = [PFCManifestTools iconForManifest:manifestDict];
            if ( icon ) {
                [_imageViewSettingsHeaderIcon setImage:icon];
            }
            
            if ( _settingsHeaderHidden ) {
                [self showSettingsHeader];
            }
            
            if ( ! _settingsErrorHidden ) {
                [self hideSettingsError];
            }
        } else {
            if ( ! _settingsHeaderHidden ) {
                [self hideSettingsHeader];
            }
            
            if ( _settingsErrorHidden ) {
                [self showSettingsError];
            }
        }
    } else {
        if ( ! _settingsHeaderHidden ) {
            [self hideSettingsHeader];
        }
        
        if ( ! _settingsErrorHidden ) {
            [self hideSettingsError];
        }
        
        // ---------------------------------------------------------------------
        //  Unset the SelectedTableViewIdentifier
        // ---------------------------------------------------------------------
        [self setSelectedPayloadTableViewIdentifier:nil];
        
    }
    
    [_tableViewSettings reloadData];
    [_tableViewSettings endUpdates];
} // selectTableViewPayloadLibrary

- (IBAction)selectSegmentedControlPayloadLibrary:(id)sender {
    
    // -------------------------------------------------------------------------
    //  If the payload library is collapsed, open it
    // -------------------------------------------------------------------------
    if ( _payloadLibraryCollapsed ) {
        [self uncollapsePayloadLibrary];
    }
    
    NSInteger selectedSegment = [_segmentedControlPayloadLibrary selectedSegment];
    
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
        [_searchFieldPayloadLibrary setStringValue:[self searchStringForPayloadLibrary:selectedSegment] ?: @""];
        [self searchFieldPayloadLibrary:nil];
    } else {
        if ( ! _searchNoMatchesHidden ) {
            [self hideSearchNoMatches];
        }
        [_searchFieldPayloadLibrary setStringValue:@""];
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

- (IBAction)searchFieldPayloadLibrary:(id)sender {
    
    // -------------------------------------------------------------------------------------------------
    //  Check if this is the beginning of a search, if so save the complete array before removing items
    // -------------------------------------------------------------------------------------------------
    if ( ! [self isSearchingPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment] ) {
        [self setIsSearchingPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment isSearching:YES];
        [self saveArray:_arrayPayloadLibrary forPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
    }
    
    NSString *searchString = [_searchFieldPayloadLibrary stringValue];
    [_tableViewPayloadLibrary beginUpdates];
    if ( ! [searchString length] ) {
        
        // ---------------------------------------------------------------------
        //  If user pressed (x) or deleted the search, restore the whole array
        // ---------------------------------------------------------------------
        [self restoreSearchForPayloadLibrary:_segmentedControlPayloadLibrarySelectedSegment];
        
        if ( ! _searchNoMatchesHidden ) {
            [self hideSearchNoMatches];
        }
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
        
        // ------------------------------------------------------------------------
        //  If no matches were found, show text "No Matches" in payload library
        // ------------------------------------------------------------------------
        if ( [matchedObjects count] == 0 && _searchNoMatchesHidden ) {
            [self showSearchNoMatches];
        } else if ( [matchedObjects count] != 0 && ! _searchNoMatchesHidden ) {
            [self hideSearchNoMatches];
        }
    }
    
    [_tableViewPayloadLibrary reloadData];
    [_tableViewPayloadLibrary endUpdates];
} // searchFieldPayloadLibrary

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
#pragma mark Payload Context Menu
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
    //  Remove this menu item unless runtime key 'PlistPath' is set in the manifest
    // -------------------------------------------------------------------------------
    NSMenuItem *menuItemShowOriginalInFinder = [menu itemWithTitle:@"Show Original In Finder"];
    if ( [manifestDict[PFCRuntimeKeyPlistPath] length] != 0 ) {
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
    if ( [manifestDict[PFCRuntimeKeyPlistPath] length] != 0 ) {
        NSError *error = nil;
        NSString *filePath = manifestDict[PFCRuntimeKeyPlistPath] ?: @"";
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