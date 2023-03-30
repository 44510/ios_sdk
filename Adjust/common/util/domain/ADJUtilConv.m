//
//  ADJUtilConv.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJUtilConv.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

@implementation ADJUtilConv

+ (NSTimeInterval)convertToSecondsWithMilliseconds:(NSUInteger)milliseconds {
    return ((double)milliseconds) / ADJSecondToMilliDouble;
}

+ (nullable NSNumber *)convertToIntegerNumberWithStringValue:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }
    /* to check: integer formatter rounds possible non integer values, instead of failing
     ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];
     return [sharedInstance.integerFormatter numberFromString:stringValue];
     */
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];
    NSInteger scannedInteger;
    if (! [scanner scanInteger:&scannedInteger]) {
        return nil;
    }

    // Contains INT_MAX or INT_MIN on overflow
    if (scannedInteger == INT_MAX || scannedInteger == INT_MIN) {
        return nil;
    }

    return @(scannedInteger);
}

+ (nullable NSNumber *)convertToLLNumberWithStringValue:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];
    long long scannedLL;
    if (! [scanner scanLongLong:&scannedLL]) {
        return nil;
    }

    // Contains LLONG_MAX or LLONG_MIN on overflow
    if (scannedLL == LLONG_MAX || scannedLL == LLONG_MIN) {
        return nil;
    }

    return @(scannedLL);
}

+ (nullable NSNumber *)convertToDoubleNumberWithStringValue:(nonnull NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }

    // use number formatter before scanner to smoke out if the value is zero
    //  so that it can't be interpreted as underflow in scan double
    NSNumber *_Nullable formatterDouble =
    [[ADJUtilF decimalStyleFormatter] numberFromString:stringValue];

    if (formatterDouble == nil) {
        return nil;
    }

    if (formatterDouble.doubleValue == 0.0) {
        return formatterDouble;
    }

    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    [scanner setLocale:[ADJUtilF usLocale]];

    double scannedDBL;

    if (! [scanner scanDouble:&scannedDBL]) {
        return nil;
    }

    // Contains HUGE_VAL or –HUGE_VAL on overflow, or 0.0 on underflow
    if (scannedDBL == HUGE_VAL || scannedDBL == -( HUGE_VAL ) || scannedDBL == 0.0) {
        return nil;
    }

    return @(scannedDBL);
}

+ (nullable NSString *)convertToBase64StringWithDataValue:(nullable NSData *)dataValue {
    if (dataValue == nil) {
        return nil;
    }

    return [dataValue base64EncodedStringWithOptions:0];
}

+ (nullable NSData *)convertToDataWithBase64String:(nullable NSString *)base64String {
    if (base64String == nil) {
        return nil;
    }

    return [[NSData alloc] initWithBase64EncodedString:base64String
                                               options:0];
}

+ (nullable NSData *)
    convertToJsonDataWithJsonFoundationValue:(nonnull id)jsonFoundationValue
    errorPtr:(NSError * _Nullable * _Nonnull)errorPtr
{
    // TODO: check isValidJSONObject:
    return [NSJSONSerialization dataWithJSONObject:jsonFoundationValue options:0 error:errorPtr];
}

+ (nullable id)convertToFoundationObjectWithJsonString:(nonnull NSString *)jsonString
                                              errorPtr:(NSError * _Nullable * _Nonnull)errorPtr
{
    return [ADJUtilConv convertToJsonFoundationValueWithJsonData:
             [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         errorPtr:errorPtr];
}

+ (nullable id)convertToJsonFoundationValueWithJsonData:(nonnull NSData *)jsonData
                                               errorPtr:(NSError * _Nullable * _Nonnull)errorPtr {
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:errorPtr];
}

+ (nonnull id)convertToFoundationObject:(nonnull id)objectToConvert {
    if ([NSJSONSerialization isValidJSONObject:objectToConvert]) {
        return objectToConvert;
    }

    if ([objectToConvert isKindOfClass:[NSDictionary class]]) {
        NSDictionary *_Nonnull dictionaryToConvert = (NSDictionary *)objectToConvert;
        NSMutableDictionary<NSString *, id> *_Nonnull foundationDictionary =
        [[NSMutableDictionary alloc] initWithCapacity:dictionaryToConvert.count];

        for (id _Nonnull key in dictionaryToConvert) {
            id _Nullable value = dictionaryToConvert[key];
            NSString *_Nonnull keyString = [key description];

            if (value == nil || [value isEqual:[NSNull null]]) {
                [foundationDictionary setObject:[NSNull null] forKey:keyString];
                continue;
            }

            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]])
            {
                [foundationDictionary
                 setObject:[ADJUtilConv convertToFoundationObject:value]
                 forKey:keyString];
                continue;
            }

            if ([value isKindOfClass:[NSNumber class]]) {
                [foundationDictionary setObject:value forKey:keyString];
                continue;
            }

            [foundationDictionary setObject:[value description] forKey:keyString];
        }

        return foundationDictionary;
    }

    if ([objectToConvert isKindOfClass:[NSArray class]]) {
        NSArray *_Nonnull arrayToConvert = (NSArray *)objectToConvert;
        NSMutableArray *_Nonnull foundationArray =
        [[NSMutableArray alloc] initWithCapacity:arrayToConvert.count];

        for (id _Nullable value in arrayToConvert) {
            if (value == nil || [value isEqual:[NSNull null]]) {
                [foundationArray addObject:[NSNull null]];
                continue;
            }

            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]])
            {
                [foundationArray addObject:[ADJUtilConv convertToFoundationObject:value]];
                continue;
            }

            if ([value isKindOfClass:[NSNumber class]]) {
                [foundationArray addObject:value];
                continue;
            }


            [foundationArray addObject:[value description]];
        }

        return foundationArray;
    }

    return [[NSDictionary alloc] init];
}

+ (nullable ADJStringMap *)convertToStringMapWithKeyValueArray:(nullable NSArray *)keyValueArray
                                             sourceDescription:(nonnull NSString *)sourceDescription
                                                        logger:(nonnull ADJLogger *)logger {
    if (keyValueArray == nil) {
        return nil;
    }

    if (keyValueArray.count % 2 != 0) {
        [logger debugDev:
         @"Cannot convert key value array with non-multiple of 2 elements"
                     key:@"keyValueArray count"
                   value:[ADJUtilF uIntegerFormat:keyValueArray.count].description
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJStringMapBuilder *_Nonnull stringMapBuilder =
    [[ADJStringMapBuilder alloc] initWithEmptyMap];

    for (NSUInteger i = 0; i < keyValueArray.count; i = i + 2) {
        NSString *_Nullable key =
        [self extractFieldWithStringObject:[keyValueArray objectAtIndex:i]
                         sourceDescription:sourceDescription
                          fieldDescription:@"key"
                                    logger:logger];
        if (key == nil) { continue; }

        ADJNonEmptyString *_Nullable value =
        [self extractNonEmptyFieldWithStringObject:[keyValueArray objectAtIndex:i + 1]
                                 sourceDescription:sourceDescription
                                  fieldDescription:@"value"
                                            logger:logger];
        if (value == nil) { continue; }

        ADJNonEmptyString *_Nullable previousValue =
        [stringMapBuilder addPairWithValue:value
                                       key:key];
        if (previousValue != nil) {
            [logger debugDev:@"Value was overwritten"
                        from:sourceDescription
                         key:@"key"
                       value:key];
        }
    }

    if (stringMapBuilder.countPairs == 0) {
        return nil;
    }

    return [[ADJStringMap alloc] initWithStringMapBuilder:stringMapBuilder];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
convertToStringMapCollectionByNameBuilderWithNameKeyValueArray:
(nullable NSArray<NSString *> *)nameKeyStringValueArray
sourceDescription:(nonnull NSString *)sourceDescription
logger:(nonnull ADJLogger *)logger {
    return [self convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyStringValueArray
                                                        sourceDescription:sourceDescription
                                                                   logger:logger
                                                            isValueString:YES];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
convertToNumberBooleanMapCollectionByNameBuilderWithNameKeyValueArray:(nullable NSArray *)nameKeyNumberBooleanValueArray
sourceDescription:(nonnull NSString *)sourceDescription
logger:(nonnull ADJLogger *)logger {
    return [self
            convertToMapCollectionByNameBuilderWithNameKeyValueArray:nameKeyNumberBooleanValueArray
            sourceDescription:sourceDescription
            logger:logger
            isValueString:NO];
}

+ (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)
convertToMapCollectionByNameBuilderWithNameKeyValueArray:(nullable NSArray<NSString *> *)nameKeyValueArray
sourceDescription:(nonnull NSString *)sourceDescription
logger:(nonnull ADJLogger *)logger
isValueString:(BOOL)isValueString {
    if (nameKeyValueArray == nil) {
        return nil;
    }

    if (nameKeyValueArray.count % 3 != 0) {
        [logger debugDev:
         @"Cannot convert name key value array with non-multiple of 3 elements"
                     key:@"nameKeyStringValueArray count"
                   value:[ADJUtilF uIntegerFormat:nameKeyValueArray.count].description
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *_Nonnull
    mapCollectionByNameBuilder =
    [[NSMutableDictionary alloc] initWithCapacity:(nameKeyValueArray.count / 3)];

    for (NSUInteger i = 0; i < nameKeyValueArray.count; i = i + 3) {
        NSString *_Nullable name =
        [self extractFieldWithStringObject:[nameKeyValueArray objectAtIndex:i]
                         sourceDescription:sourceDescription
                          fieldDescription:@"name"
                                    logger:logger];
        if (name == nil) { continue; }

        NSString *_Nullable key =
        [self extractFieldWithStringObject:[nameKeyValueArray objectAtIndex:i + 1]
                         sourceDescription:sourceDescription
                          fieldDescription:@"key"
                                    logger:logger];
        if (key == nil) { continue; }

        id _Nullable value;
        if (isValueString) {
            value = [self extractFieldWithStringObject:[nameKeyValueArray objectAtIndex:i + 2]
                                     sourceDescription:sourceDescription
                                      fieldDescription:@"value"
                                                logger:logger];
        } else {
            value = [nameKeyValueArray objectAtIndex:i + 2];
        }
        if (value == nil) { continue; }

        NSMutableDictionary<NSString *, id> *_Nullable mapBuilder =
        [mapCollectionByNameBuilder objectForKey:name];

        if (mapBuilder == nil) {
            mapBuilder = [[NSMutableDictionary alloc] init];
            [mapCollectionByNameBuilder setObject:mapBuilder
                                           forKey:name];
        }

        NSString *_Nullable previousValue = [mapBuilder objectForKey:key];
        if (previousValue != nil) {
            [logger debugDev:@"Value was overwritten"
                        from:sourceDescription
                         key:@"key"
                       value:key];
        }

        [mapBuilder setObject:value forKey:key];
    }

    if (mapCollectionByNameBuilder.count == 0) {
        return nil;
    }

    return mapCollectionByNameBuilder;
}

// assumes [ADJUtilObj copyStringOrNSNullWithInput] was for the string object
+ (nullable NSString *)extractFieldWithStringObject:(nonnull id)stringObject
                                  sourceDescription:(nonnull NSString *)sourceDescription
                                   fieldDescription:(nonnull NSString *)fieldDescription
                                             logger:(nonnull ADJLogger *)logger {
    ADJNonEmptyString *_Nullable field =
    [self extractNonEmptyFieldWithStringObject:stringObject
                             sourceDescription:sourceDescription
                              fieldDescription:fieldDescription
                                        logger:logger];

    return field != nil ? field.stringValue : nil;
}

+ (nullable ADJNonEmptyString *)extractNonEmptyFieldWithStringObject:(nonnull id)stringObject
                                                   sourceDescription:(nonnull NSString *)sourceDescription
                                                    fieldDescription:(nonnull NSString *)fieldDescription
                                                              logger:(nonnull ADJLogger *)logger {
    if ([stringObject isEqual:[NSNull null]]) {
        [logger debugDev:@"Cannot add to map with NSNull"
                    key1:@"from"
                  value1:sourceDescription
                    key2:@"field in map"
                  value2:fieldDescription
               issueType:ADJIssueInvalidInput];
        return nil;
    }

    ADJNonEmptyString *_Nullable stringValue =
    [ADJNonEmptyString instanceFromString:stringObject
                        sourceDescription:sourceDescription
                                   logger:logger];
    if (stringValue == nil) {
        [logger debugDev:@"Cannot add to map with invalid string"
                    key1:@"from"
                  value1:sourceDescription
                    key2:@"field in map"
                  value2:fieldDescription
               issueType:ADJIssueInvalidInput];
    }

    return stringValue;
}

@end
