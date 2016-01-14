//
//  PFCManifestCreationParser.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-17.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCManifestCreationParser : NSObject

+ (NSDictionary *)manifestForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary **)settingsDict;
+ (NSString *)typeStringFromValue:(id)value;

@end
