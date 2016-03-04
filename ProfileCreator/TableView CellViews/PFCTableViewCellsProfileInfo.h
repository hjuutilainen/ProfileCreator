//
//  PFCTableViewCellsProfileInfo.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-18.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPayloadInfoTitle
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewPayloadInfoTitle : NSTableCellView
- (CellViewPayloadInfoTitle *)populateCellViewPayloadInfoTitle:(CellViewPayloadInfoTitle *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewPayloadInfoValue
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewPayloadInfoValue : NSTableCellView
- (CellViewPayloadInfoValue *)populateCellViewPayloadInfoValue:(CellViewPayloadInfoValue *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row;
@end
