//
//  PFCCellTypeTextField.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTextFieldCellView : NSTableCellView

- (PFCTextFieldCellView *)populateCellView:(PFCTextFieldCellView *)cellView
                                  manifest:(NSDictionary *)manifest
                                  settings:(NSDictionary *)settings
                             settingsLocal:(NSDictionary *)settingsLocal
                               displayKeys:(NSDictionary *)displayKeys
                                       row:(NSInteger)row
                                    sender:(id)sender;

- (void)showRequired:(BOOL)show;

@end

@interface PFCTextFieldCheckboxCellView : NSTableCellView

@property (weak) IBOutlet NSButton *settingCheckbox;

- (PFCTextFieldCheckboxCellView *)populateCellView:(PFCTextFieldCheckboxCellView *)cellView
                                          manifest:(NSDictionary *)manifest
                                          settings:(NSDictionary *)settings
                                     settingsLocal:(NSDictionary *)settingsLocal
                                       displayKeys:(NSDictionary *)displayKeys
                                               row:(NSInteger)row
                                            sender:(id)sender;

@end

@interface PFCTextFieldNoTitleCellView : NSTableCellView

- (PFCTextFieldNoTitleCellView *)populateCellView:(PFCTextFieldNoTitleCellView *)cellView
                                         manifest:(NSDictionary *)manifest
                                         settings:(NSDictionary *)settings
                                    settingsLocal:(NSDictionary *)settingsLocal
                                      displayKeys:(NSDictionary *)displayKeys
                                              row:(NSInteger)row
                                           sender:(id)sender;

- (void)showRequired:(BOOL)show;

@end
