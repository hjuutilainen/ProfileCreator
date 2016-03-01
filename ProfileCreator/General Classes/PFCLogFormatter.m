//
//  PFCLogFormatter.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCLogFormatter.h"

@implementation PFCLogFormatter

- (id)init {
    if ((self = [super init])) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd HH:mm:ss:SSS" options:0 locale:[NSLocale currentLocale]];
        [threadUnsafeDateFormatter setDateFormat:formatString];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
    case DDLogFlagError:
        logLevel = @"ERROR";
        break;
    case DDLogFlagWarning:
        logLevel = @"WARNING";
        break;
    case DDLogFlagInfo:
        logLevel = @"";
        break;
    case DDLogFlagDebug:
        logLevel = @"DEBUG";
        break;
    default:
        logLevel = @"VERBOSE";
        break;
    }

    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;

    if (logMessage->_flag == DDLogFlagInfo) {
        return [NSString stringWithFormat:@"%@ %@", dateAndTime, logMsg];
    } else {
        return [NSString stringWithFormat:@"%@ [%@] %@", dateAndTime, logLevel, logMsg];
    }
}

- (void)didAddToLogger:(id<DDLogger>)logger {
    loggerCount++;
    NSAssert(loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id<DDLogger>)logger {
    loggerCount--;
}

@end
