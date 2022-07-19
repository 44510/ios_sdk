//
//  ADJAdjustAttributionSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJAdjustAttribution.h"

@protocol ADJAdjustAttributionSubscriber <NSObject>

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution;

- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution;

@end
