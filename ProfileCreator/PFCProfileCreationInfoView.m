//
//  PFCProfileCreationInfoView.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-19.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileCreationInfoView.h"
#import "PFCCustomViews.h"
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
    
    NSLog(@"manifestContentDict=%@", manifestContentDict);
    [self insertSubview:_viewManifestContent inSuperview:[self view] hidden:NO];
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    [self updateInfoForCellType:cellType manifestContentDict:manifestContentDict];
    
}

- (void)updateInfoForManifestDict:(NSDictionary *)manifestDict {
    if ( [manifestDict count] == 0 ) {
        return;
    }
    
    NSLog(@"manifestDict=%@", manifestDict);
}

- (void)updateInfoForCellType:(NSString *)cellType manifestContentDict:(NSDictionary *)manifestContentDict {
    if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
        
    }
}

- (void)updateinfoForCellTypeTextField:(NSDictionary *)manifestContentDict {
    NSLog(@"");
}

@end
