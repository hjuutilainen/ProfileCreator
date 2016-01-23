//
//  PFCError.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PFCVerificationSeverity) {
    /** Error **/
    kPFCSeverityError,
    /** Warning **/
    kPFCSeverityWarning,
    /** Notice **/
    kPFCSeverityNotice,
    /** Info **/
    kPFCSeverityInfo,
    /** Debug **/
    kPFCSeverityDebug,
};

@interface PFCError : NSObject

+ (NSDictionary *)verificationReportWithMessage:(NSString *)message severity:(int)severity manifestContentDict:(NSDictionary *)manifestContentDict;
+ (NSDictionary *)verificationMessage:(NSString *)message manifestContentDict:(NSDictionary *)manifestContentDict;

@end
