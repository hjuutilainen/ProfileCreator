//
//  PFCODManager.m
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

#import "PFCODManager.h"
#import <OpenDirectory/OpenDirectory.h>

@interface PFCODManager ()

@property (copy, nonatomic) void (^odConnectionStatusAndNodes)(NSError *error, NSArray *nodes);
@property (copy, nonatomic) void (^notificatonComplete)(NSError *error);

@end

@implementation PFCODManager

- (void)testConnection:(void (^)(NSError *, NSArray *))odConnectionStatusAndNodes {
    if (odConnectionStatusAndNodes && !self.odConnectionStatusAndNodes) {
        self.odConnectionStatusAndNodes = odConnectionStatusAndNodes;
    }

    NSError *error = nil;
    ODSession *session = [self newSession:&error];
    if (session) {
        ODNode *node = [ODNode nodeWithSession:session type:kODNodeTypeAuthentication error:&error];
        if (node != nil) {
            NSArray *subnodes = [node subnodeNamesAndReturnError:&error];
            if (subnodes.count != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  self.odConnectionStatusAndNodes(nil, subnodes);
                });
                return;
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      self.odConnectionStatusAndNodes(error, nil);
    });
}

- (ODSession *)newSession:(NSError **)error {                   // Erik
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; // Testar
    NSString *odAddress = [ud objectForKey:@"ODAddress"];
    NSString *odPort = [[ud objectForKey:@"ODPort"] stringValue] ?: @"0";

    if ([odAddress length] != 0 && [odPort length] != 0) {
        return [ODSession sessionWithOptions:@{
            ODSessionProxyAddress : odAddress,
            ODSessionProxyPort : odPort,
            ODSessionProxyUsername : [ud objectForKey:@"ODUsername"] ?: @"",
            ODSessionProxyPassword : [ud objectForKey:@"ODPassword"] ?: @""
        }
                                       error:error];
    } else {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Verify both address and port is entered" }];
    }
    return nil;
}

@end
