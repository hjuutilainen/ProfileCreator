//
//  PFCProfileUtility.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCProfileUtility.h"

@interface PFCProfileUtility ()

@property NSMutableDictionary *profilesDict; // All

@property NSMutableArray *arraySavedProfiles;
@property NSMutableDictionary *dictSavedProfiles;

@property NSMutableArray *arrayUnsavedProfiles;
@property NSMutableDictionary *dictUnsavedProfiles;

@property NSDate *savedProfilesModificationDate;
@property NSURL *savedProfilesFolderURL;

@end

@implementation PFCProfileUtility

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedUtility {
    static PFCProfileUtility *sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
      sharedUtility = [[self alloc] init];
    });
    return sharedUtility;
} // sharedUtility

- (id)init {
    self = [super init];
    if (self) {
        _profilesDict = [[NSMutableDictionary alloc] init];
        _arraySavedProfiles = [[NSMutableArray alloc] init];
        _arrayUnsavedProfiles = [[NSMutableArray alloc] init];
        _dictSavedProfiles = [[NSMutableDictionary alloc] init];
        _dictUnsavedProfiles = [[NSMutableDictionary alloc] init];
        _savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)savedProfileURLs {
    if (!_savedProfilesFolderURL) {
        [self setSavedProfilesFolderURL:[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles]];
    }

    if (![_savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil]) {
        return @[];
    } else {
        NSArray *savedProfilesContent =
            [NSFileManager.defaultManager contentsOfDirectoryAtURL:_savedProfilesFolderURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

        return [savedProfilesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pathExtension == '%@'", PFCProfileTemplateExtension]]];
    }
} // savedProfileURLs

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return All Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profiles {
    if (![self shouldUpdateProfileCache]) {
        return [self allProfiles];
    } else {
        [self updateProfileCache];
        return [self allProfiles];
    }
} // profiles

- (NSDate *)savedProfilesFolderModificationDate {
    if (!_savedProfilesFolderURL) {
        [self setSavedProfilesFolderURL:[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles]];
    }

    NSError *error = nil;
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:_savedProfilesFolderURL.path ?: @"" error:&error];
    if (attributes.count != 0) {
        return (NSDate *)attributes[NSFileModificationDate];
    } else {
        DDLogError(@"%@", error.localizedDescription);
    }
    return nil;
}

- (BOOL)shouldUpdateProfileCache {

    // FIXME -  Don't know if checking modification date of save folder is the best way of determining to return cache for this data.
    //          Am happy for better ideas.

    NSDate *modificationDate = [self savedProfilesFolderModificationDate];
    if (modificationDate) {
        if (_savedProfilesModificationDate) {
            if ([modificationDate isEqualToDate:_savedProfilesModificationDate]) {
                return NO;
            } else {
                DDLogDebug(@"Profile save folder have changed, reloading saved profiles from disk...");
            }
        }
    } else {
        DDLogDebug(@"It's Here!");
    }
    return YES;
}

- (void)addUnsavedProfile:(NSDictionary *)profile {
    [_arrayUnsavedProfiles addObject:profile];
    NSString *uuid = profile[@"Config"][PFCProfileTemplateKeyUUID];
    _dictUnsavedProfiles[uuid] = profile;
    _profilesDict[uuid] = profile;
} // addUnsavedProfile

- (void)removeUnsavedProfileWithUUID:(NSString *)uuid {
    NSUInteger index = [_arrayUnsavedProfiles indexOfObjectPassingTest:^BOOL(NSDictionary *_Nonnull profile, NSUInteger idx, BOOL *_Nonnull stop) {
      return [profile[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:uuid];
    }];

    if (index != NSNotFound) {
        [_arrayUnsavedProfiles removeObjectAtIndex:index];
    }

    [_dictUnsavedProfiles removeObjectForKey:uuid];
    [_profilesDict removeObjectForKey:uuid];
} // removeUnsavedProfileWithUUID

- (NSArray *)allProfiles {
    NSMutableArray *profiles = [[NSMutableArray alloc] initWithArray:_arraySavedProfiles];
    [profiles addObjectsFromArray:_arrayUnsavedProfiles];
    return [profiles copy];
} // allProfiles

- (NSArray *)allProfileUUIDs {
    if ([self shouldUpdateProfileCache]) {
        [self updateProfileCache];
    }
    return [_profilesDict allKeys];
} // allProfileUUIDs

- (NSArray *)allProfileNamesExceptProfileWithUUID:(NSString *)profileUUID {
    if ([self shouldUpdateProfileCache]) {
        [self updateProfileCache];
    }
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [_profilesDict.allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull uuid, NSUInteger idx, BOOL *_Nonnull stop) {
      if (![profileUUID isEqualToString:uuid]) {
          NSDictionary *profile = _profilesDict[uuid] ?: @{};
          [names addObject:profile[@"Config"][PFCProfileTemplateKeyName] ?: @""];
      }
    }];
    [names removeObject:@""];
    return [names copy];
} // allProfileNamesExceptProfileWithUUID

- (void)updateProfileCache {
    NSDate *modificationDate = [self savedProfilesFolderModificationDate];
    if (modificationDate) {
        DDLogDebug(@"Updating profile save folder modification date to: %@", modificationDate);
        [self setSavedProfilesModificationDate:modificationDate];
    }

    [_arraySavedProfiles removeAllObjects];
    [_dictSavedProfiles removeAllObjects];
    [_profilesDict removeAllObjects];

    // -------------------------------------------------------------------------
    //  Read all saved profiles from disk
    // -------------------------------------------------------------------------
    for (NSURL *profileURL in [self savedProfileURLs] ?: @[]) {

        NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
        if (profileDict.count == 0) {
            DDLogError(@"Couldn't read profile at path: %@", profileURL.path);
            continue;
        }

        // FIXME - Add sanity checking to see if this actually is a profile save

        NSString *name = profileDict[PFCProfileTemplateKeyName];
        if (name.length == 0) {
            DDLogError(@"Couldn't read profile name for profile at path: %@", profileURL.path);
            continue;
        }

        // ---------------------------------------------------------------------
        //  If profile was saved, remove it from unsaved profiles
        // ---------------------------------------------------------------------
        NSString *uuid = profileDict[PFCProfileTemplateKeyUUID];
        if (uuid.length != 0) {
            [self removeUnsavedProfileWithUUID:uuid];
        }

        NSDictionary *savedProfileDict = @{ PFCRuntimeKeyPath : profileURL.path, @"Config" : profileDict };

        [_arraySavedProfiles addObject:savedProfileDict];
        _dictSavedProfiles[uuid] = savedProfileDict;
    }

    [_profilesDict addEntriesFromDictionary:_dictSavedProfiles];
    [_profilesDict addEntriesFromDictionary:_dictUnsavedProfiles];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return Specific Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs {
    if ([self shouldUpdateProfileCache]) {
        [self updateProfileCache];
    }
    NSMutableArray *profileDicts = [[NSMutableArray alloc] init];
    for (NSString *uuid in profileUUIDs) {
        [profileDicts addObject:_profilesDict[uuid] ?: @{}];
    }
    [profileDicts removeObject:@{}];

    return [profileDicts copy];

} // profilesWithUUIDs

- (NSDictionary *)profileWithUUID:(NSString *)uuid {
    if ([self shouldUpdateProfileCache]) {
        [self updateProfileCache];
    }
    return _profilesDict[uuid] ?: @{};
} // profileWithUUID

- (BOOL)deleteProfileWithUUID:(NSString *)uuid error:(NSError **)error {
    DDLogDebug(@"Deleting profile with UUID: %@", uuid);
    NSDictionary *profile = [self profileWithUUID:uuid];
    NSString *profilePath = profile[PFCProfileTemplateKeyPath] ?: @"";
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    if ([profileURL checkResourceIsReachableAndReturnError:nil]) {
        return [NSFileManager.defaultManager removeItemAtURL:profileURL error:error];
    }
    return YES;
} // deleteProfileWithUUID:error

@end
