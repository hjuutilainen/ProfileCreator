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
    kPFCPayloadLibraryCustom,
    kPFCPayloadLibraryAll,
    kPFCPayloadLibraryLibraryPreferences,
    kPFCPayloadLibraryMCX
};

@interface PFCManifestLibrary : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedLibrary;

// -----------------------------------------------------------------------------
//  Cache properties
// -----------------------------------------------------------------------------
@property NSArray *cachedLibraryAll;
@property NSArray *cachedLibraryApple;
@property NSArray *cachedLibraryUserLibraryPreferencesLocal;
@property NSArray *cachedLibraryLibraryPreferencesLocal;
@property NSArray *cachedLibraryCustom;
@property NSArray *cachedLibraryMCX;
@property NSMutableDictionary *cachedLocalSettings;

// -----------------------------------------------------------------------------
//  Library Methods
// -----------------------------------------------------------------------------
- (NSArray *)libraryApple:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryUserLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryCustom:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryMCX:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSDictionary *)manifestFromLibrary:(PFCPayloadLibrary)library withDomain:(NSString *)domain;
- (NSArray *)manifestsWithDomains:(NSArray *)domains;

@end
