//
//  NSColor+PFCColors.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-14.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "NSColor+PFCColors.h"

@implementation NSColor (PFCColors)

+ (NSColor *)localSettingsColor {
    static NSColor *localSettingsColor = nil;
    if ( ! localSettingsColor ) localSettingsColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.9 alpha:1.0];
    return localSettingsColor;
}

@end
