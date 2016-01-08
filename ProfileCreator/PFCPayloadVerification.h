//
//  PFCPayloadVerification.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCPayloadVerification : NSObject

+ (id)sharedInstance;
- (NSDictionary *)verifyManifest:(NSArray *)manifestArray settingsDict:(NSDictionary *)settingsDict;
- (NSDictionary *)verifyCellDict:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict;

@end
