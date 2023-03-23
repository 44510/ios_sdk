//
//  ADJAdRevenuePackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 23/08/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdRevenuePackageData.h"

#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJAdRevenuePackageDataPath = @"ad_revenue";

@implementation ADJAdRevenuePackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJAdRevenuePackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:YES
                    parameters:parameters];

    return self;
}

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
{
    // does not read ioData for further information
    return [self initWithClientSdk:clientSdk parameters:parameters];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable source = [self.parameters pairValueWithKey:ADJParamAdRevenueSourceKey];

    if (source == nil) {
        return [[ADJNonEmptyString alloc]
                initWithConstStringValue:@"Ad Revenue without source"];
    }

    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:
                 @"Ad Revenue with source: %@", source]];
}

@end

