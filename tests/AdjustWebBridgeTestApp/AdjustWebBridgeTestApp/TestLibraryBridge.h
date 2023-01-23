//
//  TestLibraryBridge.h
//  AdjustWebBridgeTestApp
//
//  Created by Pedro Silva (@nonelse) on 6th August 2018.
//  Copyright © 2018 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATLTestLibrary.h"
#import "ADJAdjustBridge.h"
#import "AdjustSdkWebBridge.h"
// @import AdjustSdkWebBridge;

// simulator
static NSString * baseUrl = @"http://127.0.0.1:8080";
static NSString * gdprUrl = @"http://127.0.0.1:8080";
static NSString * controlUrl = @"ws://127.0.0.1:1987";
// device
// static NSString * baseUrl = @"http://192.168.86.65:8080";
// static NSString * gdprUrl = @"http://192.168.86.65:8080";
// static NSString * controlUrl = @"ws://192.168.86.65:1987";

@interface TestLibraryBridge : NSObject<AdjustCommandDelegate, WKScriptMessageHandler>

- (id)initWithAdjustBridgeRegister:(ADJAdjustBridge *)adjustBridge;

@end
