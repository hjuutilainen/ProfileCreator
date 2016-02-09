//
//  PFCTableViews.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PFCProfileGroupTableView;

@protocol ProfileGroupTableViewDelegate <NSTableViewDelegate>
-(BOOL)deleteKeyPressedForTableView:(PFCProfileGroupTableView *)tableView;
@end

@interface PFCProfileGroupTableView : NSTableView
@end
