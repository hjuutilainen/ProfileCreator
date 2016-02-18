//
//  PFCProfileCreationInfoView.h
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
@class PFCViewInfo;

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationInfoDelegate
////////////////////////////////////////////////////////////////////////////////

@protocol PFCProfileCreationInfoDelegate
- (void)updateInfoViewView:(NSString *)viewIdentifier;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationInfoView
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileCreationInfoView : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property (weak) IBOutlet NSScrollView *scrollViewPayloadInfo;
@property (weak) IBOutlet NSTableView *tableViewPayloadInfo;

@property NSMutableArray *arrayPayloadInfo;

// ------------------------------------------------------
//  Manifest Content View
// ------------------------------------------------------
@property (weak) IBOutlet PFCViewInfo *viewManifestContent;
@property (weak) IBOutlet PFCViewInfo *viewManifest;

- (id)initWithDelegate:(id<PFCProfileCreationInfoDelegate>)delegate;
- (void)updateInfoForManifestDict:(NSDictionary *)manifestDict;
- (void)updateInfoForManifestContentDict:(NSDictionary *)manifestContentDict;

@end
