//
//  PFCTableViewCellsSettingsTableView.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-13.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTableViewCellsSettingsTableView : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewTextField
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewTextField : NSTableCellView
- (CellViewTextField *)populateCellViewTextField:(CellViewTextField *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPopUpButton
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
@interface CellViewPopUpButton : NSTableCellView
@property (weak) IBOutlet NSPopUpButton *popUpButton;
- (CellViewPopUpButton *)populateCellViewPopUpButton:(CellViewPopUpButton *)cellView settingDict:(NSDictionary *)settingDict row:(NSInteger)row sender:(id)sender;
@end