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
        
        // Use IOReturn instead kern_return_t
        IOReturn err = IOCreatePlugInInterfaceForService(service, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &_plugInInterface, &score);
        if (err != kIOReturnSuccess) {
            return nil; // `dealloc` will be called
        }
    }
    return self;
}

- (void)dealloc {
    if (_plugInInterface != nil) {
        IOReturn err = (*_plugInInterface)->Release(_plugInInterface);
        if (err != kIOReturnSuccess) {
            NSLog(@"Warning: 0x%08X", err);
        }
    }
}

- (USBInterface *)queryInterface {
    IOUSBDeviceInterfaceLatest ** interface;
    IOReturn err = (*_plugInInterface)->QueryInterface(_plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceIDLatest), (LPVOID)&interface);
    if (err != kIOReturnSuccess) {
        return nil;
    }
    return [[USBInterface alloc] init:interface]; // move interface
}

@end


@interface USBInterface ()

@property (assign, nonatomic, readwrite) IOUSBDeviceInterfaceLatest ** interface;

@end

@implementation USBInterface

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)interface {
    self = [super init];
    if (self) {
        _interface = interface;
    }
    return self;
}

- (void)dealloc {
    IOReturn err = (*_interface)->Release(_interface);
    if (err != kIOReturnSuccess) {
        NSLog(@"Warning: 0x%08X", err);
    }
}

- (UInt16)vendorID {
    UInt16 vid;
    IOReturn err = (*_interface)->GetDeviceVendor(_interface, &vid);
    if (err != kIOReturnSuccess) {
        return 0;   // FIXME
    }
    return vid;
}

- (UInt16)productID {
    UInt16 pid;
    IOReturn err = (*_interface)->GetDeviceProduct(_interface, &pid);
    if (err != kIOReturnSuccess) {
        return 0;   // FIXME
    }
    return pid;
}

@end
