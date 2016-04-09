//
//  PFCStatusView.m
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

#import "PFCConstants.h"
#import "PFCStatusView.h"

@interface PFCStatusView ()

@property PFCStatus status;
@property (weak) IBOutlet NSTextField *textFieldStatus;

@end

@implementation PFCStatusView

- (id)initWithStatusType:(PFCStatus)status {
    self = [super initWithNibName:@"PFCStatusView" bundle:nil];
    if (self != nil) {
        _status = status;
        [self view];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_status) {
        [self showStatus:_status];
    }
}

- (NSString *)labelForStatus:(PFCStatus)status {
    switch (status) {
    case kPFCStatusLoadingSettings:
        return @"Loading Settings...";
        break;
    case kPFCStatusNoManifestSelection:
        return @"No Manifest Selected";
        break;
    case kPFCStatusNoManifests:
        return @"No Manifests";
        break;
    case kPFCStatusNoManifestsCustom:
        return @"No Custom Manifests";
        break;
    case kPFCStatusNoManifestsMCX:
        return @"No MCX Manifests";
        break;
    case kPFCStatusNoMatches:
        return @"No Matches";
        break;
    case kPFCStatusNoProfileSelected:
        return @"No Profile Selected";
        break;
    case kPFCStatusNoSelection:
        return @"No Selection";
        break;
    case kPFCStatusNoSettings:
        return @"No Settings Available";
        break;
    case kPFCStatusNotImplemented:
        return @"Not Implemented Yet";
        break;
    case kPFCStatusMultipleProfilesSelected:
        return @"Profiles Selected";
        break;
    case kPFCStatusErrorReadingSettings:
        return @"Error Reading Settings";
        break;
    }
}

- (NSAttributedString *)attributedStringForStatus:(PFCStatus)status {
    NSMutableParagraphStyle *paragraphStyleCenter = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleCenter setAlignment:NSTextAlignmentCenter];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:12], NSParagraphStyleAttributeName : paragraphStyleCenter}];

    NSString *label = [self labelForStatus:status];
    switch (status) {
    case kPFCStatusLoadingSettings:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:16];
        break;
    case kPFCStatusNoManifestSelection:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:16];
        break;
    case kPFCStatusNoManifests:
        break;
    case kPFCStatusNoManifestsCustom:
        break;
    case kPFCStatusNoManifestsMCX:
        break;
    case kPFCStatusNoMatches:
        break;
    case kPFCStatusNoProfileSelected:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:19];
        break;
    case kPFCStatusNoSelection:
        break;
    case kPFCStatusNoSettings:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:16];
        break;
    case kPFCStatusNotImplemented:
        break;
    case kPFCStatusMultipleProfilesSelected:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:14];
        label = [NSString stringWithFormat:@"%@ %@", [_counter stringValue], label];
        break;
    case kPFCStatusErrorReadingSettings:
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:16];
        break;
    }
    return [[NSAttributedString alloc] initWithString:label attributes:attributes];
}

- (void)showStatus:(PFCStatus)status {
    [self setStatus:status];
    [self.view setHidden:NO];
    [_textFieldStatus setAttributedStringValue:[self attributedStringForStatus:status]];
}

@end
