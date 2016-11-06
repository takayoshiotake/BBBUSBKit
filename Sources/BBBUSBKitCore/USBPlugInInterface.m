//
//  USBPlugInInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import "USBPlugInInterface.h"

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

- (USBDeviceInterface *)queryInterface {
    IOUSBDeviceInterfaceLatest ** interface;
    IOReturn err = (*_plugInInterface)->QueryInterface(_plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceIDLatest), (LPVOID)&interface);
    if (err != kIOReturnSuccess) {
        return nil;
    }
    return [[USBDeviceInterface alloc] init:interface]; // move interface
}

@end
