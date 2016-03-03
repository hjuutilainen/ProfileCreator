//
//  PFCCellTypes.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCCellTypes : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedInstance;

// -----------------------------------------------------------------------------
//  Instance Methods
// -----------------------------------------------------------------------------
- (CGFloat)rowHeightForCellType:(NSString *)cellType;

- (NSView *)cellViewForCellType:(NSString *)cellType
                      tableView:(NSTableView *)tableView
            manifestContentDict:(NSDictionary *)manifestContentDict
               userSettingsDict:(NSDictionary *)userSettingsDict
              localSettingsDict:(NSDictionary *)localSettingsDict
                    displayKeys:(NSDictionary *)displayKeys
                            row:(NSInteger)row
                         sender:(id)sender;

@end
