//
//  PFCFileInfoProcessors.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-15.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

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