//
//  PFCProfileUtility.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-07.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCProfileUtility : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedUtility;

// -----------------------------------------------------------------------------
//  Utility Methods
// -----------------------------------------------------------------------------
- (NSArray *)profiles;
- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs;
- (NSDictionary *)profileWithUUID:(NSString *)profileUUID;

@end
