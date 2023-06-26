//
//  ADJEventStateData.m
//  Adjust
//
//  Created by Aditi Agrawal on 03/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEventStateData.h"

#import "ADJUtilMap.h"
#import "ADJUtilObj.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJTallyCounter *eventCount;
 */

#pragma mark - Public constants
NSString *const ADJEventStateDataMetadataTypeValue = @"EventStateData";

#pragma mark - Private constants
static NSString *const kEventCountKey = @"eventCount";

@implementation ADJEventStateData
#pragma mark Instantiation
+ (nonnull ADJResult<ADJEventStateData *> *)instanceFromIoData:(nonnull ADJIoData *)ioData {
    ADJResultFail *_Nullable unexpectedMetadataTypeValueFail =
        [ioData isExpectedMetadataTypeValue:ADJEventStateDataMetadataTypeValue];
    if (unexpectedMetadataTypeValueFail != nil) {
        return [ADJResult failWithMessage:@"Cannot create event state data from io data"
                                      key:@"unexpected metadata type value fail"
                                otherFail:unexpectedMetadataTypeValueFail];
    }

    ADJResult<ADJTallyCounter *> *_Nonnull eventCountResult =
        [ADJTallyCounter instanceFromIoDataValue:
         [ioData.propertiesMap pairValueWithKey:kEventCountKey]];
    if (eventCountResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create event state data from io data"
                                      key:@"eventCount fail"
                                otherFail:eventCountResult.fail];
    }

    return [ADJResult okWithValue:
            [[ADJEventStateData alloc] initWithEventCount:eventCountResult.value]];
}

- (nonnull instancetype)initWithIntialState {
    return [self initWithEventCount:[ADJTallyCounter instanceStartingAtZero]];
}

- (nonnull instancetype)initWithEventCount:(nonnull ADJTallyCounter *)eventCount {
    self = [super init];

    _eventCount = eventCount;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJEventStateData *)generateIncrementedEventCountStateData {
    return [[ADJEventStateData alloc] initWithEventCount:
            [self.eventCount generateIncrementedCounter]];
}

#pragma mark - ADJIoDataSerializable
- (nonnull ADJIoData *)toIoData {
    ADJIoDataBuilder *_Nonnull ioDataBuilder =
    [[ADJIoDataBuilder alloc]
     initWithMetadataTypeValue:ADJEventStateDataMetadataTypeValue];

    [ADJUtilMap
     injectIntoIoDataBuilderMap:ioDataBuilder.propertiesMapBuilder
     key:kEventCountKey
     ioValueSerializable:self.eventCount];

    return [[ADJIoData alloc] initWithIoDataBuilder:ioDataBuilder];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
            ADJEventStateDataMetadataTypeValue,
            kEventCountKey, self.eventCount,
            nil];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + self.eventCount.hash;

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJEventStateData class]]) {
        return NO;
    }

    ADJEventStateData *other = (ADJEventStateData *)object;
    return [ADJUtilObj objectEquals:self.eventCount other:other.eventCount];
}

@end

