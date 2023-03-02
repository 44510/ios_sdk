//
//  ADJDeviceInfoData.m
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJDeviceInfoData.h"

#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *fbAnonymousId;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundeIdentifier;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleShortVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceType;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceName;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osName;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *systemVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *languageCode;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *countryCode;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *machineModel;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cpuTypeSubtype;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osBuild;
 */

@implementation ADJDeviceInfoData
#pragma mark Instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];

    UIDevice *_Nonnull currentDevice = UIDevice.currentDevice;

    NSBundle *_Nonnull mainBundle = NSBundle.mainBundle;

    NSLocale *_Nonnull currentLocale = NSLocale.currentLocale;

    NSDictionary<NSString *, id> *_Nullable infoDictionary = mainBundle.infoDictionary;

    _fbAnonymousId = [ADJDeviceInfoData readFbAnonymousIdWithLogger:logger];
    _bundeIdentifier = [ADJDeviceInfoData readBundleIdentifierWithLogger:logger
                                                          infoDictionary:infoDictionary];
    _bundleVersion = [ADJDeviceInfoData readBundleVersionWithLogger:logger
                                                     infoDictionary:infoDictionary];
    _bundleShortVersion = [ADJDeviceInfoData readBundleShortVersionWithLogger:logger
                                                                   mainBundle:mainBundle];
    _deviceType = [ADJDeviceInfoData readDeviceTypeWithLogger:logger
                                                currentDevice:currentDevice];
    _deviceName = [ADJDeviceInfoData readDeviceNameWithLogger:logger];
    _osName = [ADJDeviceInfoData readOsNameWithLogger:logger];
    _systemVersion = [ADJDeviceInfoData readSystemVersionWithLogger:logger
                                                      currentDevice:currentDevice];
    _languageCode = [ADJDeviceInfoData readLanguageCodeWithLogger:logger
                                                    currentLocale:currentLocale];
    _countryCode = [ADJDeviceInfoData readCountryCodeWithLogger:logger
                                                  currentLocale:currentLocale];
    _machineModel = [ADJDeviceInfoData readMachineModelWithLogger:logger];
    _cpuTypeSubtype = [ADJDeviceInfoData readCpuTypeSubtypeWithLogger:logger];
    _osBuild = [ADJDeviceInfoData readOsBuildWithLogger:logger];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
// pre FB SDK v6.0.0
// return [FBSDKAppEventsUtility retrievePersistedAnonymousID];
// post FB SDK v6.0.0
// return [FBSDKBasicUtility retrievePersistedAnonymousID];
+ (nullable ADJNonEmptyString *)readFbAnonymousIdWithLogger:(nonnull ADJLogger *)logger {
#if TARGET_OS_TV
    return nil;
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selGetId = NSSelectorFromString(@"retrievePersistedAnonymousID");

    Class _Nullable class = NSClassFromString(@"FBSDKBasicUtility");
    if (class != nil && [class respondsToSelector:selGetId]) {
        ADJResultNL<ADJNonEmptyString *> *_Nonnull basicResult =
            [ADJNonEmptyString instanceFromOptionalObject:[class performSelector:selGetId]];
        if (basicResult.fail != nil) {
            [logger debugDev:@"Invalid result from FBSDKBasicUtility"
                  resultFail:basicResult.fail
                   issueType:ADJIssueExternalApi];
        } else if (basicResult.value == nil) {
            [logger debugDev:@"No result from FBSDKBasicUtility"];
        }
        return basicResult.value;
    }

    class = NSClassFromString(@"FBSDKAppEventsUtility");
    if (class != nil && [class respondsToSelector:selGetId]) {
        ADJResultNL<ADJNonEmptyString *> *_Nonnull appEventsResult =
            [ADJNonEmptyString instanceFromOptionalObject:[class performSelector:selGetId]];
        if (appEventsResult.fail != nil) {
            [logger debugDev:@"Invalid result from FBSDKAppEventsUtility"
                  resultFail:appEventsResult.fail
                   issueType:ADJIssueExternalApi];
        } else if (appEventsResult.value == nil) {
            [logger debugDev:@"No result from FBSDKAppEventsUtility"];
        }
        return appEventsResult.value;
    }

    [logger debugDev:@"No FBSDK*Utility class + retrievePersistedAnonymousID method found"];

    return nil;
#pragma clang diagnostic pop
#endif
}

+ (nullable ADJNonEmptyString *)
    readBundleIdentifierWithLogger:(nonnull ADJLogger *)logger
    infoDictionary:(nullable NSDictionary<NSString *, id> *)infoDictionary
{
    if (infoDictionary == nil) {
        return nil;
    }

    NSString *_Nullable bundleIdentifierKey = (__bridge NSString *)kCFBundleIdentifierKey;
    if (bundleIdentifierKey == nil) {
        return nil;
    }

    id _Nullable bundleIdentifierValueObject = [infoDictionary objectForKey:bundleIdentifierKey];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalObject:bundleIdentifierValueObject];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in bundle indentifier"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)
    readBundleVersionWithLogger:(nonnull ADJLogger *)logger
    infoDictionary:(nullable NSDictionary<NSString *, id> *)infoDictionary
{
    if (infoDictionary == nil) {
        return nil;
    }

    NSString *_Nullable bundleVersionKey = (__bridge NSString *)kCFBundleVersionKey;
    if (bundleVersionKey == nil) {
        return nil;
    }

    id _Nullable bundleVersionValueObject = [infoDictionary objectForKey:bundleVersionKey];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalObject:bundleVersionValueObject];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in bundle version"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readBundleShortVersionWithLogger:(nonnull ADJLogger *)logger
                                                      mainBundle:(nonnull NSBundle *)mainBundle
{
    id _Nullable bundleShortVersionValueObject =
        [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalObject:bundleShortVersionValueObject];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in bundle short version"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readDeviceTypeWithLogger:(nonnull ADJLogger *)logger
                                           currentDevice:(nonnull UIDevice *)currentDevice {
    NSString *_Nonnull deviceType =
        [currentDevice.model stringByReplacingOccurrencesOfString:@" " withString:@""];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:deviceType];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in device type"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readDeviceNameWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable machine = [self readSysctlbByNameString:"hw.machine"];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:machine];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in device name"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readOsNameWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable osName =
#if TARGET_OS_MACCATALYST
    @"macCatalyst"
#elif TARGET_OS_TV
    @"tvOs"
#elif TARGET_OS_WATCH
    @"watchOS"
#elif TARGET_OS_BRIDGE
    @"bridgeOS"
#elif TARGET_OS_OSX
    @"macOS"
#elif TARGET_OS_DRIVERKIT
    @"driverKit"
#elif TARGET_OS_IOS
    @"iOS"
#else
    nil
#endif
    ;
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:osName];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in os name"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readSystemVersionWithLogger:(nonnull ADJLogger *)logger
                                              currentDevice:(nonnull UIDevice *)currentDevice
{
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:currentDevice.systemName];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in sytem name"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readLanguageCodeWithLogger:(nonnull ADJLogger *)logger
                                             currentLocale:(nonnull NSLocale *)currentLocale {
    id _Nullable languageCodeObject = [currentLocale objectForKey:NSLocaleLanguageCode];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalObject:languageCodeObject];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in language code"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readCountryCodeWithLogger:(nonnull ADJLogger *)logger
                                            currentLocale:(nonnull NSLocale *)currentLocale {
    id _Nullable countryCodeObject = [currentLocale objectForKey:NSLocaleCountryCode];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalObject:countryCodeObject];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in country code"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readMachineModelWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable model = [self readSysctlbByNameString:"hw.model"];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:model];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in machine model"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable ADJNonEmptyString *)readCpuTypeSubtypeWithLogger:(nonnull ADJLogger *)logger {
    ADJResultNL<ADJNonNegativeInt *> *_Nonnull cpuTypeNumberResult =
        [ADJNonNegativeInt instanceFromOptionalIntegerNumber:
         [self readSysctlbByNameInt:"hw.cputype"]];
    if (cpuTypeNumberResult.fail != nil) {
        [logger debugDev:@"Invalid cpu type read"
              resultFail:cpuTypeNumberResult.fail
               issueType:ADJIssueExternalApi];
    }

    ADJResultNL<ADJNonNegativeInt *> *_Nonnull cpuSubtypeNumberResult =
        [ADJNonNegativeInt instanceFromOptionalIntegerNumber:
         [self readSysctlbByNameInt:"hw.cpusubtype"]];
    if (cpuSubtypeNumberResult.fail != nil) {
        [logger debugDev:@"Invalid cpu subtype read "
              resultFail:cpuSubtypeNumberResult.fail
               issueType:ADJIssueExternalApi];
    }

    ADJNonNegativeInt *_Nullable cpuTypeNumber = cpuTypeNumberResult.value;
    ADJNonNegativeInt *_Nullable cpuSubtypeNumber = cpuSubtypeNumberResult.value;

    if (cpuTypeNumber == nil && cpuSubtypeNumber == nil) {
        return nil;
    }

    if (cpuTypeNumber == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:
                [NSString stringWithFormat:@"_%@", cpuSubtypeNumber]];
    }

    if (cpuSubtypeNumber == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:
                [NSString stringWithFormat:@"%@_", cpuTypeNumber]];
    }

    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"%@_%@", cpuTypeNumber, cpuSubtypeNumber]];
}

+ (nullable ADJNonEmptyString *)readOsBuildWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable osversion = [self readSysctlbByNameString:"kern.osversion"];
    ADJResultNL<ADJNonEmptyString *> *_Nonnull result =
        [ADJNonEmptyString instanceFromOptionalString:osversion];
    if (result.fail != nil) {
        [logger debugDev:@"Invalid value found in os build"
              resultFail:result.fail
               issueType:ADJIssueExternalApi];
    }
    return result.value;
}

+ (nullable NSString *)readSysctlbByNameString:(const char*)name {
    int error = 0;
    size_t length = 0;
    error = sysctlbyname(name, NULL, &length, NULL, 0);

    if (error != 0) {
        return nil;
    }

    char *p = malloc(sizeof(char) * length);
    if (!p) {
        return nil;
    }

    NSString *value = nil;

    error = sysctlbyname(name, p, &length, NULL, 0);
    if (error == 0) {
        value = [NSString stringWithUTF8String:p];
    }

    free(p);

    return value;
}

+ (nullable NSNumber *)readSysctlbByNameInt:(const char*)name {
    int error = 0;

    int intValue = -1;
    size_t length = sizeof(intValue);
    error = sysctlbyname(name, &intValue, &length, NULL, 0);

    if (error != 0) {
        return nil;
    }

    return @(intValue);
}

@end
