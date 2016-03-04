//
//  PFCFileInfoProcessors.h
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

#import <Foundation/Foundation.h>

@interface PFCFileInfoProcessors : NSObject

+ (id)fileInfoProcessorWithName:(NSString *)fileInfoProcessorName fileURL:(NSURL *)fileURL;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorCertificate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCFileInfoProcessorCertificate : NSObject
@property NSURL *fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
- (NSDictionary *)fileInfo;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorFallback
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCFileInfoProcessorFallback : NSObject
@property NSURL *fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
- (NSDictionary *)fileInfo;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PFCFileInfoProcessorFont
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

@interface PFCFileInfoProcessorFont : NSObject
@property NSURL *fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
- (NSDictionary *)fileInfo;
@end
