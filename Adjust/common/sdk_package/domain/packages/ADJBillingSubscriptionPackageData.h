//
//  ADJBillingSubscriptionPackageData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkPackageBaseData.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJBillingSubscriptionPackageDataPath;

NS_ASSUME_NONNULL_END

@interface ADJBillingSubscriptionPackageData : ADJSdkPackageBaseData
// instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters;

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
                                   logger:(nonnull ADJLogger *)logger;

@end