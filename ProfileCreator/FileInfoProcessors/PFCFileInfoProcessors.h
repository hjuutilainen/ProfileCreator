//
//  PFCFileInfoProcessors.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-15.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCFileInfoProcessors : NSObject

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