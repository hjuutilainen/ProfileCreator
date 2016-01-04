//
//  PFCTableViewCellsProfiles.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-03.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTableViewCellsProfiles : NSObject
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellViewProfile
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface CellViewProfile : NSTableCellView
- (CellViewProfile *)populateCellViewProfile:(CellViewProfile *)cellView profileDict:(NSDictionary *)profileDict row:(NSInteger)row;
@end
