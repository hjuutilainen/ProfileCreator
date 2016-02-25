//
//  PFCCellTypeFile.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCFileCellView : NSTableCellView

@property (weak) IBOutlet NSButton *settingButtonAdd;

- (PFCFileCellView *)populateCellView:(PFCFileCellView *)cellView
                             manifest:(NSDictionary *)manifest
                             settings:(NSDictionary *)settings
                        settingsLocal:(NSDictionary *)settingsLocal
                                  row:(NSInteger)row
                               sender:(id)sender;

@end
