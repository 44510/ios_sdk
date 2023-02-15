//
//  ADJAdjustLogSubscriber.h
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustLogMessageData.h"

@protocol ADJAdjustLogSubscriber <NSObject>

- (void)didLogWithMessage:(nonnull NSString *)logMessage
                 logLevel:(nonnull ADJAdjustLogLevel)logLevel;

- (void)didLogMessagesPreInitWithArray:(nonnull NSArray<ADJAdjustLogMessageData *> *)preInitLogMessageArray;

@end
