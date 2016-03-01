//
//  PFCCellTypeTextFieldHostPort.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTextFieldHostPortCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *settingTextFieldHost;
@property (weak) IBOutlet NSTextField *settingTextFieldPort;

- (PFCTextFieldHostPortCellView *)populateCellView:(PFCTextFieldHostPortCellView *)cellView
                                          manifest:(NSDictionary *)manifest
                                          settings:(NSDictionary *)settings
                                     settingsLocal:(NSDictionary *)settingsLocal
                                       displayKeys:(NSDictionary *)displayKeys
                                               row:(NSInteger)row
                                            sender:(id)sender;

- (void)showRequired:(BOOL)show;

@end

@interface PFCTextFieldHostPortCheckboxCellView : NSTableCellView

@property (weak) IBOutlet NSButton *settingCheckbox;
@property (weak) IBOutlet NSTextField *settingTextFieldHost;
@property (weak) IBOutlet NSTextField *settingTextFieldPort;

- (PFCTextFieldHostPortCheckboxCellView *)populateCellView:(PFCTextFieldHostPortCheckboxCellView *)cellView
                                                  manifest:(NSDictionary *)manifest
                                                  settings:(NSDictionary *)settings
                                             settingsLocal:(NSDictionary *)settingsLocal
                                               displayKeys:(NSDictionary *)displayKeys
                                                       row:(NSInteger)row
                                                    sender:(id)sender;

@end