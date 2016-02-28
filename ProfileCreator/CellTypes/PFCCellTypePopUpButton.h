//
//  PFCCellTypePopUpButton.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCPopUpButtonCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonCellView *)populateCellView:(PFCPopUpButtonCellView *)cellView
                                    manifest:(NSDictionary *)manifest
                                    settings:(NSDictionary *)settings
                               settingsLocal:(NSDictionary *)settingsLocal
displayKeys:(NSDictionary *)displayKeys
                                         row:(NSInteger)row
                                      sender:(id)sender;

@end

@interface PFCPopUpButtonLeftCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonLeftCellView *)populateCellView:(PFCPopUpButtonLeftCellView *)cellView
                                        manifest:(NSDictionary *)manifest
                                        settings:(NSDictionary *)settings
                                   settingsLocal:(NSDictionary *)settingsLocal
displayKeys:(NSDictionary *)displayKeys
                                             row:(NSInteger)row
                                          sender:(id)sender;

@end

@interface PFCPopUpButtonNoTitleCellView : NSTableCellView

@property (weak) IBOutlet NSPopUpButton *settingPopUpButton;

- (PFCPopUpButtonNoTitleCellView *)populateCellView:(PFCPopUpButtonNoTitleCellView *)cellView
                                           manifest:(NSDictionary *)manifest
                                           settings:(NSDictionary *)settings
                                      settingsLocal:(NSDictionary *)settingsLocal
displayKeys:(NSDictionary *)displayKeys
                                                row:(NSInteger)row
                                             sender:(id)sender;

@end