//
//  PFCTableViewCellsPayloadPreview.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-14.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsPayloadPreview.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewInfoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewInfoTitle *)populateCellViewInfoTitle:(CellViewInfoTitle *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row {
        
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:infoDict[@"Title"] ?: @""];
    
    return cellView;
} // populateCellViewMenu:menuDict:row

@end
