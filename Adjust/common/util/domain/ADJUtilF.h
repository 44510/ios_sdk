//
//  ADJUtilF.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimestampMilli.h"
//#import "ADJMoney.h"
#import "ADJLogger.h"

@interface ADJUtilF : NSObject

+ (nonnull NSLocale *)usLocale;
+ (nonnull NSNumberFormatter *)decimalStyleFormatter;

+ (nonnull NSString *)boolFormat:(BOOL)boolValue;
+ (nonnull NSString *)intFormat:(int)intValue;
+ (nonnull NSString *)uIntFormat:(unsigned int)uIntValue;
+ (nonnull NSString *)uLongFormat:(unsigned long)uLongValue;
+ (nonnull NSString *)uLongLongFormat:(unsigned long long)uLongLongValue;
+ (nonnull NSString *)integerFormat:(NSInteger)integerValue;
+ (nonnull NSString *)uIntegerFormat:(NSUInteger)uIntegerFormat;
+ (nonnull NSString *)longLongFormat:(long long)longLongValue;
+ (nonnull NSString *)usLocaleNumberFormat:(nonnull NSNumber *)number;

+ (nonnull NSString *)errorFormat:(nonnull NSError *)error;

+ (nullable NSString *)jsonDataFormat:(nonnull NSData *)jsonData;
+ (nonnull ADJResultNL<NSString *> *)jsonFoundationValueFormat:(nullable id)jsonFoundationValue;

+ (nonnull NSString *)secondsFormat:(nonnull NSNumber *)secondsNumber;

+ (nonnull NSString *)dateTimestampFormat:(nonnull ADJTimestampMilli *)timestamp;

+ (nonnull id)stringOrNsNull:(nullable NSString *)string;
+ (nonnull id)idOrNsNull:(nullable id)idObject;

+ (BOOL)matchesWithString:(nonnull NSString *)stringValue
                    regex:(nonnull NSRegularExpression *)regex;

+ (BOOL)isNotANumber:(nonnull NSNumber *)numberValue;

+ (nullable NSString *)urlReservedEncodeWithSpaceAsPlus:(nonnull NSString *)stringToEncode;

+ (nonnull NSString *)normaliseFilename:(nonnull NSString *)filename;

+ (nonnull NSString *)joinString:(nonnull NSString *)first, ...;

+ (nullable NSString *)stringValueOrNil:(nullable ADJNonEmptyString *)value;

@end
