//
//  ADJAdjust.m
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import "ADJAdjust.h"
#import "ADJAdjustInstance.h"
#import "ADJAdjustInternal.h"

@implementation ADJAdjust

+ (nonnull id<ADJAdjustInstance>)instance {
    return [ADJAdjustInternal sdkInstanceForId:nil];
}

+ (nonnull id<ADJAdjustInstance>)instanceForId:(NSString *)instanceId {
    return [ADJAdjustInternal sdkInstanceForId:instanceId];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
