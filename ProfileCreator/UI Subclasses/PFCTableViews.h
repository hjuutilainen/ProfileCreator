//
//  PFCTableViews.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PFCTableViewDelegate <NSTableViewDelegate>
@optional
- (BOOL)deleteKeyPressedForTableView:(id)sender;
- (void)validateMenu:(NSMenu *)menu forTableViewWithIdentifier:(NSString *)tableViewIdentifier row:(NSInteger)row;
- (void)didClickRow:(NSInteger)row;
@end

@interface PFCTableView : NSTableView
@end
