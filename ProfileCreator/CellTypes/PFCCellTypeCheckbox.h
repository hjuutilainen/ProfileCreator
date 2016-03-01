//
//  PFCCellTypeCheckbox.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCCheckboxCellView : NSTableCellView

- (PFCCheckboxCellView *)populateCellView:(PFCCheckboxCellView *)cellView
                                 manifest:(NSDictionary *)manifest
                                 settings:(NSDictionary *)settings
                            settingsLocal:(NSDictionary *)settingsLocal
                              displayKeys:(NSDictionary *)displayKeys
                                      row:(NSInteger)row
                                   sender:(id)sender;

@end

@interface PFCCheckboxNoDescriptionCellView : NSTableCellView

- (PFCCheckboxNoDescriptionCellView *)populateCellView:(PFCCheckboxNoDescriptionCellView *)cellView
                                              manifest:(NSDictionary *)manifest
                                              settings:(NSDictionary *)settings
                                         settingsLocal:(NSDictionary *)settingsLocal
                                           displayKeys:(NSDictionary *)displayKeys
                                                   row:(NSInteger)row
                                                sender:(id)sender;

@end