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
@property (strong, nonatomic, readonly) NSString * deviceManufacturer;
@property (strong, nonatomic, readonly) NSString * deviceProduct;
@property (strong, nonatomic, readonly) NSString * deviceSerialNumber;

- (instancetype)init:(IOUSBDeviceInterfaceLatest **)device;
- (IOReturn)open;
- (IOReturn)close;

@end
