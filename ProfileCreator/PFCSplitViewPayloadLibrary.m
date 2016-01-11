//
//  PFCSplitViewPayloadLibrary.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCSplitViewPayloadLibrary.h"

@implementation PFCSplitViewPayloadLibrary

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (NSColor *)dividerColor {
    return [NSColor whiteColor];
}

- (CGFloat) dividerThickness {
    return (CGFloat)1.0f;
}

@end
