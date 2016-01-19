//
//  PFCSplitViews.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCSplitViewWindow : NSSplitView
@property(readonly, copy) NSColor *dividerColor;
@property(readonly) CGFloat dividerThickness;
@end

@interface PFCSplitViewPayloadLibrary : NSSplitView
@property(readonly, copy) NSColor *dividerColor;
@property(readonly) CGFloat dividerThickness;
@end
