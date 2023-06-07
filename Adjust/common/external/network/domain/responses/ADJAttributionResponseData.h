//
//  ADJAttributionResponseData.h
//  Adjust
//
//  Created by Aditi Agrawal on 16/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJSdkResponseBaseData.h"
#import "ADJAttributionPackageData.h"

@interface ADJAttributionResponseData : ADJSdkResponseBaseData
// instantiation
+ (nonnull ADJOptionalFailsNN<ADJAttributionResponseData *> *)
    instanceWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    attributionPackageData:(nonnull ADJAttributionPackageData *)attributionPackageData;

- (nonnull instancetype)
    initWithBuilder:(nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
    sdkPackageData:(nonnull id<ADJSdkPackageData>)sdkPackageData
    optionalFailsMut:(nonnull NSMutableArray<ADJResultFail *> *)optionalFailsMut
 NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic)
    ADJAttributionPackageData *sourceAttributionPackageData;

@end
