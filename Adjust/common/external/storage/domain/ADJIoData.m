//
//  ADJIoData.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJIoData.h"

#import "ADJStringMapBuilder.h"
#import "ADJConstants.h"
#import "ADJUtilF.h"
#import "ADJUtilObj.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJStringMap *metadataMap;
 @property (nonnull, readonly, strong, nonatomic) ADJStringMap *propertiesMap;
 @property (nonnull, readonly, strong, nonatomic)
     NSDictionary<NSString *, ADJStringMap *> *mapCollectionByName;
 */

@implementation ADJIoData

#pragma mark Instantiation
- (nonnull instancetype)initWithIoDataBuilder:(nonnull ADJIoDataBuilder *)ioDataBuilder {
    self = [super init];

    NSMutableDictionary<ADJNonEmptyString *, ADJStringMap *> *_Nonnull
        mapCollectionByNameBuilder = [NSMutableDictionary dictionary];

    for (NSString *_Nonnull mapName in ioDataBuilder.mapCollectionByNameBuilder) {
        ADJStringMapBuilder *_Nonnull mapBuilder =
            [ioDataBuilder.mapCollectionByNameBuilder objectForKey:mapName];

        ADJStringMap *_Nonnull readOnlyMap =
            [[ADJStringMap alloc] initWithStringMapBuilder:mapBuilder];

        [mapCollectionByNameBuilder setObject:readOnlyMap forKey:mapName];
    }

    _mapCollectionByName = [mapCollectionByNameBuilder copy];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJStringMap *)metadataMap {
    return [self mapWithName:ADJMetadataMapName];
}

- (nonnull ADJStringMap *)propertiesMap {
    return [self mapWithName:ADJPropertiesMapName];
}

- (nullable ADJStringMap *)mapWithName:(nonnull NSString *)mapName {
    return [self.mapCollectionByName objectForKey:mapName];
}

- (nullable ADJResultFail *)
    isExpectedMetadataTypeValue:(nonnull NSString *)expectedMetadataTypeValue
{
    ADJNonEmptyString *_Nonnull typeValue =
        [self.metadataMap pairValueWithKey:ADJMetadataIoDataTypeKey];

    if (typeValue == nil) {
        return [[ADJResultFail alloc]
                initWithMessage:@"Cannot obtain type value from metadata map"];
    }

    if (! [typeValue.stringValue isEqualToString:expectedMetadataTypeValue]) {
        ADJResultFailBuilder *_Nonnull failBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Actual type value different than expected"];
        [failBuilder withKey:ADJLogExpectedKey stringValue:expectedMetadataTypeValue];
        [failBuilder withKey:ADJLogActualKey stringValue:typeValue.stringValue];

        return [failBuilder build];
    }

    return nil;
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    NSMutableString *_Nonnull sb =
        [NSMutableString stringWithFormat:@"\nIoData with %@ maps\n",
            [ADJUtilF uIntegerFormat:(2 + self.mapCollectionByName.count)]];

    for (NSString *_Nonnull mapName in self.mapCollectionByName) {
        ADJStringMap *_Nonnull map = [self.mapCollectionByName objectForKey:mapName];

        [sb appendString:
            [ADJUtilObj formatInlineKeyValuesWithName:mapName
                                   stringKeyDictionary:map.map]];

        [sb appendString:@"\n"];
    }

    return (NSString *_Nonnull)sb;
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [self.mapCollectionByName hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJIoData class]]) {
        return NO;
    }

    ADJIoData *other = (ADJIoData *)object;
    return [ADJUtilObj objectEquals:self.mapCollectionByName other:other.mapCollectionByName];
}

@end
