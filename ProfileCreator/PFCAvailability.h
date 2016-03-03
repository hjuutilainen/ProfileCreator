//
//  PFCAvailability.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-03.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCAvailability : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedInstance;

- (BOOL)showManifest:(NSDictionary *)manifest displayKeys:(NSDictionary *)displayKeys;
- (BOOL)requiredForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys;
- (BOOL)requiredHostForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys;
- (BOOL)requiredPortForManifestContentDict:(NSDictionary *)manifestContentDict displayKeys:(NSDictionary *)displayKeys;

@end
