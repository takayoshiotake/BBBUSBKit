//
//  USBDeviceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import "USBDeviceInterface.h"

@interface USBDeviceInterface ()

@property (assign, nonatomic, readwrite) IOUSBDeviceInterfaceLatest ** device;
@property (assign, nonatomic, readwrite) IOUSBDeviceDescriptor deviceDescriptor;
@property (strong, nonatomic, readwrite) NSString * deviceManufacturer;
@property (strong, nonatomic, readwrite) NSString * deviceProduct;
@property (strong, nonatomic, readwrite) NSString * deviceSerialNumber;

@end

@implementation USBDeviceInterface

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)device {
    self = [super init];
    if (self) {
        _device = device;
        [self setup];
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

- (void)setup {
    // DEBUG:
    UInt32 locationID;
    (*_device)->GetLocationID(_device, &locationID);
    
    // Copy the device descriptor
#if 0
    // I can not get some values with 'IOUSBDeviceInterface650'
    _deviceDescriptor.bLength = 18;
    _deviceDescriptor.bDescriptorType = 1;
    _deviceDescriptor.bcdUSB = 0;
    (*_device)->GetDeviceClass(_device, &_deviceDescriptor.bDeviceClass);
    (*_device)->GetDeviceSubClass(_device, &_deviceDescriptor.bDeviceSubClass);
    (*_device)->GetDeviceProtocol(_device, &_deviceDescriptor.bDeviceProtocol);
    _deviceDescriptor.bMaxPacketSize0 = 0;
    (*_device)->GetDeviceReleaseNumber(_device, &_deviceDescriptor.bcdDevice);
    (*_device)->GetDeviceVendor(_device, &_deviceDescriptor.idVendor);
    (*_device)->GetDeviceProduct(_device, &_deviceDescriptor.idProduct);
    (*_device)->GetDeviceReleaseNumber(_device, &_deviceDescriptor.bcdDevice);
    (*_device)->USBGetManufacturerStringIndex(_device, &_deviceDescriptor.iManufacturer);
    (*_device)->USBGetProductStringIndex(_device, &_deviceDescriptor.iProduct);
    (*_device)->USBGetSerialNumberStringIndex(_device, &_deviceDescriptor.iSerialNumber);
    (*_device)->GetNumberOfConfigurations(_device, &_deviceDescriptor.bNumConfigurations);
#else
    IOUSBDevRequest request;
    request.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
    request.bRequest = kUSBRqGetDescriptor;
    request.wValue = kUSBDeviceDesc << 8;
    request.wIndex = 0;
    request.wLength = sizeof(_deviceDescriptor);
    request.pData = &_deviceDescriptor;
    (*_device)->DeviceRequest(_device, &request);
#endif
    // I faced that it is not possible to get the following values, with MacBook (Retina, 12-inch, Early 2016) and Anker Premium USB-C hub. However, it was possible to get the values (BUFFALO, USB3.0 Card Reader, 201006010301) with the USC-C hub.
    _deviceManufacturer = [self getStringDescriptor:_deviceDescriptor.iManufacturer];
    _deviceProduct = [self getStringDescriptor:_deviceDescriptor.iProduct];
    _deviceSerialNumber = [self getStringDescriptor:_deviceDescriptor.iSerialNumber];
}

- (NSString *)getStringDescriptor:(UInt8)index {
    if (index == 0) {
        return nil;
    }
    
    UInt8 temp[2];
    IOUSBDevRequest request;
    request.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
    request.bRequest = kUSBRqGetDescriptor;
    request.wValue = (kUSBStringDesc << 8) | index;
    request.wIndex = 0;
    request.wLength = 2;
    request.pData = &temp;
    (*_device)->DeviceRequest(_device, &request);
    if (temp[0] <= 2 || temp[1] != 3) {
        return nil;
    }
    
    UInt8 string[temp[0]];
    request.wLength = temp[0];
    request.pData = &string;
    (*_device)->DeviceRequest(_device, &request);
    
    return [[NSString alloc] initWithBytes:&string[2] length:string[0] - 2 encoding:NSUTF16LittleEndianStringEncoding];
}

- (IOUSBConfigurationDescriptor *)getConfigurationDescriptor:(NSError **)error {
    UInt8 configIndex = 0;
    IOUSBConfigurationDescriptorPtr configurationDescriptor;
    IOReturn err = (*_device)->GetConfigurationDescriptorPtr(_device, configIndex, &configurationDescriptor);
    if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
        *error = [NSError BBBUSBKitErrorWithIOReturnError: err];
        return nil;
    }
    return configurationDescriptor;
}

- (IOReturn)open {
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

@end
