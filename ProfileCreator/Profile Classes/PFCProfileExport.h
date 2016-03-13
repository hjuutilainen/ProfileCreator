//
//  PFCProfileExport.h
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

#import "PFCMainWindow.h"
#import <Foundation/Foundation.h>

@interface PFCProfileExport : NSObject

- (void)payloadErrorForManifestKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict;
- (void)payloadErrorForValueClass:(NSString *)valueClass payloadKey:(NSString *)payloadKey exptectedClasses:(NSArray *)expectedClasses;

- (id)initWithProfileSettings:(NSDictionary *)settings mainWindow:(PFCMainWindow *)mainWindow;
- (void)exportProfileToURL:(NSURL *)url manifests:(NSArray *)manifests settings:(NSDictionary *)settings;

- (NSMutableDictionary *)payloadRootFromManifest:(NSDictionary *)manifest settings:(NSDictionary *)settings payloadType:(NSString *)payloadType payloadUUID:(NSString *)payloadUUID;
- (void)createPayloadFromValueKey:(NSString *)selectedValue
                  availableValues:(NSArray *)availableValues
              manifestContentDict:(NSDictionary *)manifestContentDict
                         settings:(NSDictionary *)settings
                       payloadKey:(NSString *)payloadKey
                      payloadType:(NSString *)payloadType
                      payloadUUID:(NSString *)payloadUUID
                         payloads:(NSMutableArray **)payloads;
- (void)createPayloadFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads;
- (BOOL)verifyRequiredManifestContentDictKeys:(NSArray *)manifestContentDictKeys manifestContentDict:(NSDictionary *)manifestContentDict;

@end
