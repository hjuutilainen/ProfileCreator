//
//  PFCCellTypeTextView.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-24.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTextViewCellView : NSTableCellView

- (PFCTextViewCellView *)populateCellView:(PFCTextViewCellView *)cellView
                                 manifest:(NSDictionary *)manifest
                                 settings:(NSDictionary *)settings
                            settingsLocal:(NSDictionary *)settingsLocal
                                      row:(NSInteger)row
                                   sender:(id)sender;

- (void)showRequired:(BOOL)show;

@end