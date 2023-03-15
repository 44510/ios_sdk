//
//  ADJAdjustAttributionCallback.h
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustCallback.h"

@class ADJAdjustAttribution;

@protocol ADJAdjustAttributionCallback <ADJAdjustCallback>

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution;

@end
