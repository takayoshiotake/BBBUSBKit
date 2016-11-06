//
//  USBDeviceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import "USBDeviceInterface.h"

@interface USBDeviceInterface ()

@property (assign, nonatomic, readwrite) IOUSBDeviceInterfaceLatest ** interface;

@end

@implementation USBDeviceInterface

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)interface {
    self = [super init];
    if (self) {
        _interface = interface;
    }
    return self;
}

- (void)dealloc {
    [self close];
    IOReturn err = (*_interface)->Release(_interface);
    if (err != kIOReturnSuccess) {
        NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
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

- (IOReturn)open {
    IOReturn err = (*_interface)->USBDeviceOpen(_interface);
    if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

- (IOReturn)close {
    IOReturn err = (*_interface)->USBDeviceClose(_interface);
    if (err == kIOReturnNotOpen) {
        // Ignore
    }
    else if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

@end
