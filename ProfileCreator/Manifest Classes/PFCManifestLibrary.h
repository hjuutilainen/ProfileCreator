//
//  PFCManifestLibrary.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-31.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PFCPayloadLibrary) {
    kPFCPayloadLibraryApple = 0,
    kPFCPayloadLibraryUserPreferences,
    kPFCPayloadLibraryLibraryPreferences,
    kPFCPayloadLibraryCustom
};

@interface PFCManifestLibrary : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedLibrary;

// -----------------------------------------------------------------------------
//  Cache properties
// -----------------------------------------------------------------------------
@property NSArray *cachedLibraryApple;
@property NSArray *cachedLibraryUserLibraryPreferencesLocal;
@property NSArray *cachedLibraryLibraryPreferencesLocal;
@property NSMutableDictionary *cachedLocalSettings;

// -----------------------------------------------------------------------------
//  Library Methods
// -----------------------------------------------------------------------------
- (NSArray *)libraryApple:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryUserLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSDictionary *)manifestFromLibrary:(PFCPayloadLibrary)library withDomain:(NSString *)domain;

@end
