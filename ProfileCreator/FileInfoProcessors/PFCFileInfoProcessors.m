//
//  PFCFileInfoProcessors.m
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

#import "PFCFileInfoProcessors.h"

@implementation PFCFileInfoProcessors

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorFont
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation PFCFileInfoProcessorFont

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if ( self ) {
        _fileURL = fileURL;
    }
    return self;
} // initWithFileURL

- (NSDictionary *)fileInfo {
    NSMutableDictionary *fileInfoDict = [[NSMutableDictionary alloc] init];
    
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([[_fileURL path] UTF8String]);
    if ( fontDataProvider ) {
        CGFontRef font = CGFontCreateWithDataProvider(fontDataProvider);
        if ( font ) {
            NSString *fontFullName = CFBridgingRelease(CGFontCopyPostScriptName(font));
            fileInfoDict[@"Title"] = fontFullName ?: [_fileURL path];
        }
    } else {
        NSLog(@"NoProvider!");
    }
    
    MDItemRef fontMDItem = MDItemCreateWithURL(kCFAllocatorDefault, (CFURLRef)_fileURL);
    if ( fontMDItem ) {
        NSString *copyright = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemCopyright));
        fileInfoDict[@"DescriptionLabel1"] = @"Copyright:";
        fileInfoDict[@"Description1"] = copyright ?: @"";
        
        NSString *version = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemVersion));
        if ( [version containsString:@";"] ) {
            version = [[version componentsSeparatedByString:@";"] firstObject];
        }
        fileInfoDict[@"DescriptionLabel2"] = @"Version:";
        fileInfoDict[@"Description2"] = version ?: @"";
        
        NSArray *publishers = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemPublishers));
        if ( [publishers count] != 0 ) {
            fileInfoDict[@"DescriptionLabel3"] = @"Publisher:";
            fileInfoDict[@"Description3"] = [publishers componentsJoinedByString:@", "];
        } else {
            NSString *creator = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemCreator));
            if ( [creator length] != 0 ) {
                fileInfoDict[@"DescriptionLabel3"] = @"Creator:";
                fileInfoDict[@"Description3"] = creator;
            }
        }
        CFRelease(fontMDItem);
    }
    
    return [fileInfoDict copy];
}

@end