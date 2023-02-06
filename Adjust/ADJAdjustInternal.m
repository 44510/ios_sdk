//
//  ADJAdjustInternal.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustInternal.h"

#import "ADJEntryRoot.h"
#import "ADJUtilSys.h"
#import "ADJConstants.h"
#import "ADJConstantsSys.h"
#import "ADJUtilF.h"
#import "ADJAdjustInstance.h"
#import "ADJUtilFiles.h"

static ADJEntryRoot *entryRootInstance = nil;
static dispatch_once_t entryRootOnceToken = 0;

@implementation ADJAdjustInternal

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForClientId:(nullable NSString *)clientId {
    return [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];
}
+ (nonnull ADJEntryRoot *)entryRootForClientId:(nullable NSString *)clientId {
    // add syncronization for testing teardown
#ifdef DEBUG
    @synchronized ([ADJEntryRoot class]) {
#endif
        dispatch_once(&entryRootOnceToken, ^{
            entryRootInstance = [ADJEntryRoot instanceWithClientId:clientId
                                                     sdkConfigData:nil];
        });
        return entryRootInstance;
#ifdef DEBUG
    }
#endif
}

+ (nonnull NSString *)sdkVersion {
    return ADJClientSdk;
}

+ (void)
    setSdkPrefix:(nullable NSString *)sdkPrefix
    fromInstanceWithClientId:(nullable NSString *)clientId;
{
    [[ADJAdjustInternal entryRootForClientId:clientId] setSdkPrefix:sdkPrefix];
}

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix {
    return [ADJUtilSys clientSdkWithPrefix:sdkPrefix];
}

// Resets the sdk state, as if it was not initialized or used before.
+ (nonnull NSString *)teardownWithSdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
                             shouldClearStorage:(BOOL)shouldClearStorage
{
    // restrict teardown to debug builds
#ifndef DEBUG
    return @"Teardown cannot be done in non-debug mode";
#else
    NSMutableString *_Nonnull returnMessage = [[NSMutableString alloc] initWithString:@"Entry root teardown"];

    @synchronized ([ADJEntryRoot class]) {
        if (shouldClearStorage) {
            [self teardownWhileClearingStorageWithReturnMessage:returnMessage];
        } else {
            [self teardownWithoutClearingStorageWithReturnMessage:returnMessage];
        }

        entryRootInstance = nil;

        if (sdkConfigData != nil) {
            [returnMessage appendString:@". Creating new entry root instance with injected sdk config"];
            entryRootOnceToken = 0;
            dispatch_once(&entryRootOnceToken, ^{
                entryRootInstance = [ADJEntryRoot instanceWithClientId:nil // TODO: add when testing for it
                                                         sdkConfigData:sdkConfigData];
            });
        } else {
            [returnMessage appendString:@". Not creating new entry root instance without injected sdk config"];
        }
    }

    return returnMessage;
#endif
}

+ (void)teardownWithoutClearingStorageWithReturnMessage:(nonnull NSMutableString *)returnMessage {
    if (entryRootInstance == nil) {
        [returnMessage appendString:@". No singleton root instance to null without clearing storage"];
        return;
    }
    [returnMessage appendString:@". Nulling singleton root instance without clearing storage"];

    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    void (^ closeStorageBlockSync)(void) = ^{
        dispatch_semaphore_signal(sem);
    };

    [entryRootInstance finalizeAtTeardownWithCloseStorageBlock:closeStorageBlockSync];

    if (dispatch_semaphore_wait(sem, [ADJUtilSys dispatchTimeWithMilli:(ADJOneSecondMilli * 5)]) == 0) {
        [returnMessage appendString:@". Teardown finalized within close storage timeout"];
    } else {
        [returnMessage appendString:@". Teardown not finalized within close storage timeout"];
    }
}

+ (void)teardownWhileClearingStorageWithReturnMessage:(nonnull NSMutableString *)returnMessage {
    __block NSMutableString *returnMessageInBlock = returnMessage;
    __weak NSMutableString *returnMessageWeak = returnMessageInBlock;

    __block void (^ clearStorageBlock)(void) = ^{
        NSString *_Nonnull clearMessage = [ADJAdjustInternal clearStorage];
        __strong NSMutableString *returnMessageStrong = returnMessageWeak;
        if (returnMessageStrong == nil) {
            return;
        }

        [returnMessageStrong appendFormat:@". %@", clearMessage];
    };

    if (entryRootInstance == nil) {
        [returnMessage appendString:@". No singleton root instance to null while clearing storage"];
        clearStorageBlock();
        return;
    }

    [returnMessage appendString:@". Nulling singleton root instance while clearing storage"];
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    void (^ closeAndClearStorageBlock)(void) = ^{
        clearStorageBlock();
        dispatch_semaphore_signal(sem);
    };

    [entryRootInstance finalizeAtTeardownWithCloseStorageBlock:closeAndClearStorageBlock];

    if (dispatch_semaphore_wait(sem, [ADJUtilSys dispatchTimeWithMilli:(ADJOneSecondMilli * 5)]) == 0) {
        [returnMessage appendString:@". Teardown finalized within close and clear storage timeout"];
    } else {
        // nil to avoid being accessed inside the unfinished block
        returnMessageInBlock = nil;
        [returnMessage appendString:@". Teardown not finalized within close and clear storage timeout"];
    }
}


+ (nonnull NSString *)clearStorage {
    // TODO: add delete of all instances
    NSMutableString *_Nonnull returnString = [[NSMutableString alloc]
                                              initWithString:@"Clearing storage"];

    [returnString appendFormat:@". %@",
     [ADJAdjustInternal clearDbInAdjustAppSupportWithIdString:@""]];

    [returnString appendFormat:@". %@",
     [ADJAdjustInternal clearDbInDocumentsDirWithIdString:@""]];

    //TODO: delete custom user defaults

    return returnString;
}

+ (nonnull NSString *)clearDbInAdjustAppSupportWithIdString:(nonnull NSString *)idString {
    NSString *_Nullable adjustAppSupportDirPath = [ADJUtilFiles adjustAppSupportDir];
    if (adjustAppSupportDirPath == nil) {
        return @"Could not obtain adjust app support dir";
    }

    NSString *_Nonnull dbFilename = [ADJInstanceIdData toDbNameWithIdString:idString];

    NSString *_Nonnull adjustAppSupportDirDbPath =
        [ADJUtilFiles filePathWithDir:adjustAppSupportDirPath filename:dbFilename];

    NSError *error = nil;
    BOOL removedSuccessfully =
        [[NSFileManager defaultManager] removeItemAtPath:adjustAppSupportDirDbPath
                                                   error:&error];

    if (error) {
        return [ADJUtilF errorFormat:error];
    }
    return [NSString stringWithFormat:@"db file removed at adjust app support dir? %d",
            removedSuccessfully];
}
+ (nonnull NSString *)clearDbInDocumentsDirWithIdString:(nonnull NSString *)idString {
    NSString *_Nonnull dbFilename = [ADJInstanceIdData toDbNameWithIdString:idString];

    NSString *_Nullable documentsDbFilename = [ADJUtilFiles filePathInDocumentsDir:dbFilename];
    if (documentsDbFilename == nil) {
        return @"Could not obtain db filename in documents dir";
    }

    NSError *error = nil;
    BOOL removedSuccessfully =
        [[NSFileManager defaultManager] removeItemAtPath:documentsDbFilename
                                                   error:&error];

    if (error) {
        return [ADJUtilF errorFormat:error];
    }
    return [NSString stringWithFormat:@"db file removed at documents dir? %d",
            removedSuccessfully];
}

@end
