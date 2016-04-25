//
//  PFCTableViewCellTypeProtocol.h
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

#import <Cocoa/Cocoa.h>
@class PFCProfileExport;
@class PFCManifestLint;

@protocol PFCTableViewCellType

- (instancetype)populateTableViewCellView:(id)cellView
                                 settings:(NSDictionary *)settings
                               columnDict:(NSDictionary *)columnDict
                         columnIdentifier:(NSString *)columnIdentifier
                                      row:(NSInteger)row
                                   sender:(id)sender;
+ (void)createPayloadForCellType:(NSDictionary *)tableViewColumnDict settings:(NSDictionary *)settings payloadDict:(NSMutableDictionary **)payloadDict sender:(PFCProfileExport *)sender;

@optional

+ (NSDictionary *)verifyCellType:(NSDictionary *)tableViewColumnDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys;
+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)tableViewColumnDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender;

@end
