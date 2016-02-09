//
//  PFCProfileUtility.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-07.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileUtility.h"
#import "PFCGeneralUtility.h"
#import "PFCConstants.h"
#import "PFCLog.h"

@interface PFCProfileUtility ()

@property NSMutableArray *arraySavedProfiles;
@property NSMutableArray *arrayUnsavedProfiles;
@property NSDate *savedProfilesLastCheck;

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
    if ( self ) {
        _arraySavedProfiles = [[NSMutableArray alloc] init];
        _arrayUnsavedProfiles = [[NSMutableArray alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)savedProfileURLs {
    NSURL *savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
    if ( ! [savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        return nil;
    } else {
        NSArray *savedProfilesContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:savedProfilesFolderURL
                                                                      includingPropertiesForKeys:@[]
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                           error:nil];
        
        return [savedProfilesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pathExtension == '%@'", PFCProfileTemplateExtension]]];
    }
} // savedProfileURLs

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return All Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profiles {
    // FIXME - Handle unsaved profiles as well
    return [self savedProfiles];
} // profiles

- (NSArray *)savedProfiles {
    
    // FIXME - This should be cached somehow, by checking mod time of folder etc?
    if ( [_arraySavedProfiles count] == 0 ) {
        [_arraySavedProfiles removeAllObjects];
        
        // ---------------------------------------------------------------------
        //  Read all saved profiles from disk
        // ---------------------------------------------------------------------
        for ( NSURL *profileURL in [self savedProfileURLs] ?: @[] ) {
            
            NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
            if ( [profileDict count] == 0 ) {
                DDLogError(@"Couldn't read profile at path: %@", [profileURL path]);
                continue;
            }
            
            NSString *name = profileDict[PFCProfileTemplateKeyName];
            if ( [name length] == 0 ) {
                DDLogError(@"Couldn't read profile name for profile at path: %@", [profileURL path]);
                continue;
            }
            
            NSDictionary *savedProfileDict = @{ PFCRuntimeKeyPath : [profileURL path],
                                                @"Config" : profileDict };
            
            // FIXME - Add sanity checking to see if this actually is a profile save
            
            [_arraySavedProfiles addObject:savedProfileDict];
        }
    }
    return [_arraySavedProfiles copy];
} // profiles

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return Specific Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs {
    if ( [profileUUIDs ?: @[] count] == 0 ) {
        return @[];
    }
    
    NSMutableArray *profileDicts = [[NSMutableArray alloc] init];
    [[self profiles] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [profileUUIDs containsObject:dict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""] ) {
            [profileDicts addObject:dict];
        }
    }];
    
    return [profileDicts copy];
} // profilesWithUUIDs

- (NSDictionary *)profileWithUUID:(NSString *)profileUUID {
    if ( [profileUUID length] != 0 ) {
        NSArray *profiles = [self profiles];
        NSUInteger index = [profiles indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:profileUUID];
        }];
        
        if ( index != NSNotFound ) {
            return profiles[index];
        }
    }
    return nil;
} // profileWithUUID

@end
