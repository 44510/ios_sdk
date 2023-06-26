//
//  ADJMoneyDoubleAmount.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJMoneyAmountBase.h"
#import "ADJPackageParamValueSerializable.h"
#import "ADJIoValueSerializable.h"
#import "ADJResult.h"

@interface ADJMoneyDoubleAmount : ADJMoneyAmountBase
// instantiation
+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromIoMoneyDoubleAmountSubValue:(nonnull NSString *)ioMoneyDoubleAmountSubValue;

+ (nonnull ADJResult<ADJMoneyDoubleAmount *> *)
    instanceFromDoubleNumberValue:(nullable NSNumber *)doubleNumberValue;

+ (nullable NSString *)ioMoneyDoubleAmountSubValueWithIoValue:(nonnull ADJNonEmptyString *)ioValue;

// public properties
@property (nonnull, readonly, strong, nonatomic) NSNumber *doubleNumberValue;

@end
