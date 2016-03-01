//
//  PFCCellTypeTableView.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTableViewCellView : NSTableCellView <NSTableViewDataSource, NSTableViewDelegate>

- (IBAction)segmentedControlButton:(id)sender;
- (void)popUpButtonSelection:(id)sender;
- (void)checkbox:(NSButton *)checkbox;

- (PFCTableViewCellView *)populateCellView:(PFCTableViewCellView *)cellView
                                  manifest:(NSDictionary *)manifest
                                  settings:(NSDictionary *)settings
                             settingsLocal:(NSDictionary *)settingsLocal
                               displayKeys:(NSDictionary *)displayKeys
                                       row:(NSInteger)row
                                    sender:(id)sender;

@end
