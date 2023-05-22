//
//  ADJClientConfigData.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustConfig.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJNonNegativeInt.h"
#import "ADJAdjustAttributionSubscriber.h"
#import "ADJAdjustLogSubscriber.h"

@interface ADJClientCustomEndpointData : NSObject
// instantiation
- (nonnull instancetype)initWithUrl:(nonnull ADJNonEmptyString *)url
                      publicKeyHash:(nullable ADJNonEmptyString *)publicKeyHash
NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *url;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *publicKeyHash;

@end

@interface ADJClientConfigData : NSObject
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustConfig:(nullable ADJAdjustConfig *)adjustConfig
                                                     logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *appToken;
@property (readonly, assign, nonatomic) BOOL isSandboxEnvironmentOrElseProduction;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *defaultTracker;
@property (readonly, assign, nonatomic) BOOL doLogAll;
@property (readonly, assign, nonatomic) BOOL doNotLogAny;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *urlStrategyBaseDomain;
@property (nullable, readonly, strong, nonatomic) AdjustDataResidency dataResidency;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *externalDeviceId;
@property (nullable, readonly, strong, nonatomic) ADJClientCustomEndpointData *clientCustomEndpointData;
@property (readonly, assign, nonatomic) BOOL doNotOpenDeferredDeeplink;
@property (readonly, assign, nonatomic) BOOL doNotReadAsaAttribution;
@property (readonly, assign, nonatomic) BOOL canSendInBackground;
@property (nullable, readonly, strong, nonatomic) ADJNonNegativeInt *eventIdDeduplicationMaxCapacity;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustAttributionSubscriber> adjustAttributionSubscriber;
@property (nullable, readonly, strong, nonatomic) id<ADJAdjustLogSubscriber> adjustLogSubscriber;

// public api
- (nonnull ADJNonEmptyString *)environment;

@end

