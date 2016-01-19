//
//  PFCCustomViews.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-19.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCustomViews.h"

@implementation PFCCustomViews

@end

@implementation PFCViewInfo

- (void)drawRect:(NSRect)aRect {
    [[NSColor controlColor] set];
    NSRectFill([self bounds]);
}

@end