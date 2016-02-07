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

@implementation PFCProfileUtility

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedUtility {
    // FIXME - Unsure if this has to be a singleton, figured it would be used alot and then not keep alloc/deallocing all the time
    static PFCProfileUtility *sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
        sharedUtility = [[self alloc] init];
    });
    return sharedUtility;
} // sharedParser

- (NSArray *)savedProfileURLs {
    NSURL *savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
    if ( ! [savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        return nil;
    } else {
        NSArray *savedProfilesContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:savedProfilesFolderURL
                                                                      includingPropertiesForKeys:@[]
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                           error:nil];
        
        return [savedProfilesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension == 'pfcconf'"]];
    }
}

- (NSArray *)savedProfiles {
    
    // FIXME - This should be cached somehow, by checking mod time of folder etc?
    
    // -------------------------------------------------------------------------
    //  Read in all saved profiles in an array
    // -------------------------------------------------------------------------
    NSArray *savedProfilesURLs = [self savedProfileURLs];
    NSMutableArray *savedProfiles = [[NSMutableArray alloc] init];
    for ( NSURL *profileURL in savedProfilesURLs ) {
        
        NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
        if ( [profileDict count] == 0 ) {
            NSLog(@"[ERROR] Couldn't read profile at path: %@", [profileURL path]);
            continue;
        }
        
        NSString *name = profileDict[PFCProfileTemplateKeyName];
        if ( [name length] == 0 ) {
            NSLog(@"[ERROR] Profile doesn't contain a name!");
            continue;
        }
        
        NSDictionary *savedProfileDict = @{ PFCRuntimeKeyPath : [profileURL path],
                                            @"Config" : profileDict };
        
        // FIXME - Add sanity checking to see if this actually is a profile save
        
        [savedProfiles addObject:savedProfileDict];
    }
    
    return [savedProfiles copy];
} // savedProfiles

- (NSArray *)profileDictsFromUUIDs:(NSArray *)profileUUIDs {
    if ( [profileUUIDs ?: @[] count] == 0 ) {
        return @[];
    }
    
    NSMutableArray *profileDicts = [[NSMutableArray alloc] init];
    [[[PFCProfileUtility sharedUtility] savedProfiles] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [profileUUIDs containsObject:dict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""] ) {
            [profileDicts addObject:dict];
        }
    }];
    
    return [profileDicts copy];
} // profileDictsFromUUIDs

@end
