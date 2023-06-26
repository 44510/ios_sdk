//
//  ADJAdidSubscriber.h
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPublisherBase.h"
#import "ADJNonEmptyString.h"

@protocol ADJAdidSubscriber <NSObject>

- (void)onAdidChangeWithValue:(nonnull ADJNonEmptyString *)changedAdid;

@end

@interface ADJAdidPublisher : ADJPublisherBase<id<ADJAdidSubscriber>>

@end
