//
//  PFCCellTypeDatePicker.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCDatePickerCellView : NSTableCellView

@property (weak) IBOutlet NSDatePicker *settingDatePicker;

- (PFCDatePickerCellView *)populateCellView:(PFCDatePickerCellView *)cellView
                                   manifest:(NSDictionary *)manifest
                                   settings:(NSDictionary *)settings
                              settingsLocal:(NSDictionary *)settingsLocal
                                displayKeys:(NSDictionary *)displayKeys
                                        row:(NSInteger)row
                                     sender:(id)sender;

@end

@interface PFCDatePickerNoTitleCellView : NSTableCellView

@property (weak) IBOutlet NSDatePicker *settingDatePicker;
@property (weak) IBOutlet NSTextField *settingDateDescription;

- (PFCDatePickerNoTitleCellView *)populateCellView:(PFCDatePickerNoTitleCellView *)cellView
                                          manifest:(NSDictionary *)manifest
                                          settings:(NSDictionary *)settings
                                     settingsLocal:(NSDictionary *)settingsLocal
                                       displayKeys:(NSDictionary *)displayKeys
                                               row:(NSInteger)row
                                            sender:(id)sender;

@end
