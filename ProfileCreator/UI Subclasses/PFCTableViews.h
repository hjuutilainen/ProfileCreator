//
//  PFCTableViews.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PFCTableViewDelegate <NSTableViewDelegate>
-(BOOL)deleteKeyPressedForTableView:(id)sender;
@end

@interface PFCTableView : NSTableView
@end
