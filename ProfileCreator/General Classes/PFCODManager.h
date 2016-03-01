//
//  PFCODManager.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-01.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFCODManager : NSObject

- (void)testConnection:(void (^)(NSError *, NSArray *))odConnectionStatusAndNodes;

@end
