//
//  BBBUSBKitCore.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import "BBBUSBKitCore.h"

@interface USBPlugInInterface ()

@property (assign, nonatomic, readwrite) IOCFPlugInInterface ** plugInInterface;

@end


@implementation USBPlugInInterface

- (instancetype)init:(io_service_t)service {
    self = [super init];
    if (self) {
        _plugInInterface = nil;
        SInt32 score;
        kern_return_t kr = IOCreatePlugInInterfaceForService(service, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &_plugInInterface, &score);
        if (kr != kIOReturnSuccess) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    if (_plugInInterface != nil) {
        (*_plugInInterface)->Release(_plugInInterface);
    }
}

- (USBInterface *)queryInterface {
    IOUSBDeviceInterfaceNew ** interface;
    (*_plugInInterface)->QueryInterface(_plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceIDNew), (LPVOID)&interface);
    return [[USBInterface alloc] init:interface];
}

@end


@interface USBInterface ()

@property (assign, nonatomic, readwrite) IOUSBDeviceInterfaceNew ** interface;

@end

@implementation USBInterface

- (instancetype)init:(IOUSBDeviceInterfaceNew **)interface {
    self = [super init];
    if (self) {
        _interface = interface;
    }
    return self;
}

- (void)dealloc {
    (*_interface)->Release(_interface);
}

- (UInt16)vendorID {
    UInt16 vid;
    (*_interface)->GetDeviceVendor(_interface, &vid);
    return vid;
}

- (UInt16)productID {
    UInt16 pid;
    (*_interface)->GetDeviceProduct(_interface, &pid);
    return pid;
}

@end
