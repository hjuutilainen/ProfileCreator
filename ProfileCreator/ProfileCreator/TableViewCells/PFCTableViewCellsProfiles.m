//
//  PFCTableViewCellsProfiles.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-03.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsProfiles.h"

@implementation PFCTableViewCellsProfiles
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewProfile

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewProfile *)populateCellViewProfile:(CellViewProfile *)cellView profileDict:(NSDictionary *)profileDict row:(NSInteger)row {
    
    NSDictionary *profileSettingsDict = profileDict[@"Dict"];
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:profileSettingsDict[@"Name"] ?: @""];
    
    return cellView;
} // populateCellViewMenu:menuDict:row

@end
