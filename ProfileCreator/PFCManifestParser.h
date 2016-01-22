//
//  PFCManifestParser.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-22.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCManifestParser : NSObject

// -------------------------------------------------------------
//  Class Methods
// -------------------------------------------------------------
+ (id)sharedParser;

- (NSArray *)arrayForManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal;
- (NSArray *)arrayForManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys;

@end
