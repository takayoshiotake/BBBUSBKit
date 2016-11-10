//
//  USBDeviceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"

@interface USBDeviceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBDeviceInterfaceLatest ** device;
@property (assign, nonatomic, readonly) IOUSBDeviceDescriptor deviceDescriptor;
@property (strong, nonatomic, readonly) NSString * manufacturerString;
@property (strong, nonatomic, readonly) NSString * productString;
@property (strong, nonatomic, readonly) NSString * serialNumberString;

- (instancetype)initWithDevice:(IOUSBDeviceInterfaceLatest **)device;

- (IOUSBConfigurationDescriptor *)getConfigurationDescriptor:(NSError **)error;
- (IOReturn)open;
- (IOReturn)close;
- (IOReturn)getUSBInterfaceIterator:(io_iterator_t *)iterator;

/// Control transfer on default pipe (endpoint0)
- (IOReturn)deviceRequestWithRequestType:(UInt8)bmRequestType request:(UInt8)bRequest value:(UInt16)wValue index:(UInt16)wIndex length:(UInt16)wLength data:(void *)pData;

@end
