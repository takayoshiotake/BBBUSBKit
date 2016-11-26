//
//  USBInterfaceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import "USBInterfaceInterface.h"

@interface USBInterfaceInterface ()

@property (assign, nonatomic, readwrite) IOUSBInterfaceInterfaceLatest ** interface;
@property (weak, nonatomic, readwrite) USBDeviceInterface * device;
@property (assign, nonatomic, readwrite) IOUSBInterfaceDescriptor interfaceDescriptor;

@end

@implementation USBInterfaceInterface

- (instancetype)initWithService:(io_service_t)service device:(USBDeviceInterface *)device {
    self = [super init];
    if (self) {
        IOCFPlugInInterface ** plugInInterface;
        SInt32 score;
        
        // Use IOReturn instead kern_return_t
        IOReturn err;
        err = IOCreatePlugInInterfaceForService(service, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
        if (err != kIOReturnSuccess) {
            return nil; // `dealloc` will be called
        }
        err = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceIDLatest), (LPVOID)&_interface);
        if (err != kIOReturnSuccess) {
            // Ignore result
            IODestroyPlugInInterface(plugInInterface);
            return nil; // `dealloc` will be called
        }
        
        // Ignore result
        IODestroyPlugInInterface(plugInInterface);
    }
    return self;
}

- (instancetype)initWithInterface:(IOUSBInterfaceInterfaceLatest **)interface device:(USBDeviceInterface *)device {
    self = [super init];
    if (self) {
        _interface = interface;
        _device = device;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    IOReturn err = (*_interface)->Release(_interface);
    if (err != kIOReturnSuccess) {
        NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)setup {
#if true
    IOUSBInterfaceDescriptor desc;
    desc.bLength = 9;
    desc.bDescriptorType = 4;
    (*_interface)->GetInterfaceNumber(_interface, &desc.bInterfaceNumber);
    (*_interface)->GetAlternateSetting(_interface, &desc.bAlternateSetting);
    (*_interface)->GetNumEndpoints(_interface, &desc.bNumEndpoints);
    (*_interface)->GetInterfaceClass(_interface, &desc.bInterfaceClass);
    (*_interface)->GetInterfaceSubClass(_interface, &desc.bInterfaceSubClass);
    (*_interface)->GetInterfaceProtocol(_interface, &desc.bInterfaceProtocol);
    (*_interface)->USBInterfaceGetStringIndex(_interface, &desc.iInterface);
    _interfaceDescriptor = desc;
#else
    IOUSBDeviceInterfaceLatest ** device = _device.device;
    if (device) {
        IOUSBDevRequest request;
        request.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
        request.bRequest = kUSBRqGetDescriptor;
        request.wValue = kUSBInterfaceDesc << 8;
        request.wIndex = 0;
        request.wLength = sizeof(_interfaceDescriptor);
        request.pData = &_interfaceDescriptor;
        (*device)->DeviceRequest(device, &request);
    }
#endif
}

@end
