//
//  USBInterfaceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"
#import "USBDeviceInterface.h"

@interface USBInterfaceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBInterfaceInterfaceLatest ** interface;
@property (weak, nonatomic, readonly) USBDeviceInterface * device;
@property (assign, nonatomic, readonly) IOUSBInterfaceDescriptor interfaceDescriptor;

- (instancetype)initWithService:(io_service_t)service device:(USBDeviceInterface *)device;
- (instancetype)initWithInterface:(IOUSBInterfaceInterfaceLatest **)interface device:(USBDeviceInterface *)device;

@end
