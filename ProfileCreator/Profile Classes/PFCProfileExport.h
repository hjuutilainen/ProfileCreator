//
//  PFCProfileExport.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-21.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindow.h"
#import <Foundation/Foundation.h>

@interface PFCProfileExport : NSObject

- (id)initWithProfileSettings:(NSDictionary *)settings mainWindow:(PFCMainWindow *)mainWindow;
- (void)exportProfileToURL:(NSURL *)url manifests:(NSArray *)manifests settings:(NSDictionary *)settings;

@end
