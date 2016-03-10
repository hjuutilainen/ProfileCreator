//
//  PFCProfileUtility.h
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

@interface PFCProfileUtility : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedUtility;

// -----------------------------------------------------------------------------
//  Utility Methods
// -----------------------------------------------------------------------------
- (NSArray *)allProfileUUIDs;
- (NSArray *)allProfileNamesExceptProfileWithUUID:(NSString *)uuid;

- (void)updateProfileCache;

- (NSArray *)profiles;
- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs;
- (NSDictionary *)profileWithUUID:(NSString *)profileUUID;
- (void)addUnsavedProfile:(NSDictionary *)profile;
- (void)removeUnsavedProfileWithUUID:(NSString *)uuid;
- (BOOL)deleteProfileWithUUID:(NSString *)uuid error:(NSError **)error;

@end
