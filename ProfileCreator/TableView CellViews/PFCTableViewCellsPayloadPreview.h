//
//  PFCTableViewCellsPayloadPreview.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-14.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewInfoTitle : NSTableCellView
- (CellViewInfoTitle *)populateCellViewInfoTitle:(CellViewInfoTitle *)cellView infoDict:(NSDictionary *)infoDict row:(NSInteger)row;
@end
