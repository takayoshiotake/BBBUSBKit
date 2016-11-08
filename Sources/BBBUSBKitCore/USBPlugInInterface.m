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

- (instancetype)initWithService:(io_service_t)service plugInType:(USBPlugInInterfacePlugInType)plugInType {
    self = [super init];
    if (self) {
        _plugInInterface = nil;
        SInt32 score;
        
        // Use IOReturn instead kern_return_t
        IOReturn err;
        switch (plugInType) {
            case USBPlugInInterfacePlugInTypeDevice:
                err = IOCreatePlugInInterfaceForService(service, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &_plugInInterface, &score);
                break;
            case USBPlugInInterfacePlugInTypeInterface:
                err = IOCreatePlugInInterfaceForService(service, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &_plugInInterface, &score);
                break;
            default:
                err = kIOReturnError;
        }
        if (err != kIOReturnSuccess) {
            return nil; // `dealloc` will be called
        }
    }
    return self;
}

- (void)dealloc {
    if (_plugInInterface != nil) {
        IOReturn err = IODestroyPlugInInterface(_plugInInterface);
        if (err != kIOReturnSuccess) {
            NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
        }
    }
}

- (USBDeviceInterface *)queryUSBDeviceInterface {
    IOUSBDeviceInterfaceLatest ** device;
    IOReturn err = (*_plugInInterface)->QueryInterface(_plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceIDLatest), (LPVOID)&device);
    if (err != kIOReturnSuccess) {
        return nil;
    }
    return [[USBDeviceInterface alloc] initWithDevice:device]; // move device
}

- (USBInterfaceInterface *)queryUSBInterfaceInterface {
    IOUSBInterfaceInterfaceLatest ** interface;
    IOReturn err = (*_plugInInterface)->QueryInterface(_plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceIDLatest), (LPVOID)&interface);
    if (err != kIOReturnSuccess) {
        return nil;
    }
    return [[USBInterfaceInterface alloc] initWithInterface:interface]; // move interface
}

@end
