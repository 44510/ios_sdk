//
//  ADJThreadController.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJThreadController.h"

#import "ADJPublisherBase.h"
#import "ADJUtilSys.h"

#pragma mark Private class
@interface ADJThreadExecutorAggregator : ADJPublisherBase<ADJSingleThreadExecutor *> @end

@implementation ADJThreadExecutorAggregator @end

@interface ADJThreadController ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic)
    ADJThreadExecutorAggregator *threadExecutorAggregator;
@property (readwrite, assign, nonatomic) BOOL hasFinalized;

@end

@implementation ADJThreadController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"ThreadController"];

    _threadExecutorAggregator = [[ADJThreadExecutorAggregator alloc] init];
    _hasFinalized = NO;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (void)executeInMainThreadWithBlock:(nonnull void (^)(void))blockToExecute {
    dispatch_async(dispatch_get_main_queue(), blockToExecute);
}

#pragma mark - ADJThreadExecutorFactory
- (nonnull ADJSingleThreadExecutor *)
    createSingleThreadExecutorWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    sourceDescription:(nonnull NSString *)sourceDescription
{
    ADJSingleThreadExecutor *_Nonnull singleThreadExecutor =
        [[ADJSingleThreadExecutor alloc] initWithLoggerFactory:loggerFactory
                                             sourceDescription:sourceDescription];

    [self.threadExecutorAggregator addSubscriber:singleThreadExecutor];

    return singleThreadExecutor;
}

#pragma mark - ADJClientReturnExecutor
- (void)executeClientReturnWithBlock:(nonnull void (^)(void))blockToExecute {
    [self executeInMainThreadWithBlock:blockToExecute];
}

#pragma mark - ADJTeardownFinalizer
- (void)finalizeAtTeardown {
    if (self.hasFinalized) {
        return;
    }
    self.hasFinalized = YES;

    [self.threadExecutorAggregator notifySubscribersWithSubscriberBlock:
        ^(ADJSingleThreadExecutor *_Nonnull subscriber)
    {
        [subscriber finalizeAtTeardown];
    }];
}

#pragma mark - NSObject
- (void)dealloc {
    [self finalizeAtTeardown];
}

@end
