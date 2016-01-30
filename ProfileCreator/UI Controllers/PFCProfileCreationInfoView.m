//
//  PFCProfileCreationInfoView.m
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

#import "PFCProfileCreationInfoView.h"
#import "PFCViews.h"
#import "PFCConstants.h"

@interface PFCProfileCreationInfoView ()

@end

@implementation PFCProfileCreationInfoView

- (id)initWithDelegate:(id<PFCProfileCreationInfoDelegate>)delegate {
    self = [super initWithNibName:@"PFCProfileCreationInfoView" bundle:nil];
    if (self != nil) {
        _delegate = delegate;
        [_tableViewInfoPayload setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden {
    [superview addSubview:subview positioned:NSWindowAbove relativeTo:nil];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    
    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    [superview setHidden:NO];
    [subview setHidden:hidden];
} // insertSubview:inSuperview:hidden

- (void)updateInfoForManifestContentDict:(NSDictionary *)manifestContentDict {
    if ( [manifestContentDict count] == 0 ) {
        return;
    }
    
    [self removeSubviews];
    [self insertSubview:_viewManifestContent inSuperview:[self view] hidden:NO];
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    [self updateInfoForCellType:cellType manifestContentDict:manifestContentDict];
    
}

- (void)updateInfoForManifestDict:(NSDictionary *)manifestDict {
    if ( [manifestDict count] == 0 ) {
        return;
    }

    [self removeSubviews];
    [self insertSubview:_viewManifestContent inSuperview:[self view] hidden:NO];
}

- (void)removeSubviews {
    for ( NSView *view in [[self view] subviews] ) {
        [view removeFromSuperview];
    }
}

- (void)updateInfoForCellType:(NSString *)cellType manifestContentDict:(NSDictionary *)manifestContentDict {
    if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
        
    }
}

- (void)updateinfoForCellTypeTextField:(NSDictionary *)manifestContentDict {

}

@end
