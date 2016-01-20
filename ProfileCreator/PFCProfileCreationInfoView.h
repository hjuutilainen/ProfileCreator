//
//  PFCProfileCreationInfoView.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-19.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

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
@interface PFCProfileCreationInfoView : NSViewController

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property (weak) IBOutlet NSTableView *tableViewInfoPayload;

@property NSMutableArray *arrayInfoPayload;

// ------------------------------------------------------
//  Manifest Content View
// ------------------------------------------------------
@property (weak) IBOutlet PFCViewInfo *viewManifestContent;

- (id)initWithDelegate:(id<PFCProfileCreationInfoDelegate>)delegate;
- (void)updateInfoForManifestDict:(NSDictionary *)manifestDict;
- (void)updateInfoForManifestContentDict:(NSDictionary *)manifestContentDict;

@end
