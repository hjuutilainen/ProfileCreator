//
//  PFCTableViewCellTypes.m
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

#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCTableViewCellTypeProtocol.h"
#import "PFCTableViewCellTypes.h"

@implementation PFCTableViewCellTypes

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedInstance {
    static PFCTableViewCellTypes *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedInstance

- (NSView *)cellViewForTableViewCellType:(NSString *)cellType
                               tableView:(NSTableView *)tableView
                                settings:(NSDictionary *)settings
                        columnIdentifier:(NSString *)columnIdentifier
                                     row:(NSInteger)row
                                  sender:(id)sender {

    id cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    if (cellView) {
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateTableViewCellView:cellView settings:settings columnIdentifier:columnIdentifier row:row sender:sender];
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return nil;
}

@end
