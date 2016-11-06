//
//  USBPlugInInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"
#import "USBDeviceInterface.h"

@interface USBPlugInInterface : NSObject

@property (assign, nonatomic, readonly) IOCFPlugInInterface ** plugInInterface;

- (instancetype)init:(io_service_t)service;
- (USBDeviceInterface *)queryInterface;

@end
