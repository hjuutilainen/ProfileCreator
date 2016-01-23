//
//  PFCManifestTools.m
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
