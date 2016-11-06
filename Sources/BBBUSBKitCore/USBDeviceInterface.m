//
//  USBDeviceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import "USBDeviceInterface.h"

// DEBUG:
struct USBDeviceDescriptor {
    UInt8  bLength;
    UInt8  bDescriptorType;
    UInt16 bcdUSB;
    UInt8  bDeviceClass;
    UInt8  bDeviceSubClass;
    UInt8  bDeviceProtocol;
    UInt8  bMaxPacketSize0;
    UInt16 idVendor;
    UInt16 idProduct;
    UInt16 bcdDevice;
    UInt8  iManufacturer;
    UInt8  iProduct;
    UInt8  iSerialNumber;
    UInt8  bNumConfigurations;
};

@interface USBDeviceInterface ()

@property (assign, nonatomic, readwrite) IOUSBDeviceInterfaceLatest ** device;

@end

@implementation USBDeviceInterface

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)device {
    self = [super init];
    if (self) {
        _device = device;
        [self copyDeviceDescriptor];
    }
    return self;
}

- (void)dealloc {
    [self close];
    IOReturn err = (*_device)->Release(_device);
    if (err != kIOReturnSuccess) {
        NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)copyDeviceDescriptor {
    struct USBDeviceDescriptor desc;
    desc.bLength = 18;
    desc.bDescriptorType = 1;
    desc.bcdUSB = 0;
    (*_device)->GetDeviceClass(_device, &desc.bDeviceClass);
    (*_device)->GetDeviceSubClass(_device, &desc.bDeviceSubClass);
    (*_device)->GetDeviceProtocol(_device, &desc.bDeviceProtocol);
    desc.bMaxPacketSize0 = 0;
    (*_device)->GetDeviceReleaseNumber(_device, &desc.bcdDevice);
    (*_device)->GetDeviceVendor(_device, &desc.idVendor);
    (*_device)->GetDeviceProduct(_device, &desc.idProduct);
    (*_device)->GetDeviceReleaseNumber(_device, &desc.bcdDevice);
    (*_device)->USBGetManufacturerStringIndex(_device, &desc.iManufacturer);
    (*_device)->USBGetProductStringIndex(_device, &desc.iProduct);
    (*_device)->USBGetSerialNumberStringIndex(_device, &desc.iSerialNumber);
    (*_device)->GetNumberOfConfigurations(_device, &desc.bNumConfigurations);
}

- (UInt16)vendorID {
    UInt16 vid;
    IOReturn err = (*_device)->GetDeviceVendor(_device, &vid);
    if (err != kIOReturnSuccess) {
        return 0;   // FIXME
    }
    return vid;
}

- (UInt16)productID {
    UInt16 pid;
    IOReturn err = (*_device)->GetDeviceProduct(_device, &pid);
    if (err != kIOReturnSuccess) {
        return 0;   // FIXME
    }
    return pid;
}

- (IOReturn)open {
    // DEBUG:
    [self checkConfiguration];
    
    IOReturn err = (*_device)->USBDeviceOpenSeize(_device);
    if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

- (IOReturn)close {
    IOReturn err = (*_device)->USBDeviceClose(_device);
    if (err == kIOReturnNotOpen) {
        // Ignore
    }
    else if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

- (IOReturn)checkConfiguration {
    UInt8 configIndex = 0;
    IOUSBConfigurationDescriptorPtr desc;
    IOReturn err = (*_device)->GetConfigurationDescriptorPtr(_device, configIndex, &desc);
    if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

@end
