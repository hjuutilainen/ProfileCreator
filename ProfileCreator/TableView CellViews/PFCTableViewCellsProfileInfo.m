//
//  PFCTableViewCellsProfileInfo.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-18.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCTableViewCellsProfileInfo.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPayloadInfoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewPayloadInfoTitle

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewPayloadInfoTitle *)populateCellViewPayloadInfoTitle:(CellViewPayloadInfoTitle *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:infoDict[@"Title"] ?: @""];

    return cellView;
} // populateCellViewPayloadInfoTitle:infoDict:row

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPayloadInfoValue
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation CellViewPayloadInfoValue

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (CellViewPayloadInfoValue *)populateCellViewPayloadInfoValue:(CellViewPayloadInfoValue *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView textField] setStringValue:infoDict[@"Value"] ?: @""];

    return cellView;
} // populateCellViewPayloadInfoValue:infoDict:row

@end