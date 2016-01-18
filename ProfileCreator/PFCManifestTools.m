//
//  PFCManifestTools.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-18.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCManifestTools.h"
#import "PFCConstants.h"

@implementation PFCManifestTools

+ (NSImage *)iconForManifest:(NSDictionary *)manifestDict {
    
    NSImage *icon = [[NSBundle mainBundle] imageForResource:manifestDict[PFCManifestKeyIconName]];
    if ( icon ) {
        return icon;
    }
    
    NSURL *iconURL = [NSURL fileURLWithPath:manifestDict[PFCManifestKeyIconPath] ?: @""];
    if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
        if ( icon ) {
            return icon;
        }
    }
    
    iconURL = [NSURL fileURLWithPath:manifestDict[PFCManifestKeyIconPathBundle] ?: @""];
    if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[iconURL path]];
        if ( icon ) {
            return icon;
        }
    }
    
    // FIXME - Should probaby return a bundled default icon.
    return nil;
}

@end
