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

#import "PFCConstants.h"
#import "PFCFileInfoProcessors.h"
#import "PFCLog.h"

@implementation PFCFileInfoProcessors

+ (id)fileInfoProcessorWithName:(NSString *)fileInfoProcessorName fileURL:(NSURL *)fileURL {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    if ([fileInfoProcessorName isEqualToString:@"FileInfoProcessorFont"]) {
        return [[PFCFileInfoProcessorFont alloc] initWithFileURL:fileURL];
    }
    return [[PFCFileInfoProcessorFallback alloc] initWithFileURL:fileURL];
} // fileInfoProcessorWithName:fileURL

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorCertificate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation PFCFileInfoProcessorCertificate

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _fileURL = fileURL;
    }
    return self;
} // initWithFileURL

- (NSDictionary *)fileInfo {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSMutableDictionary *fileInfoDict = [[NSMutableDictionary alloc] init];

    return [fileInfoDict copy];
} // fileInfo

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorFallback
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation PFCFileInfoProcessorFallback

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _fileURL = fileURL;
    }
    return self;
} // initWithFileURL

- (NSDictionary *)fileInfo {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSError *error = nil;

    NSMutableDictionary *fileInfoDict = [[NSMutableDictionary alloc] init];

    fileInfoDict[PFCFileInfoTitle] = [_fileURL lastPathComponent];

    fileInfoDict[PFCFileInfoLabelTop] = @"Path:";
    fileInfoDict[PFCFileInfoDescriptionTop] = [_fileURL path] ?: @"";

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fileURL path] error:&error];
    if (fileAttributes.count != 0) {
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:(long long)[fileAttributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
        fileInfoDict[PFCFileInfoLabelMiddle] = @"Size:";
        fileInfoDict[PFCFileInfoDescriptionMiddle] = fileSize ?: @"";
    } else {
        DDLogError(@"%@", error.localizedDescription);
    }

    return [fileInfoDict copy];
} // fileInfo

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorFont
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@implementation PFCFileInfoProcessorFont

- (id)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _fileURL = fileURL;
    }
    return self;
} // initWithFileURL

- (NSDictionary *)fileInfo {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSMutableDictionary *fileInfoDict = [[NSMutableDictionary alloc] init];

    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([[_fileURL path] UTF8String]);
    if (fontDataProvider) {
        CGFontRef font = CGFontCreateWithDataProvider(fontDataProvider);
        if (font) {
            NSString *fontFullName = CFBridgingRelease(CGFontCopyPostScriptName(font));
            fileInfoDict[PFCFileInfoTitle] = fontFullName ?: [_fileURL path];
        }
    } else {
        DDLogError(@"NoProvider!");
    }

    MDItemRef fontMDItem = MDItemCreateWithURL(kCFAllocatorDefault, (CFURLRef)_fileURL);
    if (fontMDItem) {
        NSString *copyright = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemCopyright));
        fileInfoDict[PFCFileInfoLabelTop] = @"Copyright:";
        fileInfoDict[PFCFileInfoDescriptionTop] = copyright ?: @"";

        NSString *version = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemVersion));
        if ([version containsString:@";"]) {
            version = [[version componentsSeparatedByString:@";"] firstObject];
        }
        fileInfoDict[PFCFileInfoLabelMiddle] = @"Version:";
        fileInfoDict[PFCFileInfoDescriptionMiddle] = version ?: @"";

        NSArray *publishers = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemPublishers));
        if (publishers.count != 0) {
            fileInfoDict[PFCFileInfoLabelBottom] = @"Publisher:";
            fileInfoDict[PFCFileInfoDescriptionBottom] = [publishers componentsJoinedByString:@", "];
        } else {
            NSString *creator = CFBridgingRelease(MDItemCopyAttribute(fontMDItem, kMDItemCreator));
            if (creator.length != 0) {
                fileInfoDict[PFCFileInfoLabelBottom] = @"Creator:";
                fileInfoDict[PFCFileInfoDescriptionBottom] = creator;
            }
        }
        CFRelease(fontMDItem);
    }

    return [fileInfoDict copy];
} // fileInfo

@end
