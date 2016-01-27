//
//  PFCLogFormatter.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFCLog.h"

@interface PFCLogFormatter : NSObject <DDLogFormatter> {
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}


@end
