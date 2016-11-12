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

@end

@implementation USBDeviceInterface

- (instancetype)initWithDevice:(IOUSBDeviceInterfaceLatest **)device {
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

- (IOReturn)getUSBInterfaceIterator:(io_iterator_t *)iterator {
    IOUSBFindInterfaceRequest request;
    request.bInterfaceClass = kIOUSBFindInterfaceDontCare;
    request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
    request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
    request.bAlternateSetting = kIOUSBFindInterfaceDontCare;
    IOReturn err = (*_device)->CreateInterfaceIterator(_device, &request, iterator);
    if (err != kIOReturnSuccess) {
        NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
    return err;
}

/// MARK: - private

/// Endpoint 0
- (IOReturn)deviceRequestWithRequestType:(UInt8)bmRequestType request:(UInt8)bRequest value:(UInt16)wValue index:(UInt16)wIndex length:(UInt16)wLength data:(void *)pData {
    return [self deviceRequest:(IOUSBDevRequest){ bmRequestType, bRequest, wValue, wIndex, wLength, pData }];
}

- (IOReturn)deviceRequest:(IOUSBDevRequest)request {
    IOReturn err = (*_device)->DeviceRequest(_device, &request);
    if (err != kIOReturnSuccess) {
        return err;
    }
    // TODO: compare request.wLength and request.wLenDone
    return kIOReturnSuccess;
}

- (NSString *)getStringDescriptorOfIndex:(UInt8)index error:(NSError **)error {
    IOReturn err;
    
    UInt8 temp[2];
    IOUSBDevRequest request;
    request.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
    request.bRequest = kUSBRqGetDescriptor;
    request.wValue = (kUSBStringDesc << 8) | index;
    request.wIndex = 0;
    request.wLength = 2;
    request.pData = &temp;
    if ((err = [self deviceRequest:request]) != kIOReturnSuccess) {
        *error = [NSError BBBUSBKitErrorWithIOReturnError: err];
        return nil;
    }
    
    UInt8 string[temp[0]];
    request.wLength = temp[0];
    request.pData = &string;
    if ((err = [self deviceRequest:request]) != kIOReturnSuccess) {
        *error = [NSError BBBUSBKitErrorWithIOReturnError: err];
        return nil;
    }
    
    return [[NSString alloc] initWithBytes:&string[2] length:string[0] - 2 encoding:NSUTF16LittleEndianStringEncoding];
}

@end
