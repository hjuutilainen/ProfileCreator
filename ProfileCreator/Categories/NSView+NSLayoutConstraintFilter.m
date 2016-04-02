//
//  NSView+NSLayoutConstraintFilter.m
//  Expanding Search
//
//  Created by Ilija Tovilo on 12/13/12.
//  Copyright (c) 2012 Ilija Tovilo. All rights reserved.
//

// Copyright (c) 2012, Ilija Tovilo
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSView+NSLayoutConstraintFilter.h"

@implementation NSView (NSLayoutConstraintFilter)

- (NSArray *)pfc_constaintsForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    NSArray *filteredArray = [self.constraints filteredArrayUsingPredicate:predicate];

    return filteredArray;
}

- (NSLayoutConstraint *)pfc_constraintForAttribute:(NSLayoutAttribute)attribute {
    NSArray *constraints = [self pfc_constaintsForAttribute:attribute];

    if (constraints.count) {
        return constraints[0];
    }

    return nil;
}

@end
