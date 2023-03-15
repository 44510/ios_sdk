//
//  ADJMainQueueTrackedPackages.h
//  Adjust
//
//  Created by Pedro Silva on 31.01.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJMainQueueStorage.h"
#import "ADJSQLiteStorageActionBase.h"
#import "ADJSdkPackageData.h"
#import "ADJInstallSessionTrackedSubscriber.h"
#import "ADJAsaClickTrackedSubscriber.h"

@interface ADJMainQueueTrackedPackages : ADJCommonBase
// instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    mainQueueStorage:(nonnull ADJMainQueueStorage *)mainQueueStorage;

// public API
- (nullable ADJNonNegativeInt *)firstSessionCount;
- (nullable ADJNonNegativeInt *)asaClickCount;

- (nullable ADJSQLiteStorageActionBase *)
    incrementTrackedCountWithPackageToAdd:(nonnull id<ADJSdkPackageData>)sdkPackageDataToAdd
    sqliteStorageActionForAdd:(nullable ADJSQLiteStorageActionBase *)sqliteStorageActionForAdd;

- (nullable ADJSQLiteStorageActionBase *)decrementTrackedCountWithPackageToRemove:
    (nonnull id<ADJSdkPackageData>)sourceResponsePackage;

// publishers
@property (nonnull, readonly, strong, nonatomic)
    ADJInstallSessionTrackedPublisher *installSessionTrackedPublisher;
@property (nonnull, readonly, strong, nonatomic)
    ADJAsaClickTrackedPublisher *asaClickTrackedPublisher;

@end

