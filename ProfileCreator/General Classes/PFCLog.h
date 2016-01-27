//
//  PFCLog.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NBICreator_NBCLogging_h
#define NBICreator_NBCLogging_h

#import <CocoaLumberjack/CocoaLumberjack.h>
extern DDLogLevel ddLogLevel;
#endif

@interface PFCLog : NSObject

+ (void)configureLoggingForSession:(int)sessionType;
+ (DDFileLogger *)fileLogger;

@end
