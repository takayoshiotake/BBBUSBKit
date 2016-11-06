//
//  BBBUSBKitCore.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>

typedef IOUSBDeviceInterface650 IOUSBDeviceInterfaceNew;
#define kIOUSBDeviceInterfaceIDNew kIOUSBDeviceInterfaceID650


@interface USBInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBDeviceInterfaceNew ** interface;
@property (assign, nonatomic, readonly) UInt16 vendorID;
@property (assign, nonatomic, readonly) UInt16 productID;

- (instancetype)init:(IOUSBDeviceInterfaceNew **)interface;

@end


@interface USBPlugInInterface : NSObject

@property (assign, nonatomic, readonly) IOCFPlugInInterface ** plugInInterface;

- (instancetype)init:(io_service_t)service;
- (USBInterface *)queryInterface;

@end
