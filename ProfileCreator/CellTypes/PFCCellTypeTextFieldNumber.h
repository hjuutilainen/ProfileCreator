//
//  PFCCellTypeTextFieldNumber.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTextFieldNumberCellView : NSTableCellView

- (PFCTextFieldNumberCellView *)populateCellView:(PFCTextFieldNumberCellView *)cellView
                                        manifest:(NSDictionary *)manifest
                                        settings:(NSDictionary *)settings
                                   settingsLocal:(NSDictionary *)settingsLocal
                                     displayKeys:(NSDictionary *)displayKeys
                                             row:(NSInteger)row
                                          sender:(id)sender;

@end

@interface PFCTextFieldNumberLeftCellView : NSTableCellView

- (PFCTextFieldNumberLeftCellView *)populateCellView:(PFCTextFieldNumberLeftCellView *)cellView
                                            manifest:(NSDictionary *)manifest
                                            settings:(NSDictionary *)settings
                                       settingsLocal:(NSDictionary *)settingsLocal
                                         displayKeys:(NSDictionary *)displayKeys
                                                 row:(NSInteger)row
                                              sender:(id)sender;

@end
